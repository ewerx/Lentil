// Lentil
// Created by Laura and Cordt Zermin

import Foundation

extension Model.Publication {
  private static func postFrom(
    postFields: PostFields,
    content: String,
    createdDate: Date,
    profilePictureUrl: URL,
    upvotedByUser: Bool,
    collectdByUser: Bool,
    commentdByUser: Bool,
    mirrordByUser: Bool
  ) -> Self? {
    return Model.Publication(
      id: postFields.id,
      typename: .post,
      createdAt: createdDate,
      content: content,
      profile: Model.Profile.from(postFields.profile.fragments.profileFields),
      upvotes: postFields.stats.fragments.publicationStatsFields.totalUpvotes,
      collects: postFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: postFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: postFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors,
      upvotedByUser: upvotedByUser,
      collectdByUser: collectdByUser,
      commentdByUser: commentdByUser,
      mirrordByUser: mirrordByUser,
      media: Model.Media.media(from: postFields.metadata.fragments.metadataOutputFields.media)
    )
  }
  
  private static func commentFrom(
    commentFields: CommentBaseFields,
    child of: Model.Publication?,
    content: String,
    createdDate: Date,
    profilePictureUrl: URL,
    upvotedByUser: Bool,
    collectdByUser: Bool,
    commentdByUser: Bool,
    mirrordByUser: Bool
  ) -> Self? {
    return Model.Publication(
      id: commentFields.id,
      typename: .comment(of: of),
      createdAt: createdDate,
      content: content,
      profile: Model.Profile.from(commentFields.profile.fragments.profileFields),
      upvotes: commentFields.stats.fragments.publicationStatsFields.totalUpvotes,
      collects: commentFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: commentFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: commentFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors,
      upvotedByUser: upvotedByUser,
      collectdByUser: collectdByUser,
      commentdByUser: commentdByUser,
      mirrordByUser: mirrordByUser,
      media: Model.Media.media(from: commentFields.metadata.fragments.metadataOutputFields.media)
    )
  }
  
  private static func mirrorFrom(
    mirrorFields: MirrorBaseFields,
    mirror of: Model.Publication?,
    content: String,
    createdDate: Date,
    profilePictureUrl: URL,
    upvotedByUser: Bool,
    collectdByUser: Bool,
    commentdByUser: Bool,
    mirrordByUser: Bool
  ) -> Self? {
    return Model.Publication(
      id: mirrorFields.id,
      typename: .mirror(of: of),
      createdAt: createdDate,
      content: content,
      profile: Model.Profile.from(mirrorFields.profile.fragments.profileFields),
      upvotes: mirrorFields.stats.fragments.publicationStatsFields.totalUpvotes,
      collects: mirrorFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: mirrorFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: mirrorFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors,
      upvotedByUser: upvotedByUser,
      collectdByUser: collectdByUser,
      commentdByUser: commentdByUser,
      mirrordByUser: mirrordByUser,
      media: Model.Media.media(from: mirrorFields.metadata.fragments.metadataOutputFields.media)
    )
  }
  
  private static func publication(from post: PostFields, reaction: ReactionTypes?) -> Self? {
    guard
      let content = post.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: post.createdAt),
      let profilePictureUrlString = post.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://infura-ipfs.io/ipfs/"))
    else { return nil }
    
    return postFrom(
      postFields: post,
      content: content,
      createdDate: createdDate,
      profilePictureUrl: profilePictureUrl,
      upvotedByUser: reaction == .upvote,
      collectdByUser: post.hasCollectedByMe,
      commentdByUser: false,
      mirrordByUser: false
    )
  }
  
  private static func publication(from comment: CommentFields, reaction: ReactionTypes?, child of: Model.Publication? = nil) -> Self? {
    guard
      let content = comment.fragments.commentBaseFields.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: comment.fragments.commentBaseFields.createdAt),
      let profilePictureUrlString = comment.fragments.commentBaseFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://infura-ipfs.io/ipfs/"))
    else { return nil }
    
    // If no parent is passed explicitly, check whether the query data contains one
    var parent: Model.Publication? = of
    if parent == nil, let parentPost = comment.mainPost.asPost {
      parent = publication(from: parentPost.fragments.postFields, reaction: parentPost.postReaction)
    }
    
    return commentFrom(
      commentFields: comment.fragments.commentBaseFields,
      child: parent,
      content: content,
      createdDate: createdDate,
      profilePictureUrl: profilePictureUrl,
      upvotedByUser: reaction == .upvote,
      collectdByUser: comment.fragments.commentBaseFields.hasCollectedByMe,
      commentdByUser: false,
      mirrordByUser: false
    )
  }
  
  private static func publication(from mirror: MirrorFields, reaction: ReactionTypes?, mirror of: Model.Publication? = nil) -> Self? {
    guard
      let content = mirror.fragments.mirrorBaseFields.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: mirror.fragments.mirrorBaseFields.createdAt),
      let profilePictureUrlString = mirror.fragments.mirrorBaseFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://infura-ipfs.io/ipfs/"))
    else { return nil }
    
    // If no parent is passed explicitly, check whether the query data contains one
    var parent: Model.Publication? = of
    if parent == nil, let parentPost = mirror.mirrorOf.asPost {
      parent = publication(from: parentPost.fragments.postFields, reaction: nil)
    }
    else if parent == nil, let parentComment = mirror.mirrorOf.asComment {
      parent = publication(from: parentComment.fragments.commentFields, reaction: nil)
    }
    
    return mirrorFrom(
      mirrorFields: mirror.fragments.mirrorBaseFields,
      mirror: parent,
      content: content,
      createdDate: createdDate,
      profilePictureUrl: profilePictureUrl,
      upvotedByUser: reaction == .upvote,
      collectdByUser: mirror.fragments.mirrorBaseFields.hasCollectedByMe,
      commentdByUser: false,
      mirrordByUser: false
    )
  }
  
  private static func publication(from comment: CommentBaseFields) -> Self? {
    guard
      let content = comment.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: comment.createdAt),
      let profilePictureUrlString = comment.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://infura-ipfs.io/ipfs/"))
    else { return nil }
    
    return commentFrom(
      commentFields: comment,
      child: nil,
      content: content,
      createdDate: createdDate,
      profilePictureUrl: profilePictureUrl,
      upvotedByUser: false,
      collectdByUser: comment.hasCollectedByMe,
      commentdByUser: false,
      mirrordByUser: false
    )
  }
  
  private static func publication(from mirror: MirrorBaseFields) -> Self? {
    guard
      let content = mirror.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: mirror.createdAt),
      let profilePictureUrlString = mirror.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://infura-ipfs.io/ipfs/"))
    else { return nil }
    
    return mirrorFrom(
      mirrorFields: mirror,
      mirror: nil,
      content: content,
      createdDate: createdDate,
      profilePictureUrl: profilePictureUrl,
      upvotedByUser: false,
      collectdByUser: mirror.hasCollectedByMe,
      commentdByUser: false,
      mirrordByUser: false
    )
  }
  
  static func publication(from item: FeedQuery.Data.Feed.Item.Root, child of: Model.Publication? = nil) -> Self? {
    if let postFields = item.asPost?.fragments.postFields {
      return publication(from: postFields, reaction: item.asPost?.postReaction)
    }
    else if let commentFields = item.asComment?.fragments.commentFields {
      return publication(from: commentFields, reaction: item.asComment?.commentReaction, child: of)
    }
    // FIXME: Include Mirrors from Feed Endpoint
    else {
      return nil
    }
  }
  
  static func publication(from item: PublicationQuery.Data.Publication?) -> Self? {
    if let postFields = item?.asPost?.fragments.postFields {
      return publication(from: postFields, reaction: nil)
    }
    else if let commentBaseFields = item?.asComment?.fragments.commentBaseFields {
      return publication(from: commentBaseFields)
    }
    else if let mirrorBaseFields = item?.asMirror?.fragments.mirrorBaseFields {
      return publication(from: mirrorBaseFields)
    }
    else {
      return nil
    }
  }
  
  static func publication(from item: PublicationsQuery.Data.Publication.Item, child of: Model.Publication? = nil) -> Self? {
    if let postFields = item.asPost?.fragments.postFields {
      return publication(from: postFields, reaction: item.asPost?.postReaction)
    }
    else if let commentFields = item.asComment?.fragments.commentFields {
      return publication(from: commentFields, reaction: item.asComment?.commentReaction, child: of)
    }
    else if let mirrorFields = item.asMirror?.fragments.mirrorFields {
      return publication(from: mirrorFields, reaction: item.asMirror?.mirrorReaction, mirror: of)
    }
    else {
      return nil
    }
  }
  
  static func publication(from item: ExplorePublicationsQuery.Data.ExplorePublication.Item, child of: Model.Publication? = nil) -> Self? {
    if let postFields = item.asPost?.fragments.postFields {
      return publication(from: postFields, reaction: item.asPost?.postReaction)
    }
    else if let commentFields = item.asComment?.fragments.commentFields {
      return publication(from: commentFields, reaction: item.asComment?.commentReaction, child: of)
    }
    else if let mirrorFields = item.asMirror?.fragments.mirrorFields {
      return publication(from: mirrorFields, reaction: item.asMirror?.mirrorReaction, mirror: of)
    }
    else {
      return nil
    }
  }
}
