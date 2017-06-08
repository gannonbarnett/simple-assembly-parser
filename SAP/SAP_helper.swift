//
//  SAP_helper.swift
//  SAP
//
//  Created by Gannon Barnett on 4/14/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation

func charToAscii(c: Character) -> Int {
    return Int(String(c).utf8.first!)
}

func AsciiToChar(n: Int) -> Character {
    return Character(UnicodeScalar(n)!)
}

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


func fitI(_ i: Int, _ size: Int = 8, right: Bool = false) -> String{
    let iAsString = "\(i)"
    let newLength = iAsString.characters.count
    return fit(iAsString, newLength > size ? newLength : size,right: right)
}

func fitA(array ia: [Int], _ size: Int = 8, right: Bool = false) -> String{
    var arrayAsString = ""
    for i in ia {
        arrayAsString.append("\(i) ")
    }
    let newLength = arrayAsString.characters.count
    return fit(arrayAsString, newLength > size ? newLength : size,right: right)
}

func fit(_ s: String, _ size: Int = 8, right: Bool = true) -> String{
    var result = ""
    let sSize = s.characters.count
    if sSize == size {return s}
    var count = 0
    if size < sSize {
        for c in s.characters {
            if count < size {result.append(c)}
            count += 1
        }
        return result
    }
    result = s
    var addon = ""
    let num = size - sSize
    for _ in 0 ..< num { addon.append(" ") }
    if right {return result + addon}
    return addon + result
}

