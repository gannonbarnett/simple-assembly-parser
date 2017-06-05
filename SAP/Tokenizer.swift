//
//  Tokenizer.swift
//  SAP
//
//  Created by Gannon Barnett on 5/3/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

class Tokenizer {
    let Instructions : [String] = ["halt", "clrr", "clrx", "clrm", "clrb", "movir", "movrr", "movrm", "movmr", "movxr", "movar", "movb", "addir", "addrr", "addmr", "addxr", "subir", "subrr", "submr", "subxr", "mulir", "mulrr", "mulmr", "mulxr", "divir", "divrr", "divmr", "divxr", "jmp", "sojz", "sojnz", "aojz", "aojnz", "cmpir", "cmprr", "cmpmr", "jmpn", "jmpz", "jmpp", "jsr", "ret", "push", "pop", "stackc", "outci", "outcr", "outcx", "outcb", "readi", "printi", "readc", "readln", "brk", "movrx", "movxx", "outs", "nop", "jmpne", "halt"]
    
    var lines : [String]
    
    var tokens : [Token] = []
    
    init(lines : [String]) {
        self.lines = lines
        for l in lines {
            Tokenize(l)
        }
    }

    func getTokens() -> [Token] {
        return tokens
    }
    
    func printTokens() {
        for t in getTokens() {
            print(t)
        }
    }
    
    private func chunkize(_ line : String) -> [String] {
        var i = 0
        var chunks : [String] = []
        var lineParts = splitStringIntoParts(expression: line)
        
        while i < lineParts.count {
            if lineParts[i].contains("\"") { //if the string has quotes, start string builder
                var stringDraft = ""
                stringDraft.append(lineParts[i]) 
                i += 1
                stringDraft.append(" ") //add spaces where needed
                
                while !lineParts[i].contains("\"") { //keep going till find end quotes
                    stringDraft.append(lineParts[i])
                    i += 1
                    stringDraft.append(" ")
                }
                
                stringDraft.append(lineParts[i])
                chunks.append(stringDraft) //add final to
            }else {
                chunks.append(lineParts[i].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            } //if no quotes found just keep adding
            i += 1
        }
        
        return chunks
    }
    
    private func Tokenize(_ line : String) {
        var type : TokenType
        var stringValue : String? = nil
        var intValue : Int? = nil
        
        let chunks = chunkize(line)
        
        for chunk in chunks{
            
            if chunk.contains("\"") {
                //STRING
                type = TokenType.ImmediateString
                stringValue = chunk.replacingOccurrences(of: "\"", with: "")
                tokens.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
                
            }else if chunk.contains(":") {
                //LABEL
                type = TokenType.Label
                stringValue = chunk.substring(to: chunk.index(before: chunk.endIndex))
                tokens.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
                
            }else if chunk.contains(".") {
                //DIRECTIVE
                type = TokenType.Directive
                stringValue = chunk.substring(from: chunk.index(after: chunk.startIndex))
                tokens.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
                
            }else if chunk.characters.contains("\\") && chunk.characters.count > 6 {
                //TUPLE
                type = TokenType.ImmediateTuple
                let c1 = Int(String(chunk[chunk.index(chunk.startIndex, offsetBy: 1)]))
                let c2 = chunk[chunk.index(chunk.startIndex, offsetBy: 1)]
                let c3 = Int(String(chunk[chunk.index(chunk.startIndex, offsetBy: 1)]))
                let c4 = chunk[chunk.index(chunk.startIndex, offsetBy: 1)]
                let c5 = chunk[chunk.index(chunk.startIndex, offsetBy: 1)]
                let t = Tuple(currS: c1!, inputC: c2, newS: c3!, outC: c4, dir: c5)
                tokens.append(Token(type: type, intValue: nil, stringValue: nil, tupleValue: t))
                
            }else if chunk.characters.contains("#") {
                if chunk.characters.first == "#" {
                    //INTEGER
                    type = TokenType.ImmediateInteger
                    intValue = Int(chunk.substring(from: chunk.index(after: chunk.startIndex)))
                    tokens.append(Token(type: type, intValue: intValue, stringValue: nil, tupleValue: nil))
                } else {
                    type = TokenType.BadToken
                    tokens.append(Token(type: type, intValue: nil, stringValue: nil, tupleValue: nil))
                }
                
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
                type = TokenType.Label
                stringValue = chunk
                tokens.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
            }
            
        }
    }
    
    
}
