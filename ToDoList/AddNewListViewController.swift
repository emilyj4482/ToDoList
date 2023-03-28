//
//  AddNewListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class AddNewListViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 화면 뜨자마자 텍스트필드 입력 모드(키보드 호출)
        textField.becomeFirstResponder()
    }

    @IBAction func btnCancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
}
