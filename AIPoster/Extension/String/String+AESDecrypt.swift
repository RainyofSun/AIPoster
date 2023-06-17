//
//  String+AESDecrypt.swift
//  AIPoster
//
//  Created by 苍蓝猛兽 on 2023/6/17.
//

import Foundation
import CryptoSwift
import CommonCrypto

enum DecyrptType {
    case AES
    case DES
}
let ResultDefault = "{\"msg\":\"检查.KEY.的截取?\", \"code\":201}"
extension String {
    /// AES 解密
    public func aesDecrypt(key: String) -> String? {
        if key.count < 28 {
            return ResultDefault
        }
        let secretKey = key.substringWithRange(loc: 8, len: 16)
        let offSet = key.substringWithRange(loc: 12, len: 16)
        return aesDecryptStr(self, secretKey, offSet)
    }
    /// AES 加密
    public func aesEncrypt(key: String) -> String? {
        if key.count < 28 {
            return ResultDefault
        }
        let secretKey = key.substringWithRange(loc: 8, len: 16)
        let offSet = key.substringWithRange(loc: 12, len: 16)
        return aesEncryptStr(self, secretKey, offSet)
    }
    
    /// AES 解密 --- IAP 专用
    public func aesDecryptForIAP(key: String) -> String? {
        return aesDecryptStr(self, key, "1234567890123456")
    }
    
    private func aesDecryptStr(_ aesText: String, _ key: String, _ iv: String) -> String? {
        do {
            let aes = try AES(key: key, iv: iv, padding: .pkcs7) // aes128
            let decryptedBase64String = try aesText.decryptBase64ToString(cipher: aes)
            return decryptedBase64String
        } catch {
            return nil
        }
    }
    private func aesEncryptStr(_ text: String, _ key: String, _ iv: String) -> String? {
        do {
            let aes = try AES(key: key, iv: iv, padding: .pkcs7) // aes128
            let ciphertext = try aes.encrypt(text.bytes)
            return ciphertext.toBase64()
        } catch {
            return nil
        }
    }
}

// MARK: IAP内购、AF统计专用 DES 加解密方式
extension String {
    // DES加密
    public func desEncrypt(key:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.data(using: String.Encoding.utf8),
           let data = self.data(using: String.Encoding.utf8),
           let cryptData    = NSMutableData(length: Int((data.count)) + kCCBlockSizeDES) {
            let keyLength              = size_t(kCCKeySizeDES)
            let operation: CCOperation = UInt32(kCCEncrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmDES)
            let options:   CCOptions   = UInt32(options)
            
            var numBytesEncrypted :size_t = 0
            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      nil,
                                      (data as NSData).bytes, data.count,
                                      cryptData.mutableBytes,
                                      cryptData.length,
                                      &numBytesEncrypted)
            
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let base64cryptString = cryptData.base64EncodedString(options: .lineLength64Characters)
                return base64cryptString
                
            }
            else {
                return nil
            }
        }
        return nil
    }
    // DES解密
    public func desDecrypt(key:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.data(using: String.Encoding.utf8),
           let data = NSData(base64Encoded: self, options: .ignoreUnknownCharacters),
           let cryptData    = NSMutableData(length: Int((data.length)) + kCCBlockSizeDES) {
            
            let keyLength              = size_t(kCCKeySizeDES)
            let operation: CCOperation = UInt32(kCCDecrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmDES)
            let options:   CCOptions   = UInt32(options)
            
            var numBytesEncrypted :size_t = 0
            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      nil,
                                      data.bytes, data.length,
                                      cryptData.mutableBytes,
                                      cryptData.length,
                                      &numBytesEncrypted)
            
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let unencryptedMessage = String(data: cryptData as Data, encoding:String.Encoding.utf8)
                return unencryptedMessage
            }
            else {
                return nil
            }
        }
        return nil
    }
    
}

