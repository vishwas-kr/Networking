//
//  CoinsViewModel.swift
//  Networking
//
//  Created by vishwas on 2/16/26.
//

import Foundation
import Combine

class CoinsViewModel: ObservableObject {
    
    @Published var coins = [Coin]()
    @Published var errorMessage : String?
    private let service = CoinService()
    
    init(){
        fetchPrice(coin: "ethereum")
        fetchCoins()
    }
    
    
    func fetchCoins(){
        service.fetchCoins { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coins) : self?.coins = coins
                case .failure(let error) : self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchPrice(coin: String){
        service.fetchPrice(coin: coin) { price in
            DispatchQueue.main.async {
                
            }
        }
    }
}
