// LentilTests
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import XCTest
@testable import Lentil

@MainActor
final class PostTests: XCTestCase {
  
  override func setUpWithError() throws {}
  override func tearDownWithError() throws {}
  
  func testUserNeedsToConfirmMirroring() async throws {
    let publication = MockData.mockPublications[0]
    let mirrorResult: MutationResult<Result<RelayerResult, RelayErrorReasons>> = MutationResult(data: .success(.init(txnHash: "abc", txnId: "123")))
    let store = TestStore(
      initialState: Post.State(
        navigationId: "abc-def",
        post: .init(publication: publication),
        typename: .post
      ),
      reducer: Post()
    )
    
    store.dependencies.lensApi.createMirror = { _, _ in mirrorResult }
    store.dependencies.profileStorageApi.load = { MockData.mockUserProfile }
    
    await store.send(.post(action: .mirrorTapped)) {
      $0.post.mirrorConfirmationDialogue = .init(
        profileHandle: publication.profile.handle,
        action: .mirrorConfirmationConfirmed
      )
    }
    
    await store.send(.post(action: .mirrorConfirmationConfirmed))
    await store.receive(.post(action: .mirrorResult(.success(mirrorResult))))
    await store.receive(.post(action: .mirrorSuccess("abc")))
  }
}
