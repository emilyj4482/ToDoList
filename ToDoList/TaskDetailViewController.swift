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
    
    var taskViewModel = TaskViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        
    }
    
}
