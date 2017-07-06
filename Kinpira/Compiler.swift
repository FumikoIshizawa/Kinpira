//
//  Compiler.swift
//  Kinpira
//
//  Created by fumiko-ishizawa on 2017/07/06.
//  Copyright © 2017年 fumikoi. All rights reserved.
//

import Foundation

class Compiler {

    var classRef: Ruleable

    var parent: String?
    var children: [String] = []
    var prefix: String

    var dict: [String : Any] = [:]

    init(classRef: Ruleable) {
        self.classRef = classRef
        self.parent = classRef.parent
        self.prefix = classRef.prefix
        createContent()
    }

    func createContent() {

        var content: [String : String] = [:]

        let authContent: [String : String] = createAuthContent()
        content.merge(contentsOf: authContent)
        let validateContent: [String : String] = createValidationContent()
        content.merge(contentsOf: validateContent)

        dict = content
    }

    func createAuthContent() -> [String : String] {

        var content: [String : String] = [:]
        if let read: String = classRef.read {
            content[".read"] = read
        }

        if let write: String = classRef.write {
            content[".write"] = write
        }

        if let indexOn: String = classRef.indexOn {
            content[".indexOn"] = indexOn
        }

        return content
    }

    func createValidationContent() -> [String : String] {

        var content: [String : String] = [:]

        var count: UInt32 = 0
        let properties = class_copyPropertyList(type(of: classRef) as! AnyClass, &count)

        if let properties = properties {
            for i in 0..<Int(count) {
                let prop = properties[i]

                guard let name = property_getName(prop) else {
                    continue
                }

                guard let propertyName: String = NSString(utf8String: name) as String? else {
                    continue
                }

                let validationType: ValidationType = classRef.validations(propertyName: propertyName)

                switch validationType {
                case .type(let type):
                    content[propertyName] = type.typeValidation
                case .status(let text, let type):
                    content[propertyName] = "\(text) && \(type.typeValidation)"
                case .child(let propertyClass):
                    content[propertyName] = String(describing: propertyClass)
                    children.append(String(describing: propertyClass))
                case .none:
                    break
                }
            }
        }
        
        return content
    }
    
}
