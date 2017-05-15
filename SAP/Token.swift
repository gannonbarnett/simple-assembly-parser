//
//  Token.swift
//  SAP
//
//  Created by Gannon Barnett on 5/3/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

/**
 * contains TokenType, Token, Tuple, and string split functions
 **/

import Foundation

enum TokenType {
    case Register
    case Label
    case ImmediateString
    case ImmediateInteger
    case ImmediateTuple
    case Instruction
    case Directive
    case BadToken
}

struct Token: CustomStringConvertible {
    let type: TokenType?
    let intValue: Int?
    let stringValue: String?
    let tupleValue: Tuple?
    
    init(type: TokenType?, intValue: Int?, stringValue: String?, tupleValue: Tuple?){
        self.type = type
        self.intValue = intValue
        self.stringValue = stringValue
        self.tupleValue = tupleValue
    }

    var description: String {
        return "Token type: \(type) intValue: \(intValue) stringValue: \(stringValue) tupleValue: \(tupleValue)"
    }
}


struct Tuple: CustomStringConvertible {
    let currentState: Int
    let inputCharacter: Int
    let newState: Int
    let outputCharacter: Int
    let direction: Int
    
    init(currS: Int, inputC: Int, newS: Int, outC: Int, dir: Int) {
        currentState = currS
        inputCharacter = inputC
        newState = newS
        outputCharacter = outC
        direction = dir
    }
    
    var description: String {
        return "/ \(currentState) \(inputCharacter) \(newState) \(outputCharacter) \(direction)"
    }
}


