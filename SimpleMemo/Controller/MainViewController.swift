//
//  ViewController.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var addMemoButton: UIButton!
    
    private var viewModels: [MainTableViewCell.ViewModel] = []
    private let realm = try! Realm()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        readMemos()
        
    }

    
    // MARK: - Private
    @objc func didTapRightBarButtonItem() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: SettingViewController.identifier) as! SettingViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapAddMemoButton() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: WriteViewController.identifier) as! WriteViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func readMemos() {
        
        for memo in realm.objects(Memo.self) {
            viewModels.append(
                .init(bodyText: memo.content, date: memo.dateFormatter, backgroundColor: memo.backgroundColor)
            )
        }
    }

    private func configure() {
        view.backgroundColor = UIColor(named: "BG")
        
        // 테이블뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        
        // 내비게이션 설정
        title = NSLocalizedString("NavigationTitle", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 서치바 설정
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = NSLocalizedString("SearchPlaceholder", comment: "")
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        
        
        // 오른쪽 바 버튼 아이템
        rightBarButtonItem.image = UIImage(systemName: "gearshape")
        rightBarButtonItem.tintColor = .black
        rightBarButtonItem.action = #selector(didTapRightBarButtonItem)
        rightBarButtonItem.target = self
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        // 메모 추가 버튼
        addMemoButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addMemoButton.tintColor = .white
        addMemoButton.backgroundColor = .black
        addMemoButton.layer.cornerRadius = addMemoButton.frame.height / 2
        addMemoButton.addTarget(self, action: #selector(didTapAddMemoButton), for: .touchUpInside)
    }
    
}

// MARK: - UITableViewDataSource, Delegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        
        cell.configure(with: viewModels[indexPath.row])
        
        return cell
    }
}
