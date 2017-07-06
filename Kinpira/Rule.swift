//
//  Rule.swift
//  Kinpira
//
//  Created by fumiko-ishizawa on 2017/07/06.
//  Copyright © 2017年 fumikoi. All rights reserved.
//

import Foundation

class Rule {

    public var mergedRule: [String : Any] = [:]

    public var encodedRule: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: mergedRule, options: .prettyPrinted)
            print(jsonData)
            return String(data: jsonData, encoding: .ascii)!
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }

    init(models: [Ruleable]) {

        let compilers: [Compiler] = {
            var compilers: [Compiler] = []
            for model in models {
                let compiler: Compiler = Compiler(classRef: model)
                compilers.append(compiler)
            }
            return compilers
        }()

        mergeRule(compilers: compilers)
    }

    func mergeRule(compilers: [Compiler]) {

        for (index, compiler) in compilers.enumerated() {

            if compiler.children != [] {
                for child in compiler.children {
                    mergeChildContent(compilers: compilers, parent: compiler, child: child, index: index)
                }
            }

            if compiler.parent == nil {
                mergedRule[compiler.prefix] = compiler.dict
            }
        }
    }

    private func mergeChildContent(compilers: [Compiler], parent: Compiler, child: String, index: Int) {

        for compiler in compilers {
            if String(describing: type(of: compiler.classRef)) != child {
                continue
            }

            if compiler.children != [] {
                for (index, child) in compiler.children.enumerated() {
                    mergeChildContent(compilers: compilers, parent: compiler, child: child, index: index)
                }
            }

            for (key, value) in parent.dict {
                if value as! String != child {
                    continue
                }

                parent.dict[key] = compiler.dict
                parent.children.remove(at: index - 1)
            }
        }
    }
    
}
