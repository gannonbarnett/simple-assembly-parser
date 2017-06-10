//
//  Assembler.swift
//  SAP
//
//  Created by Gannon Barnett on 4/24/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

class Assembler {
    var path : String = ""
    var fileName : String = ""
    var fullFileName : String {
        return path + fileName + ".txt"
    }
    
    var startLabel = ""
    var tokens = [Token]()
    
    var memory = [Int?]()
    var symbolTable : [String : Int] = [:]
    
    var Instructions : [String : Int] = [:]
    
    func setPathTo(_ path : String) {
        self.path = path
    }
    
    func AssembleFile(_ file : String) {
        fileName = file
        //make dictionary so string -> rawvalue is possible
        var counter = 0
        for i in ["halt" , "clrr", "clrx", "clrm", "clrb", "movir", "movrr", "movrm", "movmr", "movxr", "movar", "movb", "addir", "addrr", "addmr", "addxr", "subir", "subrr", "submr", "subxr", "mulir", "mulrr", "mulmr", "mulxr", "divir", "divrr", "divmr", "divxr", "jmp", "sojz", "sojnz", "aojz", "aojnz", "cmpir", "cmprr", "cmpmr", "jmpn", "jmpz", "jmpp", "jsr", "ret", "push", "pop", "stackc", "outci", "outcr", "outcx", "outcb", "readi", "printi", "readc", "readln", "brk", "movrx", "movxx", "outs", "nop", "jmpne"] {
            Instructions[i] = counter
            counter += 1
        }
        
        //load file
        loadFile()
    }
    
    let oneParInstructions : [String] = ["outs", "outc", "jmpp", "jmpne", "jmp"]
    //Used to prevent bugs in Assembler. View note in Assembler for more info.
    
    func loadFile() {
        let (message, text) = readTextFile(fullFileName)
        
        guard message == nil else {
            print("Error: File \(fullFileName) not found")
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
        makeListFile(lines: lines)
        makeBinFile()
        makeSymFile()
    }
    
    func makeListFile(lines: [String]) {
        let tokenizer = Tokenizer()
        var listFile : String = String()
        var memoryIndex = 0
        var lineTokens : [Token] = []
        var mem : [Int] = []
        var memIntro : [Int] = []
        
        for line in lines {
            lineTokens = tokenizer.tokensFromLine(line)
            mem = AssembleTokens(lineTokens)
            memoryIndex += mem.count
            var i = 0
            while i < 4 && i < mem.count {
                memIntro.append(mem[i])
                i += 1
            }
            
            listFile.append("\(memoryIndex): ")
            listFile.append(fitA(array: memIntro))
            listFile.append("\t\t")
            listFile.append(line)
            listFile.append("\n")
            mem = []
            memIntro = []
        }
        let listFilePath = path + fileName + ".lst"
        let errorMessage = writeTextFile(listFilePath, data: listFile)
        if errorMessage != nil {
            print(errorMessage!)
        }
        //prints errors if any
    }

    func makeBinFile() {
        var binFile : String = ""
        for i in memory{
            binFile.append(String(i!))
            binFile.append("\n")
        }
        let binFilePath = path + fileName + ".bin"
        let errorMessage = writeTextFile(binFilePath, data: binFile)
        if errorMessage != nil {
            print(errorMessage!)
        }
    }
    
    func makeSymFile() {
        var symFile : String = "Symbol Table: \n"
        for (label, value) in symbolTable {
            symFile.append("\t\(label): \(String(value))\n")
        }
        let symFilePath = path + fileName + ".sym"
        let errorMessage = writeTextFile(symFilePath, data: symFile)
        if errorMessage != nil {
            print(errorMessage!)
        }
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
    
    func AssembleTokens(_ tokenInput: [Token]) -> [Int] {
        var mem : [Int] = []
        
        for n in 0 ..< tokenInput.count {
            let t = tokenInput[n]
            switch t.type {
            case .Label :
                if n < tokenInput.count - 1 && tokenInput[n+1].type != TokenType.Directive && tokenInput[n+1].type != TokenType.Directive && tokenInput[n+1].type != TokenType.Instruction {
                    mem.append(symbolTable[t.stringValue!]!)
                }else if n != 0 && oneParInstructions.contains(where: {$0 == tokenInput[n-1].stringValue} ) {
                    mem.append(symbolTable[t.stringValue!]!)
                }
                
            case .Directive :
                break
                
            case .ImmediateString :
                mem.append(t.stringValue!.characters.count)
                
                for c in t.stringValue!.characters {
                    mem.append(charToAscii(c: c))
                }
                
            case .ImmediateInteger :
                mem.append(t.intValue!)
            
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
                mem.append(currentState)
                mem.append(inputCharInt)
                mem.append(newState)
                mem.append(outCharInt)
                mem.append(dirInt)
            
            case .Register :
                mem.append(t.intValue!)
                
            case .Instruction :
                if let i = Instructions[t.stringValue!] {
                    mem.append(i)
                }else {
                    print("ERROR:: INVALID INSTRUCTION", t)
                }
                
            case .BadToken :
                print("BAD TOKEN FOUND", t)
                break
            }
        }
        
        return mem
    }
}
