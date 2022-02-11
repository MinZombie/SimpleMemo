//
//  Extension.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/24.
//

import Foundation
import UIKit

extension Notification.Name {
    static let didTapAddButton = Notification.Name("didTapAddButton")
}

extension UIViewController {
    /// alert 생성을 도와주는 함수
    /// - Parameters:
    ///     - title: alert의 제목
    ///     - message: alert의 내용
    ///     - okTitle: 확인 버튼 제목
    ///     - okHandler: 확인 버튼을 누르면 실행 할 블럭
    ///     - completion: alert 종류 후 실행 할 블럭
    func createAlert(
        title: String?,
        message: String? = nil,
        okTitle: String = NSLocalizedString("Ok", comment: ""),
        okHandler: ((UIAlertAction) -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: okTitle, style: .default, handler: okHandler)
        
        controller.addAction(okAction)
        
        self.present(controller, animated: true, completion: completion)
    }
}


