//
//  APIManager.swift
//  NFCTagReaderPoC
//
//  Created by Mamun Ar Rashid on 27/4/22.
//

import Foundation

class APIManager {
    
     static func uploadDataToAPI(userID: String, locationID: String, completion: @escaping (Bool) -> ()) {
        
//        {
//          "body": "eyJ0ZXN0IjoiYm9keSJ9",
//          "httpMethod": "POST",
//          "isBase64Encoded": true,
//          "queryStringParameters": {
//            "user_id": "ABC",
//            "location_id":"123456789",
//            "timestamp":"1650999666"
//          }
//        }
        let timestamp = "\(Date().currentTimeMillis())"
        // prepare json data
        let json: [String: Any] = ["body": "eyJ0ZXN0IjoiYm9keSJ9",
                                   "httpMethod": "POST",
                                   "isBase64Encoded": true,
                                   "queryStringParameters": ["user_id":userID, "location_id":locationID, "timestamp":timestamp]]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // create post request
        let url = URL(string: "https://zz2zux9e28.execute-api.us-west-1.amazonaws.com/prod")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // insert json data to the request
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                 completion(false)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
                 completion(true)
            } else {
                 completion(false)
            }
        }

        task.resume()
    }
}
