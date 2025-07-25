//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/27.
//

import UIKit

class ToDoListViewController: UIViewController, TodoManagerInjectable {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var textFieldBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var listNameTextField: UITextField!
    
    private var todoManager: TodoManager!
    
    func inject(todoManager: TodoManager) {
        self.todoManager = todoManager
    }
    
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
        self.listNameTextField.text = todoManager.lists[index].name
        // Important list의 경우 star icon을 통해서만 task를 추가할 수 있도록 구현 >> Add a Task 기능 비활성화
        // Important list가 아닐 경우 label(textfield) 탭 시 edit 가능
        if index == 0 {
            addTaskButton.isHidden = true
        } else {
            listNameTextField.isEnabled = true
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
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Done 버튼 : list name을 tap하거나, + Add a Task 버튼을 tap했을 때 노출된다. 상황에 따라 동작이 분리된다.
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard let title = textField.text?.trim() else { return }
        guard let name = listNameTextField.text?.trim() else { return }
        
        guard let index = index else { return }
        let list = todoManager.lists[index]
        
        // list name 수정 : 입력된 값으로 list 이름 update
        // task 추가 : 입력된 값으로 task create & add
        if textField.isFirstResponder && !title.isEmpty {
            todoManager.addTask(listId: list.id, todoManager.createTask(listId: list.id, title))
        } else if listNameTextField.isFirstResponder {
            // 공백 입력 시 수정 적용 X
            if name.isEmpty {
                todoManager.updateList(listId: list.id, list.name)
            } else {
                todoManager.updateList(listId: list.id, name)
            }
        }
        // 공통 동작 : 키보드 숨김
        hideKeyboard()
        self.collectionView.reloadData()
    }
    
    // + Add a Task 버튼을 누르면 텍스트필드와 Done 버튼의 숨김이 해제되고 할 일을 입력할 수 있도록 키보드가 나타난다.
    @IBAction func addButtonTapped(_ sender: UIButton) {
        textFieldContainer.isHidden = false
        textField.becomeFirstResponder()
    }
}

// Collection View Data Source
extension ToDoListViewController: UICollectionViewDataSource {
    
    // section 개수 : task Done 발생 시 2개 아니면 1개
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let index = index else { return 0 }
        if todoManager.lists[index].tasks.firstIndex(where: { $0.isDone == true }) != nil {
            return 2
        } else {
            return 1
        }
    }
    
    // section 별 item 개수 : isDone 상태에 따라 구별
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let index = index else { return 0 }
        if section == 0 {
            return todoManager.unDoneTasks(listIndex: index).count
        } else {
            return todoManager.isDoneTasks(listIndex: index).count
        }
    }
    
    // cell 지정 : task done 여부에 따라 section 분리
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToDoCell.identifier, for: indexPath) as? ToDoCell else { return UICollectionViewCell() }
        
        guard let index = index else { return UICollectionViewCell() }
        var task: Task
        
        if indexPath.section == 0 {
            task = todoManager.unDoneTasks(listIndex: index)[indexPath.item]
        } else {
            task = todoManager.isDoneTasks(listIndex: index)[indexPath.item]
        }
        
        // cell 뷰 적용
        cell.checkButton.isSelected = task.isDone
        cell.checkbutton(isDone: task.isDone)
        cell.taskLabel.text = task.title
        cell.startButton.isSelected = task.isImportant
        
        // check & important 버튼 tap에 따른 데이터 변경 Handler를 통해 적용

        cell.checkButtonTapHandler = { isDone in
            task.isDone = isDone
            self.todoManager.updateTaskComplete(task)
            self.collectionView.reloadData()
        }
        
        cell.importantButtonTapHandler = { isImportant in
            task.isImportant = isImportant
            self.todoManager.updateImportant(task)
            self.collectionView.reloadData()
        }
        return cell
    }
    
    // header view 지정
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskDoneHeader.identifier, for: indexPath) as? TaskDoneHeader else { return UICollectionReusableView() }
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
        let taskDetailViewController: TaskDetailViewController = Storyboard.main.instantiateViewController(todoManager: todoManager)
        guard let index = index else { return }
        
        // section에 따라 task의 id 및 list id 추출
        let taskId: Int
        let listId: Int
        if indexPath.section == 0 {
            taskId = todoManager.unDoneTasks(listIndex: index)[indexPath.item].id
            listId = todoManager.unDoneTasks(listIndex: index)[indexPath.item].listId
        } else {
            taskId = todoManager.isDoneTasks(listIndex: index)[indexPath.item].id
            listId = todoManager.isDoneTasks(listIndex: index)[indexPath.item].listId
        }
        
        // 추출한 task id로 tasks에서의 index, 속한 list id 정보를 가져와 현재 페이지의 list 이름과 함께 넘긴다.
        guard let listIndex = todoManager.lists.firstIndex(where: { $0.id == listId }) else { return }
        taskDetailViewController.taskIndex = todoManager.lists[listIndex].tasks.firstIndex(where: { $0.id == taskId })
        taskDetailViewController.listId = listId
        taskDetailViewController.previousListName = listNameTextField.text
        self.navigationController?.pushViewController(taskDetailViewController, animated: true)
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
        textFieldBottonConstraint.constant = adjustmentHeight
        
        // Done button 노출
        doneButton.isHidden = false
        
        // 키보드가 올라온 상태에서는 view touch cancel (이렇게 하지 않으면 Done 버튼을 눌러도 그냥 view touch로 인식되어 버튼 기능이 작동하지 않는다)
        tapGestureRecognizer.cancelsTouchesInView = true
    }
    
    // textfield 영역 높이 원점
    @objc private func keyboardWillHide() {
        textFieldBottonConstraint.constant = 0
        
        // Done Button 숨김
        doneButton.isHidden = true
        
        // 키보드가 내려가면서 view touch 활성화 (tableview cell에 대한 touch 인식하도록 처리)
        tapGestureRecognizer.cancelsTouchesInView = false
    }
    
    // keyboard 숨기기 : list name edit or add a task 상황인지에 따라 동작 분리
    @objc private func hideKeyboard() {
        guard let index = index else { return }
        // add a task : textfield를 비우고 영역 숨김
        if textField.isFirstResponder {
            textField.text = ""
            textFieldContainer.isHidden = true
            textField.resignFirstResponder()
        } else if listNameTextField.isFirstResponder {
            // list name edit : done 버튼 탭이 아니라 단순히 다른 영역 tap인 경우 데이터 변동 X
            listNameTextField.text = todoManager.lists[index].name
            listNameTextField.resignFirstResponder()
        }
    }
}

class ToDoCell: UICollectionViewCell {
    static let identifier = String(describing: ToDoCell.self)
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    var checkButtonTapHandler: ((Bool) -> Void)?
    var importantButtonTapHandler: ((Bool) -> Void)?
    
    @IBAction func btnCheckTapped(_ sender: UIButton) {
        // 클릭 시 이전 상태와 반대로 상태 바꿈
        checkButton.isSelected = !checkButton.isSelected
        
        // isDone의 상태에 따라 task 글자 취소선, 흐리게 처리
        checkbutton(isDone: checkButton.isSelected)
        
        // 데이터 변동 : checkButtonTapHandler에 isDone 여부 전송
        checkButtonTapHandler?(checkButton.isSelected)
    }
    
    @IBAction func btnImportantTapped(_ sender: UIButton) {
        // 클릭 시 이전 상태와 반대로 상태 바꿈
        startButton.isSelected = !startButton.isSelected
        
        // 데이터 변동 : importantButtonTapHandler에 isImportant 여부 전송
        importantButtonTapHandler?(startButton.isSelected)
    }
    
    // isDone의 상태에 따라 task 글자 취소선, 흐리게 처리
    func checkbutton(isDone: Bool) {
        if isDone {
            taskLabel.attributedText = NSAttributedString(string: taskLabel.text!, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            taskLabel.alpha = 0.5
        } else {
            taskLabel.attributedText = NSAttributedString(string: taskLabel.text!, attributes: [.strikethroughStyle: NSUnderlineStyle()])
            taskLabel.alpha = 1
        }
    }
}

class TaskDoneHeader: UICollectionReusableView {
    static let identifier = String(describing: TaskDoneHeader.self)
}
