//
//  SettingViewController.swift
//  SimpleMemo
//
//  Created by 민선기 on 2022/01/17.
//

import UIKit
import Zip
import MobileCoreServices
import UniformTypeIdentifiers

/// 환경설정 하는 뷰컨트롤러
class SettingViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    /// 스토리보드 ID, 셀 identifier
    static let identifier = "SettingViewController"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.Colors.bg
        setUpTableView()
        setUpNavigation()
        indicator.isHidden = true
    }
    
    // MARK: - Private
    
    /// 인디케이터 설정
    private func setUpIndicator(_ bool: Bool) {
        if bool {
            self.indicator.isHidden = false
            self.view.isUserInteractionEnabled = false
            self.view.alpha = 0.5
        } else {
            self.indicator.isHidden = true
            self.view.isUserInteractionEnabled = true
            self.view.alpha = 1.0
        }
    }
    
    /// 내비게이션 설정
    private func setUpNavigation() {
        title = NSLocalizedString("SettingTitle", comment: "")
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .black
        
    }
    
    /// 테이블 뷰 설정
    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }

}

// MARK: - UIDocumentPickerDelegate
extension SettingViewController: UIDocumentPickerDelegate {
    /// 앱의 폴더 경로 가져오기
    /// - Returns: 옵셔널 문자열
    private func documentDirectoryPath() -> String? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = path.first {
            return directoryPath
        } else {
            return nil
        }
    }
    
    /// 데이터 백업을 위한 Activity 뷰 컨트롤러 호출
    private func presentActivityViewController() {
        //압축 파일 경로 가져오기
        let fileName = (documentDirectoryPath()! as NSString).appendingPathComponent("Simple_Memo_Backup.zip")
        let fileURL = URL(fileURLWithPath: fileName)
        
        
        // items가 any인 이유 = 이미지, 문자열 등등
        // applicationActivities: 인스타 스토리에 바로 올릴경우 활용
        let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
        
        // activityviewcontroller가 사라지고 난 후 아래 블럭 실행
        // 사라지면 인디케이터 원래대로 되돌려 놓기
        vc.completionWithItemsHandler = { [weak self] (activity, success, items, error) in
            
            self?.setUpIndicator(false)
            
        }
        self.present(vc, animated: true)
    }
    
    /// 백업 셀을 탭 했을 때 호출
    private func backUp() {
        // Doument 폴더 위치
        guard let path = documentDirectoryPath() else { return }
        // 저장공간 확인을 위한 url
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        var urlPaths = [URL]()
        // 압축 할 파일
        let realm = (path as NSString).appendingPathComponent("default.realm")
        
        do {
            // 압축 할 파일 크기
            let fileSize = try (FileManager.default.attributesOfItem(atPath: realm) as NSDictionary).fileSize()
            let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            // 사용 가능한 저장 공간
            guard let capacity = values.volumeAvailableCapacityForImportantUsage else {
                print("volumeAvailableCapacityForImportantUsage not available")
                return
            }
            
            
            if fileSize > capacity {
                // 저장 공간 부족 alert
                
                self.createAlert(title: NSLocalizedString("BackUpFileSizeAlertTitle", comment: ""))
                
            } else {
                
                if FileManager.default.fileExists(atPath: realm) {
                    // 파일 존재
                    // if 문에서 파일이 존재하는지 확인 했으니 강제 해제 해도 문제 x
                    // URL배열에 백업 파일 URL 추가
                    urlPaths.append(URL(string: realm)!)
                    // 압축 파일 만들기
                    do {
                        
                        // fileName: 원하는 걸로
                        
                        let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "Simple_Memo_Backup") // Zip
                        print("\(zipFilePath)")

                        
                        presentActivityViewController()
                        setUpIndicator(true)
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                } else {
                    // 파일 존재 x
                    self.createAlert(title: NSLocalizedString("NotExistFile", comment: ""))
                }
            }

            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// 복구 셀 탭 했을 때 호출
    private func restore() {
        // 복구 1 - 파일앱 열기 + 어떤 확장자를 보여줄지 선택
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.zip], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true)
    }
    
    /// 선택한 zip 파일을 압축해제 하는 함수
    /// - Parameters:
    ///     - directory: 얍축 해제 할 위치의 URL
    ///     - selectedFile: 선택한 zip 파일의 URL
    private func unzip(directory: URL, selectedFile: URL) {

        do {
            
            try Zip.unzipFile(selectedFile, destination: directory, overwrite: true, password: nil, progress: { [weak self] _ in
                // 복구 하는 도중에 인디케이터 보여주기 + 유저 인터랙션 불가능하게 하기
                self?.setUpIndicator(true)


            }, fileOutputHandler: { [weak self] _ in
                // 복구 성공 했을 때 인디케이터 숨기고, 복구 완료 alert 보여주기
                self?.setUpIndicator(false)
                
                // 앱 종료 안내창 보여주기
                self?.createAlert(
                    title: NSLocalizedString("RestoreCompleteTitle", comment: ""),
                    message: NSLocalizedString("RestoreCompleteMessage", comment: ""),
                    okTitle: NSLocalizedString("Ok", comment: "")
                ) { _ in
                    // 앱 종료 하는 코드
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                }

            })

        } catch {
            print(error.localizedDescription)

        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // 복구 2 - 선택한 파일에 대한 경로 가져와야 함
        guard let selectedFileURL = urls.first, selectedFileURL.path.contains("Simple_Memo_Backup") else {
            createAlert(title: NSLocalizedString("RestoreWrongFileSelected", comment: ""))
            return
        }

        // Document 위치
        // unzip 할 위치
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      
        unzip(directory: directory, selectedFile: selectedFileURL)

    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingViewController.identifier, for: indexPath)
        
        let model: [String] = [
            NSLocalizedString("Backup", comment: ""),
            NSLocalizedString("Restore", comment: "")
        ]
        
        cell.textLabel?.text = model[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            backUp()
        case 1:
            restore()

        default:
            break
        }
    }
}

