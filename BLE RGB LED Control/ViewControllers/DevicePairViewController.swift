//
//  DeviceListViewController.swift
//  BLECore
//
//  Created by Mixaill on 10.02.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicePairViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    fileprivate var discoveredDevices = [String: BLEPeripheral]()
    
    fileprivate var waitingPairDevice = false
    
    @UserDefaultOptionl<String>(key: .deviceId, defaultValue: nil) var deviceId
    
    override func viewDidLoad() {
        super.viewDidLoad()

        BLEManager.setupDiscoveryDeviceCallback { (isNew, blePeripheral) in
            DispatchQueue.main.async {
                self.discoveredDevice(isNew, blePeripheral)
            }
        }
        
        BLEManager.setupConnectStatusCallback { (connectStatus, peripheral, devType, error) in
            dLog("conn status: \(connectStatus)")
            dLog("error: \(error.orNil)")
            self.handleConnectDeviceState(connectStatus, peripheral)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard BLEManager.bluetoothEnabled() else {
            showAlert(withTitle: "Bluethooth Error", andMessage: BLEManager.alertMsgForCurrentBTState() ?? "Unknown error")
            return
        }
        
        guard !waitingPairDevice else {
            return
        }
        
        guard BLEManager.deviceDisconnected() else {
            BLEManager.disconectFromDevice()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.startDiscovery()
            }
            return
        }
        
        startDiscovery()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopDiscovery()
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        let ledControlVc = self.presentationController?.delegate as? LedControlScreenDelegate
        self.dismiss(animated: true) {
            guard let vc = ledControlVc else {
                return
            }
            vc.pairControllerWillDismiss()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension DevicePairViewController {
    
    fileprivate func startDiscovery() {
        if !BLEManager.isDiscovering() {
            discoveredDevices = [String: BLEPeripheral]()
            tableView.reloadData()
            BLEManager.startDiscovery(serviceUUIDs: [CBUUID(string: "FFE0")])
        }
    }
    
    fileprivate func stopDiscovery() {
        if BLEManager.isDiscovering() {
            BLEManager.stopDiscovery()
        }
    }
    
    fileprivate func handleConnectDeviceState(_ connectStatus: BLEDeviceConnectStatus, _ peripheral: CBPeripheral?) {
        if connectStatus == .ready {
            DispatchQueue.main.async {
                let ledControlVc = self.presentationController?.delegate as? LedControlScreenDelegate
                self.dismiss(animated: true) {
                    self.deviceId = peripheral?.identifier.uuidString
                    guard let vc = ledControlVc else {
                        return
                    }
                    vc.pairControllerWillDismiss()
                }
            }
        } else if connectStatus == .error || connectStatus == .timeoutError {
            DispatchQueue.main.async {
                self.startDiscovery()
                self.tableView.isUserInteractionEnabled = true
                self.waitingPairDevice = false
            }
        }
    }
    
    fileprivate func discoveredDevice(_ isNew: Bool, _ blePeripheral: BLEPeripheral) {
        if isNew {
            let addCellPath = IndexPath(item: Int(self.discoveredDevices.count), section: 0)
            self.discoveredDevices[blePeripheral.uuid()] = blePeripheral
            self.tableView.insertRows(at: [addCellPath], with: .automatic)
        } else {
            self.discoveredDevices[blePeripheral.uuid()] = blePeripheral
            let index = Array(self.discoveredDevices.keys).firstIndex(of: blePeripheral.uuid())
            
            let reloadCellPath = IndexPath(item: index!, section: 0)
            if let cell = self.tableView.cellForRow(at: reloadCellPath) as? DiscoveredDeviceTableViewCell {
                cell.updateDeviceRSSI(rssi: blePeripheral.rssi)
            }
        }
    }
}

extension DevicePairViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DiscoveredDeviceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell")! as! DiscoveredDeviceTableViewCell
        
        let device = discoveredDevices[Array(self.discoveredDevices.keys)[indexPath.row]]!
        
        cell.deviceName.text = device.peripheral.name ?? "Unknown"
        cell.updateDeviceRSSI(rssi: device.rssi)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let device = discoveredDevices[Array(self.discoveredDevices.keys)[indexPath.row]]!
        
        stopDiscovery()
        tableView.isUserInteractionEnabled = false
        waitingPairDevice = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            BLEManager.connectToDevice(device.peripheral, deviceType: .expectedDevice,
                                       serviceIds: [CBUUID(string: "FFE0")],
                                       characteristicIds: [CBUUID(string: "FFE1")], timeout: 10.0)
        }
    }
}
