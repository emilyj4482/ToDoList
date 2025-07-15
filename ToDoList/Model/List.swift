//
//  List.swift
//  ToDoList
//
//  Created by EMILY on 2025/07/16.
//

import Foundation

// 리스트 Object
struct List: Codable {
    let id: Int
    var name: String
    var tasks: [Task]
    
    mutating func update(name: String) {
        self.name = name
    }
}
