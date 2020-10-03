//
//  BungieAPI.swift
//  Truth
//
//  Created by David Celentano on 10/1/20.
//  Copyright © 2020 David Celentano. All rights reserved.
//

import Foundation

class BungieAPI {
  
  let baseURLString = "http://www.bungie.net/Platform/Destiny"
  let secretKey: String
  let jsonDecoder = JSONDecoder.init()
  
  init() {
    // extract secret key
    var myDict: NSDictionary?
    if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
      myDict = NSDictionary(contentsOfFile: path)
    }
    if let dict = myDict {
      secretKey = dict.value(forKey: "API_key") as! String
    } else {
      secretKey = ""
      assertionFailure("No Secret Key!")
    }
  }
  
  // MARK: Destiny 2 API
  
  // MARK: Step 0: This method chains together various calls to perform a comprehensive player search
  func getAccount(username: String, platform: Platform, completion: @escaping (Account) -> Void) {
    // get the membership ID for future calls
    getMembershipId(username: username, platform: platform) { membershipId in
      // get character Ids from the account summary
      self.getAccountSummary(membershipId: membershipId!, platform: platform) { characterIds in
        // create an account with the fetched characters
        var characters: [Character] = []
        for characterId in characterIds ?? [] {
          let character = Character()
          character.characterId = characterId
          characters.append(character)
          self.getInventorySummary(character: character, membershipId: membershipId!, platform: platform) { success in
            if success {
              self.getCharacterStats(character: character, membershipId: membershipId!, platform: platform) { success in
                if success && characterId == characterIds?.last {
                  completion(Account(characters: characters))
                }
              }
            }
          }
        }
      }
    }
  }
  
  // MARK: Step 1: Use username to get membershipID, this is needed for any future calls
  private func getMembershipId(username: String,
                               platform: Platform,
                               completion: @escaping (String?) -> Void) {
    sendBungieRequest(path: "2/SearchDestinyPlayer/\(platform.rawValue)/\(username)/") { result in
      switch result {
      case .success(let data):
        let decodedData = try! self.jsonDecoder.decode(MembershipId.self, from: data)
        guard let membershipId = decodedData.response.first?.membershipId else {
          assertionFailure("no response?")
          return completion(nil)
        }
        completion(membershipId)
      case .failure(let error):
        assertionFailure("getMembershipId error \(error)")
        return completion(nil)
      }
    }
  }
  
  // MARK: Step 2: Use `membershipId` from step 1 to fetch a summary of the users account
  private func getAccountSummary(membershipId: String,
                                 platform: Platform,
                                 completion: @escaping ([String]?) -> Void) {
    sendBungieRequest(path: "2/\(platform.rawValue)/Profile/\(membershipId)/?components=100,200") { result in
      switch result {
      case .success(let data):
        let decodedData = try! self.jsonDecoder.decode(PlayerProfile.self, from: data)
        completion(decodedData.response.profile.data.characterIds)
      case .failure(let error):
        assertionFailure("getAccountSummary error \(error)")
        return completion(nil)
      }
    }
  }
  
  // MARK: Step 3: Use `characterId`s from Step 2 to fetch the inventory of each character
  private func getInventorySummary(character: Character,
                                   membershipId: String,
                                   platform: Platform,
                                   completion: @escaping (Bool) -> Void) {
    sendBungieRequest(path: "2/\(platform.rawValue)/Profile/\(membershipId)/character/\(character.characterId ?? "")/?components=205") { result in
      switch result {
      case .success(let data):
        let decodedData = try! self.jsonDecoder.decode(InventorySummary.self, from: data)
        self.decodeItemHashes(hashes: decodedData.response.equipment.data.items) { items in
          character.primaryWeapon = items[0].response.displayProperties.name
          character.specialWeaopn = items[1].response.displayProperties.name
          character.heavyWeapon = items[2].response.displayProperties.name
          character.characterClass = items[3].response.displayProperties.name
          completion(true)
        }
      case .failure(let error):
        assertionFailure("getInventorySummary error \(error)")
      }
    }
  }
  
  // MARK: Step 4: Decode a list of item hashes from Step 3 into Items
  private func decodeItemHashes(hashes: [InventoryItem], completion: @escaping ([Item]) -> Void) {
    var items: [Item] = []
    for hash in hashes {
      sendBungieRequest(path: "2/Manifest/DestinyInventoryItemDefinition/\(hash.itemHash)") { result in
        switch result {
        case .success(let data):
          let item = try! self.jsonDecoder.decode(Item.self, from: data)
          items.append(item)
          if hash == hashes.last {
            completion(items)
          }
        case .failure(let error):
          assertionFailure("decodeItemHashes error \(error)")
        }
      }
    }
  }
  
  // MARK: Step 5: Use `characterId`s from step 2 to fetch the stats of each character
  private func getCharacterStats(character: Character,
                                 membershipId: String,
                                 platform: Platform,
                                 completion: @escaping (Bool) -> Void) {
    sendBungieRequest(path: "2/\(platform.rawValue)/Account/\(membershipId)/Character/\(character.characterId ?? "")/Stats/") { result in
      switch result {
      case .success(let data):
        let stats = try! self.jsonDecoder.decode(RawStats.self, from: data)
        let allTimePvPStats = stats.response.allPvP.allTime
        character.bestWeaponType = allTimePvPStats.weaponBestType.basic.displayValue
        character.killDeath = allTimePvPStats.killsDeathsRatio.basic.displayValue
        character.killDeathAssist = allTimePvPStats.killsDeathsAssists.basic.displayValue
        character.combatRating = allTimePvPStats.combatRating.basic.displayValue
        character.winRatio = allTimePvPStats.winLossRatio.basic.displayValue
        completion(true)
      case .failure(let error):
        assertionFailure("getCharacterStats error \(error)")
      }
    }
  }
  
  // This is a generic function that works at the base of all requests made to bungie
  private func sendBungieRequest(path: String, completion: ((Result<Data, Error>) -> Void)?) {
    print(baseURLString + path)
    var urlRequest = URLRequest(url: URL(string: baseURLString + path)!)
    urlRequest.httpMethod = "GET"
    urlRequest.addValue(secretKey, forHTTPHeaderField: "X-API-Key")
    let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
      // if there is an error, display it and abort
      if let error = error {
        completion?(.failure(error))
        return
      }
      if let data = data {
        completion?(.success(data))
      }
    })
    task.resume()
  }
}
