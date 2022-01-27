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
    private var memos: Results<Memo>!
    private var observer: NSObjectProtocol?
    private var isFiltering: Bool {
        let searchController = navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isEmpty = searchController?.searchBar.text?.isEmpty == false
        return isActive && isEmpty
    }
    private var filteredData: [MainTableViewCell.ViewModel] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        setUpObserver()
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
    
    private func setUpObserver() {
        memos = realm.objects(Memo.self)
        
        observer = memos.observe { [weak self] changes in
            switch changes {
            case .initial(let data):
                
                self?.fetchMemos(with: data)
                
            case .update(let data, _, _, _):

                self?.fetchMemos(with: data)
                
            case .error(let error):
                print(error)
                         
            }
        }
    }
    
    private func fetchMemos(with data: Results<Memo>) {
        var viewModels = [MainTableViewCell.ViewModel]()
        
        
        viewModels.removeAll()
        
        for memo in data {
            viewModels.append(
                .init(bodyText: memo.content, date: memo.date, backgroundColor: memo.backgroundColor)
            )
        }
        DispatchQueue.main.async {
            self.viewModels = viewModels.sorted(by: { $0.date > $1.date })
            self.tableView.reloadData()
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
        navigationController?.navigationBar.barTintColor = UIColor(named: "BG")
        
        // 서치바 설정
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = NSLocalizedString("SearchPlaceholder", comment: "")
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
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
        if isFiltering {
            return filteredData.count
        }
        
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        
        
        if isFiltering {
            cell.configure(with: filteredData[indexPath.row])
            cell.index = indexPath.row
            
        } else {
            cell.configure(with: viewModels[indexPath.row])
            cell.index = indexPath.row
        }

        cell.delegate = self
        
        
        return cell
    }
    
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        var tempArr = [MainTableViewCell.ViewModel]()
        let result = realm.objects(Memo.self).filter("content CONTAINS[c] '\(text)'")
        
        for item in result {
            tempArr.append(
                .init(bodyText: item.content, date: item.date, backgroundColor: item.backgroundColor)
            )
        }
        self.filteredData = tempArr.sorted(by: { $0.date > $1.date })
        tableView.reloadData()
    }
}

extension MainViewController: MainTableViewCellDelegate {
    
    func didTapOptionButton(_ cell: MainTableViewCell) {
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: NSLocalizedString("Edit", comment: ""), style: .default) { [weak self] _ in
            let vc = self?.storyboard?.instantiateViewController(withIdentifier: WriteViewController.identifier) as! WriteViewController
            self?.isFiltering == true ? (vc.viewModels = self?.filteredData[cell.index]) : (vc.viewModels = self?.viewModels[cell.index])
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [weak self] _ in
            
            try! self?.realm.write {
                let memo = self?.realm.objects(Memo.self).where {
                    self?.isFiltering == true ? ($0.date == (self?.filteredData[cell.index].date)!) : ($0.date == (self?.viewModels[cell.index].date)!)
                }
                self?.realm.delete(memo!)
                self?.filteredData.remove(at: cell.index)
                self?.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        controller.addAction(editAction)
        controller.addAction(deleteAction)
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true)
    }
    
    
}
