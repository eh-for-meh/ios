//
//  ThemeLoader.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ThemeLoader {
    
    static let sharedInstance = ThemeLoader()
    
    func loadTheme(completion: @escaping (_ theme: Theme) -> Void) {
        Database.database().reference().child("currentDeal/deal/theme").observeSingleEvent(of: .value) { snapshot in
            let theme = Theme(
                backgroundColor: UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "backgroundColor").value as? String ?? "#ffffff"),
                accentColor: UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "accentColor").value as? String ?? "#000000"),
                dark: snapshot.childSnapshot(forPath: "foreground").value as? String ?? "dark" == "dark")
            
            completion(theme)
        }
    }
    
    func loadTheme(forDeal id: String, completion: @escaping (_ theme: Theme) -> Void) {
        Database.database().reference().child("previousDeal/\(id)/deal/theme").observeSingleEvent(of: .value) { snapshot in
            let theme = Theme(
                backgroundColor: UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "backgroundColor").value as? String ?? "#ffffff"),
                accentColor: UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "accentColor").value as? String ?? "#000000"),
                dark: snapshot.childSnapshot(forPath: "foreground").value as? String ?? "dark" == "dark")
            
            completion(theme)
        }
    }
    
    func setupThemeListener(completion: @escaping (_ theme: Theme) -> Void) {
        Database.database().reference().child("currentDeal/deal/theme").observe(.value) { snapshot in
            let theme = Theme(
                backgroundColor: UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "backgroundColor").value as? String ?? "#ffffff"),
                accentColor: UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "accentColor").value as? String ?? "#000000"),
                dark: snapshot.childSnapshot(forPath: "foreground").value as? String ?? "dark" == "dark")
            
            completion(theme)
        }
    }
}
