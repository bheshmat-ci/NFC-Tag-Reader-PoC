//
//  AppManager.swift
//  NFCTagReaderPoC
//
//  Created by Mamun Ar Rashid on 26/4/22.
//

import Foundation
import UIKit

struct AppManager {
    
    static var currentData: AppData = AppData(userID: "123456789", nfcTagID: "123456789")
    
    static func showAlert(fromVC: UIViewController, title:String, message: String) {
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        fromVC.present(alertController, animated: true, completion: nil)
    }
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

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
