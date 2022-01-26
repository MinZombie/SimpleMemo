//
//  MainTableViewCell.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit

protocol MainTableViewCellDelegate: AnyObject {
    func didTapOptionButton(_ cell: MainTableViewCell)
}

class MainTableViewCell: UITableViewCell {
    
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
    @IBOutlet weak var bodyText: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    static let identifier = "MainTableViewCell"
    
    weak var delegate: MainTableViewCellDelegate?
    var index = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        configure()
        setUpContainerView()
        backgroundColor = .clear
        selectionStyle = .none
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
    
    public func configure(with viewModel: ViewModel) {
        bodyText.text = viewModel.bodyText
        date.text = "\(viewModel.dateFormatter)"
        viewContainer.backgroundColor = UIColor(named: viewModel.backgroundColor)
    }
    
    @objc private func didTapOptionButton(_ sender: UIButton) {
        delegate?.didTapOptionButton(self)
        
    }
    
    private func setUpContainerView() {
        viewContainer.layer.cornerRadius = 8
        viewContainer.layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
        viewContainer.layer.shadowOpacity = 0.3
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowRadius = 4
        viewContainer.backgroundColor = UIColor(named: "Green")
    }
    
    private func configure() {
        
        
        bodyText.numberOfLines = 0
        bodyText.font = UIFont(name: "GowunDodum-Regular", size: 15)
        date.font = .systemFont(ofSize: 11, weight: .thin)
    }
    
    private func setUpOptionButton() {
        optionButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        optionButton.tintColor = UIColor(named: "content")
        optionButton.backgroundColor = .clear
        optionButton.addTarget(self, action: #selector(didTapOptionButton(_:)), for: .touchUpInside)
    }
}
