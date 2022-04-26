//
//  MainTableViewCell.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit

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
    
    /// 셀 identifier
    static let identifier = "MainTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        setUpTableViewCell()
        //setUpContainerView()
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
}
