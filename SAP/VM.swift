//
//  VM.swift
//  SAP
//
//  Created by Gannon Barnett on 4/10/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

class VM {

    let file : String
    var memory = [Int]()
    var registers = [Int](repeating: 0, count: 10)
    
    var programCounter : Int = 0
    var compareRegister : Int = 0
    var stackPointer : Int = 0
    
    var labels = [[Int]]()
  
    init(file: String) {
        self.file = file
        load(fileName: file)
    }
    

    func load(fileName: String) {
        let file = fileName + ".txt"
        let (message, text) = readTextFile("/Users/gannonbarnett/Desktop/xCodeThings/SAP/doublesInput.txt")
        guard message == nil else {
            print("Error: File \(file) not found")
            return
        }
        let lines = splitStringIntoLines(expression: text!)
        programCounter = Int(lines[1])!
        for var index in 2 ... lines.count - 1{
            memory.append(Int(lines[index])!)
            index += 1
        }
        
        while memory.count < 2000 {
            memory.append(0)
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
        case compir
        case comprr
        case cmpmr
        case jmpn //fixed
        case jmpz
        case jmpp //added
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
    
    func getInstruction(rawValue: Int) -> Instruction{
        let instruction : Instruction = Instruction(rawValue: rawValue)!
        return instruction
    }
    
    func execute(command : Instruction) {
        switch command {
        /*case .clrr:
            break
            
        case .clrx:
            break
            
        case .clrm:
            break
            
        case .clrb:
            break
            
        case .movir:
            break
        */
        case .movrr:
            programCounter += 1
            let firstR_INDEX = memory[programCounter]
            let firstR_VALUE = registers[firstR_INDEX]
            programCounter += 1
            let secondR_INDEX = memory[programCounter]
            registers[secondR_INDEX] = firstR_VALUE
        
        case .movrm:
            break
            
        case .movmr:
            programCounter += 1
            let label = memory[programCounter]
            programCounter += 1
            let R_INDEX = memory[programCounter]
            registers[R_INDEX] = label
            
        case .movxr:
            break
            
        case .movar:
            break
            
        case .movb:
            break
        
        case .addir:
            programCounter += 1
            let constant = memory[programCounter]
            programCounter += 1
            let R_INDEX = memory[programCounter]
            registers[R_INDEX] += constant
            
        case .addrr:
            programCounter += 1
            let firstR_INDEX = memory[programCounter]
            let firstR_VALUE = registers[firstR_INDEX]
            programCounter += 1
            let secondR_INDEX = memory[programCounter]
            registers[secondR_INDEX] += firstR_VALUE
            
        case .outs:
            programCounter += 1
            print(toUnicodeChar(pc: programCounter), terminator: "")
        
        case .compir:
            programCounter += 1
            let firstR_INDEX = memory[programCounter]
            let firstR_VALUE = registers[firstR_INDEX]
            programCounter += 1
            let value = memory[programCounter]
            compareRegister = firstR_VALUE - value
            
        case .comprr:
            programCounter += 1
            let firstR_INDEX = memory[programCounter]
            let firstR_VALUE = registers[firstR_INDEX]
            programCounter += 1
            let secondR_INDEX = memory[programCounter]
            let secondR_VALUE = registers[secondR_INDEX]
            compareRegister = firstR_VALUE - secondR_VALUE
            
        case .outcr:
            programCounter += 1
            let character = unicodeValueToCharacter(memory[programCounter])
            print(character, terminator: "")
            
        case .printi:
            programCounter += 1
            let character = registers[memory[programCounter]]
            print(character, terminator: "")
        
        case .jmpne:
            var destination : Int = 0
            programCounter += 1
            if compareRegister != 0 {
                destination = memory[programCounter - 1]
                programCounter = destination
            }
            
        default:
            print("CODE MISSING")
            break
        }
        
    }
    
    func toUnicodeChar(pc : Int) -> String {
        let str_LOCATION = memory[pc]
        let str_LENGTH = memory[str_LOCATION]
        var s = String()
        for value in str_LOCATION + 1 ... str_LOCATION + str_LENGTH {
            s.append(unicodeValueToCharacter(memory[value]))
        }
        return s
    }
    
    func run() {
        print("Running program from file <" + file + ".txt>")
        while memory[programCounter] != 0 { //if memory[programCounter] = 0, halt program.
          //  print("executing command with instruction: " + String(describing: getInstruction(rawValue: memory[programCounter])))
            execute(command: getInstruction(rawValue: memory[programCounter]))
            programCounter += 1
        }
        print("Halt at line " + String(programCounter))
    }
}
