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
    
    fileprivate let presets = ["Default","Preset 1","Preset 2","Preset 3","Preset 4","Preset 5","Preset 6","Preset 7","Preset 8","Preset 9"]
    fileprivate let modes = ["RGB","HSV","Color","Color Selection","Kelvin","Color loop","Fire","Manual Fire","Strobe Light","Random Strobe Light", "Flashing"]
    
    fileprivate var presetId = 0
    fileprivate var modeId = 0
    
    @UserDefaultOptionl<String>(key: .deviceId, defaultValue: nil) var deviceId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUIOnDeviceStateChanged()
        screenDidShow()
        updateUI()
    }
    
    fileprivate func screenDidShow() {
        
        BLEManager.setupConnectStatusCallback { (connectStatus, peripheral, devType, error) in
            
            dLog("conn status: \(connectStatus)")
            dLog("error: \(error.orNil)")
            
            if connectStatus == .ready {
                DispatchQueue.main.async {
                    //self.pairButton.setTitleColor(UIColor.green, for: .normal)
                    self.controlLabel.textColor = UIColor.green
                    self.updateUIOnDeviceStateChanged()
                    self.loadSettings()
                }
            } else if connectStatus == .error || connectStatus == .timeoutError || connectStatus == .disconected {
                DispatchQueue.main.async {
                    //self.pairButton.setTitleColor(UIColor.yellow, for: .normal)
                    self.controlLabel.textColor = UIColor.yellow
                    BLEManager.connectToDevice(peripheral!, deviceType: .expectedDevice,
                                               serviceIds: [CBUUID(string: "FFE0")],
                                               characteristicIds: [CBUUID(string: "FFE1")], timeout: 30.0)
                    self.updateUIOnDeviceStateChanged()
                }
            }
            
        }
          
        //pairButton.setTitleColor(UIColor.white, for: .normal)
        self.controlLabel.textColor = UIColor.white
        
        guard !BLEManager.deviceConnected() else {
            //pairButton.setTitleColor(UIColor.green, for: .normal)
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
        
        //pairButton.setTitleColor(UIColor.yellow, for: .normal)
        self.controlLabel.textColor = UIColor.yellow
        BLEManager.connectToDevice(peripheral, deviceType: .expectedDevice,
                                   serviceIds: [CBUUID(string: "FFE0")],
                                   characteristicIds: [CBUUID(string: "FFE1")], timeout: 30.0)
    }
    
    fileprivate func updateUI() {
        presetLabel.text = presets[presetId]
        modeLabel.text = modes[modeId]
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
        
        //TODO: parse values
        
        DispatchQueue.main.async {
            self.modeId = response.mode
            self.presetId = response.preset
            
            self.updateUI()
        }
    }
    
    @IBAction func pairButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowPairScreen", sender: {(destVC: UIViewController) in
            destVC.presentationController?.delegate = self
        } as SegueSenderCallback)
    }

    @IBAction func buttonClicked(_ sender: Any) {
        LEDController.sendPing { (success) in
            dLog("send ping res: \(success)")
        }
        
//        LEDController.changePreset(presetId: 0) { (result) in
//
//        }
        
    }

    @IBAction func onOffButtonClicked(_ sender: Any) {
        onOffButton.isSelected = !onOffButton.isSelected
        
        LEDController.changeLeds(state: onOffButton.isSelected) { (result) in
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
                                         initialSelection: modeId,
                                         doneBlock: { picker, index, value in
                                            print("picker = \(String(describing: picker))")
                                            print("value = \(String(describing: value))")
                                            print("index = \(String(describing: index))")
                                            self.modeId = index
                                            self.updateUI()
                                            LEDController.changeMode(modeId: self.modeId) { (isSuccessful, response) in
                                                self.parseSettings(response: response)
                                            }
                                            return
                                         },
                                         cancel: { picker in
                                            return
                                         },
                                         origin: sender)
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
