//
//  StringExtansion.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 07/11/2021.
//

import Foundation
import CryptoKit

extension StringProtocol { // for Swift 4 you need to add the constrain `where Index == String.Index`
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }
        return byWords
    }
    
    func toSHA256() -> String{
        if let stringData = self.data(using: .utf8) {
            return SHA256.hash(data: stringData).compactMap { String(format: "%02x", $0) }.joined()
        }
        return ""
    }
}

extension String {
    func localized(useApi: Bool) -> String {
  
            return NSLocalizedString(self,
                                     tableName: "Localizable",
                                     bundle: .main,
                                     value: self, // fallback
                                     comment: self)
        }
}
