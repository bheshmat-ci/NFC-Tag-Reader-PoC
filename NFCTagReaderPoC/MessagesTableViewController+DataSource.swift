//
//  MessagesTableViewController+DataSource.swift
//  NFCTagReaderPoC
//
//  Created by bv-empower on 21/4/22.
//

import UIKit
import CoreNFC

extension MessagesTableViewController {

    // MARK: - Table View Functions

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detectedMessages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        let message = detectedMessages[indexPath.row]
        let unit = message.records.count == 1 ? " Payload" : " Payloads"
        cell.textLabel?.text = message.records.count.description + unit

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let payloadsTableViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PayloadsViewController") as? PayloadsViewController {
            payloadsTableViewController.message = detectedMessages[indexPath.row]
            self.navigationController?.show(payloadsTableViewController, sender: nil)
        }
      
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let indexPath = tableView.indexPathForSelectedRow,
//            let payloadsTableViewController = segue.destination as? PayloadsTableViewController else {
//            return
//        }
        //payloadsTableViewController.message = detectedMessages[indexPath.row]
    }


}
