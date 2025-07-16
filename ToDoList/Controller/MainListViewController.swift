//
//  MainListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class MainListViewController: UIViewController, TodoManagerInjectable {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countLabel: UILabel!
    
    private var todoManager: TodoManager!
    
    func inject(todoManager: TodoManager) {
        self.todoManager = todoManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        // 로컬에서 저장된 데이터 불러오기
        todoManager.getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Navigation Bar 숨김
        navigationController?.navigationBar.isHidden = true
        
        self.tableView.reloadData()
        updateCountLabel()
    }
    
    // + New List 버튼 tap 시 AddNewListViewController로 이동
    @IBAction func AddNeweListButtonTapped(_ sender: UIButton) {
        let addNewListViewController: AddNewListViewController = Storyboard.main.instantiateViewController(todoManager: todoManager)
        self.navigationController?.pushViewController(addNewListViewController, animated: true)
    }
    
    // list count label 뷰 적용
    func updateCountLabel() {
        let count = todoManager.numberOfCustomLists
        if count <= 1 {
            countLabel.text = "You have \(count) custom list."
        } else {
            countLabel.text = "You have \(count) custom lists."
        }
    }
}

// Table View Data Source
extension MainListViewController: UITableViewDataSource {
    // row 개수 = 생성한 list 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoManager.lists.count
    }
    
    // cell 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListNameCell.identifier, for: indexPath) as? ListNameCell else { return UITableViewCell() }
        // cell tap 시 배경색 회색되지 않게
        cell.selectionStyle = .none
        // cell 뷰 적용
        // >> icon : Important만 star image, 나머지 list는 checklist image
        if indexPath.row == 0 {
            cell.listIcon.image = UIImage(systemName: "star.fill")
        } else {
            cell.listIcon.image = UIImage(systemName: "checklist.checked")
        }
        
        // >> text label
        let list = todoManager.lists[indexPath.row]
        cell.listNameLabel?.text = list.name
        
        // >> count label : list 당 task 개수 표시. 0개일 때는 표시 X
        if list.tasks.count == 0 {
            cell.taskCountLabel.text = ""
        } else {
            cell.taskCountLabel.text = String(list.tasks.count)
        }
        return cell
    }
    
    // Important list swipe 불가 처리
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }
    
    // cell swipe 시 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let list = todoManager.lists[indexPath.row]
        
        if indexPath.row > 0 && editingStyle == .delete {
            // 삭제 여부를 확실하게 묻는 alert 호출
            let alert = UIAlertController(title: "Delete list", message: "Are you sure you want to delete the list?", preferredStyle: .actionSheet)
            let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                // list가 important task를 포함하고 있을 때, list에 속했던 important task가 Important list에서도 삭제되어야 한다.
                if list.tasks.contains(where: { $0.isImportant }) {
                    self?.todoManager.lists[0].tasks.removeAll(where: { $0.listId == list.id && $0.isImportant })
                }
                self?.todoManager.deleteList(listId: list.id)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
                // list count label 뷰 적용
                self?.updateCountLabel()
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(deleteButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true)
        }
    }
}

// Table View Delegate
extension MainListViewController: UITableViewDelegate {
    // row 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    // row tap 시 동작 : 해당 list의 task 목록 화면(ToDoListViewController)으로 이동
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toDoListViewController: ToDoListViewController = Storyboard.main.instantiateViewController(todoManager: todoManager)
        // list의 index 정보를 같이 넘긴다.
        toDoListViewController.index = indexPath.row
        self.navigationController?.pushViewController(toDoListViewController, animated: true)
    }
}

class ListNameCell: UITableViewCell {
    static let identifier = String(describing: ListNameCell.self)
    
    @IBOutlet weak var listIcon: UIImageView!
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var taskCountLabel: UILabel!
}
