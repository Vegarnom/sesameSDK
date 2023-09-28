//
//  Sesame2BleDevicePeripheral.swift
//  sesame2-sdk
//
//  Created by Cerberus on 2019/08/24.
//  Copyright © 2019 CandyHouse. All rights reserved.
//

import CoreBluetooth

private let uuidService01 = CBUUID(string: "16860001-A5AE-9856-B6D3-DBB4C676993E")
private let uuidChr02 = CBUUID(string: "16860002-A5AE-9856-B6D3-DBB4C676993E")

extension CHSesame2Device {

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid ==  uuidChr02 {
                self.characteristic = characteristic
            }

            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let mesg = gattRxBuffer.feed(characteristic.value!) {
            if mesg.type == .ciphertext {
                if let cipher = cipher {
                    do {
                        let plaintext = try cipher.decrypt(mesg.buffer)
                        parseNotifyPayload(plaintext)
                    } catch {
                        L.d("解密錯誤 ！！！", error)
                    }
                }
            } else if mesg.type == .plaintext {
                parseNotifyPayload(mesg.buffer)
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        transmit()
    }
}
