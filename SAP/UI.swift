//
//  FullMachine.swift
//  SAP
//
//  Created by Gannon Barnett on 6/8/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

class UI {
    
    let helpTable : String = "SAP Help: \n\tasm <program name> - assemble the specified program \n\trun <program name> - run the specified program \n\tpath <path specification> - set the path for the SAP program directory \n\tinclude final / but not name of file. SAP file must have an extension of .txt \n\tprintlst <program name> - print listing file for the specified program \n\tprintbin <program name> - print binary file for the specified program \n\tprintsym <program name> - print symbol table for the specified program \n\tquit  - terminate SAP program \n\thelp  - print help table"
    
    var path : String = ""
    var file : String = ""
    var listFilePath : String {
        return path + file + ".lst"
    }
    
    var binFilePath : String {
        return path + file + ".bin"
    }
    
    var symFilePath : String {
        return path + file + ".sym"
    }
    
    var AssemblerObj : Assembler = Assembler()
    var VMObj : VM = VM()
    
    func run() {
        print("Welcome to SAP!")
        print("->", separator: "", terminator: " ")
        var currentInput = getNewLine()
        while currentInput[0] != "quit" {
            switchStatement(withInput: currentInput)
            print("->", separator: "", terminator: " ")
            currentInput = getNewLine()
        }
        print("Shutting down")
    }

    func AssembleFile(_ fileName : String) {
        file = fileName
        guard !path.isEmpty else {
            print("No path specified. Set path first. Enter \"help\" to view help.")
            return
        }
        let fullName : String = path + fileName
        AssemblerObj.AssembleFile(fullName)
    }
    
    func runFile(_ fileName : String) {
        let fullPath = path + fileName + ".bin"
        VMObj.setFileTo(fullPath)
        VMObj.run()
    }
    
    func switchStatement(withInput fullInput: [String]) {
        let firstInput = fullInput[0]
        
        switch firstInput {
        case "help":
            print(helpTable)
            
        case "asm":
            guard fullInput.count > 1 else {
                print("No file name specified")
                break
            }
            print("Assembling file \(fullInput[1])...")
            AssembleFile(fullInput[1])
            print("\n Assembled.")
            
        case "run":
            guard fullInput.count > 1 else {
                print("No file name specified")
                break
            }
            print("Running file \(fullInput[1])...")
            runFile(fullInput[1])
            print("\n Completed.")
            
        case "path":
            guard fullInput.count > 1 else {
                print("No path specified")
                break
            }
            path = fullInput[1]
            print("Path set to \(path)")
            
        case "printlst":
            guard fullInput.count > 1 else {
                print("No file name specified")
                break
            }
            print("Printing listing file for file \(fullInput[1])...")
            printFile(listFilePath)
            print("\n Printing completed.")
            
        case "printbin":
            guard fullInput.count > 1 else {
                print("No file name specified")
                break
            }
            print("Printing binary file for file \(fullInput[1])...")
            printFile(binFilePath)
            print("\n Printing completed.")
            
        case "printsym":
            guard fullInput.count > 1 else {
                print("No file name specified")
                break
            }
            print("Printing symbol table file for \(fullInput[1])...")
            printFile(symFilePath)
            print("\n Printing completed.")
    
        default:
            print("\" \(fullInput.reduce("",{$0 + $1 + " "}))\" is not a valid command")
            print("Enter \"help\" for command options")
            
        }
        
    }
    
    func getNewLine() -> [String]{
        let input = readLine(strippingNewline: true)
        let splitString = splitStringIntoParts(expression: input!)
        return splitString
        
    }
    

}
