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
## 화면 별 기능 소개
### 01) 메인 화면
| MainListView | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/6c996b8e-669f-462c-bfe9-70673f11b220" width="320"> | - 할 일(`Task`)의 그룹인 `List`들의 목록을 `UITableView`로 구현한 메인 화면입니다.<br>- 북마크 된 Task들이 추가되는 `Important` list는 앱 최초 실행 시 기본값으로 존재합니다.<br>- 리스트 이름 오른쪽에는 리스트에 추가 된 할 일(`Task`) 개수를 나타내는 label이 있습니다.<br>- 하단 label에서 `Important` list를 제외한 커스텀 list의 개수를 안내하고 있습니다.<br>- 하단 `+ New List` 버튼을 눌러 새로운 `List`를 추가할 수 있습니다. |
| <img src="https://github.com/user-attachments/assets/600005b9-6175-44f4-a4d3-8868061e89dd"> | - 리스트 셀을 스와이프하여 삭제할 수 있습니다. |

### 02) 리스트 추가 화면
| AddNewListView | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/729c6416-f29f-4834-955a-260815608e99" width="320"> | - 새로운 리스트를 추가하는 화면입니다.<br>- 사용자의 입력값이 공백인 경우 placeholder에 적혀있는 `Untitled list`로 추가됩니다. |
| <img src="https://github.com/user-attachments/assets/40de2276-83f4-4595-adb3-c902f80f6c5e"> | `Cancel` 버튼을 누르면 다시 메인 화면으로, `Done` 버튼을 누르면 추가된 리스트의 `Todo` 화면으로 이동합니다. |

### 03) 투두리스트 화면
| TodoListView | |
| ----- | ----- |
| <img src="https://github.com/user-attachments/assets/d22c3a6f-ad8e-42e8-b4a0-689cecb2d571" width="320"> | - 메인화면에서 리스트 셀을 탭하면 나타나는 화면입니다. |
