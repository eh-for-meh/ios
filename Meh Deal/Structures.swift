//
//  Structures.swift
//  Meh Deal
//
//  Created by Kirin Patel on 4/24/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import Foundation

struct Deal: Decodable {
    let id: String;
    let title: String;
    let items: [Item];
    
    init(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        title = json["title"] as? String ?? ""
        items = json["items"] as? [Item] ?? []
    }
}

struct Item: Decodable {
    let id: String;
    let price: Float;
    
    init(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        price = json["price"] as? Float ?? -1
    }
}
