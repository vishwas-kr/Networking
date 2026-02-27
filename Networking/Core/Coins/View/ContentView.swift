//
//  ContentView.swift
//  Networking
//
//  Created by vishwas on 2/16/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = CoinsViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.coins) { coin in
                    HStack(spacing: 12){
                        Text("\(coin.marketCapRank)")
                            .foregroundStyle(.gray)
                        
                        VStack(alignment: .leading, spacing: 8){
                            Text(coin.name)
                                .fontWeight(.semibold)
                            Text("\(coin.currentPrice)")
                        }
                    }
                    .font(.footnote)
                }
            }
            .overlay{
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
