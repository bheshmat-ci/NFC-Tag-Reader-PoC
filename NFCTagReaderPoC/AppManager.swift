//
//  AppManager.swift
//  NFCTagReaderPoC
//
//  Created by Mamun Ar Rashid on 26/4/22.
//

import Foundation

struct AppManager {
    
    static var currentData: AppData = AppData(userID: "123456789", nfcTagID: "123456789")
}


struct AppData {
    
    var userID: String
    var nfcTagID: String
    
}

extension Date{

    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}

