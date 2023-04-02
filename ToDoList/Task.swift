//
//  Task.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/30.
//

import Foundation

/* Model */

// 할 일 Object
struct Task {
    let id: Int
    var title: String
    var isDone: Bool
    var isImportant: Bool
}

// 리스트 Object
struct List {
    var name: String
    var tasks: [Task]
}
