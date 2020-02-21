//
//  GyverStateResponse.swift
//  BLE RGB LED Control
//
//  Created by Mixaill on 18.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit

class GyverStateResponse: BLEResponse {

    //var responseValues = [Int]()
    
    var preset = 0
    var mode:LedMode = .RGB
    var brightness = 0
    var value1 = 0
    var value2 = 0
    var value3 = 0
    var value4 = 0
    var whiteLevel = 0
    var isOn = false
    
    override init?(rawData: Data?) {
        super.init(rawData: rawData)
        
        guard let data = dataArray else {
            return nil
        }
        
        guard data.count >= 14 && data[0] == 0x55 else {
            return nil
        }
        
        self.preset = Int(data[1])
        guard let theMode = LedMode(rawValue: Int(data[2])) else {
            return nil
        }
        self.mode = theMode
        
        brightness = Int(Data([data[3],data[4]]).uint16())
        value1 = Int(Data([data[5],data[6]]).uint16())
        value2 = Int(Data([data[7],data[8]]).uint16())
        value3 = Int(Data([data[9],data[10]]).uint16())
        value4 = Int(Data([data[11],data[12]]).uint16())
        
        isOn = (data[13] != 0x00)
        
        switch theMode {
        case .RGB:
            whiteLevel = value4
        case .HSV:
            whiteLevel = value3
        case .Color:
            whiteLevel = value2
        case .ColorSelection:
            whiteLevel = value2
        case .Kelvin:
            whiteLevel = value2
        case .ColorLoop:
            whiteLevel = value3
        case .Fire:
            whiteLevel = value4 //undefined
        case .ManualFire:
            whiteLevel = brightness
        case .StrobeLight:
            whiteLevel = value4
        case .RandomStrobeLight:
            whiteLevel = value4
        case .Flashing:
            whiteLevel = value4 //undefined
        }
    }
    
}
