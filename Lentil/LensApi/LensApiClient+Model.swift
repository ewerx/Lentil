// Lentil

import Foundation

extension Model.Publication {
  static func from(_ item: ExplorePublicationsQuery.Data.ExplorePublication.Item) -> Self? {
    guard
      let postFields = item.asPost?.fragments.postFields,
      let content = postFields.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: postFields.createdAt),
      let profilePictureUrlString = postFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString)
    else { return nil }
    
    return Model.Publication(
      id: postFields.id,
      typename: .post,
      createdAt: createdDate,
      content: content,
      profileName: postFields.profile.fragments.profileFields.name,
      profileHandle: postFields.profile.fragments.profileFields.handle,
      profilePictureUrl: profilePictureUrl,
      upvotes: postFields.stats.fragments.publicationStatsFields.totalUpvotes,
      downvotes: postFields.stats.fragments.publicationStatsFields.totalDownvotes,
      collects: postFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: postFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: postFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors
    )
  }
  
  static func from(_ item: PublicationsQuery.Data.Publication.Item, child of: Model.Publication) -> Self? {
    guard
      let commentFields = item.asComment?.fragments.commentFields.fragments.commentBaseFields,
      let content = commentFields.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: commentFields.createdAt),
      let profilePictureUrlString = commentFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString)
    else { return nil }
    
    return Model.Publication(
      id: commentFields.id,
      typename: .comment(of: of),
      createdAt: createdDate,
      content: content,
      profileName: commentFields.profile.fragments.profileFields.name,
      profileHandle: commentFields.profile.fragments.profileFields.handle,
      profilePictureUrl: profilePictureUrl,
      upvotes: commentFields.stats.fragments.publicationStatsFields.totalUpvotes,
      downvotes: commentFields.stats.fragments.publicationStatsFields.totalDownvotes,
      collects: commentFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: commentFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: commentFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors
    )
  }
}

extension Model.Profile {
  static func from(_ profile: DefaultProfileQuery.Data.DefaultProfile?) -> Self? {
    guard
      let profile = profile?.fragments.profileFields,
      profile.isDefault,
      let profilePictureURL = profile.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let url = URL(string: profilePictureURL)
    else { return nil }
    
    return Model.Profile(
      id: profile.id,
      name: profile.name,
      handle: profile.handle,
      ownedBy: profile.ownedBy,
      isFollowedByMe: false,
      profilePictureUrl: url,
      isDefault: profile.isDefault
    )
  }
  
  static func from(_ profiles: ProfilesQuery.Data.Profile) -> [Self] {
    return profiles.items.map { profile in
      let fields = profile.fragments.profileFields
      var url: URL? = nil
      if let urlString = fields.picture?.asMediaSet?.original.fragments.mediaFields.url { url = URL(string: urlString) }
      
      return Model.Profile(
        id: fields.id,
        name: fields.name,
        handle: fields.handle,
        ownedBy: fields.ownedBy,
        isFollowedByMe: false,
        profilePictureUrl: url,
        isDefault: fields.isDefault
      )
    }
  }
}
