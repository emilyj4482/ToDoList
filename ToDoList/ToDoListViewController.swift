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
    @IBOutlet weak var lblListName: UILabel!
    
    let taskViewModel = TaskViewModel()
    var listName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // keyboard detection
        detectKeyboard()
        // (입력 종료) 사용자의 화면 tap을 감지하여 keyboard 숨김
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        
        
        
        
        // test code
        taskViewModel.addList(taskViewModel.createList("to study"))
        taskViewModel.addTask(listName: "to study", task: taskViewModel.createTask("iOS"))
        taskViewModel.addTask(listName: "to study", task: taskViewModel.createTask("Swift"))

        // AddNewListViewController로부터 listName 전달 받기
        if let listName = listName {
            self.lblListName.text = listName
            taskViewModel.addList(List(name: listName, tasks: []))
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // AddNewViewController를 Navigation Stack에서 제외한다. >> popViewController를 했을 때 이전 Stack이 MainListViewController가 되게 하기 위함
        guard let navigationController = self.navigationController else { return }
        // stack의 모든 View Controller를 Array로 가져온다.
        var navigationArray = navigationController.viewControllers
        // MainListViewController에서 cell을 탭하여 이동했을 경우, 조치 X
        // AddNewListViewController에서 넘어왔을 경우, Stack에서 삭제한다.
        if navigationArray.count > 2 {
            navigationArray.remove(at: 1)
            print("AddNewListViewController deleted : \(navigationArray)")
            self.navigationController?.viewControllers = navigationArray
        }
    }
    
    @IBAction func btnListsTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        guard let title = textField.text else { return }
        if title.isEmpty {
            hideKeyBoard()
        } else {
            if let listName = listName {
                taskViewModel.addTask(listName: listName, task: taskViewModel.createTask(title))
            }
            print(taskViewModel.lists)
            hideKeyBoard()
        }
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
    // row 개수 = 생성한 task 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let index = taskViewModel.lists.firstIndex(where: { $0.name == "to study" }) {
            return taskViewModel.lists[index].tasks.count
        } else {
            return 0
        }
    }
    
    // cell 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? ToDoCell else { return UITableViewCell() }
        // cell tap 시 배경색 회색되지 않게
        cell.selectionStyle = .none
        // cell 뷰 적용
        // >> check
        
        // >> text label
        if let index = taskViewModel.lists.firstIndex(where: { $0.name == "to study" }) {
            cell.lblTask.text = taskViewModel.lists[index].tasks[indexPath.row].title
        }

        // >> important
        
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
    
    // keyboard 숨기기 + textfield를 비운 뒤 done 버튼과 함께 숨김
    @objc private func hideKeyBoard() {
        textField.text = ""
        textField.resignFirstResponder()
        tfView.isHidden = true
        btnDone.isHidden = true
    }
}

class ToDoCell: UITableViewCell {
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTask: UILabel!
    @IBOutlet weak var btnImportant: UIButton!
    
    @IBAction func btnCheckTapped(_ sender: UIButton) {
        // 클릭 시 이전 상태와 반대로 상태 바꿈
        btnCheck.isSelected = !btnCheck.isSelected
    }
    
    @IBAction func btnImportantTapped(_ sender: UIButton) {
        // 클릭 시 이전 상태와 반대로 상태 바꿈
        btnImportant.isSelected = !btnImportant.isSelected
    }
}
