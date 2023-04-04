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
    @IBOutlet weak var btnAddTask: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var tfViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lblListName: UITextField!
    
    var taskViewModel = TaskViewModel.shared
    var index: Int?
    var listId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // keyboard detection
        detectKeyboard()
        // (입력 종료) 사용자의 화면 tap을 감지하여 keyboard 숨김
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))

        // 이전 VC로부터 전달 받은 index 정보로 ViewModel에서 현재 list 불러오기 >> viewDidLoad에서 값을 부여하므로 앞으로 forced unwrapping 적용
        guard let index = index else { return }
        listId = taskViewModel.lists[index].id
        
        // list 이름 라벨에 적용
        self.lblListName.text = taskViewModel.lists[index].name
        
        // Important list의 경우 star icon을 통해서만 task를 추가할 수 있도록 구현 >> Add a Task 기능 비활성화
        // Important list가 아닐 경우 label(textfield) 탭 시 edit 가능
        if index == 0 {
            btnAddTask.isHidden = true
        } else {
            lblListName.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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
            self.navigationController?.viewControllers = navigationArray
        }
    }
    
    @IBAction func btnListsTapped(_ sender: UIButton) {
        // ViewModel 넘기면서 Main으로 이동
        guard let mainListVC = self.storyboard?.instantiateViewController(identifier: "MainListViewController") as? MainListViewController else { return }
        mainListVC.taskViewModel = self.taskViewModel
        self.navigationController?.popViewController(animated: true)
    }
    
    // list name edit or add a task 상황에 따라 동작 분리
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        guard let title = textField.text?.trim() else { return }
        
        if textField.isFirstResponder && !title.isEmpty {
            taskViewModel.addTask(listId: listId!, taskViewModel.createTask(listId: listId!, title))
        } else if lblListName.isFirstResponder {
            
        }
        hideKeyBoard()
        self.tableView.reloadData()
    }
    
    // + Add a Task 버튼을 누르면 텍스트필드와 Done 버튼의 숨김이 해제되고 할 일을 입력할 수 있도록 키보드가 나타난다.
    @IBAction func btnAddTapped(_ sender: UIButton) {
        tfView.isHidden = false
        textField.becomeFirstResponder()
    }
}

// Table View Data Source
extension ToDoListViewController: UITableViewDataSource {
    // row 개수 = 생성한 task 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskViewModel.lists[index!].tasks.count
    }
    
    // cell 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? ToDoCell else { return UITableViewCell() }
        // cell tap 시 배경색 회색되지 않게
        cell.selectionStyle = .none
        
        var task: Task = taskViewModel.lists[index!].tasks[indexPath.row]
        
        // cell 뷰 적용
        cell.btnCheck.isSelected = task.isDone
        cell.checkbutton(isDone: task.isDone)
        cell.lblTask.text = task.title
        cell.btnImportant.isSelected = task.isImportant
        
        // check & important 버튼 tap에 따른 데이터 변경 Handler를 통해 적용

        cell.checkButtonTapHandler = { isDone in
            task.isDone = isDone
            // Important task의 경우 양쪽 list에 모두 데이더 업데이트
            if self.index == 0 || task.isImportant {
                self.taskViewModel.updateTask(listId: 1, taskId: task.id, task: task)
                self.taskViewModel.updateTask(listId: task.listId, taskId: task.id, task: task)
            }
            self.taskViewModel.updateTask(listId: task.listId, taskId: task.id, task: task)
            self.tableView.reloadData()
        }
        
        cell.importantButtonTapHandler = { isImportant in
            task.isImportant = isImportant
            self.taskViewModel.updateTask(listId: task.listId, taskId: task.id, task: task)
            
            // Important list에 대한 추가/삭제 적용
            if isImportant {
                self.taskViewModel.addImportant(task)
            } else {
                self.taskViewModel.unImportant(listId: task.listId, taskId: task.id, task: task)
            }
            self.tableView.reloadData()
        }
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
        
        // Done button 노출
        btnDone.isHidden = false
    }
    
    // textfield 영역 높이 원점
    @objc private func keyboardWillHide() {
        tfViewBottom.constant = 0
        
        // Done Button 숨김
        btnDone.isHidden = true
    }
    
    // keyboard 숨기기 : list name edit or add a task 상황인지에 따라 동작 분리
    @objc private func hideKeyBoard() {
        if textField.isFirstResponder {
            textField.text = ""
            textField.resignFirstResponder()
            tfView.isHidden = true
        } else if lblListName.isFirstResponder {
            lblListName.resignFirstResponder()
        }
    }
}

class ToDoCell: UITableViewCell {
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTask: UILabel!
    @IBOutlet weak var btnImportant: UIButton!
    
    var checkButtonTapHandler: ((Bool) -> Void)?
    var importantButtonTapHandler: ((Bool) -> Void)?
    
    @IBAction func btnCheckTapped(_ sender: UIButton) {
        // 클릭 시 이전 상태와 반대로 상태 바꿈
        btnCheck.isSelected = !btnCheck.isSelected
        
        // isDone의 상태에 따라 task 글자 취소선, 흐리게 처리
        checkbutton(isDone: btnCheck.isSelected)
        
        // 데이터 변동 : checkButtonTapHandler에 isDone 여부 전송
        checkButtonTapHandler?(btnCheck.isSelected)
    }
    
    @IBAction func btnImportantTapped(_ sender: UIButton) {
        // 클릭 시 이전 상태와 반대로 상태 바꿈
        btnImportant.isSelected = !btnImportant.isSelected
        
        // 데이터 변동 : importantButtonTapHandler에 isImportant 여부 전송
        importantButtonTapHandler?(btnImportant.isSelected)
    }
    
    // isDone의 상태에 따라 task 글자 취소선, 흐리게 처리
    func checkbutton(isDone: Bool) {
        if isDone {
            lblTask.attributedText = NSAttributedString(string: lblTask.text!, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            lblTask.alpha = 0.5
        } else {
            lblTask.attributedText = NSAttributedString(string: lblTask.text!, attributes: [.strikethroughStyle: NSUnderlineStyle()])
            lblTask.alpha = 1
        }
    }
}
