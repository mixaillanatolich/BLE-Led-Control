//
//  LedControlViewController.swift
//  BLE RGB LED Control
//
//  Created by Mixaill on 17.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

public protocol LedControlScreenDelegate : NSObjectProtocol {
    func pairControllerWillDismiss()
}

class LedControlViewController: BaseViewController {

    @IBOutlet weak var pairButton: UIButton!
    @IBOutlet weak var controlLabel: UILabel!
    
     @UserDefaultOptionl<String>(key: .deviceId, defaultValue: nil) var deviceId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        screenDidShow()
    }
    
    fileprivate func screenDidShow() {
        
        BLEManager.setupConnectStatusCallback { (connectStatus, peripheral, devType, error) in
            
            dLog("conn status: \(connectStatus)")
            dLog("error: \(error.orNil)")
            
            if connectStatus == .ready {
                DispatchQueue.main.async {
                    //self.pairButton.setTitleColor(UIColor.green, for: .normal)
                    self.controlLabel.textColor = UIColor.green
                }
            } else if connectStatus == .error || connectStatus == .timeoutError || connectStatus == .disconected {
                DispatchQueue.main.async {
                    //self.pairButton.setTitleColor(UIColor.yellow, for: .normal)
                    self.controlLabel.textColor = UIColor.yellow
                    BLEManager.connectToDevice(peripheral!, deviceType: .expectedDevice,
                                               serviceIds: [CBUUID(string: "FFE0")],
                                               characteristicIds: [CBUUID(string: "FFE1")], timeout: 30.0)
                }
            }
            
        }
          
        //pairButton.setTitleColor(UIColor.white, for: .normal)
        self.controlLabel.textColor = UIColor.white
        
        guard !BLEManager.deviceConnected() else {
            //pairButton.setTitleColor(UIColor.green, for: .normal)
            self.controlLabel.textColor = UIColor.green
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
    
    @IBAction func pairButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowPairScreen", sender: {(destVC: UIViewController) in
            destVC.presentationController?.delegate = self
        } as SegueSenderCallback)
    }

    @IBAction func buttonClicked(_ sender: Any) {
        
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
