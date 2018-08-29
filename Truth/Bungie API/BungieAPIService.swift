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
import Flurry_iOS_SDK

// API request types
enum RequestType {
    case accountId
    case accountSummary
    case inventorySummary
    case subclass
    case primary
    case special
    case heavy
    case accountStats
}

// Console types
enum Console {
    case Xbox
    case PlayStation
    case PC
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
            guard let id = accountId else { returnError(with: "❕Guardian Not Found"); return }
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
    var overallCombatRating: Variable<String> = Variable("")
    var overallWinLossRatio: Variable<String> = Variable("")
    var overallKD: Variable<String> = Variable("")
    var overallKDA: Variable<String> = Variable("")
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
            guard let _ = secretKey else { assertionFailure("No API Key"); return }
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
                case .accountStats:
                    self?.parseAccountStats(from: data)
                default:
                    self?.parseItemInfo(from: data, type: type)
                }
            }
            if error != nil {
                self?.isLoading.value = false
                // analytics
                Flurry.endTimedEvent("Search_Time", withParameters: ["Type" : "D1 API Error Response"])
                self?.returnError(with: "No Internet Connection 😞")
            }
        })
        task.resume()
    }
    
    // gather initial account Id for further calls
    func fetchAccountId(for username: String, console: Console, destiny2Enabled: Bool) {
        // start loading state
        isLoading.value = true
        // analytics
        Flurry.logEvent("Search_Time", timed: true)
        // safetly pass the username as a query param
        let formattedUsername: String = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // set console type
        switch console {
        case .PlayStation:
            consoleId = "2"
        case .Xbox:
            consoleId = "1"
        case .PC:
            consoleId = "4"
        }
        // set destiny version
        self.destiny2Enabled = destiny2Enabled
        // set last searched for user for search history
        lastUsername = username
        if destiny2Enabled {
            sendDestiny2(request: "/SearchDestinyPlayer/\(consoleId)/\(formattedUsername)/", type: .accountId)
        }
        else {
            sendDestiny1(request: "/SearchDestinyPlayer/\(consoleId)/\(formattedUsername)/", type: .accountId)
        }
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
        // extract hours played, if we can't find it, we throw an error since something has gone poorly
        guard let minutesPlayed = jsonData["Response"]["data"]["characters"][0]["characterBase"]["minutesPlayedTotal"].string else {
            returnError(with: "No Destiny 1 stats found for this Guardian"); return
        }
        // else set the hours played and proceed since we probably have the rest of the data
        hoursPlayed.value = String(Int(minutesPlayed)! / 60)
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
        if let id = accountId {
            sendDestiny1(request: "/Stats/Account/\(consoleId)/\(id)/", type: .accountStats)
        }
    }
    
    // extract name from item data
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
                case .accountId:
                    self?.accountId = self?.parseAccountId(from: data)
                case .accountSummary:
                    self?.d2ParseAccountSummary(from: data)
                case .inventorySummary:
                    self?.d2ParseInventorySummary(from: data)
                case .accountStats:
                    self?.parseAccountStats(from: data)
                default:
                    self?.d2ParseItemInfo(from: data, type: type)
                }
            }
            if error != nil {
                self?.isLoading.value = false
                // analytics
                Flurry.endTimedEvent("Search_Time", withParameters: ["Type" : "D2 API Error Response"])
                self?.returnError(with: "No Internet Connection 😞")
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
    
    private func d2FetchAccountStats(for accountId: String) {
        sendDestiny2(request: "/\(consoleId)/Account/\(accountId)/Stats", type: .accountStats)
    }
    
    private func d2FetchItemInfo(for itemHash: String, type: RequestType) {
        sendDestiny2(request: "/Manifest/DestinyInventoryItemDefinition/\(itemHash)", type: type)
    }
    
    // MARK: Destiny 2 Parser Methods
    
    private func d2ParseAccountSummary(from data: Data) {
        let jsonData = JSON(data)
        // an account must have at least one character to be valid
        guard let recentCharacterId = jsonData["Response"]["profile"]["data"]["characterIds"][0].string else { returnError(with: "No Destiny 2 stats found for this Guardian"); return }
        // extract time played and light level from the most recent character
        if let lightLevel = jsonData["Response"]["characters"]["data"][recentCharacterId]["light"].number {
            self.lightLevel.value = String(describing: lightLevel)
        }
        if let minutesPlayed = jsonData["Response"]["characters"]["data"][recentCharacterId]["minutesPlayedTotal"].string {
            hoursPlayed.value = String(Int(minutesPlayed)! / 60)
        }
        // fetch inventory for the most recent character
        d2FetchInventorySummary(for: recentCharacterId)
        // fetch performance stats for all characters
        d2FetchAccountStats(for: d2AccountId!)
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
        guard let itemName = jsonData["Response"]["displayProperties"]["name"].string else { assertionFailure("stat not found"); return }
        guard let itemType = jsonData["Response"]["itemTypeDisplayName"].string else { assertionFailure("stat not found"); return }
        switch type {
        case .subclass:
            subclass.value = itemType.split(separator: " ").first! + " | " + itemName
        case .primary:
            primary.value = itemName + " | " + itemType
        case .special:
            special.value = itemName + " | " + itemType
        case .heavy:
            heavy.value = itemName + " | " + itemType
        default:
            return
        }
    }
    
    private func parseAccountStats(from data: Data) {
        let jsonData = JSON(data)
        if let kd = jsonData["Response"]["mergedAllCharacters"]["results"]["allPvP"]["allTime"]["killsDeathsRatio"]["basic"]["displayValue"].string {
            overallKD.value = "  \(kd)" //TODO UI issue with spacing
        } else {
            overallKD.value = "No KD Data"
        }
        if let kda = jsonData["Response"]["mergedAllCharacters"]["results"]["allPvP"]["allTime"]["killsDeathsAssists"]["basic"]["displayValue"].string {
            overallKDA.value = "  \(kda)"
        } else {
            overallKDA.value = "No KDA Data"
        }
        if let winLoss = jsonData["Response"]["mergedAllCharacters"]["results"]["allPvP"]["allTime"]["winLossRatio"]["basic"]["displayValue"].string {
            overallWinLossRatio.value = "  \(winLoss)"
        } else {
            overallWinLossRatio.value = "No W/L Data"
        }
        if let combatRating = jsonData["Response"]["mergedAllCharacters"]["results"]["allPvP"]["allTime"]["combatRating"]["basic"]["displayValue"].string {
            overallCombatRating.value = "  \(combatRating)"
            // stop loading state
            isLoading.value = false
            // analytics
            Flurry.endTimedEvent("Search_Time", withParameters: ["Type" : "Success - Account Stats"])
        } else {
            // analytics
            Flurry.logEvent("No PvP Data")
            overallCombatRating.value = "No CR Data"
            isLoading.value = false
            // analytics
            Flurry.endTimedEvent("Search_Time", withParameters: ["Type" : "Failure - Account Stats"])
        }
    }
    
    // MARK: Helper Methods
    
    // clears all existing character data
    private func returnError(with message: String) {
        // analytics
        let errorDetails = ["Error Message" : message]
        Flurry.logEvent("Search Error", withParameters: errorDetails)
        info.value = message
        isLoading.value = false
        // analytics
        Flurry.endTimedEvent("Search_Time", withParameters: ["Type" : "Failure - Error: \(message)"])
        subclass.value = ""
        lightLevel.value = ""
        primary.value = ""
        special.value = ""
        heavy.value = ""
        overallCombatRating.value = ""
        overallWinLossRatio.value = ""
        overallKD.value = ""
        overallKDA.value = ""
        hoursPlayed.value = ""
    }
}
