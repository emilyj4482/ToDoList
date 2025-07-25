//
//  TodoManager.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/30.
//  Refactored by EMILY on 2025/07/15.

import Foundation

protocol TodoManagerInjectable {
    func inject(todoManager: TodoManager)
}

// List와 Task를 관리하는 객체
class TodoManager {
    
    // Task.id 저장용 프로퍼티
    private var lastTaskId: Int = 0
    // List.id 저장용 프로퍼티
    private var lastListId: Int = 1
    
    // Important list는 고정값
    // lists에 변동이 생길 때마다 로컬에 저장 : didSet
    var lists: [List] = [List(id: 1, name: "Important", tasks: [])] {
        didSet {
            saveData()
        }
    }
    
    // Important list를 제외한 리스트의 개수 반환
    var numberOfCustomLists: Int {
        return lists.count - 1
    }
    
    // UserDefaults 저장 key 값
    private let dataKey: String = "dataKey"
    
    private func createList(with input: String) -> List {
        // 공백, 중복 검사 통과한 list name
        let newListName = examListName(input)
        
        let nextId = lastListId + 1
        lastListId = nextId
        
        return List(id: nextId, name: newListName, tasks: [])
    }
    
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
    
    func addList(with input: String) {
        let newList = createList(with: input)
        lists.append(newList)
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
    
    // important task인 경우 Important list와 속한 list 양쪽에서 삭제 처리 필요
    func deleteTaskComplete(_ task: Task) {
        if task.isImportant {
            deleteSingleTask(listId: 1, taskId: task.id)
        }
        deleteSingleTask(listId: task.listId, taskId: task.id)
    }
    
    private func deleteSingleTask(listId: Int, taskId: Int) {
        if let index1 = lists.firstIndex(where: { $0.id == listId }) {
            if let index2 = lists[index1].tasks.firstIndex(where: { $0.id == taskId }) {
                lists[index1].tasks.remove(at: index2)
            }
        }
    }
    
    // important task인 경우 Important list와 속한 list 양쪽에서 업데이트 필요
    func updateTaskComplete(_ task: Task) {
        if task.isImportant {
            updateSingleTask(listId: 1, taskId: task.id, task: task)
        }
        updateSingleTask(listId: task.listId, taskId: task.id, task: task)
    }
    
    private func updateSingleTask(listId: Int, taskId: Int, task: Task) {
        if let index1 = lists.firstIndex(where: { $0.id == listId }) {
            if let index2 = lists[index1].tasks.firstIndex(where: { $0.id == taskId }) {
                lists[index1].tasks[index2].update(title: task.title, isDone: task.isDone, isImportant: task.isImportant)
            }
        }
    }
    
    // isImportant update : Important list로의 추가/삭제 함께 동작 필요
    func updateImportant(_ task: Task) {
        if task.isImportant {
            lists[0].tasks.append(task)
        } else {
            if let index = lists[0].tasks.firstIndex(where: { $0.id == task.id }) {
                lists[0].tasks.remove(at: index)
            }
        }
        updateSingleTask(listId: task.listId, taskId: task.id, task: task)
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

    // task.isDone 여부에 따라 section 분리
    func unDoneTasks(listIndex: Int) -> [Task] {
        return lists[listIndex].tasks.filter({ $0.isDone == false })
    }
    
    func isDoneTasks(listIndex: Int) -> [Task] {
        return lists[listIndex].tasks.filter({ $0.isDone == true })
    }
    
    // UserDefaults를 통해 데이터를 로컬에 저장, 불러오기
    func saveData() {
        if let encodedData = try? JSONEncoder().encode(lists) {
            UserDefaults.standard.set(encodedData, forKey: dataKey)
        }
    }
    
    func getData() {
        guard
            let data = UserDefaults.standard.data(forKey: dataKey),
            let savedData = try? JSONDecoder().decode([List].self, from: data)
        else { return }
        self.lists = savedData
    }
}
