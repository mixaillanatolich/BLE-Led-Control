//
//  GyverSetStateRequest.swift
//  BLE RGB LED Control
//
//  Created by Mixaill on 18.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit

class GyverSetStateRequest: GyverRequest {

    static fileprivate let divider: UInt8 = 0x2c
    
    class func buildRequest(brightness: Int, white: Int, settings:[SliderSetting], b7: Int, mode: String?) -> Data {
        
        var b2 = 0
        var b3 = 0
        var b4 = 0

        var theBrightness = brightness
        var theB7 = b7
        
        var tmpSettings = settings
        
        if let mode = mode {
            if mode == "HSV" {
                
                if b7 == 1 {
                    if let setting = tmpSettings.first {
                        theBrightness = setting.value
                        tmpSettings.removeFirst()
                    }
                } else {
                    tmpSettings.removeFirst()
                }
                
                if let setting = tmpSettings.first {
                    b2 = setting.value
                    tmpSettings.removeFirst()
                }
                
                if let setting = tmpSettings.first {
                    b3 = setting.value
                    tmpSettings.removeFirst()
                }
                
                if theB7 > 0 && theB7 != 10 {
                    theB7 -= 1
                }
            } else if "Color Selection" == mode {
                
                b2 = b7
                theB7 = 1
                
            }
            
            
        } else {
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
            
        }
        
        

        
        return buildRequest(brightness: theBrightness, b2: b2, b3: b3, b4: b4, b5: 0, white: white, b7: theB7)
        
    }
    
    class func buildRequest(brightness: Int, b2: Int, b3: Int, b4: Int, b5: Int, white: Int, b7: Int) -> Data {
        
        let commandId:UInt8 = 0x02
        var data = Data([commandId, divider])
        data.append(Data([UInt8(brightness), divider]))
        if b2 <= UINT8_MAX {
            data.append(Data([UInt8(b2), divider]))
        } else {
            data.append(Data([UInt8(b2 >> 8), UInt8(b2 & 0x00ff), divider]))
        }
        if b3 < 256 {
            data.append(Data([UInt8(b3), divider]))
        } else {
            data.append(Data([UInt8(b3 >> 8), UInt8(b3 & 0x00ff), divider]))
        }
        if b4 < 256 {
            data.append(Data([UInt8(b4), divider]))
        } else {
            data.append(Data([UInt8(b4 >> 8), UInt8(b4 & 0x00ff), divider]))
        }
        if b5 < 256 {
            data.append(Data([UInt8(b5), divider]))
        } else {
            data.append(Data([UInt8(b5 >> 8), UInt8(b5 & 0x00ff), divider]))
        }
        data.append(Data([UInt8(white), divider]))
        data.append(Data([UInt8(b7)]))
//        let presetId:UInt8 = UInt8(id)
//
//        var requestStr = "2"
//        requestStr.append(",\(brightness)")
//        requestStr.append(",\(b2)")
//        requestStr.append(",\(b3)")
//        requestStr.append(",\(b4)")
//        requestStr.append(",0")
//        requestStr.append(",\(white)")
//        requestStr.append(",\(b7)")
        
        /*
        init(value: UInt16) {
            self.init([UInt8(value >> 8), UInt8(value & 0x00ff)])
        }
        
        init(valueBack: UInt16) {
            self.init([UInt8(valueBack & 0x00ff), UInt8(valueBack >> 8)])
        }
        */
        
        return data
    }

    
}
