//
//  Group.swift
//  Example
//
//  Created by fumiko-ishizawa on 2017/07/06.
//  Copyright © 2017年 fumikoi. All rights reserved.
//

import Foundation
import Kinpira

class Group: Ruleable {

    dynamic var name: String?
    dynamic var users: Set<String> = []

    var read: String? {
        return "true"
    }

    var write: String? {
        return "auth != null"
    }

    var indexOn: String? {
        return "[\"name\"]"
    }

    var parent: String? = nil
    var prefix: String = "group"

    func validations(propertyName: String) -> ValidationType {
        switch propertyName {
        case "name":
            return .status("newData.length <= 15", .string)
        default:
            return .none
        }
    }
    
}
