//
//  PayloadsViewController.swift
//  NFCTagReaderPoC
//
//  Created by Mamun Ar Rashid on 25/4/22.
//


import UIKit
import CoreNFC


class PayloadsViewController: UIViewController, UITextFieldDelegate {

      @IBOutlet var tagDataTextField: UITextField!
   
    var message: NFCNDEFMessage = .init(records: [])
    var session: NFCNDEFReaderSession?
    var isTagWrite: Bool = false

    @IBAction func writeButtonTapped(_ sender: Any) {
        isTagWrite = true
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near an NDEF tag to write the message."
        session?.begin()
    }
    
    /// - Tag: beginScanning
    @IBAction func beginScanning(_ sender: Any) {
        
        isTagWrite = false
        
        guard NFCNDEFReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        guard NFCNDEFReaderSession.readingAvailable else {
                       return
                   }

                   //readerSession1 = NFCTagReaderSession(pollingOption:  [.iso14443, .iso15693, .iso18092], delegate: self, queue: nil)
                
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."
        session?.begin()
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

    
        // Do any additional setup after loading the view.
        showNFCTagData()
        tagDataTextField.delegate = self
        tagDataTextField.returnKeyType = .done
     }
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool
     {
         textField.resignFirstResponder()
         return true
     }
    
    func showNFCTagData ()  {
        if let payload = message.records.first {
        
        switch payload.typeNameFormat {
        case .nfcWellKnown:
                if let data = String(data: payload.payload, encoding: .utf8) {
                    tagDataTextField.text = "\(data)"
            }
        case .absoluteURI:
                if let data = String(data: payload.payload, encoding: .utf8) {
                    tagDataTextField.text = "\(data)"
                }
        case .media:
            if let type = String(data: payload.type, encoding: .utf8) {
                tagDataTextField.text = "\(payload.typeNameFormat.description): " + type
            }
        case .nfcExternal, .empty, .unknown, .unchanged:
            fallthrough
        @unknown default:
                if let data = String(data: payload.payload, encoding: .utf8) {
                    tagDataTextField.text = "\(data)"
                }
        }
        }
    }
}

extension PayloadsViewController: NFCNDEFReaderSessionDelegate {
// MARK: - NFCNDEFReaderSessionDelegate

func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {

}

/// - Tag: writeToTag
func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
    if tags.count > 1 {
        // Restart polling in 500 milliseconds.
        let retryInterval = DispatchTimeInterval.milliseconds(500)
        session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
        DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
            session.restartPolling()
        })
        return
    }
    
    // Connect to the found tag and write an NDEF message to it.
    let tag = tags.first!
    session.connect(to: tag, completionHandler: { (error: Error?) in
        if nil != error {
            session.alertMessage = "Unable to connect to tag."
            session.invalidate()
            return
        }
        
        tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
            guard error == nil else {
                session.alertMessage = "Unable to query the NDEF status of tag."
                session.invalidate()
                return
            }
            
            if !self.isTagWrite {
                tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                    var statusMessage: String
                    if nil != error || nil == message {
                        statusMessage = "Fail to read NDEF from tag"
                    } else {
                        statusMessage = "Found 1 NDEF message"
                        DispatchQueue.main.async {
                            if let message = message {
                            self.message = message
                            self.showNFCTagData()
                            }
                            // Process detected NFCNDEFMessage objects.
//                            self.detectedMessages.append(message!)
//                            self.tableView.reloadData()
                        }
                    }
                    
                    session.alertMessage = statusMessage
                    session.invalidate()
                })
                
            }

            switch ndefStatus {
            case .notSupported:
                session.alertMessage = "Tag is not NDEF compliant."
                session.invalidate()
            case .readOnly:
                    DispatchQueue.main.async {
                session.alertMessage = "Tag is read only."
                session.invalidate()
                    }
            case .readWrite:
                    DispatchQueue.main.async {
                        
                    
                    if self.isTagWrite {
                if  let text = self.tagDataTextField.text {
                    var payloadData = Data([0x02])
                    payloadData.append(text.data(using: .utf8)!)

                    let payload = NFCNDEFPayload.init(
                        format: NFCTypeNameFormat.nfcWellKnown,
                        type: "T".data(using: .utf8)!,
                        identifier: Data.init(count: 0),
                        payload: payloadData,
                        chunkSize: 0)

                    let writeData = NFCNDEFMessage(records: [payload])
                    
                tag.writeNDEF(writeData, completionHandler: { (error: Error?) in
                    if nil != error {
                        session.alertMessage = "Write NDEF message fail: \(error!)"
                    } else {
                        session.alertMessage = "Write NDEF message successful."
                    }
                    session.invalidate()
                })}
                    } else {
                      
                    }
                    }
            @unknown default:
                session.alertMessage = "Unknown NDEF tag status."
                session.invalidate()
            }
        })
    })
}

/// - Tag: sessionBecomeActive
func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
    
}

/// - Tag: endScanning
func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    // Check the invalidation reason from the returned error.
    if let readerError = error as? NFCReaderError {
        // Show an alert when the invalidation reason is not because of a success read
        // during a single tag read mode, or user canceled a multi-tag read mode session
        // from the UI or programmatically using the invalidate method call.
        if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
            && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
            let alertController = UIAlertController(
                title: "Session Invalidated",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
}

