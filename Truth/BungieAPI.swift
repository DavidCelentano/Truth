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
    getMembershipId(username: username, platform: platform) { membershipId in
      self.getAccountSummary(membershipId: membershipId!, platform: platform) { characterIds in
        completion(Account(characterIds: characterIds!))
      }
    }
  }
  
  // MARK: Step 1: Use username to get membershipID, this is needed for any future calls
  private func getMembershipId(username: String, platform: Platform, completion: @escaping (String?) -> Void) {
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
        assertionFailure("error \(error)")
        return completion(nil)
      }
    }
  }
  
  // MARK: Step 2: Use `membershipId` from step 1 to fetch a summary of the users account
  private func getAccountSummary(membershipId: String, platform: Platform, completion: @escaping ([String]?) -> Void) {
    sendBungieRequest(path: "2/\(platform.rawValue)/Profile/\(membershipId)/?components=100,200") { result in
      switch result {
      case .success(let data):
        let decodedData = try! self.jsonDecoder.decode(PlayerProfile.self, from: data)
        completion(decodedData.response.profile.data.characterIds)
      case .failure(let error):
        assertionFailure("error \(error)")
        return completion(nil)
      }
    }
  }
  
  // This is a generic function that works at the base of all requests made to bungie
  private func sendBungieRequest(path: String, completion: ((Result<Data, Error>) -> Void)?) {
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
