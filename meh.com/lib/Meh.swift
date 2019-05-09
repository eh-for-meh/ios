//
//  Meh.swift
//  meh.com
//
//  Created by Kirin Patel on 5/4/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

fileprivate func defaultStyles(_ backgroundColor: String = "#FFFFFF", _ accentColor: String = "#000000") -> String {
    return """
    <style> \
        body { \
            background-color: \(backgroundColor); \
            color: \(accentColor); \
            font-family: Helvetica; \
        } \
        h1 { \
            font-size: 50px; \
        } \
        p { \
            font-size: 40px; \
        }\
        a, \
        a:link, \
        a:visited, \
        a:link:active, \
        a:visited:active { \
            color: \(accentColor); \
        } /
    </style>
    """
}

fileprivate func markdownLinkReplacerScript(_ elementName: String = "body") -> String {
    return """
    <script> \
        let pattern = /(\\[.*?\\])(\\(.*?\\))/g; \
        let element = document.getElementById("\(elementName)"); \
        element.innerHTML.match(pattern).forEach(match => { \
        let textPattern = /\\[.*?\\]/; \
        let text = match.match(textPattern).join("").replace(/\\[|\\]/g, ""); \
        let hrefPattern = /\\(.*?\\)/; \
        let href = match.match(hrefPattern).join("").replace(/\\(|\\)/g, ""); \
        let link = `<a href="${href}">${text}</a>`; \
        element.innerHTML = element.innerHTML.replace(match, link); \
        }); \
    </script>
    """
}

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
    func asHTML(_ backgroundColor: String = "#FFFFFF", _ accentColor: String = "#000000") -> String? {
        if let body = body, let title = title {
            var parsedBody = body.replacingOccurrences(of: "\r", with: "")
            parsedBody = parsedBody.replacingOccurrences(of: "\n", with: "<br>")
            parsedBody = parsedBody.replacingOccurrences(of: "\'", with: "'")
            return """
            <!doctype html> \
            <html lang="en"> \
                <head> \
                    <meta charset="utf-8"> \
                    <title>eh for meh story</title> \
                </head> \
                \(defaultStyles(backgroundColor, accentColor)) \
                <body> \
                    <h1>\(title)</h1> \
                    <p id="body">\(parsedBody)</p> \
                    \(markdownLinkReplacerScript()) \
                </body> \
            </html>
            """
        } else {
            return nil
        }
    }
}

@objc class Theme: NSObject, Decodable {
    @objc var accentColor: String?
    @objc var backgroundColor: String?
    @objc var backgroundImage: String?
    @objc var forground: String?
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
