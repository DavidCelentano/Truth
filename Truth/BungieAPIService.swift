//
//  BungieAPIService.swift
//  Truth
//
//  Created by David Celentano on 10/5/17.
//  Copyright © 2017 David Celentano. All rights reserved.
//

import Foundation
import SwiftyJSON

class BungieAPIService {
    
    // secret key needed for API access
    private var secretKey: String?
    
    init() {
        // extract secret key
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            secretKey = dict.value(forKey: "API_key") as? String
        }
    }
    
    private func sendBungieRequest(withRequest bungieAPIRequest: String) {
        // ensure secret key exists
        guard let key = secretKey else { assertionFailure("SECRET API KEY NOT FOUND"); return }
        let session = URLSession.shared
        // A request to the bungie API with a specified call: bungieRequest (an api call to bungie)
        var request = URLRequest(url: URL(string: "http://www.bungie.net/Platform/Destiny\(bungieAPIRequest)")!)
        request.httpMethod = "GET"
        // TODO make secret
        request.addValue(key, forHTTPHeaderField: "X-API-Key")
        // send request
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            // parse data
            if let data = data {
                let jsonData = JSON(data: data)
                if let membershipId = jsonData["Response"][0]["membershipId"].string {
                    print(membershipId)
                }
            }
        })
        task.resume()
    }
    
    func fetchAccountId(for username: String) {
        // safetly pass the username as a query param
        let formattedUsername: String = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // TODO allow console swap
        sendBungieRequest(withRequest: "/SearchDestinyPlayer/1/\(formattedUsername)/")
    }
}
