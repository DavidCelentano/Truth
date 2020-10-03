//
//  SearchView.swift
//  Truth
//
//  Created by David Celentano on 10/1/20.
//  Copyright © 2020 David Celentano. All rights reserved.
//

import SwiftUI

struct SearchView: View {
  private let bungieAPI = BungieAPI()
  @State private var username = "Hurk"
  @State private var account = Account(characters: [])
  
    var body: some View {
      VStack {
        TextField("Username", text: $username)
          .frame(width: 150, height: 30, alignment: .center)
        Button("Search") {
          bungieAPI.getAccount(username: username, platform: .xbox) { account in
            self.account = account
            print(account.characters.first?.specialWeaopn)
          }
        }
      }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
