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
    var lists: [String: [Task]] = [:]
    
    func createList(listName: String) -> Void {
        lists[listName] = []
        print(lists)
    }
    
    func createTask(listName: String, title: String) -> Void {
        let nextId = lastId + 1
        lastId = nextId
        lists[listName]?.append(Task(id: nextId, title: title, isDone: false, isImportant: false))
        print(lists)
    }
    
    func addTask() {
        
    }
    
    func deleteTask() {
        
    }
    
    func updateTask() {
        
    }
    
    func deleteList() {
        
    }
    
    func updateList() {
        
    }
    
}
