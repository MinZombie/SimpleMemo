//
//  ViewController.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit

class MainViewController: UIViewController {
    
    let dummy: [MainTableViewCell.ViewModel] = [
        .init(bodyText: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s", date: "2021/12/12", backgroundColor: "Red"),
        .init(bodyText: "Lorem Ipsum", date: "2021/12/12", backgroundColor: "Orange"),
        .init(bodyText: "내일 이마트 가기", date: "2021/12/12", backgroundColor: "Yellow"),
        .init(bodyText: "오늘 리뷰 꼭 쓰기", date: "2021/12/12", backgroundColor: "Green"),
        .init(bodyText: "제발 제발 제발 제발 제발 제발 제발🤩", date: "2021/12/12", backgroundColor: "Blue"),
        .init(bodyText: "There are many variations of passages of Lorem Ipsum available, but", date: "2021/12/12", backgroundColor: "Light_Purple"),
        .init(bodyText: "내일 이마트 가기", date: "2021/12/12", backgroundColor: "Dark_Purple"),
    ]

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var addMemoButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
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
        return dummy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        
        cell.configure(with: dummy[indexPath.row])
        
        return cell
    }
}
