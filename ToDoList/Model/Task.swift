//
//  Task.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/30.
//

import Foundation

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
