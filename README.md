# ToDoList
> 안녕하세요, Emily입니다. 이 앱은 제가 Swift 프로그래밍과 iOS 앱 개발을 독학하며 처음으로 혼자 만든 프로젝트입니다.
> <br>ToDoList는 이름 그대로 투두리스트 앱으로, `할 일`과 `할 일 그룹`을 관리하는 앱입니다.

<img src="https://github.com/user-attachments/assets/5bbff787-ea7e-4532-99aa-fb5f116ec8bc">

## 개요
- 개인 프로젝트입니다.
- storyboard 기반 `UIKit`으로 구현했습니다.
- 오토레이아웃을 적용했습니다.
- `MVC` 아키텍처를 적용했습니다.
## 프로젝트 구조
```
📦 ToDoList
├── 📂 Delegate
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── 📂 Extension
│   ├── Extension+String.swift
│   ├── Extension+UIStoryboard.swift
│   └── Extension+UIViewController.swift
├── 📂 Model
│   ├── List.swift
│   ├── Task.swift
│   └── TodoManager.swift
├── 📂 Storyboard
│   ├── LaunchScreen.storyboard
│   └── Main.storyboard
├── 📂 Controller
│   ├── MainListViewController.swift
│   ├── AddNewListViewController.swift.swift
│   ├── ToDoListViewController.swift
│   └── TaskDetailViewController.swift
├── Assets.xcassets
└── Info.plist
```
## 화면 별 구현
### 01) 메인 화면
| MainListView | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/6c996b8e-669f-462c-bfe9-70673f11b220" width="320"> | - 할 일(`Task`)의 그룹인 `List`들의 목록을 `UITableView`로 구현한 메인 화면입니다.<br>- 북마크 된 Task들이 추가되는 `Important` list는 앱 최초 실행 시 기본값으로 존재합니다.<br>- 리스트 이름 오른쪽에는 리스트에 추가 된 할 일(`Task`) 개수를 나타내는 label이 있습니다.<br>- 하단 label에서 `Important` list를 제외한 커스텀 list의 개수를 안내하고 있습니다.<br>- 하단 `+ New List` 버튼을 눌러 새로운 `List`를 추가할 수 있습니다. |
#### MVC 아키텍처를 따르기 때문에, view controller가 TodoManager에 의존하여 UI configuring
```swift
class MainListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    private var todoManager: TodoManager!

    // ... //

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoManager.lists.count
    }
}
```
| | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/600005b9-6175-44f4-a4d3-8868061e89dd"> | - 리스트 셀을 스와이프하여 삭제할 수 있습니다.<br>- Delete 버튼을 누르면, 삭제 여부를 확실히 묻는 액션시트가 호출됩니다. |
```swift
// Important list는 swipe 불가능하도록 처리
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
            self?.todoManager.deleteList(listId: list.id)
            // ... 삭제 처리 및 UI 갱신 ... //
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true)
    }
}
```


### 02) 리스트 추가 화면
| AddNewListView | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/729c6416-f29f-4834-955a-260815608e99" width="320"> | - 새로운 리스트를 추가하는 화면입니다.<br>- 사용자의 입력값이 공백인 경우 placeholder에 적혀있는 `Untitled list`로 추가됩니다. |
#### 화면에 진입하자마자 키보드 호출
```swift
class AddNewListViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
    }

    // ... //
}
```

| | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/40de2276-83f4-4595-adb3-c902f80f6c5e"> | `Cancel` 버튼을 누르면 다시 메인 화면으로, `Done` 버튼을 누르면 추가된 리스트의 `Todo` 화면으로 이동합니다. |
- Cancel 버튼 : 새로운 list 추가를 취소하고 이전 화면(main)으로 회귀
```swift
@IBAction func cancelButtonTapped(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
}
```
- Done 버튼 : textfield에 입력된 이름으로 list 생성하며 task 목록 화면(ToDoListViewController)으로 이동
```swift
@IBAction func doneButtonTapped(_ sender: UIButton) {
    // 새로운 list 생성
    guard let input = textField.text else { return }
    todoManager.addList(with: input)
        
    // 생성된 list의 index를 ToDoListViewController로 넘기면서 이동
    let toDoListViewController: ToDoListViewController = Storyboard.main.instantiateViewController(todoManager: todoManager)
    toDoListViewController.index = todoManager.numberOfCustomLists
    self.navigationController?.pushViewController(toDoListViewController, animated: false)
}
```
#### TodoListView에 진입하면, navigation stack에서 AddNewListView를 제거한다 : popViewController를 했을 때 메인 뷰로 돌아가기 위함
> 이 때, 리스트 추가가 아닌 메인 뷰에서 테이블 뷰 셀을 탭하여 바로 이동했을 경우엔 해당 처리를 하지 않는다.
```swift
class ToDoListViewController: UIViewController
    // ... //

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let navigationController = self.navigationController else { return }
        // stack의 모든 view controller를 array로 가져온다.
        var navigationArray = navigationController.viewControllers
        // MainListView에서 cell을 탭하여 이동했을 경우 조치 X >>> AddNewListView에서 넘어왔을 경우 Stack에서 삭제
        if navigationArray.count > 2 {
            navigationArray.remove(at: 1)
            self.navigationController?.viewControllers = navigationArray
        }
    }
}
```

### 03) 투두리스트 화면
| TodoListView | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/d22c3a6f-ad8e-42e8-b4a0-689cecb2d571" width="320"> | 메인화면에서 리스트 셀을 탭하면 나타나는 화면입니다. |
#### 학습 목적으로 Task 목록은 UICollectionView로 구현
```swift
class ToDoListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!

    // ... //

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

    // ... //
}
```
#### 컬렉션 뷰 레이아웃 : UICollectionViewDelegateFlowLayout을 채택하여 구현
```swift
extension ToDoListViewController: UICollectionViewDelegateFlowLayout {
    // cell 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 30
        return CGSize(width: width, height: height)
    }

    // ... //
}
```

| | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/1fafe293-e835-4dd8-a19d-dfd0892f51e7"> | - `+ Add a Task` 버튼을 탭하면 키보드와 입력창이 올라옵니다.<br>- 화면을 누르면 입력모드가 취소되고, Done을 누르면 `Task`가 추가됩니다. |
#### 키보드 오르고 내릴 때마다 입력창 UI 위치 변경 : NSLayoutConstraint 값 조절
> `+ Add a Task` 버튼을 누르면 버튼은 숨김 + textfield 노출하고 키보드 위에 위치 시킴 + 오른쪽 상단 Done 버튼 나타남
> <br>`NotifiCationCenter`로 키보드 감지 : `UIResponder.keyboardWillShowNotification`, `.keyboardWillHideNotification`으로 가능
```swift
class ToDoListViewController: UIViewController {
    @IBOutlet weak var textFieldContainer: UIView!  // check 버튼 이미지 + textfield
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var textFieldBottonConstraint: NSLayoutConstraint!

    // ... //

    override func viewDidLoad() {
        // ... //

        // 키보드 감지 observer 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        textFieldContainer.isHidden = false
        textField.becomeFirstResponder()
    }

    @objc private func keyboardWillShow(notification: Notification) {
        // 키보드 높이 추출
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardFrame.height
        // 키보드 높이 - safearea bottom
        let adjustmentHeight = keyboardHeight - view.safeAreaInsets.bottom
        // textfield의 bottom 제약조건에 계산한 높이 값을 적용한다.
        textFieldBottonConstraint.constant = adjustmentHeight
        // done 버튼 노출
        doneButton.isHidden = false
    }

    @objc private func keyboardWillHide() {
        // textfield bottom 제약조건 원점
        textFieldBottonConstraint.constant = 0
        // done 버튼 숨김
        doneButton.isHidden = true
    }
}
```
#### 화면을 눌렀을 때 입력모드 취소 : `UITapGestureRecognizer` 활용
```swift
class ToDoListViewController: UIViewController {
    var tapGestureRecognizer = UITapGestureRecognizer()

    // ... //

    override func viewDidLoad() {
        // ... //

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // collection view cell에 대한 tap 인식과 중복되지 않도록 처리 필요
        tapGestureRecognizer.cancelsTouchesInView = false
    }

    // ... //

    @objc private func hideKeyboard() {
        textField.text = ""
        textFieldContainer.isHidden = true
        textField.resignFirstResponder()
    }
}
```
