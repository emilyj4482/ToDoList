//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class ToDoListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tfView: UIView!
    @IBOutlet weak var btnAddTask: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var tfViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lblListName: UITextField!
    
    var taskViewModel = TaskViewModel.shared
    var index: Int?
    var tapGestureRecognizer = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        // 키보드 detection
        detectKeyboard()
        // (입력 종료) 사용자의 화면 tap을 감지하여 keyboard 숨김
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // collectionview cell에 대한 touch가 인식되도록 처리
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)

        guard let index = index else { return }
        // list 이름 라벨에 적용
        self.lblListName.text = taskViewModel.lists[index].name
        // Important list의 경우 star icon을 통해서만 task를 추가할 수 있도록 구현 >> Add a Task 기능 비활성화
        // Important list가 아닐 경우 label(textfield) 탭 시 edit 가능
        if index == 0 {
            btnAddTask.isHidden = true
        } else {
            lblListName.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // AddNewViewController를 Navigation Stack에서 제외한다. >> popViewController를 했을 때 이전 Stack이 MainListViewController가 되게 하기 위함
        guard let navigationController = self.navigationController else { return }
        // stack의 모든 View Controller를 Array로 가져온다.
        var navigationArray = navigationController.viewControllers
        // MainListViewController에서 cell을 탭하여 이동했을 경우, 조치 X
        // AddNewListViewController에서 넘어왔을 경우, Stack에서 삭제한다.
        if navigationArray.count > 2 {
            navigationArray.remove(at: 1)
            self.navigationController?.viewControllers = navigationArray
        }
    }
    
    // Lists 버튼 : MainViewController로 돌아간다.
    @IBAction func btnListsTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Done 버튼 : list name을 tap하거나, + Add a Task 버튼을 tap했을 때 노출된다. 상황에 따라 동작이 분리된다.
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        guard let title = textField.text?.trim() else { return }
        guard let name = lblListName.text?.trim() else { return }
        
        guard let index = index else { return }
        let list = taskViewModel.lists[index]
        
        // list name 수정 : 입력된 값으로 list 이름 update
        // task 추가 : 입력된 값으로 task create & add
        if textField.isFirstResponder && !title.isEmpty {
            taskViewModel.addTask(listId: list.id, taskViewModel.createTask(listId: list.id, title))
        } else if lblListName.isFirstResponder {
            // 공백 입력 시 수정 적용 X
            if name.isEmpty {
                taskViewModel.updateList(listId: list.id, list.name)
            } else {
                taskViewModel.updateList(listId: list.id, name)
            }
        }
        // 공통 동작 : 키보드 숨김
        hideKeyboard()
        self.collectionView.reloadData()
    }
    
    // + Add a Task 버튼을 누르면 텍스트필드와 Done 버튼의 숨김이 해제되고 할 일을 입력할 수 있도록 키보드가 나타난다.
    @IBAction func btnAddTapped(_ sender: UIButton) {
        tfView.isHidden = false
        textField.becomeFirstResponder()
    }
}

// Collection View Data Source
extension ToDoListViewController: UICollectionViewDataSource {
    
    // section 개수 : task Done 발생 시 2개 아니면 1개
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let index = index else { return 0 }
        if taskViewModel.lists[index].tasks.firstIndex(where: { $0.isDone == true }) != nil {
            return 2
        } else {
            return 1
        }
    }
    
    // section 별 item 개수 : isDone 상태에 따라 구별
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let index = index else { return 0 }
        if section == 0 {
            return taskViewModel.unDoneTasks(listIndex: index).count
        } else {
            return taskViewModel.isDoneTasks(listIndex: index).count
        }
    }
    
    // cell 지정 : task done 여부에 따라 section 분리
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToDoCell", for: indexPath) as? ToDoCell else { return UICollectionViewCell() }
        
        guard let index = index else { return UICollectionViewCell() }
        var task: Task
        
        if indexPath.section == 0 {
            task = taskViewModel.unDoneTasks(listIndex: index)[indexPath.item]
        } else {
            task = taskViewModel.isDoneTasks(listIndex: index)[indexPath.item]
        }
        
        // cell 뷰 적용
        cell.btnCheck.isSelected = task.isDone
        cell.checkbutton(isDone: task.isDone)
        cell.lblTask.text = task.title
        cell.btnImportant.isSelected = task.isImportant
        
        // check & important 버튼 tap에 따른 데이터 변경 Handler를 통해 적용

        cell.checkButtonTapHandler = { isDone in
            task.isDone = isDone
            self.taskViewModel.updateTaskComplete(task)
            self.collectionView.reloadData()
        }
        
        cell.importantButtonTapHandler = { isImportant in
            task.isImportant = isImportant
            self.taskViewModel.updateImportant(task)
            self.collectionView.reloadData()
        }
        return cell
    }
    
    // header view 지정
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TaskDoneHeader", for: indexPath) as? TaskDoneHeader else { return UICollectionReusableView() }
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

// Collection View Delegate
extension ToDoListViewController: UICollectionViewDelegate {
    // item tap 시 동작 : 해당 task의 상세화면(TaskDetailViewController)으로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let taskDetailVC = self.storyboard?.instantiateViewController(identifier: "TaskDetailViewController") as? TaskDetailViewController else { return }
        guard let index = index else { return }
        
        // section에 따라 task의 id 및 list id 추출
        let taskId: Int
        let listId: Int
        if indexPath.section == 0 {
            taskId = taskViewModel.unDoneTasks(listIndex: index)[indexPath.item].id
            listId = taskViewModel.unDoneTasks(listIndex: index)[indexPath.item].listId
        } else {
            taskId = taskViewModel.isDoneTasks(listIndex: index)[indexPath.item].id
            listId = taskViewModel.isDoneTasks(listIndex: index)[indexPath.item].listId
        }
        
        // 추출한 task id로 tasks에서의 index, 속한 list id 정보를 가져와 현재 페이지의 list 이름과 함께 넘긴다.
        guard let listIndex = taskViewModel.lists.firstIndex(where: { $0.id == listId }) else { return }
        taskDetailVC.taskIndex = taskViewModel.lists[listIndex].tasks.firstIndex(where: { $0.id == taskId })
        taskDetailVC.listId = listId
        taskDetailVC.previousListName = lblListName.text
        self.navigationController?.pushViewController(taskDetailVC, animated: true)
    }
}

extension ToDoListViewController: UICollectionViewDelegateFlowLayout {
    // cell 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 30
        return CGSize(width: width, height: height)
    }
    
    // header 크기 지정 : section 0은 header 안보이게 하고, section 1만 보이게
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 35
        if section == 1 {
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}

// Keyboard 관련 기능 : 1) Keyboard 노출 = Done button 노출 2) Add a Task 버튼 클릭 시 textfield를 포함한 view가 키보드 바로 위에 위치하도록 구현
extension ToDoListViewController {
    // 키보드 detection
    func detectKeyboard() {
        // 키보드가 나타나는 것 감지 >> keyboardWillShow 함수 호출
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 키보드가 사라지는 것 감지 >> keyboardWillHide 함수 호출
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        // keyboard 크기 > 높이 추출
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardFrame.height
        // 적용할 높이 = keyboard 높이 - safe area 높이
        let adjustmentHeight = keyboardHeight - view.safeAreaInsets.bottom
        // 적용할 높이만큼 textfield 영역 높임
        tfViewBottom.constant = adjustmentHeight
        
        // Done button 노출
        btnDone.isHidden = false
        
        // 키보드가 올라온 상태에서는 view touch cancel (이렇게 하지 않으면 Done 버튼을 눌러도 그냥 view touch로 인식되어 버튼 기능이 작동하지 않는다)
        tapGestureRecognizer.cancelsTouchesInView = true
    }
    
    // textfield 영역 높이 원점
    @objc private func keyboardWillHide() {
        tfViewBottom.constant = 0
        
        // Done Button 숨김
        btnDone.isHidden = true
        
        // 키보드가 내려가면서 view touch 활성화 (tableview cell에 대한 touch 인식하도록 처리)
        tapGestureRecognizer.cancelsTouchesInView = false
    }
    
    // keyboard 숨기기 : list name edit or add a task 상황인지에 따라 동작 분리
    @objc private func hideKeyboard() {
        guard let index = index else { return }
        // add a task : textfield를 비우고 영역 숨김
        if textField.isFirstResponder {
            textField.text = ""
            tfView.isHidden = true
            textField.resignFirstResponder()
        } else if lblListName.isFirstResponder {
            // list name edit : done 버튼 탭이 아니라 단순히 다른 영역 tap인 경우 데이터 변동 X
            lblListName.text = taskViewModel.lists[index].name
            lblListName.resignFirstResponder()
        }
    }
}

class ToDoCell: UICollectionViewCell {
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTask: UILabel!
    @IBOutlet weak var btnImportant: UIButton!
    
    var checkButtonTapHandler: ((Bool) -> Void)?
    var importantButtonTapHandler: ((Bool) -> Void)?
    
    @IBAction func btnCheckTapped(_ sender: UIButton) {
        // 클릭 시 이전 상태와 반대로 상태 바꿈
        btnCheck.isSelected = !btnCheck.isSelected
        
        // isDone의 상태에 따라 task 글자 취소선, 흐리게 처리
        checkbutton(isDone: btnCheck.isSelected)
        
        // 데이터 변동 : checkButtonTapHandler에 isDone 여부 전송
        checkButtonTapHandler?(btnCheck.isSelected)
    }
    
    @IBAction func btnImportantTapped(_ sender: UIButton) {
        // 클릭 시 이전 상태와 반대로 상태 바꿈
        btnImportant.isSelected = !btnImportant.isSelected
        
        // 데이터 변동 : importantButtonTapHandler에 isImportant 여부 전송
        importantButtonTapHandler?(btnImportant.isSelected)
    }
    
    // isDone의 상태에 따라 task 글자 취소선, 흐리게 처리
    func checkbutton(isDone: Bool) {
        if isDone {
            lblTask.attributedText = NSAttributedString(string: lblTask.text!, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            lblTask.alpha = 0.5
        } else {
            lblTask.attributedText = NSAttributedString(string: lblTask.text!, attributes: [.strikethroughStyle: NSUnderlineStyle()])
            lblTask.alpha = 1
        }
    }
}

class TaskDoneHeader: UICollectionReusableView {}
