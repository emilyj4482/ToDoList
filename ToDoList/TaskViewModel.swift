//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/30.
//

import Foundation

/* ViewModel : Model의 정보를 View에서 사용할 수 있도록 구성한다. */
class TaskViewModel {
    
    var lastId: Int = 0

    // Important 리스트는 고정값
    var lists: [List] = [List(name: "Important", tasks: [])]
    
    func createList(_ listName: String) -> List {
        return List(name: listName, tasks: [])
    }
    
    func addList(_ list: List) {
        lists.append(list)
    }
    
    func createTask(_ title: String) -> Task {
        let nextId = lastId + 1
        lastId = nextId
        return Task(id: nextId, title: title, isDone: false, isImportant: false)
    }
    
    func addTask(listName: String, task: Task) {
        if let index = lists.firstIndex(where: { $0.name == listName }) {
            lists[index].tasks.append(task)
        }
    }
    
    func deleteTask() {
        
    }
    
    func updateTask() {
        
    }
    
    func deleteList(_ list: List) {
        
    }
    
    func updateList() {
        
    }
    
}
