//
//  GyverStateResponse.swift
//  BLE RGB LED Control
//
//  Created by Mixaill on 18.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit

enum StateResponseOptions: Int {
    case brightness = 0
    case value1
    case value2
    case value3
    case value4
    case onOffState
}

class GyverStateResponse: BLEResponse {

    var responseValues = [Int]()
    
    var preset = 0
    var mode:LedMode = .RGB
    var whiteLevel = 0
    
    override init?(rawData: Data?) {
        super.init(rawData: rawData)
        
        guard let data = rawData else {
            return nil
        }
        
        var values = data.split(separator: UInt8(0x20))
        
        guard values.count > 8 else {
            return nil
        }
        
        var value = values.removeFirst()
        guard value.count == 1, value.first == 0x55 else {
            return nil
        }
        
        value = values.removeFirst()
        guard value.count == 1 else {
            return nil
        }
        self.preset = Int(value.uint8())

        value = values.removeFirst()
        guard let theMode = LedMode(rawValue: Int(value.uint8())) else {
            return nil
        }
        self.mode = theMode

        for value in values {
            if value.count == 1 {
                responseValues.append(Int(value.uint8()))
            } else if value.count == 2 {
                responseValues.append(Int(value.uint16()))
            }
        }
        
        switch theMode {
        case .RGB:
            whiteLevel = responseValues[4]
        case .HSV:
            whiteLevel = responseValues[3]
        case .Color:
            whiteLevel = responseValues[2]
        case .ColorSelection:
            whiteLevel = responseValues[2]
        case .Kelvin:
            whiteLevel = responseValues[2]
        case .ColorLoop:
            whiteLevel = responseValues[3]
        case .Fire:
            whiteLevel = responseValues[4] //undefined
        case .ManualFire:
            whiteLevel = responseValues[0]
        case .StrobeLight:
            whiteLevel = responseValues[4]
        case .RandomStrobeLight:
            whiteLevel = responseValues[4]
        case .Flashing:
            whiteLevel = responseValues[4] //undefined
        }
    }
    
    func isOn() -> Bool {
        return responseValues[StateResponseOptions.onOffState.rawValue] != 0
    }
    
}
