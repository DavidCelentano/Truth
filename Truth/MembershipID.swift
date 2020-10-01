//
//  MembershipID.swift
//  Truth
//
//  Created by David Celentano on 10/1/20.
//  Copyright © 2020 David Celentano. All rights reserved.
//

import Foundation

struct MembershipID: Codable {
  let response: [Response]
  
  enum CodingKeys : String, CodingKey {
    case response = "Response"
  }
}

struct Response: Codable {
  let membershipId: String
  
  enum CodingKeys : String, CodingKey {
    case membershipId = "membershipId"
  }
}
