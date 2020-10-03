//
//  Item.swift
//  Truth
//
//  Created by David Celentano on 10/3/20.
//  Copyright © 2020 David Celentano. All rights reserved.
//

import Foundation

struct Item: Codable {
  let response: ItemResponse
  
  enum CodingKeys : String, CodingKey {
    case response = "Response"
  }
}

struct ItemResponse: Codable {
  let displayProperties: ItemDisplayProperties
  let itemTypeDisplayName: String
  
  enum CodingKeys : String, CodingKey {
    case displayProperties
    case itemTypeDisplayName
  }
}

struct ItemDisplayProperties: Codable {
  let name: String
  
  enum CodingKeys : String, CodingKey {
    case name
  }
}
