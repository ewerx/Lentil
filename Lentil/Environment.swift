// Lentil
// Created by Laura and Cordt Zermin

import Foundation

class LentilEnvironment {
  let logLevel: LogLevel
  let baseUrl: String
  
  #if DEBUG
  let testWalletAddress: String
  #endif
  
  static let shared: LentilEnvironment = LentilEnvironment()
  
  private init() {
    #if DEBUG
    self.logLevel = LogLevel(rawValue: ProcessInfo.processInfo.environment["LOG_LEVEL"]!.lowercased())!
    self.baseUrl = ProcessInfo.processInfo.environment["BASE_URL"]!
    self.testWalletAddress = ProcessInfo.processInfo.environment["TEST_WALLET_ADDRESS"]!
    #else
    self.logLevel = .error
    self.baseUrl = "https://api.lens.dev"
    #endif
  }
}
