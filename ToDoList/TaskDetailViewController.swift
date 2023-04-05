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
        let currentList = taskViewModel.lists[listIndex]
        
        // task 정보 view에 적용
        configureUI(listName: currentList.name, task: currentList.tasks[taskIndex])

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
        hideKeyboard()
    }
    
    @IBAction func btnDeleteTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func btnCheckTapped(_ sender: UIButton) {
        btnCheck.isSelected = !btnCheck.isSelected
        checkbutton(isDone: btnCheck.isSelected)
    }
    
    @IBAction func btnImportantTapped(_ sender: UIButton) {
        btnImportant.isSelected = !btnImportant.isSelected
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
    
    // 키보드 숨기기
    @objc private func hideKeyboard() {
        lblTaskTitle.resignFirstResponder()
    }
}
