//
//  Deal.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import Foundation

class Deal {
    
    var id: String
    var features: String
    var isPreviousDeal: Bool = false
    var items: [Item] = []
    var photos: [URL] = []
    var soldOut: Bool = false
    var specifications: String
    var story: Story
    var theme: Theme
    var title: String
    var topic: Topic?
    var url: URL
    var date: Date?
    
    init(id: String, title: String, features: String, specifications: String, story: Story, theme: Theme, url: URL) {
        self.id = id
        self.title = title
        self.features = features
        self.specifications = specifications
        self.theme = theme
        self.story = story
        self.url = url
    }
}
