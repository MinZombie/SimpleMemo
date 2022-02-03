//
//  WriteViewController.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit
import RealmSwift

class WriteViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet var colorButtons: [UIButton]!
    
    let realm = try! Realm()
    
    static let identifier = "WriteViewController"
    private var textViewPlaceholder = NSLocalizedString("TextViewPlaceholder", comment: "")
    private var selectedColor = ""
    
    var viewModels: MainTableViewCell.ViewModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.bg
        
        setUpNavigation()
        setUpTextView()
        setUpColorButtons()
        
        switch viewModels {
        case .some(let data):
            title = NSLocalizedString("WriteViewEditTitle", comment: "")
            textView.text = data.bodyText
            textView.textColor = .black
            selectedColor = data.backgroundColor
            
            for button in colorButtons.filter({ $0.titleLabel?.text == selectedColor }) {
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.darkGray.cgColor
            }
        case .none:
            title = NSLocalizedString("WriteViewAddTitle", comment: "")
        }
        
        
    }
    
    
    // MARK: - Private
    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    
    @objc private func didTapColorButton(_ sender: UIButton) {
        if let color = sender.titleLabel?.text {
            self.selectedColor = color
        }

        for button in colorButtons {

            button.isSelected = (sender == button)
            
            if !button.isSelected {
                button.layer.borderWidth = 0
                button.layer.borderColor = UIColor.clear.cgColor
            } else {
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.darkGray.cgColor
            }
        }
    }
    
    private func setUpColorButtons() {
        for button in colorButtons {
            button.setTitle("", for: .normal)
            button.layer.cornerRadius = button.frame.width / 2
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            button.layer.shadowRadius = 4.0
            button.layer.shadowOpacity = 0.5
            button.addTarget(self, action: #selector(didTapColorButton(_:)), for: .touchUpInside)
        }
        buttonView.backgroundColor = .clear
    }
    
    private func setUpAccessoryView() -> UIView {
        guard let accessoryView = Bundle.main.loadNibNamed(AccessoryView.identifier, owner: self, options: nil)?.first as? AccessoryView else {
            return UIView()
        }
        accessoryView.delegate = self
        return accessoryView
    }
    
    private func setUpTextView() {
        textView.delegate = self
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.font = Constants.Fonts.normal
        textView.backgroundColor = .white
        textView.text = textViewPlaceholder
        textView.textColor = .lightGray
        textView.inputAccessoryView = setUpAccessoryView()
    }
    
    private func setUpNavigation() {
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .black
    }
    


}

extension WriteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 제한된 글자수에 도달하면 alert 보여주기
        if textView.text.count > 172 {
            self.createAlert(title: NSLocalizedString("MaximumTexts", comment: ""))
        }
    }
    
    // 텍스트뷰에 placeholder를 지움(텍스트뷰에 텍스트를 쓰기 시작하니까)
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
            
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceholder
            textView.textColor = .lightGray
        }
    }

}

extension WriteViewController: AccessoryViewDelegate {
    func AccessoryViewDidTapAddButton(view: AccessoryView) {

        guard let text = textView.text,
              !text.trimmingCharacters(in: .whitespaces).isEmpty,
              !selectedColor.isEmpty else {
            // alert 화면 보여주기
            let controller = UIAlertController(
                title: NSLocalizedString("Notice", comment: ""),
                message: NSLocalizedString("AlertMessageForWriteVC", comment: ""),
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(
                title: NSLocalizedString("Ok", comment: ""),
                style: .default, handler: nil
            )
            controller.addAction(okAction)
            self.present(controller, animated: true)
            
            return
        }
        
        if text.count <= 172 {
            if viewModels == nil {
                // 새 메모를 작성할 때
                let data = Memo(content: text, backgroundColor: selectedColor)
                
                try! realm.write {
                    realm.add(data)
                }
            } else {
                // 기존에 있던 메모를 수정할 때
                try! realm.write {
                    let memo = realm.objects(Memo.self).where {
                        $0.date == viewModels!.date
                    }
                    memo[0].content = text
                    memo[0].backgroundColor = selectedColor
                    memo[0].date = Date()
                }
                
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "didTapAddButton"), object: nil)
            navigationController?.popViewController(animated: true)
            
        } else {
            self.createAlert(title: NSLocalizedString("MaximumTexts", comment: ""))
        }
    }
}

