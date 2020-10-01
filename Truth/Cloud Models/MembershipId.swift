//
//  MembershipID.swift
//  Truth
//
//  Created by David Celentano on 10/1/20.
//  Copyright © 2020 David Celentano. All rights reserved.
//

import Foundation

struct MembershipId: Codable {
  let response: [MembershipResponse]
  
  enum CodingKeys : String, CodingKey {
    case response = "Response"
  }
}

struct MembershipResponse: Codable {
  let membershipId: String
  
  enum CodingKeys : String, CodingKey {
    case membershipId = "membershipId"
  }
}
