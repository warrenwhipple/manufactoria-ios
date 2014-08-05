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

let PassResults = ["Nice.", "That works.", "Acceptable.", "Fine."]
let FailResults = ["Nope.", "Wrong.", "No.", "Sorry.", "Yeah um no.", "Fail.", "Not good.", "Problematic."]
let LoopResults = ["Circular.", "Bored.", "Out of patience.", "No no no no no... no."]

struct LevelSetup {
  let tag: String
  let instructions: String
  let space: GridSpace
  let buttons: [ToolbarButtonType]
  let exemplars: [String]
  let generationFunction: GenerationFunction
  let passFunction: PassFunction?
  let transformFunction: TransformFunction?
  
  init(tag: String, instructions: String, space: GridSpace, buttons: [ToolbarButtonType], exemplars: [String],
    generationFunction: GenerationFunction, passFunction: PassFunction) {
      self.tag = tag
      self.instructions = instructions
      self.space = space
      self.buttons = buttons
      self.exemplars = exemplars
      self.generationFunction = generationFunction
      self.passFunction = passFunction
      self.transformFunction = nil
  }
  
  init(tag: String, instructions: String, space: GridSpace, buttons: [ToolbarButtonType], exemplars: [String],
    generationFunction: GenerationFunction, transformFunction: TransformFunction) {
      self.tag = tag
      self.instructions = instructions
      self.space = space
      self.buttons = buttons
      self.exemplars = exemplars
      self.generationFunction = generationFunction
      self.passFunction = nil
      self.transformFunction = transformFunction
  }
}

// Helper functions for generating string inputs

private func generate(characters: String, count: Int, filter: ((String) -> (Bool))) -> [String] {
  var list: [String] = [""]
  if characters == "" {return list}
  var lastLevel = [""]
  var nextLevel: [String] = []
  while true {
    for string in lastLevel {
      for character in characters {
        let newString = string + character
        if filter(newString) {list.append(newString)}
        if list.count >= count {return list}
        nextLevel.append(newString)
      }
    }
    lastLevel = nextLevel
    nextLevel = []
  }
}

private func generate(characters: String, count: Int) -> [String] {
  return generate(characters, count, {s in return true})
}

private func toInt(s: String) -> Int {
  var n = 0
  var i = 1
  for c in s {
    if c == "b" {n += i}
    i *= 2
  }
  return n
}

private func toStr(var n: Int) -> String {
  if n == 0 {return "r"}
  var s = ""
  var i = 1
  while n > 0 {
    if n % (2 * i) > 0 {
      n -= i
      s += "b"
    } else {
      s += "r"
    }
    i *= 2
  }
  return s
}

let LevelLibrary: [LevelSetup] = [
  
  LevelSetup(
    tag: "↑",
    instructions: "Connect the entrance and exit.",
    space: GridSpace(3, 3),
    buttons: [.Blank, .Belt],
    exemplars: [""],
    generationFunction: {n in return [""]},
    passFunction: {string in return true}
  ),
  
  LevelSetup(
    tag: "    B",
    instructions: "Accept blue: to the exit.\nReject red: to the floor.",
    space: GridSpace(5, 5),
    buttons: [.Blank, .Belt, .PullerBR],
    exemplars: ["b", "r"],
    generationFunction: {n in return ["b", "r"]},
    passFunction: {string in return string == "b"}
  ),
  
  LevelSetup(
    tag: "BRB...    ",
    instructions: "Accept any that begin blue red blue.",
    space: GridSpace(7, 7),
    buttons: [.Blank, .BeltBridge, .PullerBR],
    exemplars: ["brbr", "rbrb"],
    generationFunction: {n in return generate("br", n)},
    passFunction: {
      s in
      if s.length() < 3 {return false}
      return s[0...2] == "brb"
    }
  ),
  
  LevelSetup(
    tag: ">= 3B",
    instructions: "Accept three or more blues.",
    space: GridSpace(9, 9),
    buttons: [.Blank, .Belt],
    exemplars: ["brbrb", "rbrbr"],
    generationFunction: {n in return generate("br", n)},
    passFunction: {
      s in
      var k = 0
      for c in s {if c == "b" {if ++k >= 3 {return true}}}
      return false
    }
  ),
  
  LevelSetup(
    tag: "no R",
    instructions: "Reject any red anywhere.",
    space: GridSpace(11, 11),
    buttons: [.Blank, .Belt],
    exemplars: ["bbbb", "bbrb"],
    generationFunction: {n in return generate("br", n)},
    passFunction: {
      s in
      var k = 0
      for c in s {if c == "r" {return false}}
      return true
    }
  ),
  
  LevelSetup(
    tag: "first last",
    instructions: "Move the first color to the end.",
    space: GridSpace(13, 13),
    buttons: [.Blank, .Belt],
    exemplars: ["brbr", "rrbb"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {
      s in
      if s.length() > 1 {return s[1 ..< s.length()] + s[0]}
      return s
    }
  ),
]