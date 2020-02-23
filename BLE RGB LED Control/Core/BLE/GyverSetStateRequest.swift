//
//  GyverSetStateRequest.swift
//  BLE RGB LED Control
//
//  Created by Mixaill on 18.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit

class GyverSetStateRequest: GyverRequest {
    
    class func buildRequest(brightness: Int, white: Int, settings:[SliderSetting], b7: Int, mode: LedMode) -> Data {
        
        var b2 = 0
        var b3 = 0
        var b4 = 0

        var theBrightness = brightness
        var theB7 = b7
        
        var tmpSettings = settings
        
        if mode == .HSV || mode == .StrobeLight || mode == .RandomStrobeLight {
            
            if b7 == 1 {
                if let setting = tmpSettings.first {
                    theBrightness = setting.value
                    tmpSettings.removeFirst()
                }
            } else {
                tmpSettings.removeFirst()
            }
            
            if theB7 > 0 && theB7 != 10 {
                theB7 -= 1
            }
        } else if mode == .ColorSelection {
            b2 = b7
            theB7 = 1
        }
        
        if let setting = tmpSettings.first {
            b2 = setting.value
            tmpSettings.removeFirst()
        }
        
        if let setting = tmpSettings.first {
            b3 = setting.value
            tmpSettings.removeFirst()
        }
        
        if let setting = tmpSettings.first {
            b4 = setting.value
            tmpSettings.removeFirst()
        }
        
        return buildRequest(brightness: theBrightness, b2: b2, b3: b3, b4: b4, b5: 0, white: white, b7: theB7)
    }
    
    class func buildRequest(brightness: Int, b2: Int, b3: Int, b4: Int, b5: Int, white: Int, b7: Int) -> Data {
        
        let commandId:UInt8 = 0x02
        var data = Data([commandId])
        data.append(Data([UInt8(brightness)]))
        data.append(Data([UInt8(b2 >> 8), UInt8(b2 & 0x00ff)]))
        data.append(Data([UInt8(b3 >> 8), UInt8(b3 & 0x00ff)]))
        data.append(Data([UInt8(b4 >> 8), UInt8(b4 & 0x00ff)]))
        data.append(Data([UInt8(b5 >> 8), UInt8(b5 & 0x00ff)]))
        data.append(Data([UInt8(white)]))
        data.append(Data([UInt8(b7)]))
        
        return data
    }

    
}
