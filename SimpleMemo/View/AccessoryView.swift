//
//  AccessoryView.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/23.
//

import UIKit

protocol AccessoryViewDelegate: AnyObject {
    func AccessoryViewDidTapAddButton(view: AccessoryView)
}

class AccessoryView: UIView {
    
    @IBOutlet weak var addButton: UIButton!
    
    static let identifier = "AccessoryView"
    weak var delegate: AccessoryViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        setUpAddButton()
    }
    
    private func setUpAddButton() {
        addButton.setTitle(NSLocalizedString("AddButtonSetTitle", comment: ""), for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.setTitleColor(.white, for: .highlighted)
        addButton.layer.cornerRadius = 14
        addButton.backgroundColor = UIColor(named: "button")
        addButton.addTarget(self, action: #selector(didTapAddButton(_:)), for: .touchUpInside)
    }
    
    @objc func didTapAddButton(_ sender: UIButton) {
        delegate?.AccessoryViewDidTapAddButton(view: self)
    }
}
