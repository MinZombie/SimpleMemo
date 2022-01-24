//
//  Memo.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/21.
//

import RealmSwift
import UIKit

class Memo: Object {
    @Persisted var date: Date = Date()
    @Persisted var content: String
    @Persisted var backgroundColor: String
    
    convenience init(content: String, backgroundColor: String) {
        self.init()
        self.content = content
        self.backgroundColor = backgroundColor
    }
    
    var dateFormatter: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: self.date)
    }
}
