//
//  MainTableViewCell.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit

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
    
    static let identifier = "MainTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        configure()
        setUpContainerView()
        viewContainer.backgroundColor = UIColor(named: "Green")
        backgroundColor = .clear
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func configure(with viewModel: ViewModel) {
        bodyText.text = viewModel.bodyText
        date.text = "\(viewModel.dateFormatter)"
        viewContainer.backgroundColor = UIColor(named: viewModel.backgroundColor)
    }
    
    private func setUpContainerView() {
        viewContainer.layer.cornerRadius = 8
        viewContainer.layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
        viewContainer.layer.shadowOpacity = 0.3
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowRadius = 4
    }
    
    private func configure() {
        
        
        bodyText.numberOfLines = 0
        bodyText.font = UIFont(name: "GowunDodum-Regular", size: 15)
        date.font = .systemFont(ofSize: 11, weight: .thin)
    }
}
