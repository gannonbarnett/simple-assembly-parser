//
//  Tokenizer.swift
//  SAP
//
//  Created by Gannon Barnett on 5/3/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

class Tokenizer {
    let Instructions : [String] = ["halt", "clrr", "clrx", "clrm", "clrb", "movir", "movrr", "movrm", "movmr", "movxr", "movar", "movb", "addir", "addrr", "addmr", "addxr", "subir", "subrr", "submr", "subxr", "mulir", "mulrr", "mulmr", "mulxr", "divir", "divrr", "divmr", "divxr", "jmp", "sojz", "sojnz", "aojz", "aojnz", "cmpir", "cmprr", "cmpmr", "jmpn", "jmpz", "jmpp", "jsr", "ret", "push", "pop", "stackc", "outci", "outcr", "outcx", "outcb", "readi", "printi", "readc", "readln", "brk", "movrx", "movxx", "outs", "nop", "jmpne"]
    
    var line : String = ""
    var lineParts : [String] = []
    
    var chunks : [String] = []
    var tokens : [Token] = []
    
    init() {}
    
    func setLine(to lineInput : String) {
        line = lineInput
        lineParts = splitStringIntoParts(expression: line)
    }
    
    func getTokens() -> [Token] {
        Tokenize()
        return tokens
    }
    
    func printTokens() {
        for t in getTokens() {
            print(t)
        }
    }
    
    func chunkize() -> [String] {
        var i = 0
        var chunks : [String] = []
        
        while i < lineParts.count {
            if lineParts[i].contains("\"") { //if the string has quotes, start string builder
                var stringDraft = ""
                stringDraft.append(lineParts[i].replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range:nil)) //take out startquotes
                i += 1
                stringDraft.append(" ") //add spaces where needed
                
                while !lineParts[i].contains("\"") { //keep going till find end quotes
                    stringDraft.append(lineParts[i])
                    i += 1
                    stringDraft.append(" ")
                }
                
                stringDraft.append(lineParts[i].replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range:nil)) //take out endquotes
                chunks.append(stringDraft) //add final to
            }else { chunks.append(lineParts[i]) } //if no quotes found just keep adding
            i += 1
        }
        return chunks
    }
    
    func Tokenize() {
        var type : TokenType
        var stringValue : String? = nil
        var intValue : Int? = nil
        var tupleValue : Tuple? = nil
        
        chunks = chunkize()
        for i in 0 ..< chunks.count {
            let chunk = chunks[i]
            
            if chunk.contains(":") {
                //LABEL
                type = TokenType.Label
                stringValue = chunk.substring(to: chunk.index(before: chunk.endIndex))
                tokens.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
            }else if chunk.contains(".") {
                //DIRECTIVE
                type = TokenType.Directive
                stringValue = chunk.substring(from: chunk.index(after: chunk.startIndex))
                tokens.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
            }else if chunk.contains(" ") {
                //STRING
                type = TokenType.ImmediateString
                stringValue = chunk
                tokens.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
            }else if chunk.contains("#") {
                //INTEGER
                type = TokenType.ImmediateInteger
                intValue = Int(chunk.substring(from: chunk.index(after: chunk.startIndex)))
                tokens.append(Token(type: type, intValue: intValue, stringValue: nil, tupleValue: nil))
            }else if chunk.contains("r") && chunk.characters.count == 2 {
                //REGISTER
                type = TokenType.Register
                intValue = Int(chunk.substring(from: chunk.index(after: chunk.startIndex)))
                tokens.append(Token(type: type, intValue: intValue, stringValue: nil, tupleValue: nil))
            }else if Instructions.contains(chunk){
                //INSTRUCTION
                type = TokenType.Instruction
                stringValue = chunk
                tokens.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
            } else {
                type = TokenType.BadToken
                tokens.append(Token(type: type, intValue: nil, stringValue: nil, tupleValue: nil))
            }
            
        }
    }
    
    
}
