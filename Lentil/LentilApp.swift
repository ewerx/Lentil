//
//  LentilApp.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import SwiftUI
import ComposableArchitecture

@main
struct LentilApp: App {
  @State var isPresented = false
  
  var body: some Scene {
    WindowGroup {
      SettingsView(store: .init(initialState: .init(), reducer: Settings()))
//      RootView(
//        store: Store(
//          initialState: Root.State(
//            trendingState: .init()
//          ),
//          reducer: Root()
//        )
//      )
    }
  }
}
