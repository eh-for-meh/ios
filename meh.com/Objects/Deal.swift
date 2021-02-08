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

struct PreviousDealCreatedAt: Codable {
    var html: String
}

struct PreviousDeal: Codable {
    private var createdAt: PreviousDealCreatedAt
    var startedAt: String {
        let dateString = String(createdAt.html.split(separator: "\"", maxSplits: 2, omittingEmptySubsequences: true)[1])
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = formatter.date(from: dateString) {
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        } else {
            return dateString
        }
    }
    var flavorText: String
    var hasViewed: Bool
    var hasVoted: Bool
    var id: String
    var title: String
    var url: String
    var photo: String
}
