//
//  AddNewListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class AddNewListViewController: UIViewController, TodoManagerInjectable {

    @IBOutlet weak var textField: UITextField!
    
    private var todoManager: TodoManager!
    
    func inject(todoManager: TodoManager) {
        self.todoManager = todoManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 화면 뜨자마자 텍스트필드 입력 모드(키보드 호출)
        textField.becomeFirstResponder()
    }

    // Cancel 버튼 : 새로운 list 추가를 취소하고 이전 화면(main)으로 회귀
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Done 버튼 : textfield에 입력된 이름으로 list 생성하며 task 목록 화면(ToDoListViewController)으로 이동
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        // 새로운 list 생성
        guard let input = textField.text else { return }
        todoManager.addList(with: input)
        
        // 생성된 list의 index를 ToDoListViewController로 넘기면서 이동
        let toDoListVC: ToDoListViewController = Storyboard.main.instantiateViewController(todoManager: todoManager)
        toDoListVC.index = todoManager.numberOfCustomLists
        self.navigationController?.pushViewController(toDoListVC, animated: false)
    }
}
