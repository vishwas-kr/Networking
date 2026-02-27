//
//  Untitled.swift
//  Networking
//
//  Created by vishwas on 2/16/26.
//

import Foundation

struct CoinService {
    
    private let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=bitcoin&names=Bitcoin&symbols=btc&category=layer-1&price_change_percentage=1h"
    
    //MARK: Async/Await approach much cleaner
    
    func fetchCoins() async throws -> [Coin] {
        
        guard let url = URL(string : urlString) else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let coins = try JSONDecoder().decode([Coin].self, from: data)
            return coins
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}

extension CoinService {
    
    //MARK: With Completion Handlers
    
    func fetchCoinsWithResult(completion: @escaping(Result<[Coin], CoinApiError>) -> Void) {
        guard let url = URL(string:urlString) else {return}
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            
            if let error = error {
                completion(.failure(.unkownError(error: error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed(description: "Request failed")))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(.invalidStatusCode(statusCode: response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return }
            
            do {
                let coins = try JSONDecoder().decode([Coin].self,from: data)
                completion(.success(coins))
            } catch {
                print(error)
                completion(.failure(.jsonParsingFailure))
            }
        }.resume()
    }
    
    
    func fetchCoinsWithCompletion(completion: @escaping([Coin]?, Error?) -> Void) {
        guard let url = URL(string:urlString) else {return}
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else { return }
            
            do {
                let coins = try JSONDecoder().decode([Coin].self,from: data)
                completion(coins, nil)
            } catch {
                print(error)
                completion(nil, error)
            }
        }.resume()
    }
    
    
    
    func fetchPrice(coin:String, completion: @escaping(Double)->Void) {
        let urlString = "https://api.coingecko.com/api/v3/simple/price?vs_currencies=usd&ids=\(coin)"
        
        
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print("DEBUG:: Something went wrong : \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            guard httpResponse.statusCode == 200 else { return }
            
            guard let data = data else {return}
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String : Any] else {return}
            print(jsonObject)
            guard let value = jsonObject[coin] as? [String : CGFloat] else {return}
            guard let price = value["usd"] else {return}
            
            completion(price)
            
        }.resume()
    }
}
