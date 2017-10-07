//
//  BungieAPIService.swift
//  Truth
//
//  Created by David Celentano on 10/5/17.
//  Copyright © 2017 David Celentano. All rights reserved.
//

import SwiftyJSON
import RxCocoa
import RxSwift

enum RequestType {
    case accountId
    case accountSummary
    case subclass
    case primary
    case special
    case heavy
}

enum Console {
    case Xbox
    case PlayStation
}

class BungieAPIService {
    
    // secret key needed for API access
    private var secretKey: String?
    
    // console identifier
    private var consoleId = "1"
    
    // key to make requests for a user
    private var accountId: String? {
        // once we get an account id, we want to fetch the account summary
        didSet {
            // if the accountId is not found, we clear existing data and return PNF
            guard let id = accountId else { clearExistingData(); info.value = "Player Not Found"; return }
            info.value = ""
            fetchAccountSummary(with: id)
        }
    }
    
    // Observable vars for character stats
    var subclass: Variable<String> = Variable("")
    var lightLevel: Variable<String> = Variable("")
    var primary: Variable<String> = Variable("")
    var special: Variable<String> = Variable("")
    var heavy: Variable<String> = Variable("")
    var hoursPlayed: Variable<String> = Variable("")
    var info: Variable<String> = Variable("")
    
    
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
    
    // MARK: API Request Sender
    
    private func sendBungieRequest(with bungieAPIRequest: String, type: RequestType) {
        // ensure secret key exists
        guard let key = secretKey else { assertionFailure("SECRET API KEY NOT FOUND"); return }
        let session = URLSession.shared
        // A request to the bungie API with a specified call: bungieRequest (an api call to bungie)
        var request = URLRequest(url: URL(string: "http://www.bungie.net/Platform/Destiny\(bungieAPIRequest)")!)
        request.httpMethod = "GET"
        request.addValue(key, forHTTPHeaderField: "X-API-Key")
        // send request
        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            // parse data
            if let data = data {
                switch type {
                case .accountId:
                    self?.accountId = self?.parseAccountId(from: data)
                case .accountSummary:
                    self?.parseAccountSummary(from: data)
                default:
                    self?.parseItemInfo(from: data, type: type)
                }
            }
        })
        task.resume()
    }
    
    // MARK: API Requests
    
    func fetchAccountId(for username: String, console: Console) {
        // safetly pass the username as a query param
        let formattedUsername: String = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        switch console {
        case .PlayStation:
            consoleId = "2"
        case .Xbox:
            consoleId = "1"
        }
        sendBungieRequest(with: "/SearchDestinyPlayer/\(consoleId)/\(formattedUsername)/", type: .accountId)
    }
    
    private func fetchAccountSummary(with accountId: String) {
        sendBungieRequest(with: "/\(consoleId)/Account/\(accountId)/Summary/", type: .accountSummary)
    }
    
    private func fetchItemInfo(for itemHash: String, type: RequestType) {
        sendBungieRequest(with: "/Manifest/InventoryItem/\(itemHash)", type: type)
    }
    
    
    // MARK: Parser Methods
    
    private func parseAccountId(from data: Data) -> String? {
        let jsonData = JSON(data)
        if let membershipId = jsonData["Response"][0]["membershipId"].string {
            return membershipId
        }
        //assertionFailure("parseAccountId: no account ID!"); return nil
        return nil
    }
    
    private func parseAccountSummary(from data: Data) {
        let jsonData = JSON(data)
        // extract hours played
        if let minutesPlayed = jsonData["Response"]["data"]["characters"][0]["characterBase"]["minutesPlayedTotal"].string {
            hoursPlayed.value = String(Int(minutesPlayed)! / 60)
        }
        if let lightLevel = jsonData["Response"]["data"]["characters"][0]["characterBase"]["powerLevel"].number {
            self.lightLevel.value = String(describing: lightLevel)
        }
        if let sublcass = jsonData["Response"]["data"]["characters"][0]["characterBase"]["peerView"]["equipment"][0]["itemHash"].number {
            fetchItemInfo(for: String(describing: sublcass), type: .subclass)
        }
        if let primary = jsonData["Response"]["data"]["characters"][0]["characterBase"]["peerView"]["equipment"][6]["itemHash"].number {
            fetchItemInfo(for: String(describing: primary), type: .primary)
        }
        if let special = jsonData["Response"]["data"]["characters"][0]["characterBase"]["peerView"]["equipment"][7]["itemHash"].number {
            fetchItemInfo(for: String(describing: special), type: .special)
        }
        if let heavy = jsonData["Response"]["data"]["characters"][0]["characterBase"]["peerView"]["equipment"][8]["itemHash"].number {
            fetchItemInfo(for: String(describing: heavy), type: .heavy)
        }
    }
    
    private func parseItemInfo(from data: Data, type: RequestType) {
        let jsonData = JSON(data)
        if let name = jsonData["Response"]["data"]["inventoryItem"]["itemName"].string {
            switch type {
            case .subclass:
                subclass.value = name
            case .primary:
                primary.value = name
            case .special:
                special.value = name
            case .heavy:
                heavy.value = name
            default:
                return
            }
        }
    }
    
    // MARK: Helper Methods
    private func clearExistingData() {
        subclass.value = ""
        lightLevel.value = ""
        primary.value = ""
        special.value = ""
        heavy.value = ""
        hoursPlayed.value = ""
    }
}
