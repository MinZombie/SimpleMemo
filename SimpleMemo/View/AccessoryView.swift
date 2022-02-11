//
//  AccessoryView.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/23.
//

import UIKit

/// 액세서리 뷰의 버튼 델리게이트
protocol AccessoryViewDelegate: AnyObject {
    func AccessoryViewDidTapAddButton(view: AccessoryView)
}

/// 액세서리 뷰
class AccessoryView: UIView {
    
    @IBOutlet weak var addButton: UIButton!
    
    /// 뷰 identifier
    static let identifier = "AccessoryView"
    
    /// 델리게이트
    weak var delegate: AccessoryViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        setUpAddButton()
    }
    
    /// addButton 설정
    private func setUpAddButton() {
        addButton.setTitle(NSLocalizedString("AddButtonSetTitle", comment: ""), for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.setTitleColor(.white, for: .highlighted)
        addButton.layer.cornerRadius = 14
        addButton.backgroundColor = Constants.Colors.button
        addButton.addTarget(self, action: #selector(didTapAddButton(_:)), for: .touchUpInside)
    }
    
    /// addButton 탭 했을 때 호출
    @objc func didTapAddButton(_ sender: UIButton) {
        delegate?.AccessoryViewDidTapAddButton(view: self)
    }
}
