//
//  PlayerProfile.swift
//  Truth
//
//  Created by David Celentano on 10/1/20.
//  Copyright © 2020 David Celentano. All rights reserved.
//

import Foundation

struct PlayerProfile: Codable {
  let response: ProfileResponse
  
  enum CodingKeys : String, CodingKey {
    case response = "Response"
  }
}

struct ProfileResponse: Codable {
  let profile: Profile
  
  enum CodingKeys : String, CodingKey {
    case profile
  }
}

struct Profile: Codable {
  let data: ProfileData
  
  enum CodingKeys : String, CodingKey {
    case data
  }
}

struct ProfileData: Codable {
  let characterIds: [String]
  
  enum CodingKeys : String, CodingKey {
    case characterIds
  }
}
