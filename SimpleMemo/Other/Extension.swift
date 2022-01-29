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


