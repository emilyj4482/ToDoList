//
//  AddNewListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class AddNewListViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    var vm = TaskViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 화면 뜨자마자 텍스트필드 입력 모드(키보드 호출)
        textField.becomeFirstResponder()
    }

    // Cancel 버튼 : 새로운 list 추가를 취소하고 이전 화면(main)으로 회귀
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Done 버튼 : textfield에 입력된 이름으로 list 생성하며 task 목록 화면(ToDoListViewController)으로 이동
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        // 새로운 list 생성 (textfield 공백 시 "Untitled list" 부여)
        guard var newListName = textField.text?.trim() else { return }
        if newListName.isEmpty {
            newListName = "Untitled list"
        }
        vm.addList(vm.createList(examListName(newListName)))
        
        // 생성된 list의 index를 ToDoListViewController로 넘기면서 이동
        guard let toDoListVC = self.storyboard?.instantiateViewController(identifier: "ToDoListViewController") as? ToDoListViewController else { return }
        toDoListVC.index = vm.lists.count - 1
        self.navigationController?.pushViewController(toDoListVC, animated: false)
    }
    
    // list name 중복검사
    func examListName(_ text: String) -> String {
        let list = vm.lists.map { list in
            list.name
        }
        
        var count = 1
        var listName = text
        while list.contains(listName) {
            listName = "\(text) (\(count))"
            count += 1
        }
        
        return listName
    }
}
