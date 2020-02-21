//
//  LedModeEnum.swift
//  BLE RGB LED Control
//
//  Created by Mixaill on 21.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import Foundation

enum LedMode: Int {
    case RGB = 0
    case HSV
    case Color
    case ColorSelection
    case Kelvin
    case ColorLoop
    case Fire
    case ManualFire
    case StrobeLight
    case RandomStrobeLight
    case Flashing
    
    var name: String {
        switch self {
            case .RGB: return "RGB"
            case .HSV: return "HSV"
            case .Color: return "Color"
            case .ColorSelection: return "Color Selection"
            case .Kelvin: return "Kelvin"
            case .ColorLoop: return "Color Loop"
            case .Fire: return "Fire"
            case .ManualFire: return "Manual Fire"
            case .StrobeLight: return "Strobe Light"
            case .RandomStrobeLight: return "Random Strobe Light"
            case .Flashing: return "Flashing"
        }
    }
}
