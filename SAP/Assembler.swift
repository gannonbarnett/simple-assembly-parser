//
//  Assembler.swift
//  SAP
//
//  Created by Gannon Barnett on 4/24/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

class Assembler {
    let file : String = ""
    
    var startLabel = ""
    var tokens = [Token]()
    
    var memory = [Int?]()
    var symbolTable : [String : Int] = [:]
    
    var Instructions : [String : Int] = [:]
    
    init(fileName : String) {
        //make dictionary so string -> rawvalue is possible
        var counter = 0
        for i in ["halt" , "clrr", "clrx", "clrm", "clrb", "movir", "movrr", "movrm", "movmr", "movxr", "movar", "movb", "addir", "addrr", "addmr", "addxr", "subir", "subrr", "submr", "subxr", "mulir", "mulrr", "mulmr", "mulxr", "divir", "divrr", "divmr", "divxr", "jmp", "sojz", "sojnz", "aojz", "aojnz", "cmpir", "cmprr", "cmpmr", "jmpn", "jmpz", "jmpp", "jsr", "ret", "push", "pop", "stackc", "outci", "outcr", "outcx", "outcb", "readi", "printi", "readc", "readln", "brk", "movrx", "movxx", "outs", "nop", "jmpne"] {
            Instructions[i] = counter
            counter += 1
        }
        
        //load file 
        loadFile(fileName)
    }
    
    func loadFile(_ fileName: String) {
        let (message, text) = readTextFile("/Users/gannonbarnett/Desktop/xCodeThings/SAP/" + fileName + ".txt")
        
        guard message == nil else {
            print("Error: File \(file) not found")
            return
        }
        
        let lines = splitStringIntoLines(expression: text!)
        let tokenizerObject = Tokenizer(lines: lines)
        let fullTokens = tokenizerObject.getTokens()
        startLabel = fullTokens[1].stringValue!
        
        for i in 2 ..< fullTokens.count {
            tokens.append(fullTokens[i])
        }
    
        print("Load finished!")
    }
    
    enum Instruction : Int {
        case halt
        case clrr
        case clrx
        case clrm
        case clrb
        case movir
        case movrr
        case movrm
        case movmr
        case movxr
        case movar
        case movb
        case addir
        case addrr
        case addmr
        case addxr
        case subir
        case subrr
        case submr
        case subxr
        case mulir
        case mulrr
        case mulmr
        case mulxr
        case divir
        case divrr
        case divmr
        case divxr
        case jmp
        case sojz
        case sojnz
        case aojz
        case aojnz
        case cmpir
        case cmprr
        case cmpmr
        case jmpn
        case jmpz
        case jmpp
        case jsr
        case ret
        case push
        case pop
        case stackc
        case outci
        case outcr
        case outcx
        case outcb
        case readi
        case printi
        case readc
        case readln
        case brk
        case movrx
        case movxx
        case outs
        case nop
        case jmpne
    }

    func printMemory() {
        for i in memory{
            print(i!)
        }
    }
    
    func Assemble() {
        print("first pass...")
        memory.append(0)
        memory.append(0)
        
        var emptySlots : [Int : String] = [:]
        //** NOTE ON emptySlots **
        //Memory index is key, Label is value.
        //Used to hold place if Label has unknown location
        
        //MARK:: FIRST PASS. POST CONDITION: MEMORY HAY HAVE NIL VALUES
        var memoryCounter = 0
        for n in 0 ..< tokens.count {
            let t = tokens[n]
            
            switch t.type {
            case .Label :
                
                if let i = symbolTable[t.stringValue!] {
                    memory.append(i)
                    symbolTable[t.stringValue!] = memoryCounter
                    memoryCounter += 1
                }else if tokens[n + 1].type == TokenType.Directive || tokens[n + 1].type == TokenType.Instruction {
                    symbolTable[t.stringValue!] = memoryCounter
                    
                } else {
                    memory.append(nil)
                    emptySlots[memoryCounter] = t.stringValue!
                    memoryCounter += 1
                }
                
            case .ImmediateString :
                memory.append(t.stringValue!.characters.count)
                memoryCounter += 1
                for c in t.stringValue!.characters {
                    memory.append(charToAscii(c: c))
                    memoryCounter += 1
                }
                
            case .ImmediateInteger :
                memory.append(t.intValue!)
                memoryCounter += 1
                
            case .ImmediateTuple :
                //IMPLEMENT
                print("lol")
                
            case .Instruction :
                if let i = Instructions[t.stringValue!] {
                    memory.append(i)
                    memoryCounter += 1
                }else {
                    print("ERROR:: INVALID INSTRUCTION", t)
                }
                
            case .Register :
                memory.append(t.intValue!)
                memoryCounter += 1
                
            case .Directive :
                break
                
            case .BadToken :
                print("ERROR:: INVALID TOKEN", t)
            }
        }
        
        //MARK:: SECOND PASS. POSTCONDITION: MEMORY WILL BE COMPLETE
        for i in emptySlots.keys {
            let label = emptySlots[i]!
            
            guard !symbolTable.contains(where: {$0.key == label} ) else{
                print("ERROR:: INVALID LABEL", label)
                return
            }
            memory[i] = symbolTable[label]!
        }
        
        //MARK:: COMPLETE. POSTCONDITION: MEMORY SIZE AND START FILLED
        memory[0] = memory.count - 2
        memory[1] = symbolTable[startLabel]!
        
    }
    
    func printTokens() {
        print(tokens)
    }
}
