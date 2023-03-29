//
//  MainListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class MainListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    
    
    @IBAction func btnNewListTapped(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "AddNewListViewController") as? AddNewListViewController else { return }
        viewController.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
}

// Table View Data Source
extension MainListViewController: UITableViewDataSource {
    // row 개수 = 생성한 list 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    // cell 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListNameCell", for: indexPath)
        // cell tap 시 배경색 회색되지 않게
        cell.selectionStyle = .none
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
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "ToDoListViewController") as? ToDoListViewController else { return }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
