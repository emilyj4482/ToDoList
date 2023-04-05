//
//  TaskDetailViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/04/04.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnImportant: UIButton!
    @IBOutlet weak var lblTaskTitle: UITextField!
    @IBOutlet weak var lblListName: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    
    var taskViewModel = TaskViewModel.shared
    var taskIndex: Int?
    var listId: Int?
    var previousListName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이전 VC로부터 정보 전달 받기
        guard let taskIndex = taskIndex, let listIndex = taskViewModel.lists.firstIndex(where: { $0.id == listId }), let previousListName = previousListName else { return }
        let originalList = taskViewModel.lists[listIndex]
        
        // task 정보 view에 적용
        configureUI(listName: originalList.name, task: originalList.tasks[taskIndex])

        // Back 버튼 text에 이전 페이지 list 이름 적용
        btnBack.setTitle(" \(previousListName)", for: .normal)
        
        // 키보드 detection
        detectKeyboard()
        // (textfield 입력 종료) 사용자의 화면 tap을 감지하여 keyboard 숨김
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    func configureUI(listName: String, task: Task) {
        btnCheck.isSelected = task.isDone
        btnImportant.isSelected = task.isImportant
        lblTaskTitle.text = task.title
        lblListName.text = listName
        checkbutton(isDone: task.isDone)
    }
    
    // isDone의 상태에 따라 task 글자 취소선, 흐리게 처리
    func checkbutton(isDone: Bool) {
        if isDone {
            lblTaskTitle.attributedText = NSAttributedString(string: lblTaskTitle.text!, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            lblTaskTitle.alpha = 0.5
        } else {
            lblTaskTitle.attributedText = NSAttributedString(string: lblTaskTitle.text!, attributes: [.strikethroughStyle: NSUnderlineStyle()])
            lblTaskTitle.alpha = 1
        }
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        // 키보드 숨김 처리
        lblTaskTitle.resignFirstResponder()
        
        // 데이터 update (view update는 textfield라 필요 X)
        guard let listIndex = taskViewModel.lists.firstIndex(where: { $0.id == listId }), let taskIndex = taskIndex, let taskTitle = lblTaskTitle.text else { return }
        var task = taskViewModel.lists[listIndex].tasks[taskIndex]
        task.title = taskTitle
        taskViewModel.updateTaskComplete(task)
    }
    
    @IBAction func btnDeleteTapped(_ sender: UIButton) {
        guard let listIndex = taskViewModel.lists.firstIndex(where: { $0.id == listId }), let taskIndex = taskIndex else { return }
        let task = taskViewModel.lists[listIndex].tasks[taskIndex]
        
        // 삭제 여부를 확실하게 묻는 alert 호출
        let alert = UIAlertController(title: "Delete task", message: "Are you sure you want to delete the task?", preferredStyle: .actionSheet)
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.taskViewModel.deleteTaskComplete(task)
            self.navigationController?.popViewController(animated: true)
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true)
    }
    
    @IBAction func btnCheckTapped(_ sender: UIButton) {
        // view update
        btnCheck.isSelected = !btnCheck.isSelected
        checkbutton(isDone: btnCheck.isSelected)
        
        // 데이터 update
        guard let listIndex = taskViewModel.lists.firstIndex(where: { $0.id == listId }), let taskIndex = taskIndex else { return }
        var task = taskViewModel.lists[listIndex].tasks[taskIndex]
        task.isDone = btnCheck.isSelected
        taskViewModel.updateTaskComplete(task)
    }
    
    @IBAction func btnImportantTapped(_ sender: UIButton) {
        // view update
        btnImportant.isSelected = !btnImportant.isSelected
        
        // 데이터 update
        guard let listIndex = taskViewModel.lists.firstIndex(where: { $0.id == listId }), let taskIndex = taskIndex else { return }
        var task = taskViewModel.lists[listIndex].tasks[taskIndex]
        task.isImportant = btnImportant.isSelected
        taskViewModel.updateImportant(task)
    }
}

// Keyboard 관련 기능 : 1) keyboard 노출 = Done 버튼 노출
extension TaskDetailViewController {
    
    // 키보드 detection
    func detectKeyboard() {
        // 키보드가 나타나는 것 감지 >> keyboardWillShow 함수 호출
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 키보드가 사라지는 것 감지 >> keyboardWillHide 함수 호출
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        btnDone.isHidden = false
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        btnDone.isHidden = true
    }
    
    // 키보드 숨기기 : done 버튼 tap이 아닌 단순 화면 tap이기 때문에 task title label이 원래대로 돌아오도록 처리
    @objc private func hideKeyboard() {
        guard let listIndex = taskViewModel.lists.firstIndex(where: { $0.id == listId }), let taskIndex = taskIndex else { return }
        var task = taskViewModel.lists[listIndex].tasks[taskIndex]
        
        lblTaskTitle.resignFirstResponder()
        lblTaskTitle.text = task.title
    }
}
