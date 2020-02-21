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

    fileprivate let divider: UInt8 = 0x2c
    
    public static let sharedInstance: LedControlManager = {
        let instance = LedControlManager()
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    func sendPing(callback: @escaping (_ isSuccess: Bool) -> Void) {
        
        let request = GyverRequest(rawData: Data([0x00]), requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
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
        
        let request = GyverRequest(rawData: Data([0x01]), requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
        request.isWaitResponse = true
        request.isWriteWithResponse = true
        request.mode = .write
        request.retryCount = 0
        
        let command = GyverStateCommand(with: request)
        command.responseCallback = { (status, response, error) in
            dLog("status: \(status)")
            dLog("response: \(response?.dataAsString().orNil ?? "")")
            dLog(" ")
            dLog("error: \(error.orNil)")
            callback(status == .success , response as? GyverStateResponse)
        }

        BLEManager.currentDevice?.addCommandToQueue(command)
        
    }
    
    func changeSetting(command: Data, callback: @escaping (_ isSuccess: Bool) -> Void) {
        
        let request = GyverRequest(rawData: command, requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
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
    
    func changePreset(presetId id: Int, callback: @escaping (_ isSuccessful: Bool, _ response: GyverStateResponse?) -> Void) {
        
        let commandId:UInt8 = 0x03
        let presetId:UInt8 = UInt8(id)
        
        let request = GyverRequest(rawData: Data([commandId, divider, presetId]), requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
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
        
        let commandId:UInt8 = 0x04
        let mode:UInt8 = UInt8(id)
        
        let request = GyverRequest(rawData: Data([commandId, divider, mode]), requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
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
        
        let commandId:UInt8 = 0x05
        let state:UInt8 = isOn ? 0x01 : 0x00
        
        let request = GyverRequest(rawData: Data([commandId, divider, state]), requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
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
