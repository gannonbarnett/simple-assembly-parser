//
//  Assembler.swift
//  SAP
//
//  Created by Gannon Barnett on 4/24/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

class Assembler {
    var t = Tokenizer()
    let file : String
    
    init(file: String) {
        self.file = file
        load(fileName: file)
    }
    
    func load(fileName: String) {
        let (message, text) = readTextFile("/Users/gannonbarnett/Desktop/xCodeThings/SAP/" + fileName + ".txt")
        guard message == nil else {
            print("Error: File \(file) not found")
            return
        }
        var lines = splitStringIntoLines(expression: text!)
        for l in lines {
            t.setLine(to: l)
            t.printTokens()
        }
        print("Load finished!")
    }
}
