//
//  InventorySummary.swift
//  Truth
//
//  Created by David Celentano on 10/3/20.
//  Copyright © 2020 David Celentano. All rights reserved.
//

import Foundation

struct InventorySummary: Codable {
  let response: InventoryResponse
  
  enum CodingKeys : String, CodingKey {
    case response = "Response"
  }
}

struct InventoryResponse: Codable {
  let equipment: InventoryEquipment
  
  enum CodingKeys : String, CodingKey {
    case equipment
  }
}

struct InventoryEquipment: Codable {
  let data: InventoryData
  
  enum CodingKeys : String, CodingKey {
    case data
  }
}

struct InventoryData: Codable {
  let items: [InventoryItem]
  
  enum CodingKeys : String, CodingKey {
    case items
  }
}

struct InventoryItem: Codable, Equatable {
  let itemHash: Int
  
  enum CodingKeys : String, CodingKey {
    case itemHash
  }
}
