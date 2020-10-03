//
//  RawStats.swift
//  Truth
//
//  Created by David Celentano on 10/3/20.
//  Copyright © 2020 David Celentano. All rights reserved.
//

import Foundation

struct RawStats: Codable {
  let response: StatsResponse
  
  enum CodingKeys : String, CodingKey {
    case response = "Response"
  }
}

struct StatsResponse: Codable {
  let allPvP: AllPvPStats
}

struct AllPvPStats: Codable {
  let allTime: AllTimePvPStats
}

struct AllTimePvPStats: Codable {
  let winLossRatio: RawStat
  let killsDeathsRatio: RawStat
  let killsDeathsAssists: RawStat
  let weaponBestType: RawStat
  let combatRating: RawStat
}

struct RawStat: Codable {
  let basic: BasicStat
}

struct BasicStat: Codable {
  let displayValue: String
}
