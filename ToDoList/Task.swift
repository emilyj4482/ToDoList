//
//  Task.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/30.
//

import Foundation

/* Model */

// 할 일 Object
struct Task: Codable {
    let id: Int
    let listId: Int
    var title: String
    var isDone: Bool
    var isImportant: Bool
    
    mutating func update(title: String, isDone: Bool, isImportant: Bool) {
        self.title = title
        self.isDone = isDone
        self.isImportant = isImportant
    }
}

// 리스트 Object
struct List: Codable {
    let id: Int
    var name: String
    var tasks: [Task]
    
    mutating func update(name: String) {
        self.name = name
    }
}
