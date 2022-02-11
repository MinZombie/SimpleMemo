//
//  RealmManager.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/02/04.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared: RealmManager = .init()

    private var realm: Realm {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.headingtodev.simplememo")
        let realmURL = container?.appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        return try! Realm(configuration: config)
    }
    
    func getMemos() -> [Memo] {
        return Array(realm.objects(Memo.self)).sorted(by: { $0.date > $1.date })
    }
}
