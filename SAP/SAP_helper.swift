//
//  SAP_helper.swift
//  SAP
//
//  Created by Gannon Barnett on 4/14/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation


func characterToUnicodeValue (_ c : Character) -> Int {
    let s = String(c)
    return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
}

func unicodeValueToCharacter(_ n : Int) -> Character {
    return Character(UnicodeScalar(n)!)
}

func splitStringIntoLines(expression: String) -> [String] {
    return expression.characters.split{ $0 == "\n"}.map{ String($0) }
}

func splitStringIntoParts(expression: String) -> [String] {
    return expression.characters.split{ $0 == " "}.map{ String($0) }
}

//functions for input/output from console and filesystem
func readTextFile(_ path: String) -> (message: String?, fileText: String?) {
    let text: String
    do {
        text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
    }
    catch {
        return ("\(error)", nil)
    }
    return (nil, text)
}

func writeTextFile(_ path: String, data: String) -> String? {
    let url = NSURL.fileURL(withPathComponents: [path])
    do {
        try data.write(to: url!, atomically: true, encoding: String.Encoding.utf8)
    } catch let error as NSError {
        return "Failed writing to URL: \(url), Error: " + error.localizedDescription
    }
    return nil
}


