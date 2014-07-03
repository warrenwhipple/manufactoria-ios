//
//  TapeProtocol.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/1/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

enum Color {
    case Blue, Red, Green, Yellow
}

protocol TapeProtocol {
    func color() -> Color?
    func writeColor(color: Color)
    func deleteColor()
}
