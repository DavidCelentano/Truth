//
//  BungieAPI.swift
//  Truth
//
//  Created by David Celentano on 10/1/20.
//  Copyright © 2020 David Celentano. All rights reserved.
//

import Foundation

class BungieAPI {
  
  let baseURL = URL(string: "http://www.bungie.net/Platform/Destiny")
  let secretKey: String
  
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
  
  // MARK: Step 1: Use username to get membershipID, this is needed for any future calls
  func getMembershipID(username: String, platform: Platform, completion: @escaping (String?) -> Void) {
    sendBungieRequest(path: "/SearchDestinyPlayer/\(platform.rawValue)/\(username)/") { result in
      switch result {
      case .success(let data):
        let decodedData = try! JSONDecoder.init().decode(MembershipID.self, from: data)
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
  
  private func sendBungieRequest(path: String, completion: ((Result<Data, Error>) -> Void)?) {
    var urlRequest = URLRequest(url: baseURL!.appendingPathComponent(path))
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
