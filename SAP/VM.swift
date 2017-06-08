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
    var stack : IntStack = IntStack(size: 10)
    var lines : [String] = []
    
    var programCounter : Int = 0
    var compareRegister : Int = 0
    var stackPointer : Int = 0
    
    var labels = [[Int : String]]() //Int is position, String is label
    
    init(file: String) {
        self.file = file
        load(fileName: file)
    }
    
    
    func load(fileName: String) {
        let (message, text) = readTextFile("/Users/maxgoldberg1/Desktop/Programming_Class_Projects/SAP/SAP/" + fileName + ".txt")
        guard message == nil else {
            print("Error: File \(file) not found")
            return
        }
        lines = splitStringIntoLines(expression: text!)
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
    
    func getInstruction(rawValue: Int) -> Instruction{
        let instruction : Instruction = Instruction(rawValue: rawValue)!
        return instruction
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
    
    func execute(command : Instruction) {
        switch command {
            
        case .clrx:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            memory[firstR_VALUE] = 0
            
        case .clrm:
            programCounter += 1
            let label = memory[programCounter]
            let label_VALUE = memory[label]
            memory[label_VALUE] = 0
            
        case .clrb:
            programCounter += 1
            let start_INDEX = registers[memory[programCounter]]
            programCounter += 1
            let block_COUNT = registers[memory[programCounter]]
            var positionToBeCleared = start_INDEX
            for _ in 0..<block_COUNT {
                memory[positionToBeCleared] = 0
                positionToBeCleared += 1
            }
            
        case .movir:
            programCounter += 1
            let constant = memory[programCounter]
            programCounter += 1
            registers[memory[programCounter]] = constant
            
        case .movrr:
            programCounter += 1
            let firstR_INDEX = memory[programCounter]
            let firstR_VALUE = registers[firstR_INDEX]
            programCounter += 1
            let secondR_INDEX = memory[programCounter]
            registers[secondR_INDEX] = firstR_VALUE
            
        case .movrm:
            programCounter += 1
            let firstR_INDEX = memory[programCounter]
            let firstR_VALUE = registers[firstR_INDEX]
            programCounter += 1
            let LABEL_VALUE = memory[programCounter]
            memory[LABEL_VALUE] = firstR_VALUE
            
        case .movmr:
            programCounter += 1
            let label = memory[programCounter]
            let label_VALUE = memory[label]
            programCounter += 1
            let R_INDEX = memory[programCounter]
            registers[R_INDEX] = label_VALUE
            
        case .movxr:
            programCounter += 1
            let r1_VALUE = registers[memory[programCounter]]
            programCounter += 1
            registers[memory[programCounter]] = r1_VALUE
            
        case .movar:
            programCounter += 1
            let label_INDEX = memory[programCounter]
            programCounter += 1
            registers[memory[programCounter]] = label_INDEX
            
        case .movb:
            programCounter += 1
            let start_INDEX = memory[programCounter]
            programCounter += 1
            let block_DESTINATION = memory[programCounter]
            programCounter += 1
            let block_COUNT = memory[programCounter]
            var positionToBeMoved = start_INDEX
            var destinationPosition = block_DESTINATION
            for _ in 0..<block_COUNT {
                memory[destinationPosition] = memory[positionToBeMoved]
                destinationPosition += 1
                positionToBeMoved += 1
            }
            
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
            
        case .addmr:
            programCounter += 1
            let label = memory[programCounter]
            let label_VALUE = memory[label]
            programCounter += 1
            registers[memory[programCounter]] = label_VALUE
            
        case .addxr:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            let value = memory[firstR_VALUE]
            programCounter += 1
            registers[memory[programCounter]] = value
            
        case .subir:
            programCounter += 1
            let constant = memory[programCounter]
            programCounter += 1
            let R_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = R_VALUE - constant
            
        case .subrr:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            programCounter += 1
            let secondR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = secondR_VALUE - firstR_VALUE
            
        case .submr:
            programCounter += 1
            let label = memory[programCounter]
            let label_VALUE = memory[label]
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = firstR_VALUE - label_VALUE
            
        case .subxr:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            let value = memory[firstR_VALUE]
            programCounter += 1
            let secondR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = secondR_VALUE - value
            
        case .mulir:
            programCounter += 1
            let constant = memory[programCounter]
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = firstR_VALUE * constant
            
        case .mulrr:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            programCounter += 1
            let secondR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = secondR_VALUE * firstR_VALUE
            
        case .mulmr:
            programCounter += 1
            let label = memory[programCounter]
            let label_VALUE = memory[label]
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = firstR_VALUE * label_VALUE
            
        case .mulxr:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            let value = memory[firstR_VALUE]
            programCounter += 1
            let secondR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = secondR_VALUE * value
            
        case .divir:
            programCounter += 1
            let constant = memory[programCounter]
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = firstR_VALUE / constant
            
        case .divrr:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            programCounter += 1
            let secondR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = secondR_VALUE / firstR_VALUE
            
        case .divmr:
            programCounter += 1
            let label = memory[programCounter]
            let label_VALUE = memory[label]
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = firstR_VALUE / label_VALUE
            
        case .divxr:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            let value = memory[firstR_VALUE]
            programCounter += 1
            let secondR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = secondR_VALUE / value
            
        case .jmp:
            programCounter += 1
            let destination = memory[programCounter]
            programCounter = destination
            programCounter -= 1
            
        case .sojz:
            programCounter += 1
            let constant = 1
            let firstR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = firstR_VALUE - constant
            let updatedFirstR_VALUE = registers[memory[programCounter]]
            programCounter += 1
            let label = memory[programCounter]
            if updatedFirstR_VALUE == 0 {
                programCounter = label
            }
            
        case .sojnz:
            programCounter += 1
            let constant = 1
            let firstR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = firstR_VALUE - constant
            let updatedFirstR_VALUE = registers[memory[programCounter]]
            programCounter += 1
            let label = memory[programCounter]
            if updatedFirstR_VALUE != 0 {
                programCounter = label
            }
            
        case .aojz:
            programCounter += 1
            let constant = 1
            let firstR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = firstR_VALUE + constant
            let updatedFirstR_VALUE = registers[memory[programCounter]]
            programCounter += 1
            let label = memory[programCounter]
            if updatedFirstR_VALUE == 0 {
                programCounter = label
            }
            
        case .aojnz:
            programCounter += 1
            let constant = 1
            let firstR_VALUE = registers[memory[programCounter]]
            registers[memory[programCounter]] = firstR_VALUE + constant
            let updatedFirstR_VALUE = registers[memory[programCounter]]
            programCounter += 1
            let label = memory[programCounter]
            if updatedFirstR_VALUE != 0 {
                programCounter = label
            }
            
        case .cmpmr:
            programCounter += 1
            let label = memory[programCounter]
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            compareRegister = label - firstR_VALUE
            
        case .jmpn:
            programCounter += 1
            var destination = 0
            let label = memory[programCounter]
            destination = label
            if compareRegister < 0 {
                programCounter = destination
            }
            
        case .jmpz:
            programCounter += 1
            var destination = 0
            let label = memory[programCounter]
            destination = label
            if compareRegister == 0 {
                programCounter = destination
            }
            
        case .jmpp:
            programCounter += 1
            var destination = 0
            let label = memory[programCounter]
            destination = label
            if compareRegister > 0 {
                programCounter = destination
            }
            
        case .jsr: //jump to subroutine, r5-r9 pushed
            break
            
        case .ret: //return from subroutine, r5-r9 popped
            break
            
        case .push: //push r1 onto stack
            programCounter += 1
            let VAL_INDEX = memory[programCounter]
            let VALUE = registers[VAL_INDEX]
            stack.push(VALUE)
            
        case .pop: //stack pop inot r1
            programCounter += 1
            let destination = memory[programCounter]
            registers[destination] = stack.pop()
            
        case .stackc: //check stack condition, 0-ok, 1-full, 2-empty
            programCounter += 1
            let destination = memory[programCounter]
            registers[destination] = stack.getCondition()
            
            
        case .outci:
            programCounter += 1
            let characterUnicode = memory[programCounter]
            print(unicodeValueToCharacter(characterUnicode))
            
        case .outcx:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            let characterUnicode = memory[firstR_VALUE]
            print(unicodeValueToCharacter(characterUnicode))
            
        case .outcb:
            programCounter += 1
            let start_INDEX = registers[memory[programCounter]]
            programCounter += 1
            let block_COUNT = registers[memory[programCounter]]
            var positionToPrinted = start_INDEX
            for _ in 0..<block_COUNT {
                print(memory[positionToPrinted])
                positionToPrinted += 1
            }
            
        case .readi:
            print(">")
            let input = readLine()
            let int = Int(input!)!
            programCounter += 1
            let destination = memory[programCounter]
            registers[destination] = int
            
            //MARK:: NEED TO IMPLEMENT ERROR CODE OF INTEGER CASTING
            programCounter += 1
            let errorCode = 0
            
        case .readc: //read charac from console
            let input = readLine()
            let char = Character(input!)
            programCounter += 1
            let destination = memory[programCounter]
            registers[destination] = charToAscii(c: char)
            
        case .readln: // read line from console
            break
            
        case .brk: // go into debugger
            break
            
        case .movrx:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            programCounter += 1
            let secondR_VALUE = registers[memory[programCounter]]
            memory[secondR_VALUE] = firstR_VALUE
            
        case .movxx:
            programCounter += 1
            let firstR_VALUE = registers[memory[programCounter]]
            let contents = memory[firstR_VALUE]
            programCounter += 1
            let secondR_VALUE = registers[memory[programCounter]]
            memory[secondR_VALUE] = contents
            
        case .outs:
            programCounter += 1
            print(toUnicodeChar(pc: programCounter), terminator: "")
            
        case .nop:
            break
            
        case .cmpir:
            programCounter += 1
            let value = memory[programCounter]
            programCounter += 1
            let firstR_INDEX = memory[programCounter]
            let firstR_VALUE = registers[firstR_INDEX]
            compareRegister = firstR_VALUE - value
            
        case .cmprr:
            programCounter += 1
            let firstR_INDEX = memory[programCounter]
            let firstR_VALUE = registers[firstR_INDEX]
            programCounter += 1
            let secondR_INDEX = memory[programCounter]
            let secondR_VALUE = registers[secondR_INDEX]
            compareRegister = firstR_VALUE - secondR_VALUE
            
        case .outcr:
            programCounter += 1
            let label = memory[programCounter]
            let label_VALUE = registers[label]
            let character = unicodeValueToCharacter(label_VALUE)
            print(character, terminator: "")
            
        case .printi:
            programCounter += 1
            let character = registers[memory[programCounter]]
            print(character, terminator: "")
            
        case .jmpne:
            programCounter += 1
            var destination = 0
            destination = memory[programCounter]
            if compareRegister != 0 {
                programCounter = destination
                programCounter -= 1
            }
            
        case .clrr:
            programCounter += 1
            let R_INDEX = memory[programCounter]
            registers[R_INDEX] = 0
            
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
        print("Running program from file <" + file + ".txt> \n")
        while memory[programCounter] != 0 { //if memory[programCounter] = 0, halt program
            execute(command: getInstruction(rawValue: memory[programCounter]))
            programCounter += 1
        }
    }
}
