//
//  Extension+String.swift
//  ToDoList
//
//  Created by EMILY on 2025/07/15.
//

import Foundation

// 문자열 앞뒤 공백 삭제 메소드 정의
extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
