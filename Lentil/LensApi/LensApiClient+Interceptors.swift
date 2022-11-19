// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import Dependencies
import Foundation


class NetworkInterceptorProvider: DefaultInterceptorProvider {
  enum InterceptorSetup {
    case tokenAdding, requestLogging
    
    func interceptor() -> any ApolloInterceptor {
      switch self {
        case .tokenAdding:
          return TokenAddingInterceptor()
        case .requestLogging:
          return RequestLoggingInterceptor()
      }
    }
  }
  
  let setup: [InterceptorSetup]
  
  init(
    client: URLSessionClient = URLSessionClient(),
    store: ApolloStore,
    setup: [InterceptorSetup] = [.requestLogging]
  ) {
    self.setup = setup
    super.init(client: client, store: store)
  }
  
  override func interceptors<Operation>(
    for operation: Operation
  ) -> [ApolloInterceptor] where Operation : GraphQLOperation {
    var interceptors = super.interceptors(for: operation)
    // Always add origin
    interceptors.insert(OriginHeaderInterceptor(), at: 0)
    
    for setupItem in self.setup.enumerated() {
      interceptors.insert(setupItem.element.interceptor(), at: setupItem.offset + 1)
    }
    
    return interceptors
  }
}

class OriginHeaderInterceptor: ApolloInterceptor {
  func interceptAsync<Operation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) where Operation : GraphQLOperation {
      
      request.addHeader(name: "Origin", value: LentilEnvironment.shared.origin)
      
      chain.proceedAsync(
        request: request,
        response: response,
        completion: completion
      )
  }
}

class TokenAddingInterceptor: ApolloInterceptor {
  @Dependency(\.authTokenApi) var authTokenApi
  
  func interceptAsync<Operation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) where Operation : GraphQLOperation {
      do {
        let accessToken = try authTokenApi.load(.access)
        request.addHeader(
          name: "x-access-token",
          value: accessToken
        )
        chain.proceedAsync(
          request: request,
          response: response,
          completion: completion
        )
      }
      catch let storageError {
        log("No access token available, cannot add authentication to request", level: .error, error: storageError)
        chain.cancel()
      }
  }
}

class RequestLoggingInterceptor: ApolloInterceptor {
  func interceptAsync<Operation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) where Operation : GraphQLOperation {
      let requestUrl = try? request.toURLRequest().url?.absoluteString.removingPercentEncoding
      let requestVariables = request.operation.variables
      let requestHeaders = request.additionalHeaders.reduce("") { current, next in
        current + "\tKey:\t\t\(next.key)\n\tValue:\t\(next.value)\n"
      }
      
      var logMessage = "Running GraphQL operation:"
      logMessage += "\nOperation:\t\(request.operation.operationName)"
      if let requestUrl { logMessage += "\nURL:\t\t\t\t\(requestUrl)" }
      if let requestVariables { logMessage += "\nVariables:\t\(requestVariables)" }
      if request.additionalHeaders.count > 0 { logMessage += "\nHeaders:\n\(requestHeaders)" }
      log(logMessage, level: .info)
      
      chain.proceedAsync(
        request: request,
        response: response,
        completion: completion
      )
  }
}
