//
//  Coin.swift
//  Networking
//
//  Created by vishwas on 2/27/26.
//
import Foundation

struct Coin : Codable , Identifiable{
    let id : String
    let symbol : String
    let name : String
    let currentPrice : Double
    let marketCapRank : Int?
    
    private enum CodingKeys: String, CodingKey {
        case id, symbol, name
        case currentPrice = "current_price"
        case marketCapRank = "market_cap_rank"
    }
}
