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

// API request types
enum RequestType {
    case accountId
    case accountSummary
    case inventorySummary
    case subclass
    case primary
    case special
    case heavy
}

// Console types
enum Console {
    case Xbox
    case PlayStation
}

// Handles all requests and data parsing from Bungie.net
class BungieAPIService {
    
    // secret key needed for API access
    private var secretKey: String?
    
    // console identifier
    private var consoleId = "1"
    
    // bool for if we're looking up D1 or D2 stats
    private var destiny2Enabled: Bool = true
    
    // last searched username for history
    private var lastUsername: String?
    
    // key to make requests for a user
    private var accountId: String? {
        // once we get an account id, we want to fetch the account summary
        didSet {
            // if the accountId is not found, we clear existing data and return PNF
            guard let id = accountId else { clearExistingData(); isLoading.value = false; info.value = "❕Error - Guardian Not Found"; return }
            info.value = ""
            if let username = lastUsername {
                // append last searched player to history
                if !recentPlayers.value.contains(username) {
                    recentPlayers.value.append(username)
                    // we only want 3 recent players in the history
                    recentPlayers.value.keepLast(3)
                }
            }
            if destiny2Enabled {
                d2FetchAccountSummary(for: id)
            }
            else {
                fetchAccountSummary(with: id)
            }
            
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
    var recentPlayers: Variable<[String]> = Variable([])
    var isLoading: Variable<Bool> = Variable(false)
    
    
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
    
    // MARK: Destiny 1 API
    
    private func sendDestiny1(request bungieAPIRequest: String, type: RequestType) {
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
    
    // gather initial account Id for further calls
    func fetchAccountId(for username: String, console: Console, destiny2Enabled: Bool) {
        // start loading state
        isLoading.value = true
        // safetly pass the username as a query param
        let formattedUsername: String = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // set console type
        switch console {
        case .PlayStation:
            consoleId = "2"
        case .Xbox:
            consoleId = "1"
        }
        // set destiny version
        self.destiny2Enabled = destiny2Enabled
        // set last searched for user for search history
        lastUsername = formattedUsername
        sendDestiny1(request: "/SearchDestinyPlayer/\(consoleId)/\(formattedUsername)/", type: .accountId)
    }
    
    // gather account data for the current account Id
    private func fetchAccountSummary(with accountId: String) {
        sendDestiny1(request: "/\(consoleId)/Account/\(accountId)/Summary/", type: .accountSummary)
    }
    
    // gather data on a specified item
    private func fetchItemInfo(for itemHash: String, type: RequestType) {
        sendDestiny1(request: "/Manifest/InventoryItem/\(itemHash)", type: type)
    }
    
    
    // MARK: Destiny 1 Parser Methods
    
    // extract account Id
    private func parseAccountId(from data: Data) -> String? {
        let jsonData = JSON(data)
        if let membershipId = jsonData["Response"][0]["membershipId"].string {
            return membershipId
        }
        return nil
    }
    
    // extract character stats and item hash values from account data (the hash values will be fetched for further data)
    private func parseAccountSummary(from data: Data) {
        let jsonData = JSON(data)
        // extract hours played
        if let minutesPlayed = jsonData["Response"]["data"]["characters"][0]["characterBase"]["minutesPlayedTotal"].string {
            hoursPlayed.value = String(Int(minutesPlayed)! / 60)
        }
        // extract light level
        if let lightLevel = jsonData["Response"]["data"]["characters"][0]["characterBase"]["powerLevel"].number {
            self.lightLevel.value = String(describing: lightLevel)
        }
        // fetch data for subclass, primary weapon, special weapon, and heavy weapon
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
    
    // extract name from item data
    private func parseItemInfo(from data: Data, type: RequestType) {
        let jsonData = JSON(data)
        if let name = jsonData["Response"]["data"]["inventoryItem"]["itemName"].string {
            switch type {
            case .subclass:
                // stop loading state
                isLoading.value = false
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
    
    // MARK: -----------------------------------------
    
    // MARK: Destiny 2 API
    
    private var d2AccountId: String?
    
    private func sendDestiny2(request bungieAPIRequest: String, type: RequestType) {
        // ensure secret key exists
        guard let key = secretKey else { assertionFailure("SECRET API KEY NOT FOUND"); return }
        let session = URLSession.shared
        // A request to the bungie API with a specified call: bungieRequest (an api call to bungie)
        var request = URLRequest(url: URL(string: "http://www.bungie.net/Platform/Destiny2\(bungieAPIRequest)")!)
        request.httpMethod = "GET"
        request.addValue(key, forHTTPHeaderField: "X-API-Key")
        // send request
        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            // parse data
            if let data = data {
                switch type {
                case .accountSummary:
                    self?.d2ParseAccountSummary(from: data)
                case .inventorySummary:
                    self?.d2ParseInventorySummary(from: data)
                default:
                    self?.d2ParseItemInfo(from: data, type: type)
                }
            }
        })
        task.resume()
    }
    
    private func d2FetchAccountSummary(for accountId: String) {
        d2AccountId = accountId
        sendDestiny2(request: "/\(consoleId)/Profile/\(accountId)/?components=100,200", type: .accountSummary)
    }
    
    private func d2FetchInventorySummary(for characaterId: String) {
        guard let accountId = d2AccountId else { assertionFailure("\(#function) no id found"); return }
        sendDestiny2(request: "/\(consoleId)/Profile/\(accountId)/character/\(characaterId)/?components=205", type: .inventorySummary)
    }
    
    private func d2FetchItemInfo(for itemHash: String, type: RequestType) {
        sendDestiny2(request: "/Manifest/DestinyInventoryItemDefinition/\(itemHash)", type: type)
    }
    
    // MARK: Destiny 2 Parser Methods
    
    private func d2ParseAccountSummary(from data: Data) {
        let jsonData = JSON(data)
        guard let recentCharacterId = jsonData["Response"]["profile"]["data"]["characterIds"][0].string else { assertionFailure("\(#function) no character id"); return }
        if let lightLevel = jsonData["Response"]["characters"]["data"][recentCharacterId]["light"].number {
            self.lightLevel.value = String(describing: lightLevel)
        }
        if let minutesPlayed = jsonData["Response"]["characters"]["data"][recentCharacterId]["minutesPlayedTotal"].string {
            hoursPlayed.value = String(Int(minutesPlayed)! / 60)
        }
        d2FetchInventorySummary(for: recentCharacterId)
    }
    
    private func d2ParseInventorySummary(from data: Data) {
        let jsonData = JSON(data)
        if let primaryHash = jsonData["Response"]["equipment"]["data"]["items"][0]["itemHash"].number {
            d2FetchItemInfo(for: String(describing: primaryHash), type: .primary)
        }
        if let specialHash = jsonData["Response"]["equipment"]["data"]["items"][1]["itemHash"].number {
            d2FetchItemInfo(for: String(describing: specialHash), type: .special)
        }
        if let heavyHash = jsonData["Response"]["equipment"]["data"]["items"][2]["itemHash"].number {
            d2FetchItemInfo(for: String(describing: heavyHash), type: .heavy)
        }
        if let subclassHash = jsonData["Response"]["equipment"]["data"]["items"][11]["itemHash"].number {
            d2FetchItemInfo(for: String(describing: subclassHash), type: .subclass)
        }
    }
    
    private func d2ParseItemInfo(from data: Data, type: RequestType) {
        let jsonData = JSON(data)
        guard let itemName = jsonData["Response"]["displayProperties"]["name"].string else { return }
        guard let itemType = jsonData["Response"]["itemTypeDisplayName"].string else { return }
        switch type {
        case .subclass:
            subclass.value = itemType.split(separator: " ").first! + " - " + itemName
        case .primary:
            primary.value = itemName + " - " + itemType
        case .special:
            special.value = itemName + " - " + itemType
        case .heavy:
            heavy.value = itemName + " - " + itemType
        default:
            return
        }
    }
    
    // MARK: Helper Methods
    
    // clears all existing character data
    private func clearExistingData() {
        subclass.value = ""
        lightLevel.value = ""
        primary.value = ""
        special.value = ""
        heavy.value = ""
        hoursPlayed.value = ""
    }
}
