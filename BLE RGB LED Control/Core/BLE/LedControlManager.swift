//
//  LedControlManager.swift
//  BLE RGB LED Control
//
//  Created by Mixaill on 18.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit


let LEDController = LedControlManager.sharedInstance

class LedControlManager: NSObject {

    
    
    public static let sharedInstance: LedControlManager = {
        let instance = LedControlManager()
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    func sendPing(callback: @escaping (_ isSuccess: Bool) -> Void) {
        
        let request = GyverRequest(request: "0", requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
        request.isWaitResponse = true
        request.isWriteWithResponse = true
        request.mode = .write
        request.retryCount = 0
        
        let command = BLECommand(with: request)
        command.responseCallback = { (status, response, error) in
            dLog("status: \(status)")
            dLog("response: \(response?.dataAsString().orNil ?? "")")
            dLog("error: \(error.orNil)")
            callback(status == .success && response != nil)
        }

        BLEManager.currentDevice?.addCommandToQueue(command)
        
    }
    
    func loadSetting(callback: @escaping (_ isSuccessful: Bool, _ response: GyverStateResponse?) -> Void) {
        
        let request = GyverRequest(request: "1", requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
        request.isWaitResponse = true
        request.isWriteWithResponse = true
        request.mode = .write
        request.retryCount = 0
        
        let command = GyverStateCommand(with: request)
        command.responseCallback = { (status, response, error) in
            dLog("status: \(status)")
            dLog("response: \(response?.dataAsString().orNil ?? "")")
            dLog("error: \(error.orNil)")
            callback(status == .success , response as? GyverStateResponse)
        }

        BLEManager.currentDevice?.addCommandToQueue(command)
        
    }
    
    func changeSetting(callback: @escaping (_ isSuccess: Bool) -> Void) {
        
        let commandId = "2"
        //let state =
        
        let request = GyverRequest(request: "\(commandId)", requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
        request.isWaitResponse = true
        request.isWriteWithResponse = true
        request.mode = .write
        request.retryCount = 0
        
        let command = BLECommand(with: request)
        command.responseCallback = { (status, response, error) in
            dLog("status: \(status)")
            dLog("response: \(response?.dataAsString().orNil ?? "")")
            dLog("error: \(error.orNil)")
            callback(status == .success && response != nil)
        }

        BLEManager.currentDevice?.addCommandToQueue(command)
        
    }
    
    func changePreset(presetId id: Int, callback: @escaping (_ isSuccessful: Bool, _ response: GyverStateResponse?) -> Void) {
        
        let commandId = "3"
        let state = "\(id)"
        
        let request = GyverRequest(request: "\(commandId),\(state)", requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
        request.isWaitResponse = true
        request.isWriteWithResponse = true
        request.mode = .write
        request.retryCount = 0
        
        let command = GyverStateCommand(with: request)
        command.responseCallback = { (status, response, error) in
            dLog("status: \(status)")
            dLog("response: \(response?.dataAsString().orNil ?? "")")
            dLog("error: \(error.orNil)")
            callback(status == .success , response as? GyverStateResponse)
        }

        BLEManager.currentDevice?.addCommandToQueue(command)
        
    }
    
    func changeMode(modeId id: Int, callback: @escaping (_ isSuccessful: Bool, _ response: GyverStateResponse?) -> Void) {
        
        let commandId = "4"
        let state = "\(id)"
        
        let request = GyverRequest(request: "\(commandId),\(state)", requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
        request.isWaitResponse = true
        request.isWriteWithResponse = true
        request.mode = .write
        request.retryCount = 0
        
        let command = GyverStateCommand(with: request)
        command.responseCallback = { (status, response, error) in
            dLog("status: \(status)")
            dLog("response: \(response?.dataAsString().orNil ?? "")")
            dLog("error: \(error.orNil)")
            callback(status == .success , response as? GyverStateResponse)
        }

        BLEManager.currentDevice?.addCommandToQueue(command)
        
    }
    
    func changeLeds(state isOn: Bool, callback: @escaping (_ isSuccess: Bool) -> Void) {
        
        let commandId = "5"
        let state = isOn ? "1" : "0"
        
        let request = GyverRequest(request: "\(commandId),\(state)", requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
        request.isWaitResponse = false
        request.isWriteWithResponse = false
        request.mode = .write
        request.retryCount = 0
        
        let command = BLECommand(with: request)
        command.responseCallback = { (status, response, error) in
            dLog("status: \(status)")
            dLog("response: \(response?.dataAsString().orNil ?? "")")
            dLog("error: \(error.orNil)")
            callback(status == .success)
        }

        BLEManager.currentDevice?.addCommandToQueue(command)
        
    }
    
}
