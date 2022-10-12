// Lentil

import ComposableArchitecture
import SwiftUI


struct CommentView: View {
  let store: Store<Comment.State, Comment.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading, spacing: 8) {
        PostHeaderView(
          store: self.store.scope(
            state: \.comment,
            action: Comment.Action.comment
          )
        )
        
        VStack(alignment: .leading, spacing: 8) {
          HStack(alignment: .top, spacing: 16) {
            PostVotingView(
              store: self.store.scope(
                state: \.comment,
                action: Comment.Action.comment
              )
            )
            .padding(.leading, 8)
              
            Text(viewStore.comment.shortenedContent)
              .font(.subheadline)
          }
          
          PostStatsShortDetailView(
            store: self.store.scope(
              state: \.comment,
              action: Comment.Action.comment
            )
          )
          .padding(.leading, 42)
        }
      }
      .padding([.leading, .trailing])
    }
  }
}

struct CommentView_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 16) {
      CommentView(
        store: .init(
          initialState: .init(comment: .init(publication: mockComments[0])),
          reducer: Comment()
        )
      )
      CommentView(
        store: .init(
          initialState: .init(comment: .init(publication: mockComments[0])),
          reducer: Comment()
        )
      )
      CommentView(
        store: .init(
          initialState: .init(comment: .init(publication: mockComments[0])),
          reducer: Comment()
        )
      )
      Spacer()
    }
  }
}
