//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/30.
//

import Foundation

/* ViewModel : Model의 정보를 View에서 사용할 수 있도록 구성한다. */
class TaskViewModel {
    
    // Task.id 저장용 프로퍼티
    var lastId: Int = 0
    // List 이름 중복 횟수 저장용 딕셔너리 [List이름: 중복 횟수]
    var noOverlap: [String: Int] = [:]
    
    // Important 리스트는 고정값
    var lists: [List] = [List(name: "Important", tasks: [])]
    
    func createList(_ listName: String) -> List {
        // List 이름 중복 검사 : 입력값 앞뒤 공백 제거해준 뒤 lists Array 및 noOverlap Dictionary에서 중복 검사를 해준다. 중복 횟수에 따라 이름 뒤에 () 괄호 안 숫자를 넣어 붙여준다.
        if lists.firstIndex(where: { $0.name == listName.trim() }) != nil && noOverlap[listName] == nil {
            noOverlap[listName] = 1
            if let count = noOverlap[listName] {
                return List(name: "\(listName.trim()) (\(count))", tasks: [])
            }
        } else if lists.firstIndex(where: { $0.name == listName.trim() }) != nil && noOverlap[listName] != nil {
            noOverlap[listName]! += 1
            if let count = noOverlap[listName] {
                return List(name: "\(listName.trim()) (\(count))", tasks: [])
            }
        }
        return List(name: listName.trim(), tasks: [])
    }
    
    func addList(_ list: List) {
        lists.append(list)
    }
    
    // Task 내용은 중복 허용(검사 X), 입력값에 대해 앞뒤 공백을 제거해준 뒤 생성한다.
    func createTask(_ title: String) -> Task {
        let nextId = lastId + 1
        lastId = nextId
        return Task(id: nextId, title: title.trim(), isDone: false, isImportant: false)
    }
    
    func addTask(_ listName: String, _ task: Task) {
        if let index = lists.firstIndex(where: { $0.name == listName }) {
            lists[index].tasks.append(task)
        }
    }
    
    func deleteTask(_ taskId: Int) {
        
    }
    
    func updateTask() {
        
    }
    
    func deleteList(_ list: List) {
        
    }
    
    func updateList() {
        
    }
    
}

// 문자열 앞뒤 공백 삭제 메소드 정의
extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
