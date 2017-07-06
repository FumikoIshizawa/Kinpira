//
//  User.swift
//  Example
//
//  Created by fumiko-ishizawa on 2017/07/06.
//  Copyright © 2017年 fumikoi. All rights reserved.
//

import Foundation
import Kinpira

class User: Ruleable {

    dynamic var name: String?
    dynamic var age: Int = 0
    dynamic var groups: Set<String> = []

    var read: String? {
        return "true"
    }

    var write: String? {
        return "auth != null"
    }

    var indexOn: String? {
        return "[\"name\", \"age\"]"
    }

    var parent: String? = nil
    var prefix: String = "user"

    func validations(propertyName: String) -> ValidationType {
        switch propertyName {
        case "name":
            return .status("newData.length <= 15", .string)
        case "age":
            return .type(.number)
        default:
            return .none
        }
    }
    
}
