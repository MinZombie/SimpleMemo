//
//  SettingViewController.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    static let identifier = "SettingViewController"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BG")
        setUpTableView()
        setUpNavigation()
    }
    
    private func setUpNavigation() {
        title = NSLocalizedString("SettingTitle", comment: "")
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .black
        
    }
    
    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }

}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingViewController.identifier, for: indexPath)
        
        cell.textLabel?.text = "백업"
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        return cell
    }
}
