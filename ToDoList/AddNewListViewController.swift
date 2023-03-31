//
//  AddNewListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class AddNewListViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    let taskViewModel = TaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 화면 뜨자마자 텍스트필드 입력 모드(키보드 호출)
        textField.becomeFirstResponder()
    }
    
    

    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Done button 기능 : 1) 새로운 list를 생성하고 2) 생성된 list의 todo 목록으로 넘어간다.
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        // 1) 새로운 list 생성 (textfield 공백 시 Untitled list 전달)
        guard var newListName = textField.text else { return }
        if newListName.isEmpty {
            newListName = "Untitled list"
        }
        taskViewModel.addList(taskViewModel.createList(newListName))
        print(taskViewModel.lists)
        // 2) 생성된 list 정보를 ToDoListViewController로 넘기면서 이동
        guard let toDoListVC = self.storyboard?.instantiateViewController(identifier: "ToDoListViewController") as? ToDoListViewController else { return }
        toDoListVC.listName = newListName
        self.navigationController?.pushViewController(toDoListVC, animated: false)
    }
}
