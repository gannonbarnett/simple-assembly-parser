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
            tokens += tokensFromLine(l)
        }
    }

    init() {
        self.lines = []
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
            if lineParts[i].contains(";") || lineParts[i].isEmpty {
                break
            } else if lineParts[i].contains("\"") {
                //STRING
                var stringDraft = ""
                while i < lineParts.count {
                    stringDraft.append(lineParts[i])
                    if i < lineParts.count - 1 { //If there is another chunk left, add space after.
                        stringDraft.append(" ")
                    }
                    i += 1
                }
                chunks.append(stringDraft) //add final to
            }else if lineParts[i].contains("\\"){
                //TUPLE
                var tupleString = ""
                while i < lineParts.count {
                    tupleString.append(lineParts[i])
                    tupleString.append(" ")
                    i += 1
                }
                chunks.append(tupleString)
            }else {
                let value = lineParts[i].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if value != "" && value != "\t" {
                    chunks.append(value)
                }
            }
            i += 1
        }

        return chunks
    }
    
    func tokensFromLine(_ line : String) -> [Token]{
        var type : TokenType
        var stringValue : String? = nil
        var intValue : Int? = nil
        var tokensFromLine : [Token] = []
        
        let chunks = chunkize(line)
        for chunk in chunks{
            
            guard !chunk.isEmpty else{
                print("Empty Chunk Caught in Tokenizer,", chunk)
                break
            }
            
            if chunk.contains("\"") {
                //STRING
                type = TokenType.ImmediateString
                stringValue = chunk.replacingOccurrences(of: "\"", with: "")
                tokensFromLine.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
                
            }else if chunk.contains(":") {
                //LABEL
                type = TokenType.Label
                stringValue = chunk.substring(to: chunk.index(before: chunk.endIndex))
                tokensFromLine.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
                
            }else if chunk.contains(".") {
                //DIRECTIVE
                type = TokenType.Directive
                stringValue = chunk.substring(from: chunk.index(after: chunk.startIndex))
                tokensFromLine.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
                
            }else if chunk.characters.contains("\\") && chunk.characters.count > 6 {
                //TUPLE
                type = TokenType.ImmediateTuple
                let c1 = Int(String(chunk[chunk.index(chunk.startIndex, offsetBy: 1)]))
                let c2 = chunk[chunk.index(chunk.startIndex, offsetBy: 3)]
                let c3 = Int(String(chunk[chunk.index(chunk.startIndex, offsetBy: 5)]))
                let c4 = chunk[chunk.index(chunk.startIndex, offsetBy: 7)]
                let c5 = chunk[chunk.index(chunk.startIndex, offsetBy: 9)]
                let t = Tuple(currS: c1!, inputC: c2, newS: c3!, outC: c4, dir: c5)
                tokensFromLine.append(Token(type: type, intValue: nil, stringValue: nil, tupleValue: t))
                
            }else if chunk.characters.contains("#") {
                if chunk.characters.first == "#" {
                    //INTEGER
                    type = TokenType.ImmediateInteger
                    intValue = Int(chunk.substring(from: chunk.index(after: chunk.startIndex)))
                    tokensFromLine.append(Token(type: type, intValue: intValue, stringValue: nil, tupleValue: nil))
                } else {
                    type = TokenType.BadToken
                    tokensFromLine.append(Token(type: type, intValue: nil, stringValue: nil, tupleValue: nil))
                }
                
            }else if chunk.contains("r") && chunk.characters.count == 2 {
                //REGISTER
                type = TokenType.Register
                intValue = Int(chunk.substring(from: chunk.index(after: chunk.startIndex)))
                tokensFromLine.append(Token(type: type, intValue: intValue, stringValue: nil, tupleValue: nil))
                
            }else if Instructions.contains(chunk){
                //INSTRUCTION
                
                type = TokenType.Instruction
                stringValue = chunk
                tokensFromLine.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
                
            } else {
                type = TokenType.Label
                stringValue = chunk
                tokensFromLine.append(Token(type: type, intValue: nil, stringValue: stringValue, tupleValue: nil))
            }
            
        }
        
        return tokensFromLine
    }
    
    
}
