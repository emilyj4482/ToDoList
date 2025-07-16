//
//  Extension+UIStoryboard.swift
//  ToDoList
//
//  Created by EMILY on 2025/07/15.
//

import UIKit

extension UIStoryboard {
    func instantiateViewController<T: UIViewController & TodoManagerInjectable> (todoManager: TodoManager) -> T {
        guard let viewController = instantiateViewController(withIdentifier: T.identifier) as? T else {
            fatalError("Could not instantiate \(T.self) with identifier '\(T.identifier)'")
        }
        viewController.inject(todoManager: todoManager)
        return viewController
    }
}

struct Storyboard {
    static let main: UIStoryboard = .init(name: "Main", bundle: nil)
}
