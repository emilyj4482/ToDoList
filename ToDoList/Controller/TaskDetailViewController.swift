//
//  TaskDetailViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/04/04.
//

import UIKit

class TaskDetailViewController: UIViewController, TodoManagerInjectable {
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    private var todoManager: TodoManager!
    
    func inject(todoManager: TodoManager) {
        self.todoManager = todoManager
    }
    
    var taskIndex: Int?
    var listId: Int?
    var previousListName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이전 VC로부터 정보 전달 받기
        guard let taskIndex = taskIndex, let listIndex = todoManager.lists.firstIndex(where: { $0.id == listId }), let previousListName = previousListName else { return }
        let originalList = todoManager.lists[listIndex]
        
        // task 정보 view에 적용
        configureUI(listName: originalList.name, task: originalList.tasks[taskIndex])

        // Back 버튼 text에 이전 페이지 list 이름 적용
        backButton.setTitle(" \(previousListName)", for: .normal)
        
        // 키보드 detection
        detectKeyboard()
        // (textfield 입력 종료) 사용자의 화면 tap을 감지하여 keyboard 숨김
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    func configureUI(listName: String, task: Task) {
        checkButton.isSelected = task.isDone
        starButton.isSelected = task.isImportant
        listNameLabel.text = listName
        isTaskDone(isDone: task.isDone, string: task.title)
    }
    
    // isDone의 상태에 따라 task 글자 취소선, 흐리게 처리
    func isTaskDone(isDone: Bool, string: String) {
        if isDone {
            taskTitleTextField.attributedText = NSAttributedString(string: string, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            taskTitleTextField.alpha = 0.5
        } else {
            taskTitleTextField.attributedText = NSAttributedString(string: string, attributes: [.strikethroughStyle: NSUnderlineStyle()])
            taskTitleTextField.alpha = 1
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        // 키보드 숨김 처리
        taskTitleTextField.resignFirstResponder()
        
        // 데이터 update (view update는 textfield라 필요 X)
        guard let listIndex = todoManager.lists.firstIndex(where: { $0.id == listId }), let taskIndex = taskIndex, let taskTitle = taskTitleTextField.text?.trim() else { return }
        var task = todoManager.lists[listIndex].tasks[taskIndex]
        // textfield 공백 시 수정 적용 X
        if taskTitle.isEmpty {
            taskTitleTextField.text = task.title
        } else {
            task.title = taskTitle
            taskTitleTextField.text = taskTitle
        }
        todoManager.updateTaskComplete(task)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let listIndex = todoManager.lists.firstIndex(where: { $0.id == listId }), let taskIndex = taskIndex else { return }
        let task = todoManager.lists[listIndex].tasks[taskIndex]
        
        // 삭제 여부를 확실하게 묻는 alert 호출
        let alert = UIAlertController(title: "Delete task", message: "Are you sure you want to delete the task?", preferredStyle: .actionSheet)
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.todoManager.deleteTaskComplete(task)
            self?.navigationController?.popViewController(animated: true)
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true)
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        guard let listIndex = todoManager.lists.firstIndex(where: { $0.id == listId }), let taskIndex = taskIndex else { return }
        var task = todoManager.lists[listIndex].tasks[taskIndex]
        
        // view update
        checkButton.isSelected = !checkButton.isSelected
        isTaskDone(isDone: checkButton.isSelected, string: task.title)
        
        // 데이터 update
        task.isDone = checkButton.isSelected
        todoManager.updateTaskComplete(task)
    }
    
    @IBAction func starButtonTapped(_ sender: UIButton) {
        guard let listIndex = todoManager.lists.firstIndex(where: { $0.id == listId }), let taskIndex = taskIndex else { return }
        var task = todoManager.lists[listIndex].tasks[taskIndex]
        
        // view update
        starButton.isSelected = !starButton.isSelected
        
        // 데이터 update
        task.isImportant = starButton.isSelected
        todoManager.updateImportant(task)
    }
}

// Keyboard 관련 기능 : 1) keyboard 노출 = Done 버튼 노출, check, important 버튼 비활성화
extension TaskDetailViewController {
    
    // 키보드 detection
    func detectKeyboard() {
        // 키보드가 나타나는 것 감지 >> keyboardWillShow 함수 호출
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 키보드가 사라지는 것 감지 >> keyboardWillHide 함수 호출
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        doneButton.isHidden = false
        checkButton.isEnabled = false
        starButton.isEnabled = false
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        doneButton.isHidden = true
        checkButton.isEnabled = true
        starButton.isEnabled = true
    }
    
    // 키보드 숨기기 : done 버튼이 아닌 단순 화면 tap이기 때문에 입력이 발생하더라도 데이터 update되지 않고 task title label이 원래대로 돌아오도록 처리
    @objc private func hideKeyboard() {
        guard let listIndex = todoManager.lists.firstIndex(where: { $0.id == listId }), let taskIndex = taskIndex else { return }
        let task = todoManager.lists[listIndex].tasks[taskIndex]
        
        taskTitleTextField.resignFirstResponder()
        isTaskDone(isDone: task.isDone, string: task.title)
    }
}
