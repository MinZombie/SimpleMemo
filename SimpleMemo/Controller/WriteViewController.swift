//
//  WriteViewController.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit

class WriteViewController: UIViewController {
    
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet var colorButtons: [UIButton]!
    
    static let identifier = "WriteViewController"
    private var keyboardHeigt: CGFloat = 0
    private var textViewPlaceholder = NSLocalizedString("TextViewPlaceholder", comment: "")
    private var isMovedButton = false

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BG")
        
        setUpNavigation()
        setUpAddButton()
        setUpTextView()
        setUpColorButtons()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Private
    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }
    
    @objc private func didTapColorButton(_ sender: UIButton) {
        
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        if isMovedButton {
            addButton.frame.origin.y += keyboardHeigt
            isMovedButton.toggle()
        }
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        
        if !isMovedButton {
            
            if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeigt = keyboardRectangle.height
                addButton.frame.origin.y -= keyboardHeigt
                isMovedButton.toggle()

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
    
    private func setUpTextView() {
        textView.delegate = self
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.font = UIFont(name: "GowunDodum-Regular", size: 15)
        textView.backgroundColor = .white
        textView.text = textViewPlaceholder
        textView.textColor = .lightGray
    }
    
    private func setUpNavigation() {
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .black
    }
    

    
    private func setUpAddButton() {
        addButton.setTitle(NSLocalizedString("AddButtonSetTitle", comment: ""), for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor(named: "Button")
        addButton.layer.cornerRadius = 12
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



