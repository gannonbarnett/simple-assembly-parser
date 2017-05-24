//
//  Assembler.swift
//  SAP
//
//  Created by Gannon Barnett on 4/24/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

class Assembler {
    let file : String
    let t : Tokenizer
    
    init(file: String) {
        self.file = file
        let (message, text) = readTextFile("/Users/gannonbarnett/Desktop/xCodeThings/SAP/" + file + ".txt")
        guard message == nil else {
            print("Error: File \(file) not found")
            t = Tokenizer(lines: ["ERROR"])
            return
        }
        let lines = splitStringIntoLines(expression: text!)
        
        self.t = Tokenizer(lines: lines)
        print("Load finished!")
    }
    
    func printTokens() {
        t.printTokens()
    }
}
