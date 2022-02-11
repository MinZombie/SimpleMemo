//
//  MainTableViewCell.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit

/// 메모의 옵션 버튼이 선택 됐을 때 알려주는 델리게이트
protocol MainTableViewCellDelegate: AnyObject {
    func didTapOptionButton(_ cell: MainTableViewCell)
}

/// 메모 리스트의 테이블 뷰 셀
class MainTableViewCell: UITableViewCell {
    
    /// 메모 테이블 뷰 셀 뷰모델
    struct ViewModel {
        var bodyText: String
        var date: Date
        var backgroundColor: String
        
        var dateFormatter: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: self.date)
        }
    }
    
    @IBOutlet weak var viewContainer: UIView!
    
    /// 메모 내용 레이블
    @IBOutlet weak var bodyText: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    /// 셀 identifier
    static let identifier = "MainTableViewCell"
    
    /// 델리게이트
    weak var delegate: MainTableViewCellDelegate?
    
    /// 몇번째 셀이 선택 되었는지 값을 전달 받는 변수
    var index = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        setUpTableViewCell()
        setUpContainerView()
        setUpOptionButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bodyText.text = nil
        date.text = nil
        viewContainer.backgroundColor = nil
    }
    
    /// 셀의 컨텐츠(메모 내용, 날짜, 색깔) 설정
    public func configure(with viewModel: ViewModel) {
        bodyText.text = viewModel.bodyText
        date.text = "\(viewModel.dateFormatter)"
        viewContainer.backgroundColor = UIColor(named: viewModel.backgroundColor)
    }
    
    // MARK: - Private
    
    /// 셀의 optionButton 클릭 했을 때 사용하는 함수
    @objc private func didTapOptionButton(_ sender: UIButton) {
        delegate?.didTapOptionButton(self)
        
    }
    
    /// 셀 안에 최상위 뷰 설정
    private func setUpContainerView() {
        viewContainer.layer.cornerRadius = 8
        viewContainer.layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
        viewContainer.layer.shadowOpacity = 0.3
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowRadius = 4
        viewContainer.backgroundColor = Constants.Colors.green
    }
    
    /// 셀 설정
    private func setUpTableViewCell() {
        backgroundColor = .clear
        selectionStyle = .none
        bodyText.numberOfLines = 0
        bodyText.font = Constants.Fonts.normal
        date.font = .systemFont(ofSize: 11, weight: .thin)
    }
    
    /// optionButton 설정
    private func setUpOptionButton() {
        optionButton.setImage(Constants.Images.ellipsis, for: .normal)
        optionButton.tintColor = Constants.Colors.content
        optionButton.backgroundColor = .clear
        optionButton.addTarget(self, action: #selector(didTapOptionButton(_:)), for: .touchUpInside)
    }
}
