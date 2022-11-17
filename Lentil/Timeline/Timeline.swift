// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture


struct Timeline: ReducerProtocol {
  struct State: Equatable {
    var userProfile: UserProfile? = nil
    var posts: IdentifiedArrayOf<Post.State> = []
    var cursorPublications: String?
    var cursorExplore: String?
    
    var walletConnect: Wallet.State = .init()
  }
  
  enum Action: Equatable {
    enum ResponseType: Equatable {
      case explore, personal
    }
    case timelineAppeared
    case refreshFeed
    case fetchPublications
    case publicationsResponse(QueryResult<[Model.Publication]>, ResponseType)
    case loadMore
    
    case walletConnect(Wallet.Action)
    case post(id: Post.State.ID, action: Post.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.walletConnect, action: /Action.walletConnect) {
        Wallet()
      }
    
    Reduce { state, action in
      enum CancelFetchPublicationsID {}
      
      switch action {
        case .timelineAppeared:
          state.userProfile = profileStorageApi.load()
          return Effect(value: .refreshFeed)
          
        case .refreshFeed:
          state.cursorPublications = nil
          return .concatenate(
            .cancel(id: CancelFetchPublicationsID.self),
            .init(value: .fetchPublications)
          )
          
        case .fetchPublications:
          if let userProfile = state.userProfile {
            return .run { [cursorPublications = state.cursorPublications, cursorExplore = state.cursorExplore, id = userProfile.id] send in
              try await send(.publicationsResponse(lensApi.publications(40, cursorPublications, id, [.post], id), .personal))
              try await send(.publicationsResponse(lensApi.trendingPublications(40, cursorExplore, .topCommented, [.post], id), .explore))
            }
            .cancellable(id: CancelFetchPublicationsID.self)
          }
          else {
            return .run { [cursor = state.cursorExplore, id = state.userProfile?.id] send in
              try await send(.publicationsResponse(lensApi.trendingPublications(50, cursor, .topCommented, [.post], id), .explore))
            }
            .cancellable(id: CancelFetchPublicationsID.self)
          }
          
        case .loadMore:
          return .concatenate(
            .cancel(id: CancelFetchPublicationsID.self),
            .init(value: .fetchPublications)
          )
          
        case .publicationsResponse(let response, let responseType):
          response.data
            .filter { $0.typename == .post }
            .map { Post.State(post: .init(publication: $0)) }
            .forEach { postState in
              if let index = state.posts.firstIndex(where: { $0.post.publication.createdAt < postState.post.publication.createdAt }) {
                state.posts.updateOrInsert(postState, at: index)
              }
              else {
                state.posts.updateOrAppend(postState)
              }
            }
          
          switch responseType {
            case .explore:
              state.cursorExplore = response.cursorToNext
            case .personal:
              state.cursorPublications = response.cursorToNext
          }
          return .none
          
        case .walletConnect:
          return .none
          
        case .post:
          return .none
      }
    }
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
  }
}
