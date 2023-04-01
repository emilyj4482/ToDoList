//
//  MainListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class MainListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var taskViewModel = TaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // pop 이기 때문에 동작하지 않는다. 추후에 reload 필요
        print(taskViewModel.lists)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Navigation Bar 숨김
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func btnNewListTapped(_ sender: UIButton) {
        print(taskViewModel.lists)
        guard let addNewListVC = self.storyboard?.instantiateViewController(identifier: "AddNewListViewController") as? AddNewListViewController else { return }
        // AddNewListViewController로 ViewModel 넘기면서 이동
        addNewListVC.taskViewModel = self.taskViewModel
        self.navigationController?.pushViewController(addNewListVC, animated: true)
    }
}

// Table View Data Source
extension MainListViewController: UITableViewDataSource {
    // row 개수 = 생성한 list 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskViewModel.lists.count
    }
    
    // cell 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListNameCell", for: indexPath) as? ListNameCell else { return UITableViewCell() }
        // cell tap 시 배경색 회색되지 않게
        cell.selectionStyle = .none
        // cell 뷰 적용
        // >> icon
        if indexPath.row > 0 {
            cell.listIcon.image = UIImage(systemName: "checklist.checked")
        }
        
        // >> text label
        let list = taskViewModel.lists[indexPath.row]
        cell.lblListName?.text = list.name
        
        // >> count label
        if list.tasks.count == 0 {
            cell.lblTaskCount.text = ""
        } else {
            cell.lblTaskCount.text = String(list.tasks.count)
        }
        return cell
    }
}

// Table View Delegate
extension MainListViewController: UITableViewDelegate {
    // row 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // row tap 시 동작
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let toDoListVC = self.storyboard?.instantiateViewController(identifier: "ToDoListViewController") as? ToDoListViewController else { return }
        // ToDoListViewController로 ViewModel 및 list 정보 넘기면서 이동
        toDoListVC.list = taskViewModel.lists[indexPath.row]
        self.navigationController?.pushViewController(toDoListVC, animated: true)
    }
}

class ListNameCell: UITableViewCell {
    @IBOutlet weak var listIcon: UIImageView!
    @IBOutlet weak var lblListName: UILabel!
    @IBOutlet weak var lblTaskCount: UILabel!
}
