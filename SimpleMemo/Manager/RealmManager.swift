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
    
    private init() {}
    
    /// 여러 타겟에서 같이 사용하기 위한 realm 인스턴스
    private var realm: Realm {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.headingtodev.simplememo")
        let realmURL = container?.appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        return try! Realm(configuration: config)
    }
    
    
    // MARK: - Public
    
    /// realm에 저장 되어 있는 메모 객체
    public lazy var memos = realm.objects(Memo.self)
    
    /// 전체 메모 가져오는 함수
    /// - Returns: [Memo] 최근날짜 순으로
    public func getMemos() -> [Memo] {
        return Array(memos).sorted(by: { $0.date > $1.date })
    }
    
    /// 메모 수정
    /// - Parameters:
    ///     - date: 선택한 셀의 date
    ///     - text: 텍스트뷰의 텍스트
    ///     - selectedColor: 선택한 색깔
    func editMemo(date: Date, text: String, selectedColor: String) {
        try! realm.write {
            let memo = memos.where {
                $0.date == date
            }
            memo[0].content = text
            memo[0].backgroundColor = selectedColor
            // 메모를 수정하면 리스트 맨위로 올리기 위해서 새로운 날짜 저장
            memo[0].date = Date()
        }
    }
    
    /// 메모 추가
    /// - Parameter memo: realm 메모 모델
    func addMemo(memo: Memo) {
        try! realm.write {
            realm.add(memo)
        }
    }
    
    /// 메모 삭제
    /// - Parameter date: 선택한 셀 date. db에 있는 데이터와 셀의 데이터가 일치하는지 확인하기 위한 파라미터
    func deleteMemo(date: Date) {
        try! realm.write {
            // 선택한 셀의 데이터와 realm에 저장 돼 있는 데이터가 맞는지 날짜를 통해 확인
            let memo = memos.where {
                $0.date == date
            }
            realm.delete(memo)
            
        }
    }
}
