//
//  ViewController.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit
import RealmSwift
import WidgetKit

/// 메모 리스트 보여주는 뷰컨트롤러
class MainViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    /// SettingViewController로 이동하는 버튼
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    /// WriteViewController로 이동하는 버튼
    @IBOutlet weak var addMemoButton: UIButton!
    
    /// 모든 메모 데이터
    private var viewModels: [MainTableViewCell.ViewModel] = []
    
    /// 검색 결과 데이터
    private var filteredData: [MainTableViewCell.ViewModel] = []
    
    /// realm 인스턴스
    private let realm = try! Realm()
    
    /// realm에 저장 되어 있는 Memo 객체
    private var memos: Results<Memo>!
    
    /// 메모 리스트 업데이트를 위한 옵저버
    private var observer: NSObjectProtocol?
    
    /// 검색중인지 확인하는 변수
    private var isFiltering: Bool {
        let searchController = navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isEmpty = searchController?.searchBar.text?.isEmpty == false
        return isActive && isEmpty
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Constants.Colors.bg
        
        setUpAddButton()
        setUpTableView()
        setUpSearchController()
        setUpBarButtonItem()
        setUpNavigationController()
        setUpObserver()
    }

    
    // MARK: - Private
    
    /// SettingViewController로 이동하는 메서드. RightBarButtonItem 탭 했을 때 호출
    @objc func didTapRightBarButtonItem() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: SettingViewController.identifier) as! SettingViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// WriteViewController로 이동하는 메서드. addMemoButton 탭 했을 때 호출
    @objc func didTapAddMemoButton() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: WriteViewController.identifier) as! WriteViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 옵저버 설정
    private func setUpObserver() {
        memos = realm.objects(Memo.self)
        
        observer = memos.observe { [weak self] changes in
            switch changes {
            case .initial(let data):
                
                self?.fetchMemos(with: data)
                
            case .update(let data, _, _, _):

                self?.fetchMemos(with: data)
                
                // realm에 저장 돼 있는 메모가 업데이트 되면, 위젯 타임라인도 업데이트
                WidgetCenter.shared.reloadAllTimelines()
                
            case .error(let error):
                print(error)
                         
            }
        }
    }
    
    /// realm에서 메모 데이터를 불러오는 함수
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
    
    /// addButton 설정
    private func setUpAddButton() {
        addMemoButton.setImage(Constants.Images.plus, for: .normal)
        addMemoButton.tintColor = .white
        addMemoButton.backgroundColor = .black
        addMemoButton.layer.cornerRadius = addMemoButton.frame.height / 2
        addMemoButton.addTarget(self, action: #selector(didTapAddMemoButton), for: .touchUpInside)
    }
    
    /// rightBarButtonItem 설정
    private func setUpBarButtonItem() {
        rightBarButtonItem.image = Constants.Images.gearshape
        rightBarButtonItem.tintColor = .black
        rightBarButtonItem.action = #selector(didTapRightBarButtonItem)
        rightBarButtonItem.target = self
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    /// 서치바 설정
    private func setUpSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = NSLocalizedString("SearchPlaceholder", comment: "")
        searchController.searchBar.tintColor = .black
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    /// 내비게이션 설정
    private func setUpNavigationController() {
        title = NSLocalizedString("NavigationTitle", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = Constants.Colors.bg
    }
    
    /// 테이블뷰 설정
    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
}

// MARK: - UITableViewDataSource, Delegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 검색 했을 때 셀의 갯수
        if isFiltering {
            return filteredData.count
        }
        
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        
        // 검색 했을 때 보여주는 경우
        if isFiltering {
            cell.configure(with: filteredData[indexPath.row])
            cell.index = indexPath.row
            
        // 모든 메모 보여주는 경우
        } else {
            cell.configure(with: viewModels[indexPath.row])
            cell.index = indexPath.row
        }
        
        // 셀에 있는 옵션 버튼에 대한 델리게이트
        cell.delegate = self
        
        
        return cell
    }
    
}

// MARK: - UISearchResultsUpdating
extension MainViewController: UISearchResultsUpdating {
    /// 검색 결과 업데이트
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

// MARK: - MainTableViewCellDelegate
extension MainViewController: MainTableViewCellDelegate {
    /// 셀에 있는 옵션 버튼 눌렀을 때 호출.
    /// - Parameter cell: 선택한 셀
    func didTapOptionButton(_ cell: MainTableViewCell) {
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        /// 메모를 수정 하는 액션. WriteViewController로 이동
        let editAction = UIAlertAction(title: NSLocalizedString("Edit", comment: ""), style: .default) { [weak self] _ in
            let vc = self?.storyboard?.instantiateViewController(withIdentifier: WriteViewController.identifier) as! WriteViewController
            
            // 검색 결과창에 있는 셀이 선택 됐는지, 메인 리스트에 있는 셀이 선택 됐는지 확인
            self?.isFiltering == true ? (vc.viewModels = self?.filteredData[cell.index]) : (vc.viewModels = self?.viewModels[cell.index])
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        /// 메모를 삭제 하는 액션.
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [weak self] _ in
            
            try! self?.realm.write {
                // 선택한 셀의 데이터와 realm에 저장 돼 있는 데이터가 맞는지 날짜를 통해 확인
                let memo = self?.realm.objects(Memo.self).where {
                    self?.isFiltering == true ? ($0.date == (self?.filteredData[cell.index].date)!) : ($0.date == (self?.viewModels[cell.index].date)!)
                }
                self?.realm.delete(memo!)
                
                // 검색중 이라면 검색 결과 셀을 삭제
                if self?.isFiltering == true {
                    self?.filteredData.remove(at: cell.index)
                }
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
