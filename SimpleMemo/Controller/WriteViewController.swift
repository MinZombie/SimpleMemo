//
//  WriteViewController.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit
import RealmSwift

/// 메모를 작성하거나 수정하는 뷰컨트롤러
class WriteViewController: UIViewController {
    // MARK: - Properties
    
    /// 텍스트 입력 받는 텍스트 뷰
    @IBOutlet weak var textView: UITextView!
    
    /// 컬러 버튼 담는 뷰
    @IBOutlet weak var buttonView: UIView!
    
    /// 색깔 배열
    @IBOutlet var colorButtons: [UIButton]!
    
    @IBOutlet weak var buttonViewTrailingConstraint: NSLayoutConstraint!
    
    /// 뷰 이동을 위한 identifier
    static let identifier = "WriteViewController"
    private var textViewPlaceholder = NSLocalizedString("TextViewPlaceholder", comment: "")
    
    /// 현재 선택된 색깔을 저장하는 변수
    private var selectedColor = ""
    
    /// 새로운 메모를 추가 할지 아니면 메모를 수정할지 판단 하는 변수.
    var viewModels: MainTableViewCell.ViewModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.bg
        
        setUpNavigation()
        setUpTextView()
        setUpColorButtons()
        
        // viewModels에 데이터가 있으면 텍스트뷰에 전 화면에서 선택된 셀의 데이터를 가져와 설정
        switch viewModels {
        case .some(let data):
            title = NSLocalizedString("WriteViewEditTitle", comment: "")
            textView.text = data.bodyText
            textView.textColor = .black
            textView.backgroundColor = UIColor(named: data.backgroundColor)
            selectedColor = data.backgroundColor
            
            for button in colorButtons.filter({ $0.titleLabel?.text == selectedColor }) {
                button.alpha = 0
                button.isEnabled = false
            }
        case .none:
            title = NSLocalizedString("WriteViewAddTitle", comment: "")
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonContainerAppearAnimation()
    }
    
    // MARK: - Private
    
    /// 뷰 탭 했을 때 키보드 내리는 함수
    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    /// 색깔 선택 했을 때 호출 되는 함수
    @objc private func didTapColorButton(_ sender: UIButton) {
        if let color = sender.titleLabel?.text {
            self.selectedColor = color
        }

        for button in colorButtons {

            button.isSelected = (sender == button)
            
            if !button.isSelected {

                UIView.animate(withDuration: 1.2, delay: 0, options: .curveEaseInOut) {

                    button.alpha = 1.0
                    button.isEnabled = true

                }
                
            } else {
                
                UIView.animate(withDuration: 1.2, delay: 0.4, options: .curveEaseOut) {

                    self.textView.backgroundColor = button.backgroundColor
                    button.alpha = 0
                    button.isEnabled = false

                } completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self.textView.textColor = .black
                    }
                }
            }
        }
        
        // 버튼 클릭시 키보드 올리기
        textView.becomeFirstResponder()
    }
    
    /// 왼쪽 화면 밖에서 화면 안으로 이동하는 애니메이션 함수
    private func buttonContainerAppearAnimation() {
        let animation = CASpringAnimation(keyPath: "position.x")
        animation.damping = 7
        animation.toValue = view.bounds.size.width / 2
        animation.fromValue = -(view.bounds.size.width / 2)
        animation.duration = 2.0
        buttonView.layer.add(animation, forKey: "")
    }
    
    /// 색깔 버튼 설정
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
    
    /// 악세사리 뷰 설정
    private func setUpAccessoryView() -> UIView {
        guard let accessoryView = Bundle.main.loadNibNamed(AccessoryView.identifier, owner: self, options: nil)?.first as? AccessoryView else {
            return UIView()
        }
        accessoryView.delegate = self
        return accessoryView
    }
    
    /// 텍스트 뷰 설정
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
    
    /// 내비게이션 설정
    private func setUpNavigation() {
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .black
    }
    


}

// MARK: - UITextViewDelegate
extension WriteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 제한된 글자수에 도달하면 alert 보여주기
        if textView.text.count > 172 {
            self.createAlert(title: NSLocalizedString("MaximumTexts", comment: ""))
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 텍스트뷰에 placeholder를 지움
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

// MARK: - AccessoryViewDelegate
extension WriteViewController: AccessoryViewDelegate {
    /// 악세사리 뷰에 있는 버튼 탭 했을 때 호출 되는 함수.
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
                
                RealmManager.shared.addMemo(memo: data)
                
            } else {
                // 기존에 있던 메모를 수정할 때
                RealmManager.shared.editMemo(date: viewModels!.date, text: text, selectedColor: selectedColor)
            }
            
            navigationController?.popViewController(animated: true)
            
        } else {
            // 172자 초과 했는데 버튼을 눌렀을 때
            self.createAlert(title: NSLocalizedString("MaximumTexts", comment: ""))
        }
    }
}

