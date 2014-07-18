//
//  LevelLibrary.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/10/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

typealias GenerationFunction = (Int) -> ([String])
typealias PassFunction = (String) -> (Bool)
typealias TransformFunction = (String) -> (String)

struct LevelData {
  let tag: String
  let description: String
  let space: GridSpace
  let exemplars: [String]
  let generationFunction: GenerationFunction
  let passFunction: PassFunction?
  let transformFunction: TransformFunction?
}

class LevelLibrary {
  class var sharedInstace: LevelLibrary {struct Static {static let instance = LevelLibrary()}; return Static.instance}
  subscript(i: Int) -> LevelData {get {return library[i]}}
  
  
  
  let library: [LevelData] = [
    
    LevelData(
      tag: "move", // ↑
      description: "Transport across\n the factory floor.",
      space: GridSpace(5, 5),
      exemplars: ["br", "rb"],
      generationFunction: {i in return [""]},
      passFunction: {i in return true},
      transformFunction: nil
    ),
    
    LevelData(
      tag: "sort", // ↖↗
      description: "Accept: Blue. Transport across.\nReject: Red. Dump on the floor.",
      space: GridSpace(9, 9),
      exemplars: ["br", "rb"],
      generationFunction: {i in return ["B", "R"]},
      passFunction: {i in return true},
      transformFunction: nil
    ),
    
    LevelData(
      tag: "rbr…", // …
      description: "Accept: Strings that begin red, blue, red.",
      space: GridSpace(9, 9),
      exemplars: ["br", "rb"],
      generationFunction: {i in return ["", "RBR", "BRB"]},
      passFunction: {i in return true},
      transformFunction: nil
    ),
    
    LevelData(
      tag: "≥3b", // ≥
      description: "Accept: Strings with three or more blues.",
      space: GridSpace(9, 9),
      exemplars: ["br", "rb"],
      generationFunction: {i in return [""]},
      passFunction: {i in return true},
      transformFunction: nil
    ),
  ]
}