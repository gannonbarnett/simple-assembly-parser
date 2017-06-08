//
//  Assembler.swift
//  SAP
//
//  Created by Gannon Barnett on 4/24/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

class AssemblerBack {
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
    
    let oneParInstructions : [String] = ["outs", "outc", "jmpp", "jmpne", "jmp"]
    //Used to prevent bugs in Assembler. View note in Assembler for more info.
    
    func loadFile(_ fileName: String) {
        let (message, text) = readTextFile("/Users/gannonbarnett/Desktop/xCodeThings/SAP/" + fileName + ".txt")
        
        guard message == nil else {
            print("Error: File \(file) not found")
            return
        }
        
        let lines = splitStringIntoLines(expression: text!)
        let tokenizer = Tokenizer(lines: lines)
        let fullTokens = tokenizer.getTokens()
        startLabel = fullTokens[1].stringValue!
        
        for i in 2 ..< fullTokens.count {
            tokens.append(fullTokens[i])
        }
        
        Assemble()
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
    
    
    func printTokens() {
        print(tokens)
    }
    
    func Assemble() {
        memory.append(0)
        memory.append(0)
        
        var emptySlots : [String : [Int]] = [String : [Int]]()
        /** NOTE ON emptySlots **
         Key is a label name, value is an array of all instances (indexes)
         in memory where the label index is required but unknown.
         **/
        
        //MARK:: FIRST PASS. POST CONDITION: MEMORY HAY HAVE NIL VALUES
        var memoryIndex = 1
        for n in 0 ..< tokens.count {
            let t = tokens[n]
            memoryIndex = memory.count - 1
            
            switch t.type {
            case .Label :
                
                if let i = symbolTable[t.stringValue!] {
                    //See if the label has already been defined. If so, add label memory index.
                    memory.append(i)
                } else if n != 0 && oneParInstructions.contains(where: {$0 == tokens[n-1].stringValue} ) {
                    //Else check to see if an instruction with only one parameter precedes the label.
                    //If true, the label is not defined and is being used as a parameter.
                    //Add the memory index to emptySlot array.
                    memory.append(nil)
                    memoryIndex += 1
                    if emptySlots.contains(where: {$0.key == t.stringValue!}) {
                        emptySlots[t.stringValue!]!.append(memoryIndex)
                    }else {
                        emptySlots[t.stringValue!] = [memoryIndex]
                    }
                    
                    
                }else if tokens[n + 1].type == TokenType.Directive || tokens[n + 1].type == TokenType.Instruction {
                    //Else check to see if the next token is a directive or instruciton.
                    //If true, the label is being defined.
                    symbolTable[t.stringValue!] = memoryIndex - 1
                } else {
                    //Else the label is undefined and being used as a parameter.
                    //Add to emptySlots
                    memory.append(nil)
                    memoryIndex += 1
                    emptySlots[t.stringValue!]?.append(memoryIndex)
                }
                
            case .ImmediateString :
                memory.append(t.stringValue!.characters.count)
                memoryIndex += 1
                
                for c in t.stringValue!.characters {
                    memory.append(charToAscii(c: c))
                    memoryIndex += 1
                }
                
            case .ImmediateInteger :
                memory.append(t.intValue!)
                
            case .ImmediateTuple :
                let tuple = t.tupleValue!
                let currentState = tuple.currentState
                let inputCharInt = charToAscii(c: tuple.inputCharacter)
                let newState = tuple.newState
                let outCharInt = charToAscii(c: tuple.outputCharacter)
                var dirInt = Int()
                if tuple.direction == "r" {
                    dirInt = 1
                }else if tuple.direction == "l" {
                    dirInt = 0
                }
                memory.append(currentState)
                memory.append(inputCharInt)
                memory.append(newState)
                memory.append(outCharInt)
                memory.append(dirInt)
                
            case .Instruction :
                if let i = Instructions[t.stringValue!] {
                    memory.append(i)
                }else {
                    print("ERROR:: INVALID INSTRUCTION", t)
                }
                
            case .Register :
                memory.append(t.intValue!)
                
            case .Directive :
                break
                
            case .BadToken :
                print("ERROR:: INVALID TOKEN", t)
            }
        }
        
        //MARK:: SECOND PASS. POSTCONDITION: MEMORY WILL BE COMPLETE
        for label in emptySlots.keys {
            let value = symbolTable[label]
            let slots = emptySlots[label]!
            for n in slots {
                memory[n] = value
            }
            
        }
        
        //MARK:: FINAL ADDITIONS. POSTCONDITION: MEMORY SIZE AND START FILLED, ASSEMBLY COMPLETE
        memory[0] = memory.count - 2
        memory[1] = symbolTable[startLabel]!
        
    }
}
