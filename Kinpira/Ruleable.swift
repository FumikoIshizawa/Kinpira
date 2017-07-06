//
//  Ruleable.swift
//  Kinpira
//
//  Created by fumiko-ishizawa on 2017/07/06.
//  Copyright © 2017年 fumikoi. All rights reserved.
//

import Foundation

public enum ValidationType {
    case type(PropertyType)
    case status(String, PropertyType)
    case child(AnyClass)
    case none
}

public enum PropertyType {
    case string
    case number
    case boolean

    var typeValidation: String {
        switch self {
        case .string:
            return "newData.isString()"
        case .number:
            return "newData.isNumber()"
        case .boolean:
            return "newData.isBoolean()"
        }
    }
}

public protocol Ruleable {

    var read: String? { get }
    var write: String? { get }

    var indexOn: String? { get }

    var parent: String? { get }
    var prefix: String { get }

    func validations(propertyName: String) -> ValidationType
    
}
