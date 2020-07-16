//
//  Deal.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import Foundation

struct Deal: Codable {
    var id: String 
    var features: String
    var items: [Item] = []
    var photos: [URL] = []
    var soldOut: String?
    var specifications: String
    var story: Story
    var theme: Theme
    var title: String
    var topic: Topic?
    var url: URL
    var date: Date?
}

struct PreviousDeal: Codable {
    var flavorText: String
    var hasViewed: Bool
    var hasVoted: Bool
    var id: String
    var title: String
    var url: String
    var photo: String
}
