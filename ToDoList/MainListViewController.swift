//
//  MainListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class MainListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblCount: UILabel!
    
    var taskViewModel = TaskViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Navigation Bar 숨김
        navigationController?.navigationBar.isHidden = true
        
        self.tableView.reloadData()
        
        let count = taskViewModel.lists.count - 1
        if count <= 1 {
            lblCount.text = "You have \(count) custom list."
        } else {
            lblCount.text = "You have \(count) custom lists."
        }
    }
    
    @IBAction func btnNewListTapped(_ sender: UIButton) {
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
        // >> icon : Important만 star image, 나머지 list는 checklist image
        if indexPath.row == 0 {
            cell.listIcon.image = UIImage(systemName: "star.fill")
        } else {
            cell.listIcon.image = UIImage(systemName: "checklist.checked")
        }
        
        // >> text label
        let list = taskViewModel.lists[indexPath.row]
        cell.lblListName?.text = list.name
        
        // >> count label : list 당 task 개수 표시. 0개일 때는 표시 X
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
        toDoListVC.taskViewModel = self.taskViewModel
        toDoListVC.index = indexPath.row
        self.navigationController?.pushViewController(toDoListVC, animated: true)
    }
}

class ListNameCell: UITableViewCell {
    @IBOutlet weak var listIcon: UIImageView!
    @IBOutlet weak var lblListName: UILabel!
    @IBOutlet weak var lblTaskCount: UILabel!
}
