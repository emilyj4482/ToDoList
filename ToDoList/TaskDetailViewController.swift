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
        
    }
    
    @IBAction func btnCheckTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func btnImportantTapped(_ sender: UIButton) {
        
    }
}
