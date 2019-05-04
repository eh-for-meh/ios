//
//  Meh.swift
//  meh.com
//
//  Created by Kirin Patel on 5/4/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

class Anwser: Decodable {
    var id: String?
    var text: String?
    var voteCount: Int?
}

class Item: Decodable {
    var condition: String?
    var id: String?
    var photo: String?
    var price: Float?
}

class PurchaseQuantity: Decodable {
    var maximumLimit: Int?
    var minimumLimit: Int?
}

class Story: Decodable {
    var body: String?
    var title: String?
}

class Theme: Decodable {
    var accentColor: String?
    var backgroundColor: String?
    var backgroundImage: String?
    var forground: String?
}

class Topic: Decodable {
    var commentCount: Int?
    var createdAt: String?
    var id: String?
    var replyCount: Int?
    var url: String?
    var votecount: Int?
}

class Deal: Decodable {
    var features: String?
    var id: String?
    var items: Array<Item>?
    var photos: Array<String>?
    var purchaseQuantity: PurchaseQuantity?
    var story: Story?
    var theme: Theme?
    var title: String?
    var topic: Topic?
    var url: String?
}

class Poll: Decodable {
    var answers: Array<Anwser>?
    var id: String?
    var startDate: String?
    var title: String?
    var topic: Topic?
}

class Video: Decodable {
    var id: String?
    var startDate: String?
    var title: String?
    var topic: Topic?
    var url: String?
}

class APIData: Decodable {
    var deal: Deal?
    var poll: Poll?
    var video: Video?
}
