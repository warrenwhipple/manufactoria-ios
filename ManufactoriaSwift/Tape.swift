//
//  Tape.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/8/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

enum Color {
    case Blue, Red, Green, Yellow
}

protocol TapeDelegate {
    func writeColor(color: Color)
    func deleteColor()
}

class Tape {
    var string: String
    var delegate: TapeDelegate?
    
    init() {
        string = ""
    }
    
    init(_ string: String) {
        self.string = string
        clean()
    }
    
    func clean() {
        var newString = ""
        for c in string {
            switch c {
            case "b", "B", "1": newString += "b"
            case "r", "R", "0": newString += "r"
            case "g", "G": newString += "g"
            case "y", "Y": newString += "y"
            default: break
            }
        }
        if string != newString {string = newString}
    }
    
    func color() -> Color? {
        if countElements(string) == 0 {return nil}
        switch Array(string)[0] {
        case "b": return Color.Blue
        case "r": return Color.Red
        case "g": return Color.Green
        case "y": return Color.Yellow
        default: return nil
        }
    }
    
    func writeColor(color: Color) {
        switch color {
        case .Blue: string += "b"
        case .Red: string += "r"
        case .Green: string += "g"
        case .Yellow: string += "y"
        }
        delegate?.writeColor(color)
    }
    
    func deleteColor() {
        if countElements(string) != 0 {
            string = string.substringFromIndex(1)
            delegate?.deleteColor()
        }
    }    
}