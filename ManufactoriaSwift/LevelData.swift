//
//  LevelData.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/10/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

struct LevelData {
    let tag: String
    let description: String
    let space: GridSpace
    let exemplars: [String]
    let generationFunction: Int -> [String]
    let passFunction: (String -> Bool)?
    let transformFunction: (String -> String)?
}

let levelLibrary: [LevelData] = [
    
    LevelData(
        tag: "↑", //↑
        description: "Transport across\n the factory floor.",
        space: GridSpace(9, 9),
        exemplars: ["br", "rb"],
        generationFunction: {i in return [""]},
        passFunction: {i in return true},
        transformFunction: nil
    ),
    
    LevelData(
        tag: "↖↗", // ↖↗
        description: "Accept: Blue. Transport across.\nReject: Red. Dump on the floor.",
        space: GridSpace(9, 9),
        exemplars: ["br", "rb"],
        generationFunction: {i in return ["B", "R"]},
        passFunction: {i in return true},
        transformFunction: nil
    ),
    
    LevelData(
        tag: "RBR...",
        description: "Accept: Strings that begin red, blue, red.",
        space: GridSpace(9, 9),
        exemplars: ["br", "rb"],
        generationFunction: {i in return ["", "RBR", "BRB"]},
        passFunction: {i in return true},
        transformFunction: nil
    ),
    
    LevelData(
        tag: "≥3B", // ≥
        description: "Accept: Strings with three or more blues.",
        space: GridSpace(9, 9),
        exemplars: ["br", "rb"],
        generationFunction: {i in return [""]},
        passFunction: {i in return true},
        transformFunction: nil
    ),
]