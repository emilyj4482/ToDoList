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
    
    // 화면 탭할 시 키보드 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func btnDoneTapped(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
}
