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
      RootView(
        store: Store(
          initialState: RootState(
            timelineState: .init(),
            trendingState: .init(),
            settingsState: .init()
          ),
          reducer: rootReducer,
          environment: RootEnvironment(lensApi: .live)
        )
      )
    }
  }
}
