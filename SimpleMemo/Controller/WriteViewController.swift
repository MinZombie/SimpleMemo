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
    private var keyboardHeigt: CGFloat = 0
    private var textViewPlaceholder = NSLocalizedString("TextViewPlaceholder", comment: "")
    private var selectedColor = ""

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BG")
        
        setUpNavigation()
        
        setUpTextView()
        setUpColorButtons()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
            sender == button ? (sender.isSelected = true) : (sender.isSelected = false)
            
            if button.isSelected {
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.darkGray.cgColor
            } else {
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.lightGray.cgColor
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
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.addTarget(self, action: #selector(didTapColorButton(_:)), for: .touchUpInside)
            
        }
        buttonView.backgroundColor = .clear
    }
    
    private func setUpTextView() {
        textView.delegate = self
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.font = UIFont(name: "GowunDodum-Regular", size: 15)
        textView.backgroundColor = .white
        textView.text = textViewPlaceholder
        textView.textColor = .lightGray
        
        guard let accessoryView = Bundle.main.loadNibNamed(AccessoryView.identifier, owner: self, options: nil)?.first as? AccessoryView else { return }
        accessoryView.delegate = self
        textView.inputAccessoryView = accessoryView
    }
    
    private func setUpNavigation() {
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .black
    }
    


}

extension WriteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 제한된 글자수에 도달하면 alert 보여주기
        if textView.text.count == 172 {
            print("텍스트를 172자 이하로 입력해주세요")
        }
    }
    
    // 텍스트뷰에 placeholder를 지움(텍스트뷰에 텍스트를 쓰기 시작하니까)
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceholder {
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

        guard let text = textView.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            // alert 화면 보여주기
            return
        }
        let data = Memo(content: text, backgroundColor: selectedColor)
        
        try! realm.write {
            realm.add(data)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

