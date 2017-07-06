//
//  KinpiraTests.swift
//  KinpiraTests
//
//  Created by fumiko-ishizawa on 2017/07/06.
//  Copyright © 2017年 fumikoi. All rights reserved.
//

import XCTest
@testable import Kinpira


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

class NestedUser: Ruleable {

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

    var parent: String? = "group"
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


class NestedGroup: Ruleable {

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
        case "users":
            return .child(NestedUser.self)
        default:
            return .none
        }
    }

}


func XCTAssertEqualDictionaries<S, T: Equatable>(first: [S:T], second: [S:T]) {
    XCTAssert(first == second)
}


class GenerateFlatRuleTests: XCTestCase {

    var rule: Rule?
    let user: User = User()
    let group: Group = Group()

    let expectedUserContent: [String : String] = [
        ".read": "true",
        ".write": "auth != null",
        ".indexOn": "[\"name\", \"age\"]",
        "name": "newData.length <= 15 && newData.isString()",
        "age": "newData.isNumber()",
        ]

    let expectedGroupContent: [String : String] = [
        ".read": "true",
        ".write": "auth != null",
        ".indexOn": "[\"name\"]",
        "name": "newData.length <= 15 && newData.isString()",
        ]

    let expectedContent = [
        "user": [
            ".read": "true",
            ".write": "auth != null",
            ".indexOn": "[\"name\", \"age\"]",
            "name": "newData.length <= 15 && newData.isString()",
            "age": "newData.isNumber()",
        ],
        "group": [
            ".read": "true",
            ".write": "auth != null",
            ".indexOn": "[\"name\"]",
            "name": "newData.length <= 15 && newData.isString()",

        ]
    ]

    override func setUp() {
        super.setUp()

        rule = Rule(models: [user, group])
    }

    func testGenerateMergedData() {
        let content = rule!.mergedRule

        XCTAssertTrue(content.keys.contains("user"))
        XCTAssertTrue(content.keys.contains("group"))
        XCTAssertEqual(content["user"] as! [String : String], expectedUserContent)
        XCTAssertEqual(content["group"] as! [String : String], expectedGroupContent)
    }

    // :thinking_face:
    func testGenerateJsonData() {
        let content = rule?.encodedRule
        var jsonContent: String = ""

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: expectedContent, options: .prettyPrinted)
            jsonContent = String(data: jsonData, encoding: .ascii)!
        } catch {
            print(error.localizedDescription)
        }

        XCTAssertEqual(content, jsonContent)
    }

}


class GenerateNextedRuleTests: XCTestCase {

    var rule: Rule?
    let user: NestedUser = NestedUser()
    let group: NestedGroup = NestedGroup()

    let expectedUserContent: [String : String] = [
        ".read": "true",
        ".write": "auth != null",
        ".indexOn": "[\"name\", \"age\"]",
        "name": "newData.length <= 15 && newData.isString()",
        "age": "newData.isNumber()",
        ]

    override func setUp() {
        super.setUp()

        rule = Rule(models: [user, group])
    }

    func testGenerateMergedData() {
        let content = rule!.mergedRule

        XCTAssertFalse(content.keys.contains("user"))
        XCTAssertTrue(content.keys.contains("group"))

        if let groupContent = content["group"] as? Dictionary<String, Any> {
            XCTAssertTrue(groupContent.keys.contains("users"))
            XCTAssertEqual(groupContent["users"] as! [String : String], expectedUserContent)
        } else {
            XCTFail()
        }
    }
}


class NotNestedModelTests: XCTestCase {

    var compiler: Compiler?
    let user: User = User()

    override func setUp() {
        super.setUp()

        compiler = Compiler(classRef: user)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCreateAuthContent() {
        let content: [String : String] = compiler!.createAuthContent()
        let expectedContent = [
            ".read": "true",
            ".write": "auth != null",
            ".indexOn": "[\"name\", \"age\"]"
        ]
        XCTAssertEqual(content, expectedContent)
    }

    func testCreateValidateContent() {
        let content: [String : String] = compiler!.createValidationContent()
        let expectedContent = [
            "name": "newData.length <= 15 && newData.isString()",
            "age": "newData.isNumber()"
        ]
        XCTAssertEqual(content, expectedContent)
    }

}


class NestedModelTests: XCTestCase {

    var compiler: Compiler?
    let group: NestedGroup = NestedGroup()

    override func setUp() {
        super.setUp()

        compiler = Compiler(classRef: group)
    }


    func testCreateAuthContent() {
        let content: [String : String] = compiler!.createAuthContent()
        let expectedContent = [
            ".read": "true",
            ".write": "auth != null",
            ".indexOn": "[\"name\"]"
        ]
        XCTAssertEqual(content, expectedContent)
    }

    func testCreateValidateContent() {
        let content: [String : String] = compiler!.createValidationContent()
        let expectedContent = [
            "name": "newData.length <= 15 && newData.isString()",
            "users": "NestedUser",
            ]
        XCTAssertEqual(content, expectedContent)
    }
}
