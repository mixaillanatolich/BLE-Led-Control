//
//  GyverStateResponse.swift
//  BLE RGB LED Control
//
//  Created by Mixaill on 18.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit

class GyverStateResponse: BLEResponse {

    private var responseValues = [Int]()
    
    var preset = 0
    var mode = 0
    
    override init?(rawData: Data?) {
        super.init(rawData: rawData)
        
        guard let responseStr = dataAsString() else {
            return nil
        }
        
        var values = responseStr.split(separator: " ")
        
        guard values.count > 3 else {
            return nil
        }
        
        guard values[0] == "GS" else {
            return nil
        }
        
        //removing command id
        values.removeFirst()
        
        guard let preset = Int(values.removeFirst()) else {
            return nil
        }
        
        self.preset = preset-1
        
        guard let mode = Int(values.removeFirst()) else {
            return nil
        }
        
        self.mode = mode-1
        
        for str in values {
            if let value = Int(str) {
                responseValues.append(value)
            }
        }
    }
}
