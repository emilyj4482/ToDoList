//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class ToDoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var tfViewBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        // keyboard detection
        detectKeyboard()
        // (입력 종료) 사용자의 화면 tap을 감지하여 keyboard 숨김
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
    }
    
    @IBAction func btnListsTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        hideKeyBoard()
    }
    
    // + Add a Task 버튼을 누르면 텍스트필드와 Done 버튼의 숨김이 해제되고 할 일을 입력할 수 있도록 키보드가 나타난다.
    @IBAction func btnAddTapped(_ sender: UIButton) {
        tfView.isHidden = false
        btnDone.isHidden = false
        textField.becomeFirstResponder()
    }
}

// Table View Data Source
extension ToDoListViewController: UITableViewDataSource {
    // row 개수 = 생성한 list 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    // cell 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        // cell tap 시 배경색 회색되지 않게
        cell.selectionStyle = .none
        return cell
    }
}

// Table View Delegate
extension ToDoListViewController: UITableViewDelegate {
    // row 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// Keyboard 관련 기능 : textfield를 포함한 view가 키보드 팝업 시 바로 위에 위치하도록 구현
extension ToDoListViewController {
    // 키보드 detection
    func detectKeyboard() {
        // 키보드가 나타나는 것 감지 >> keyboardWillShow 함수 호출
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 키보드가 사라지는 것 감지 >> keyboardWillHide 함수 호출
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        // keyboard 크기 > 높이 추출
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardFrame.height
        // 적용할 높이 = keyboard 높이 - safe area 높이
        let adjustmentHeight = keyboardHeight - view.safeAreaInsets.bottom
        // 적용할 높이만큼 textfield 영역 높임
        tfViewBottom.constant = adjustmentHeight
    }
    
    // textfield 영역 높이 원점
    @objc private func keyboardWillHide() {
        tfViewBottom.constant = 0
    }
    
    // keyboard 숨기기 + textfield와 done 버튼 함께 숨김
    @objc private func hideKeyBoard() {
        textField.resignFirstResponder()
        tfView.isHidden = true
        btnDone.isHidden = true
    }
}
