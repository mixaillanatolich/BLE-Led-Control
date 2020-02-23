//
//  LedControlViewController.swift
//  BLE RGB LED Control
//
//  Created by Mixaill on 17.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth
import ActionSheetPicker_3_0

public protocol LedControlScreenDelegate : NSObjectProtocol {
    func pairControllerWillDismiss()
}

class LedControlViewController: BaseViewController {

    @IBOutlet weak var pairButton: UIButton!
    @IBOutlet weak var controlLabel: UILabel!
    
    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet weak var presetButton: UIButton!
    @IBOutlet weak var presetLabel: UILabel!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var modeLabel: UILabel!
    
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var brightnessValueLabel: UILabel!
    
    @IBOutlet weak var whiteSlider: UISlider!
    @IBOutlet weak var whiteValueLabel: UILabel!
    
    @IBOutlet weak var option1Label: UILabel!
    @IBOutlet weak var option1Slider: UISlider!
    @IBOutlet weak var option1ValueLabel: UILabel!
    @IBOutlet weak var option1HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var option2Label: UILabel!
    @IBOutlet weak var option2Slider: UISlider!
    @IBOutlet weak var option2ValueLabel: UILabel!
    @IBOutlet weak var option2HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var option3Label: UILabel!
    @IBOutlet weak var option3Slider: UISlider!
    @IBOutlet weak var option3ValueLabel: UILabel!
    @IBOutlet weak var option3HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var option4Label: UILabel!
    @IBOutlet weak var option4Slider: UISlider!
    @IBOutlet weak var option4ValueLabel: UILabel!
    @IBOutlet weak var option4HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var optionColorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentColorLabel: UILabel!
    
    fileprivate let presets = ["Default","Preset 1","Preset 2","Preset 3","Preset 4","Preset 5","Preset 6","Preset 7","Preset 8","Preset 9"]
    fileprivate let modes = ["RGB","HSV","Color","Color Selection","Kelvin","Color loop","Fire","Manual Fire","Strobe Light","Random Strobe Light", "Flashing"]
    fileprivate let colors = ["White","Silver","Gray","Black","Red","Maroon","Yellow","Olive","Lime","Green","Aqua","Teal","Blue","Navy","Pink", "Purple"]
    
    fileprivate var modesSettings = [[SliderSetting]]()
    fileprivate var currentModeSlidersStorage = [SliderSetting]()
    
    fileprivate var isOn = false
    fileprivate var presetId = 0
    fileprivate var currentMode: LedMode = .RGB
    
    fileprivate var currentBrightness = 0
    fileprivate var currentWhite = 0
    fileprivate var currentColor = 0
    
    @UserDefaultOptionl<String>(key: .deviceId, defaultValue: nil) var deviceId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSliderModels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSliders()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUIOnDeviceStateChanged()
        screenDidShow()
        updateUI()
    }
    
    @IBAction func brightnessSliderChanged(_ slider: UISlider) {
        let value = Int(slider.value)
        brightnessValueLabel.text = "\(value)"
    }
    
    @IBAction func brightnessSliderTouchUp(_ slider: UISlider) {
        
        let value = Int(slider.value)
        brightnessValueLabel.text = "\(value)"
        
        currentBrightness = value
        
        sendNewSettings(b7: 0)
    }
    
    @IBAction func whiteSliderChanged(_ slider: UISlider) {
        let value = Int(slider.value)
        whiteValueLabel.text = "\(value)"
    }
    
    @IBAction func whiteSliderTouchUp(_ slider: UISlider) {
        
        let value = Int(slider.value)
        whiteValueLabel.text = "\(value)"
        
        currentWhite = value
        
        sendNewSettings(b7: 10)
    }
    
    @IBAction func option1SliderChanged(_ slider: UISlider) {
        var value = Int(slider.value)
        if currentMode == .Kelvin {
            value = value*100
        }
        option1ValueLabel.text = "\(value)"
    }
    
    @IBAction func option1SliderTouchUp(_ slider: UISlider) {
        
        var value = Int(slider.value)
        if currentMode == .Kelvin {
            value = value*100
        }
        option1ValueLabel.text = "\(value)"
        
        let sliderSettings = currentModeSlidersStorage[0]
        sliderSettings.value = value

        sendNewSettings(b7: sliderSettings.b7)
    }
    
    @IBAction func option2SliderChanged(_ slider: UISlider) {
        let value = Int(slider.value)
        option2ValueLabel.text = "\(value)"
    }
    
    @IBAction func option2SliderTouchUp(_ slider: UISlider) {
        
        let value = Int(slider.value)
        option2ValueLabel.text = "\(value)"
        
        let sliderSettings = currentModeSlidersStorage[1]
        sliderSettings.value = value

        sendNewSettings(b7: sliderSettings.b7)
    }
    
    @IBAction func option3SliderChanged(_ slider: UISlider) {
        let value = Int(slider.value)
        option3ValueLabel.text = "\(value)"
    }
    
    @IBAction func option3SliderTouchUp(_ slider: UISlider) {
        
        let value = Int(slider.value)
        option3ValueLabel.text = "\(value)"
        
        let sliderSettings = currentModeSlidersStorage[2]
        sliderSettings.value = value

        sendNewSettings(b7: sliderSettings.b7)
    }
    
    @IBAction func option4SliderChanged(_ slider: UISlider) {
        let value = Int(slider.value)
        option4ValueLabel.text = "\(value)"
    }
    
    @IBAction func option4SliderTouchUp(_ slider: UISlider) {
        
        let value = Int(slider.value)
        option4ValueLabel.text = "\(value)"
        
        let sliderSettings = currentModeSlidersStorage[3]
        sliderSettings.value = value

        sendNewSettings(b7: sliderSettings.b7)
    }
    
    @IBAction func colorButtonClicked(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Colors",
                                        rows: colors,
                                        initialSelection: currentColor,
                                        doneBlock: { picker, index, value in
                                            print("picker = \(String(describing: picker))")
                                            print("value = \(String(describing: value))")
                                            print("index = \(String(describing: index))")
                                            self.currentColor = index
                                            self.updateUI()
                                            self.sendNewSettings(b7: 1)
                                            return
                                        },
                                        cancel: { picker in
                                            return
                                        },
                                        origin: sender)
    }
    
    @IBAction func pairButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowPairScreen", sender: {(destVC: UIViewController) in
            destVC.presentationController?.delegate = self
        } as SegueSenderCallback)
    }

    @IBAction func onOffButtonClicked(_ sender: Any) {
        onOffButton.isSelected = !onOffButton.isSelected
        isOn = onOffButton.isSelected
        LEDController.changeLeds(state: isOn) { (result) in
            dLog("set state res: \(result)")
        }
    }
    
    @IBAction func presetButtonClicked(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Presets",
                                         rows: presets,
                                         initialSelection: presetId,
                                         doneBlock: { picker, index, value in
                                            print("picker = \(String(describing: picker))")
                                            print("value = \(String(describing: value))")
                                            print("index = \(String(describing: index))")
                                            self.presetId = index
                                            self.updateUI()
                                            LEDController.changePreset(presetId: self.presetId) { (isSuccessful, response) in
                                                self.parseSettings(response: response)
                                            }
                                            return
                                         },
                                         cancel: { picker in
                                            return
                                         },
                                         origin: sender)
        
    }
    
    @IBAction func modeButtonClicked(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Presets",
                                         rows: modes,
                                         initialSelection: currentMode.rawValue,
                                         doneBlock: { picker, index, value in
                                            print("picker = \(String(describing: picker))")
                                            print("value = \(String(describing: value))")
                                            print("index = \(String(describing: index))")
                                            self.currentMode = LedMode(rawValue: index)!
                                            self.updateUI()
                                            LEDController.changeMode(modeId: self.currentMode.rawValue) { (isSuccessful, response) in
                                                self.parseSettings(response: response)
                                            }
                                            return
                                         },
                                         cancel: { picker in
                                            return
                                         },
                                         origin: sender)
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
//            LEDController.sendPing { (success) in
//                dLog("send ping res: \(success)")
//            }
            
        LEDController.loadSetting(callback: { (result, response) in
            self.parseSettings(response: response)
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension LedControlViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        DispatchQueue.main.async {
            self.screenDidShow()
        }
    }
}

extension LedControlViewController: LedControlScreenDelegate {
    func pairControllerWillDismiss() {
        DispatchQueue.main.async {
            self.screenDidShow()
        }
    }
}

extension LedControlViewController {
    
    fileprivate func sendNewSettings(b7: Int) {
        var theB7 = b7
        if currentMode == .ColorSelection  {
            theB7 = currentColor
        }
        let data = GyverSetStateRequest.buildRequest(brightness: currentBrightness, white: currentWhite, settings: currentModeSlidersStorage, b7: theB7, mode: currentMode)
        LEDController.changeSetting(command: data) { (result) in
        }
    }
    
    fileprivate func screenDidShow() {
        
        BLEManager.setupConnectStatusCallback { (connectStatus, peripheral, devType, error) in
            
            dLog("conn status: \(connectStatus)")
            dLog("error: \(error.orNil)")
            
            if connectStatus == .ready {
                DispatchQueue.main.async {
                    self.controlLabel.textColor = UIColor.green
                    self.updateUIOnDeviceStateChanged()
                    self.loadSettings()
                }
            } else if connectStatus == .error || connectStatus == .timeoutError || connectStatus == .disconected {
                DispatchQueue.main.async {
                    self.controlLabel.textColor = UIColor.yellow
                    BLEManager.connectToDevice(peripheral!, deviceType: .expectedDevice,
                                               serviceIds: [CBUUID(string: "FFE0")],
                                               characteristicIds: [CBUUID(string: "FFE1")], timeout: 30.0)
                    self.updateUIOnDeviceStateChanged()
                }
            }
            
        }
          
        self.controlLabel.textColor = UIColor.white
        
        guard !BLEManager.deviceConnected() else {
            self.controlLabel.textColor = UIColor.green
            self.loadSettings()
            return
        }
          
        guard let deviceId = deviceId else {
            return
        }
        
        guard let peripheral = BLEManager.canConnectToPeripheral(with: deviceId) else {
            return
        }
        
        self.controlLabel.textColor = UIColor.yellow
        BLEManager.connectToDevice(peripheral, deviceType: .expectedDevice,
                                   serviceIds: [CBUUID(string: "FFE0")],
                                   characteristicIds: [CBUUID(string: "FFE1")], timeout: 30.0)
    }
    
    fileprivate func hideSliders() {
        option1HeightConstraint.constant = 0
        option2HeightConstraint.constant = 0
        option3HeightConstraint.constant = 0
        option4HeightConstraint.constant = 0
        optionColorHeightConstraint.constant = 0
    }
    
    fileprivate func updateUI() {
        
        dLog("update UI")
        
        onOffButton.isSelected = isOn
        presetLabel.text = presets[presetId]
        modeLabel.text = modes[currentMode.rawValue]
        
        brightnessValueLabel.text = "\(currentBrightness)"
        brightnessSlider.value = Float(currentBrightness)
        
        whiteValueLabel.text = "\(currentWhite)"
        whiteSlider.value = Float(currentWhite)
        
        hideSliders()
        var index = 0
        for sliderSettings in currentModeSlidersStorage {
            switch index {
            case 0:
                option1HeightConstraint.constant = 48
                option1Label.text = sliderSettings.name
                option1Slider.minimumValue = Float(sliderSettings.min)
                option1Slider.maximumValue = Float(sliderSettings.max)
                if currentMode == .Kelvin {
                    option1Slider.value = Float(sliderSettings.value/100)
                } else {
                    option1Slider.value = Float(sliderSettings.value)
                }
                option1ValueLabel.text = "\(sliderSettings.value)"
            case 1:
                option2HeightConstraint.constant = 48
                option2Label.text = sliderSettings.name
                option2Slider.minimumValue = Float(sliderSettings.min)
                option2Slider.maximumValue = Float(sliderSettings.max)
                option2Slider.value = Float(sliderSettings.value)
                option2ValueLabel.text = "\(sliderSettings.value)"
            case 2:
                option3HeightConstraint.constant = 48
                option3Label.text = sliderSettings.name
                option3Slider.minimumValue = Float(sliderSettings.min)
                option3Slider.maximumValue = Float(sliderSettings.max)
                option3Slider.value = Float(sliderSettings.value)
                option3ValueLabel.text = "\(sliderSettings.value)"
            case 3:
                option4HeightConstraint.constant = 48
                option4Label.text = sliderSettings.name
                option4Slider.minimumValue = Float(sliderSettings.min)
                option4Slider.maximumValue = Float(sliderSettings.max)
                option4Slider.value = Float(sliderSettings.value)
                option4ValueLabel.text = "\(sliderSettings.value)"
            default:
                break
            }
            index += 1
        }
        
        if currentModeSlidersStorage.isEmpty {
            optionColorHeightConstraint.constant = 44
            currentColorLabel.text = colors[currentColor]
        }
        
    }
    
    fileprivate func updateUIOnDeviceStateChanged() {
        if BLEManager.deviceConnected() {
            onOffButton.isEnabled = true
            presetButton.isEnabled = true
            modeButton.isEnabled = true
        } else {
            onOffButton.isEnabled = false
            presetButton.isEnabled = false
            modeButton.isEnabled = false
        }
    }
    
    fileprivate func loadSettings() {
        LEDController.loadSetting { (isSuccessful, response) in
            self.parseSettings(response: response)
        }
    }
    
    fileprivate func parseSettings(response: GyverStateResponse?) {

        guard let response = response else {
            return
        }
        
        DispatchQueue.main.async {
            self.currentMode = response.mode
            self.presetId = response.preset
            self.isOn = response.isOn
            
            self.currentBrightness = response.brightness
            self.currentWhite = response.whiteLevel
            
            self.currentModeSlidersStorage = self.modesSettings[self.currentMode.rawValue]
            
            var index = 0
            for sliderSettings in self.currentModeSlidersStorage {
                switch index {
                case 0:
                    sliderSettings.value = response.value1
                case 1:
                    sliderSettings.value = response.value2
                case 2:
                    sliderSettings.value = response.value3
                case 3:
                    sliderSettings.value = response.value4
                default:
                    break
                }
                index += 1
            }
            
            if self.currentModeSlidersStorage.isEmpty {
                self.currentColor = response.value1
                if self.currentColor >= self.colors.count {
                    self.currentColor = 0
                }
            }
            
            self.updateUI()
        }
    }
}

extension LedControlViewController {
    
    fileprivate func setupSliderModels() {
        
        var modeSlidersStorage = [SliderSetting]()
        modeSlidersStorage.append(SliderSetting(name: "Red", min: 0, max: 255, b7: 1))
        modeSlidersStorage.append(SliderSetting(name: "Green", min: 0, max: 255, b7: 2))
        modeSlidersStorage.append(SliderSetting(name: "Blue", min: 0, max: 255, b7: 3))
        modesSettings.append(modeSlidersStorage)
        
        modeSlidersStorage = [SliderSetting]()
        modeSlidersStorage.append(SliderSetting(name: "H", min: 0, max: 255, b7: 1))
        modeSlidersStorage.append(SliderSetting(name: "S", min: 0, max: 255, b7: 2))
        modeSlidersStorage.append(SliderSetting(name: "V", min: 0, max: 255, b7: 3))
        modesSettings.append(modeSlidersStorage)
        
        modeSlidersStorage = [SliderSetting]()
        modeSlidersStorage.append(SliderSetting(name: "Color", min: 0, max: 1530, b7: 1))
        modesSettings.append(modeSlidersStorage)
        
        modeSlidersStorage = [SliderSetting]()
        modesSettings.append(modeSlidersStorage)
        
        modeSlidersStorage = [SliderSetting]()
        modeSlidersStorage.append(SliderSetting(name: "Kelvin", min: 0, max: 100, b7: 1))
        modesSettings.append(modeSlidersStorage)
        
        modeSlidersStorage = [SliderSetting]()
        modeSlidersStorage.append(SliderSetting(name: "Speed", min: 0, max: 1000, b7: 1))
        modeSlidersStorage.append(SliderSetting(name: "Step", min: 0, max: 1000, b7: 2))
        modesSettings.append(modeSlidersStorage)
        
        modeSlidersStorage = [SliderSetting]()
        modeSlidersStorage.append(SliderSetting(name: "Speed", min: 1, max: 255, b7: 1))
        modeSlidersStorage.append(SliderSetting(name: "Min", min: 0, max: 255, b7: 2))
        modesSettings.append(modeSlidersStorage)
        
        modeSlidersStorage = [SliderSetting]()
        modeSlidersStorage.append(SliderSetting(name: "Color", min: 0, max: 255, b7: 1))
        modeSlidersStorage.append(SliderSetting(name: "Speed", min: 1, max: 255, b7: 2))
        modeSlidersStorage.append(SliderSetting(name: "Min", min: 0, max: 255, b7: 3))
        modesSettings.append(modeSlidersStorage)
        
        modeSlidersStorage = [SliderSetting]()
        modeSlidersStorage.append(SliderSetting(name: "H", min: 0, max: 255, b7: 1))
        modeSlidersStorage.append(SliderSetting(name: "S", min: 0, max: 255, b7: 2))
        modeSlidersStorage.append(SliderSetting(name: "V", min: 0, max: 255, b7: 3))
        modeSlidersStorage.append(SliderSetting(name: "Speed", min: 1, max: 1000, b7: 4))
        modesSettings.append(modeSlidersStorage)
        
        modeSlidersStorage = [SliderSetting]()
        modeSlidersStorage.append(SliderSetting(name: "H", min: 0, max: 255, b7: 1))
        modeSlidersStorage.append(SliderSetting(name: "S", min: 0, max: 255, b7: 2))
        modeSlidersStorage.append(SliderSetting(name: "V", min: 0, max: 255, b7: 3))
        modeSlidersStorage.append(SliderSetting(name: "Speed", min: 1, max: 1000, b7: 4))
        modesSettings.append(modeSlidersStorage)
        
        modeSlidersStorage = [SliderSetting]()
        modeSlidersStorage.append(SliderSetting(name: "Speed", min: 1, max: 1000, b7: 1))
        modesSettings.append(modeSlidersStorage)
        
    }
    
    
}
