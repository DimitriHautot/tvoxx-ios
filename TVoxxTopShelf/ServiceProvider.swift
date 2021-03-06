//
//  ServiceProvider.swift
//  TVoxxTopShelf
//
//  Created by Sebastien Arbogast on 14/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import Foundation
import TVServices

class ServiceProvider: NSObject, TVTopShelfProvider {
    var topTalks:[TVContentItem]?
    var watchlistTalks:[TVContentItem]?

    override init() {
        super.init()
    }

    // MARK: - TVTopShelfProvider protocol

    var topShelfStyle: TVTopShelfContentStyle {
        return .Sectioned
    }

    var topShelfItems: [TVContentItem] {
        let semaphore = dispatch_semaphore_create(0)
        
        TVoxxServer.sharedServer.getTopTalks { (talks:[TalkListItem]) -> Void in
            self.topTalks = talks.map({ (talk:TalkListItem) -> TVContentItem in
                guard let contentIdentifier = TVContentIdentifier(identifier: talk.talkId, container: nil) else {
                    fatalError("Error creating content identifier.")
                }
                guard let contentItem = TVContentItem(contentIdentifier: contentIdentifier) else {
                    fatalError("Error creating content item.")
                }
                
                contentItem.title = talk.title
                contentItem.displayURL = NSURL(string:"tvoxx://talks/\(talk.talkId)")
                contentItem.playURL = NSURL(string: "tvoxx://talks/\(talk.talkId)/play")
                contentItem.imageURL = NSURL(string: talk.thumbnailUrl)
                contentItem.imageShape = TVContentItemImageShape.HDTV
                
                return contentItem
            })
            
            WatchList.sharedWatchList.moviesInWatchList({ (talks:[TalkListItem]?, error:WatchListError?) in
                if let talks = talks where talks.count > 0 {
                    self.watchlistTalks = talks.map({ (talk:TalkListItem) -> TVContentItem in
                        guard let contentIdentifier = TVContentIdentifier(identifier: talk.talkId, container: nil) else {
                            fatalError("Error creating content identifier.")
                        }
                        guard let contentItem = TVContentItem(contentIdentifier: contentIdentifier) else {
                            fatalError("Error creating content item.")
                        }
                        
                        contentItem.title = talk.title
                        contentItem.displayURL = NSURL(string:"tvoxx://talks/\(talk.talkId)")
                        contentItem.playURL = NSURL(string: "tvoxx://talks/\(talk.talkId)/play")
                        contentItem.imageURL = NSURL(string: talk.thumbnailUrl)
                        contentItem.imageShape = TVContentItemImageShape.HDTV
                        
                        return contentItem
                    })
                } else {
                    if let error = error {
                        switch error {
                        case .NotAuthenticated: print("You need to sign in to CloudKit in order to use the watch list feature")
                        case .BackendError(let rootCause): print("CloudKit error: " + rootCause.debugDescription)
                        }
                    }
                    self.watchlistTalks = [TVContentItem]()
                }
                
                dispatch_semaphore_signal(semaphore)
            })
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        var items = [TVContentItem]()
        if let watchlistTalks = self.watchlistTalks where watchlistTalks.count > 0 {
            guard let contentIdentifier = TVContentIdentifier(identifier: "watchlist", container: nil) else {
                fatalError("Error creating content identifier.")
            }
            guard let contentItem = TVContentItem(contentIdentifier: contentIdentifier) else {
                fatalError("Error creating content item.")
            }
            
            contentItem.title = NSLocalizedString("Watchlist", comment:"")
            contentItem.topShelfItems = watchlistTalks
            items.append(contentItem)
        }
        if let topTalks = self.topTalks where topTalks.count > 0 {
            guard let contentIdentifier = TVContentIdentifier(identifier: "top", container: nil) else {
                fatalError("Error creating content identifier.")
            }
            guard let contentItem = TVContentItem(contentIdentifier: contentIdentifier) else {
                fatalError("Error creating content item.")
            }
            
            contentItem.title = NSLocalizedString("Top Talks", comment:"")
            contentItem.topShelfItems = topTalks
            items.append(contentItem)
        }
        
        return items
    }

}

