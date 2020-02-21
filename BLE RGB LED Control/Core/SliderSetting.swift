//
//  SliderSetting.swift
//  BLE RGB LED Control
//
//  Created by Mixaill on 20.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit

class SliderSetting: NSObject {

    var name: String
    var min: Int
    var max: Int
    var b7: Int
    var value: Int
    
    init(name: String, min: Int, max: Int, b7: Int) {
        self.name = name
        self.min = min
        self.max = max
        self.b7 = b7
        self.value = min
    }
    
}
