//
//  Tokenizer.swift
//  SAP
//
//  Created by Gannon Barnett on 5/3/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

class Tokenizer {
    let line : String
    let lineParts : [String]
    var type : TokenType
    var stringValue : String? = nil
    var intValue : Int? = nil
    var tupleValue : Tuple? = nil
    
    init(for lineInput: String) {
        line = lineInput
        lineParts = splitStringIntoParts(expression: line)
    }
    
    func getToken() -> Token {
        return Token(type: type, intValue: intValue, stringValue: stringValue, tupleValue: tupleValue)
    }
    
    func makeChunks() -> [String]{
        for i in 0 ... lineParts.count - 1 {
            var part = lineParts[i]
            if part.contains(":") { //
                type = TokenType.Label
                stringValue = part.substring(to: part.index(before: part.endIndex))
                
            } else if part.contains(".") {
                type = TokenType.Directive
                stringValue = part.substring(from: part.index(after: part.startIndex))
                
            } else if part.contains("#") {
                
            }
            
            if part.contains("\"") {
                while !part.contains("\"") {
                    i += 1
                }
            }
        }
    }
    
}
