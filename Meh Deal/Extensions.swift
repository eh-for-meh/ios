//
//  Extensions.swift
//  Meh Deal
//
//  Created by Kirin Patel on 4/24/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import Foundation

extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Deal {
    var price: String {
        var prices: [Float] = []
        for item in self.items {
            if !item.price.isLess(than: 0) {
                prices.append(item.price)
            }
        }
        if let min = prices.min(), let max = prices.max() {
            if min.isEqual(to: max) {
                return "$\(min.clean)"
            } else {
                return "$\(min.clean) - $\(max.clean)"
            }
        }
        return "Unknown Price"
    }
}
