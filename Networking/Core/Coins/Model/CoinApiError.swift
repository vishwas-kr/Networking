//
//  CoinApiError.swift
//  Networking
//
//  Created by vishwas on 2/27/26.
//

import Foundation

enum CoinApiError : Error {
    case invalidData
    case jsonParsingFailure
    case requestFailed(description:String)
    case invalidStatusCode(statusCode: Int)
    case unkownError(error:Error)
    
    var customDescription : String {
        switch self {
        case .invalidData: return "Invalid Data"
        case .jsonParsingFailure: return "Falied to parse JSON"
        case let .requestFailed(description) : return "Request Failed : \(description)"
        case let .invalidStatusCode(statusCode) : return "Invalid Status Code : \(statusCode)"
        case let .unkownError(error) : return "Unkown Error : \(error)"
        }
    }
}
