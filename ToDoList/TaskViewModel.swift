//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/30.
//

import Foundation

/* ViewModel : Model의 정보를 View에서 사용할 수 있도록 구성한다. */
class TaskViewModel {
    
    // 싱글톤 객체로 선언 : 앱 전반에서 앱 관리를 이 객체 혼자서 하기 때문에 싱글톤으로 선언한다.
    static let shared = TaskViewModel()
    
    // Task.id 저장용 프로퍼티
    private var lastTaskId: Int = 0
    // List.id 저장용 프로퍼티
    private var lastListId: Int = 1
    // List 이름 중복 횟수 저장용 딕셔너리 [List이름: 중복 횟수]
    private var noOverlap: [String: Int] = [:]
    
    // Important list는 고정값
    var lists: [List] = [List(id: 1, name: "Important", tasks: [])]
    
    func createList(_ listName: String) -> List {
        let nextId = lastListId + 1
        lastListId = nextId
        
        // List 이름 중복 검사 : 입력값 앞뒤 공백 제거해준 뒤 lists Array 및 noOverlap Dictionary에서 중복 검사를 해준다. 중복 횟수에 따라 이름 뒤에 () 괄호 안 숫자를 넣어 붙여준다.
        if lists.firstIndex(where: { $0.name == listName.trim() }) != nil && noOverlap[listName] == nil {
            noOverlap[listName] = 1
            if let count = noOverlap[listName] {
                return List(id: nextId, name: "\(listName.trim()) (\(count))", tasks: [])
            }
        } else if lists.firstIndex(where: { $0.name == listName.trim() }) != nil && noOverlap[listName] != nil {
            noOverlap[listName]! += 1
            if let count = noOverlap[listName] {
                return List(id: nextId, name: "\(listName.trim()) (\(count))", tasks: [])
            }
        }
        return List(id: nextId, name: listName.trim(), tasks: [])
    }
    
    func addList(_ list: List) {
        lists.append(list)
    }
    
    // Task 내용은 중복 허용(검사 X), 입력값에 대해 앞뒤 공백을 제거해준 뒤 생성한다.
    func createTask(listId: Int, _ title: String) -> Task {
        let nextId = lastTaskId + 1
        lastTaskId = nextId
        return Task(id: nextId, listId: listId, title: title.trim(), isDone: false, isImportant: false)
    }
    
    func addTask(listId: Int, _ task: Task) {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            lists[index].tasks.append(task)
        }
    }
    
    func deleteTask() {
        
    }
    
    func updateTask(listId: Int, taskId: Int, task: Task) {
        if let index1 = lists.firstIndex(where: { $0.id == listId }) {
            if let index2 = lists[index1].tasks.firstIndex(where: { $0.id == taskId }) {
                lists[index1].tasks[index2].update(title: task.title, isDone: task.isDone, isImportant: task.isImportant)
            }
        }
    }
    
    func deleteList(listId: Int) {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            lists.remove(at: index)
        }
    }
    
    func updateList(listId: Int, _ name: String) {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            lists[index].update(name: name)
        }
    }
    
    func addImportant(_ task: Task) {
        lists[0].tasks.append(task)
    }
    
    // Important list에서 삭제될 뿐만 아니라 task가 속한 list에서도 isImportant 정보가 update 되도록 한다.
    func unImportant(listId: Int, taskId: Int, task: Task) {
        if let index = lists[0].tasks.firstIndex(where: { $0.id == taskId }) {
            lists[0].tasks.remove(at: index)
        }
        updateTask(listId: listId, taskId: taskId, task: task)
    }
}

// 문자열 앞뒤 공백 삭제 메소드 정의
extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
