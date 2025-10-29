# ToDoList
> 안녕하세요, Emily입니다. 이 앱은 제가 Swift 프로그래밍과 iOS 앱 개발을 독학하며 처음으로 혼자 만든 프로젝트입니다.
> <br>ToDoList는 이름 그대로 투두리스트 앱으로, `할 일`과 `할 일 그룹`을 관리하는 앱입니다.

<img src="https://github.com/user-attachments/assets/5bbff787-ea7e-4532-99aa-fb5f116ec8bc">

## 개요
- 개인 프로젝트입니다.
- storyboard 기반 `UIKit`으로 구현했습니다.
- 오토레이아웃을 적용했습니다.
- `MVC` 아키텍처를 적용했습니다.

## 목차
- [화면 별 구현사항](#📌-화면-별-구현)
- [트러블슈팅](#📌-트러블슈팅)

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
│   ├── AddNewListViewController.swift
│   ├── ToDoListViewController.swift
│   └── TaskDetailViewController.swift
├── Assets.xcassets
└── Info.plist
```

## 📌 스토리보드 기반 프로젝트에서 객체 의존성 주입
```swift
class MainViewController: UIViewController {
	private var todoManager: TodoManager
    
    init(todoManager: TodoManager) {
    	self.todoManager = TodoManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ... //
}
```
코드베이스 프로젝트에서 위 코드는 평범하고 성공적인 코드지만 스토리보드 프로젝트에서는 그렇지 않습니다. `required init?`이 최우선적으로 호출되고 `init`은 호출되지 않기 때문에 `manager` 객체를 이니셜라이징 하는 데 실패합니다.
> [자세한 이유와 고민 과정을 담은 포스트](https://velog.io/@emilyj4482/iOS-storyboard-%EA%B8%B0%EB%B0%98-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8%EC%97%90%EC%84%9C%EC%9D%98-%EC%9D%98%EC%A1%B4%EC%84%B1-%EC%A3%BC%EC%9E%85)

여러가지 방법이 있지만 저는 그중에서도 모든 컨트롤러에 `TodoManagerInjectable` protocol을 채택시켜 `inject` 메소드를 필수 구현하도록 하고, `UIStoryboard`의 `extension`을 활용하여 팩토리 메소드가 호출되도록 하였습니다.
```swift
protocol TodoManagerInjectable {
    func inject(todoManager: TodoManager)
}

class MainViewController: UIViewController, TodoManagerInjectable {
	private var todoManager: TodoManager!
    
    func inject(todoManager: TodoManager) {
        self.todoManager = todoManager
    }
}
```
```swift
extension UIStoryboard {
	func instantiateViewController<T: UIViewController & TodoManagerInjectable>(with todoManager: TodoManager) -> T {
    	// 1. identifier를 통해 view controller 생성
    	guard let viewController = instantiateViewController(withIdentifier: T.identifier) as? T else {
            fatalError("Could not instantiate \(T.self) with identifier '\(T.identifier)'")
        }
        // 2. 의존성 주입
        viewController.inject(todoManager: todoManager)
        // 3. 반환
        return viewController
    }
}
```
```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // manager 생성
        let todoManager: TodoManager = .init()
        
        // ViewController 타입을 명시하며 instantiate
        let rootViewController: MainViewController = Storyboard.main.instantiateViewController(todoManager: todoManager)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: rootViewController)
        window.makeKeyAndVisible()
        self.window = window
    }
    
    // ... //
}
```

## 📌 화면 별 구현
### 1️⃣ 메인 화면
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


### 2️⃣ 리스트 추가 화면
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
#### 이름 중복 검사 로직 : 같은 이름이 있을 경우 `Untitled list (1)`, `Untitled list (2)`...가 추가되도록 구현
```swift
// list name 검사 : 1. input 공백 시 "Untitled list" 부여 2. 중복 검사 후 이미 있는 이름일 경우 (n) 붙이고 반환
private func examListName(_ input: String) -> String {
    // 1. 공백 검사
    let text = input.trim().isEmpty ? "Untitled list" : input.trim()
        
    // 2. 중복 검사
    let listNames = lists.map { $0.name }
        
    var count = 1
    var listName = text
    while listNames.contains(listName) {
        listName = "\(text) (\(count))"
        count += 1
    }
       
    return listName
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

### 3️⃣ 투두리스트 화면
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

| | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/e914914d-3c12-456a-876d-dc43eccc1c09"> | List 타이틀 부분을 탭하면, 타이틀 수정모드가 됩니다. |
#### 타이틀 컴포넌트를 UItextField로 구현
> 이에 따라 `Done` 버튼을 탭했을 때 타이틀 수정 모드인지 할 일 추가 모드인지 분기 처리 필요
```swift
@IBAction func doneButtonTapped(_ sender: UIButton) {
    if taskTextField.isFirstResponder && !title.isEmpty {
            todoManager.addTask(...)
    } else if listNameTextField.isFirstResponder {
        todoManager.updateList(...)
    }

    hideKeyboard()
    collectionView.reloadData()
}
```

| | |
| ----- | ----- |
| <img src ="https://github.com/user-attachments/assets/5cf4b919-931a-49db-93a4-76e72abae804"> | - 할 일 완료/취소 처리, 중요한 일로 북마크/취소 처리를 할 수 있습니다.<br>- 북마크하면 `Important` 리스트에 추가되고, 업데이트 동작은 싱크됩니다. |
```swift
class TodoManager {
    // ... //

    func updateTaskComplete(_ task: Task) {
        // important task라면 Important list에서와 원래 속한 list 모두에서 업데이트 적용
        if task.isImportant {
            updateSingleTask(listId: 1, taskId: task.id, task: task)
        }
        updateSingleTask(listId: task.listId, taskId: task.id, task: task)
    }
}
```

### 4️⃣ 디테일 화면
| TaskDetailView | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/0c978981-137d-4fa0-a453-0a9a9b6284d4"> | - `TodoListView`에서 `Task` 셀을 탭하면 디테일 화면으로 이동합니다.<br>- 할 일 완료 및 북마크/취소 처리와 타이틀 수정, 할 일 삭제를 할 수 있습니다. |

## 📌 트러블슈팅
### 1️⃣ 제약조건(Constraint) 우선순위 문제
할 일 추가 시 키보드가 나타나면 `textfield` 영역을 키보드 위로 올리기 위해 `bottom` Constraint를 조정함
```swift
@objc private func keyboardWillShow(notification: Notification) {
    guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
    let keyboardHeight = keyboardFrame.height
    let adjustmentHeight = keyboardHeight - view.safeAreaInsets.bottom
    textFieldBottonConstraint.constant = adjustmentHeight
}
```
#### 📝 문제
키보드 높이를 계산하여 제약조건을 업데이트 했는데도 텍스트필드가 키보드 위가 아닌 아래로 이동해 화면 밖으로 벗어나는 현상 발생
#### 🎯 원인
오토레이아웃의 `First Item`과 `Second Item`이 잘못 설정 되어 있었음 - `TextFieldContainer.bottom = SafeArea.bottom + constant` 형태가 되어야 했으나 반대로 설정되어 `constant`가 양수일수록 아래 방향으로 이동하게 되었던 것
<br><br><img src="https://github.com/user-attachments/assets/d549b53c-b43a-4c0d-a75b-3a52c0be8468" width="300">
#### ⚡ 해결
`SafeArea.bottom`이 `First Item`이 되도록 지정
#### 💭 성과
- Constraint의 `First Item`과 `Second Item` 위치에 따라 `constant`의 방향(+, -)이 달라짐을 학습
- 오토레이아웃 문제의 원인을 찾을 때 뷰 계층과 제약조건 방향을 시각적으로 확인하는 것의 중요성을 깨달음

### 2️⃣ UITapGestureRecognizer 사용 시 터치이벤트 경합 문제
키보드가 올라와있는 상태에서 화면을 탭했을 때 키보드가 내려가도록 구현하기 위해 UITapGestureRecognizer 활용
```swift
override func viewDidLoad() {
	// ... //

	view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
}
```
#### 📝 문제 1
collectionView의 didSelectItemAt이 인식되지 않음
#### 🎯 원인
UITapGestureRecognizer.cancelsTouchesInView (탭 제스처 이외의 터치 이벤트 무시)의 기본값이 true - 셀에 대한 터치 이벤트가 뷰로 전달되지 않음
#### ⚡ 해결
UITapGestureRecognizer.cancelsTouchesInView를 false로 지정
```swift
let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
tapGestureRecognizer.cancelsTouchesInView = false
view.addGestureRecognizer(tapGestureRecognizer)
```
> 하지만 이렇게 처리한 뒤 새로운 문제 발생
#### 📝 문제 2
`UIButton`에 대한 탭 인식이 되지 않음 - 탭 제스처 이외의 터치 이벤트도 인식하도록 `cancelsTouchesInView = false`처리를 했기 때문에 예상을 벗어나는 상황
#### 🎯 원인
- cell 탭 이벤트는 UIKit 내부적으로 제스처 기반으로 처리되므로 UITapGestureRecognizer와 자연스럽게 공존
- 반면 button 탭은 UIControlEvent 기반으로 작동하여 제스처와 충돌
- 심지어, 키보드가 올라와 있다는 특수상황 때문에 키보드 dismiss 동작과 우선순위에서 밀리게 됨 > 버튼의 `touchUpInside`가 호출되지 않음(이벤트 무효화)

| 단계 | 셀 탭 (정상 동작) | 버튼 탭 (문제 발생) |
| --- | --- | --- |
| 1. 터치 시작 | 셀 터치 시작 | 버튼 터치 시작 |
| 2. iOS 내부 처리 | UITapGestureRecognizer와 셀 제스처 **동시에 작동** | **키보드 dismiss 제스처가 먼저 작동** |
| 3. cancelsTouchesInView = false | 두 이벤트 모두 처리됨 | 버튼 이벤트가 **소모되어 무효화** |
| 최종 결과 | `didSelectItemAt` 정상 호출 ✅ | `touchUpInside` 호출되지 않음 ❌ |

#### ⚡ 해결
cancelsTouchesInView 값을 키보드 상황에 따라 toggle
```swift
class ToDoListViewController: UIViewController {
	// ... //

	// 탭 제스쳐를 전역변수로 선언
	var tapGestureRecognizer = UITapGestureRecognizer()

	override func viewDidLoad() {
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		tapGestureRecognizer.cancelsTouchesInView = false view.addGestureRecognizer(tapGestureRecognizer)
	}

	// 입력모드 on/off 때마다 cancelsTouchesInView값 toggle
	@objc private func keyboardWillShow() {
		// ... //

		tapGestureRecognizer.cancelsTouchesInView = true
	}

	@objc private func keyboardWillHide() {
		// ... //

	tapGestureRecognizer.cancelsTouchesInView = false
	}
}
```
#### 💭 성과
- 셀과 버튼의 터치 이벤트 처리 방식이 다르다는 것 이해
- 특히 키보드가 올라와 있을 때는 키보드 dismiss 제스처가 우선 작동하여 버튼 이벤트가 무효화될 수 있다는 것을 학습
- 이벤트 충돌을 방지하는 제스처 관리 전략 습득
