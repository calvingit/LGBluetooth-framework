/*
* Copyright (c) 2016, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
* documentation and/or other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
* software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
* HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
* USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import CoreBluetooth

@objc internal class SecureDFUService : NSObject, CBPeripheralDelegate, DFUService {
    static internal let UUID = CBUUID(string: "FE59")
    
    static func matches(_ service: CBService) -> Bool {
        return service.uuid.isEqual(UUID)
    }
    
    /// The target DFU Peripheral
    internal var targetPeripheral: DFUPeripheralAPI?
    /// The logger helper.
    private var logger:LoggerHelper
    /// The service object from CoreBluetooth used to initialize the SecureDFUService instance.
    private let service:CBService
    private var dfuPacketCharacteristic:SecureDFUPacket?
    private var dfuControlPointCharacteristic:SecureDFUControlPoint?

    private var paused = false
    private var aborted = false
    
    /// A temporary callback used to report end of an operation.
    private var success          : Callback?
    /// A temporary callback used to report an operation error.
    private var report           : ErrorCallback?
    /// A temporaty callback used to report progress status.
    private var progressDelegate : DFUProgressDelegate?
    
    // -- Properties stored when upload started in order to resume it --
    private var firmware:DFUFirmware?
    private var packetReceiptNotificationNumber:UInt16 = 0
    private var range:Range<Int>?
    // -- End --
    
    // MARK: - Initialization
    
    required init(_ service: CBService, _ logger: LoggerHelper) {
        self.service = service
        self.logger = logger
        super.init()
        self.logger.v("Secure DFU Service found")
    }
    
    func destroy() {
        dfuPacketCharacteristic = nil
        dfuControlPointCharacteristic = nil
        targetPeripheral = nil
    }
    
    // MARK: - Controler API methods
    
    func pause() -> Bool {
        if !aborted {
            paused = true
        }
        return paused
    }
    
    func resume() -> Bool {
        if !aborted && paused && firmware != nil {
            paused = false
            dfuPacketCharacteristic!.sendNext(packetReceiptNotificationNumber, bytesFrom: range!, of: firmware!,
                                                   andReportProgressTo: progressDelegate, andCompletionTo: success!)
            return paused
        }
        paused = false
        return paused
    }
    
    func abort() -> Bool {
        aborted = true
        // When upload has been started and paused, we have to send the Reset command here as the device will
        // not get a Packet Receipt Notification. If it hasn't been paused, the Reset command will be sent after receiving it, on line 292.
        if paused && firmware != nil {
            let _report = report!
            firmware = nil
            range    = nil
            success  = nil
            report   = nil
            progressDelegate = nil
            // Upload has been aborted. Reset the target device. It will disconnect automatically
            sendReset(onError: _report)
        }
        paused = false
        return aborted
    }
    
    // MARK: - Service API methods
    
    /**
    Discovers characteristics in the DFU Service.
    */
    func discoverCharacteristics(onSuccess success: @escaping Callback, onError report: @escaping ErrorCallback) {
        // Save callbacks
        self.success = success
        self.report  = report
        
        // Get the peripheral object
        let peripheral = service.peripheral
        
        // Set the peripheral delegate to self
        peripheral.delegate = self
        
        // Discover DFU characteristics
        logger.v("Discovering characteristics in DFU Service...")
        logger.d("peripheral.discoverCharacteristics(nil, for: \(SecureDFUService.UUID.uuidString))")
        peripheral.discoverCharacteristics(nil, for: service)
    }
    
    /**
     Enables notifications for DFU Control Point characteristic. Result it reported using callbacks.
     
     - parameter success: method called when notifications were enabled without a problem
     - parameter report:  method called when an error occurred
     */
    func enableControlPoint(onSuccess success: @escaping Callback, onError report: @escaping ErrorCallback) {
        if !aborted {
            // Support for experimental Buttonless DFU Service from SDK 12.x
            if experimentalButtonlessDfuCharacteristic != nil {
                experimentalButtonlessDfuCharacteristic!.enableNotifications(onSuccess: success, onError: report)
                return
            }
            // End
            dfuControlPointCharacteristic!.enableNotifications(onSuccess: success, onError: report)
        } else {
            sendReset(onError: report)
        }
    }
    
    /**
     Reads Command Object Info
     */
    func readCommandObjectInfo(onReponse response: @escaping SecureDFUResponseCallback, onError report: @escaping ErrorCallback) {
        if !aborted {
            dfuControlPointCharacteristic!.send(SecureDFURequest.readCommandObjectInfo, onResponse: response, onError: report)
        } else {
            sendReset(onError: report)
        }
    }
    
    /**
     Reads object info Data
     */
    func readDataObjectInfo(onReponse response: @escaping SecureDFUResponseCallback, onError report: @escaping ErrorCallback) {
        if !aborted {
            dfuControlPointCharacteristic!.send(SecureDFURequest.readDataObjectInfo, onResponse: response, onError: report)
        } else {
            sendReset(onError: report)
        }
    }
    
    /**
     Create object command
     */
    func createCommandObject(withLength aLength: UInt32, onSuccess success : @escaping Callback, onError report: @escaping ErrorCallback) {
        if !aborted {
            dfuControlPointCharacteristic!.send(SecureDFURequest.createCommandObject(withSize: aLength), onSuccess: success, onError:report)
        } else {
            sendReset(onError: report)
        }
    }
    
    /**
     Create object data
     */
    func createDataObject(withLength aLength: UInt32, onSuccess success : @escaping Callback, onError report: @escaping ErrorCallback) {
        if !aborted {
            dfuControlPointCharacteristic!.send(SecureDFURequest.createDataObject(withSize: aLength), onSuccess: success, onError:report)
        } else {
            sendReset(onError: report)
        }
    }
    
    /**
     Sends a Packet Receipt Notification request eith given value.
     */
    func setPacketReceiptNotificationValue(_ aValue: UInt16 = 0, onSuccess success: @escaping Callback, onError report: @escaping ErrorCallback) {
        self.packetReceiptNotificationNumber = aValue
        dfuControlPointCharacteristic?.send(SecureDFURequest.setPacketReceiptNotification(value: aValue),
            onSuccess: {
                if aValue > 0 {
                    self.logger.a("Packet Receipt Notif enabled (Op Code = 2, Value = \(aValue))")
                } else {
                    self.logger.a("Packet Receipt Notif disabled (Op Code = 2, Value = 0)")
                }
                success()
            },
            onError: report
        )
    }
    
    /**
     Sends Calculate checksum request
     */
    func calculateChecksumCommand(onSuccess success: @escaping SecureDFUResponseCallback, onError report: @escaping ErrorCallback) {
        if !aborted {
            dfuControlPointCharacteristic!.send(SecureDFURequest.calculateChecksumCommand, onResponse: success, onError: report)
        } else {
            sendReset(onError: report)
        }
    }
    
    /**
     Sends execute command request
     */
    func executeCommand(onSuccess success: @escaping Callback, onError report: @escaping ErrorCallback) {
        if !aborted {
            dfuControlPointCharacteristic?.send(SecureDFURequest.executeCommand, onSuccess: success, onError: report)
        } else {
            sendReset(onError: report)
        }
    }
    
    /**
     Disconnects from the device.
     
     - parameter report: a callback called when writing characteristic failed
     */
    private func sendReset(onError report: @escaping ErrorCallback) {
        aborted = true
        // There is no command to reset a Secure DFU device. We can just disconnect
        targetPeripheral!.disconnect()
    }
    
    //MARK: - Packet commands
    
    /**
     Sends the init packet. This method is synchronous and will terminate when all data were written.
     The init data file should not have more than ~16 packets of data as the buffer overflow error may occur.
     */
    func sendInitPacket(withdata packetData : Data){
        dfuPacketCharacteristic!.sendInitPacket(packetData)
    }

    func sendNextObject(from aRange: Range<Int>, of aFirmware: DFUFirmware, andReportProgressTo progressDelegate: DFUProgressDelegate?,
                            onSuccess success: @escaping Callback, onError report: @escaping ErrorCallback) {
        if aborted {
            sendReset(onError: report)
            return
        }
        
        // Those will be stored here in case of pause/resume
        self.firmware         = aFirmware
        self.range            = aRange
        self.progressDelegate = progressDelegate
        
        self.report = {
            error, message in
            self.firmware = nil
            self.range    = nil
            self.success  = nil
            self.report   = nil
            self.progressDelegate = nil
            report(error, message)
        }
        self.success = {
            self.firmware = nil
            self.range    = nil
            self.success  = nil
            self.report   = nil
            self.progressDelegate = nil
            self.dfuControlPointCharacteristic!.peripheralDidReceiveObject()
            success()
        }

        dfuControlPointCharacteristic!.waitUntilUploadComplete(onSuccess: self.success!, onPacketReceiptNofitication: { bytesReceived in
                if !self.paused && !self.aborted {
                    let bytesSent = self.dfuPacketCharacteristic!.bytesSent + UInt32(aRange.lowerBound)
                    if bytesSent == bytesReceived {
                        self.dfuPacketCharacteristic!.sendNext(self.packetReceiptNotificationNumber, bytesFrom: aRange, of: aFirmware,
                                                               andReportProgressTo: progressDelegate, andCompletionTo: self.success!)
                    } else {
                        // Target device deported invalid number of bytes received
                        report(.bytesLost, "\(bytesSent) bytes were sent while \(bytesReceived) bytes were reported as received")
                    }
                } else if self.aborted {
                    self.firmware = nil
                    self.range    = nil
                    self.success  = nil
                    self.report   = nil
                    self.progressDelegate = nil
                    self.sendReset(onError: report)
                }
            }, onError: self.report!)
        
        // A new object is started, reset counters before sending the next object
        // It must be done even if the upload was paused, otherwise it would be resumed from a wrong place
        dfuPacketCharacteristic!.resetCounters()
        
        if !paused && !aborted {
            // ...and start sending firmware if
            dfuPacketCharacteristic!.sendNext(packetReceiptNotificationNumber, bytesFrom: aRange, of: aFirmware,
                                                   andReportProgressTo: progressDelegate, andCompletionTo: self.success!)
        } else if aborted {
            self.firmware = nil
            self.range    = nil
            self.success  = nil
            self.report   = nil
            self.progressDelegate = nil
            sendReset(onError: report)
        }
    }
    
    // MARK: - Peripheral Delegate callbacks

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Create local references to callback to release the global ones
        let _success = self.success
        let _report  = self.report
        self.success = nil
        self.report  = nil
        
        if error != nil {
            logger.e("Characteristics discovery failed")
            logger.e(error!)
            _report?(.serviceDiscoveryFailed, "Characteristics discovery failed")
        } else {
            logger.i("DFU characteristics discovered")
            
            // Find DFU characteristics
            for characteristic in service.characteristics! {
                if SecureDFUPacket.matches(characteristic) {
                    dfuPacketCharacteristic = SecureDFUPacket(characteristic, logger)
                } else if SecureDFUControlPoint.matches(characteristic) {
                    dfuControlPointCharacteristic = SecureDFUControlPoint(characteristic, logger)
                }
                // Support for experimental Buttonless DFU Service from SDK 12.x
                else if ExperimentalButtonlessDFU.matches(characteristic) {
                    experimentalButtonlessDfuCharacteristic = ExperimentalButtonlessDFU(characteristic, logger)
                    _success?()
                    return
                }
                // End
            }
            
            // Some validation
            if dfuControlPointCharacteristic == nil {
                logger.e("DFU Control Point characteristics not found")
                // DFU Control Point characteristic is required
                _report?(.deviceNotSupported, "DFU Control Point characteristic not found")
                return
            }
            if dfuPacketCharacteristic == nil {
                logger.e("DFU Packet characteristics not found")
                // DFU Packet characteristic is required
                _report?(.deviceNotSupported, "DFU Packet characteristic not found")
                return
            }
            if !dfuControlPointCharacteristic!.valid {
                logger.e("DFU Control Point characteristics must have Write and Notify properties")
                // DFU Control Point characteristic must have Write and Notify properties
                _report?(.deviceNotSupported, "DFU Control Point characteristic does not have the Write and Notify properties")
                return
            }
            
            _success?()
        }
    }
    
    // MARK: - Support for experimental Buttonless DFU Service from SDK 12.x
    
    /// The buttonless jump feature was experimental in SDK 12. It did not support passing bond information to the DFU bootloader,
    /// was not safe (possible DOS attack) and had bugs. This is the service UUID used by this service.
    static internal let ExperimentalButtonlessDfuUUID = CBUUID(string: "8E400001-F315-4F60-9FB8-838830DAEA50")
    
    static func matches(experimental service: CBService) -> Bool {
        return service.uuid.isEqual(ExperimentalButtonlessDfuUUID)
    }
    
    private var experimentalButtonlessDfuCharacteristic:ExperimentalButtonlessDFU?
    
    /**
     This method tries to estimate whether the DFU target device is in Application mode which supports
     the buttonless jump to the DFU Bootloader.
     
     - returns: true, if it is for sure in the Application more, false, if definitely is not, nil if uknown
     */
    func isInApplicationMode() -> Bool? {
        // If the experimental buttonless DFU characteristic is not nil it means that the device is in app mode
        return experimentalButtonlessDfuCharacteristic != nil
    }
    
    var newAddressExpected: Bool {
        // The experimental Buttonless DFU will cause the device to advertise with address +1
        return experimentalButtonlessDfuCharacteristic != nil
    }
    
    /**
     Triggers a switch to DFU Bootloader mode on the remote target by sending DFU Start command.
     
     - parameter report:  method called when an error occurred
     */
    func jumpToBootloaderMode(onError report:@escaping ErrorCallback) {
        if !aborted {
            experimentalButtonlessDfuCharacteristic!.send(ExperimentalButtonlessDFURequest.enterBootloader, onSuccess: nil, onError: report)
        } else {
            sendReset(onError: report)
        }
    }
    
    // End
}
