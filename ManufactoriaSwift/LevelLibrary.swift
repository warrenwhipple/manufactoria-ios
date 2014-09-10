//
//  LevelLibrary.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/10/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

typealias GenerationFunction = (Int) -> ([String])
typealias AcceptFunction = (String) -> (Bool)
typealias TransformFunction = (String) -> (String)

let PassComments = ["Nice.", "That works.", "Acceptable.", "Pass."]
let FailComments = ["Nope.", "Wrong.", "No.", "Sorry.", "Fail."]
let LoopComments = ["Circular.", "Out of patience.", "Loopy."]

struct LevelSetup {
  let tag: String
  let instructions: String
  let space: GridSpace
  let editModes: [EditMode]
  let exemplars: [String]
  let generationFunction: GenerationFunction
  let acceptFunction: AcceptFunction?
  let transformFunction: TransformFunction?
  
  init(tag: String, instructions: String, space: GridSpace, editModes: [EditMode], exemplars: [String],
    generationFunction: GenerationFunction, acceptFunction: AcceptFunction) {
      self.tag = tag
      self.instructions = instructions
      self.space = space
      self.editModes = editModes
      self.exemplars = exemplars
      self.generationFunction = generationFunction
      self.acceptFunction = acceptFunction
      self.transformFunction = nil
  }
  
  init(tag: String, instructions: String, space: GridSpace, editModes: [EditMode], exemplars: [String],
    generationFunction: GenerationFunction, transformFunction: TransformFunction) {
      self.tag = tag
      self.instructions = instructions
      self.space = space
      self.editModes = editModes
      self.exemplars = exemplars
      self.generationFunction = generationFunction
      self.acceptFunction = nil
      self.transformFunction = transformFunction
  }
}

// Helper functions for generating string inputs

private func generate(characters: String, count: Int, filter: ((String) -> (Bool))) -> [String] {
  var list: [String] = []
  if filter("") {list.append("")}
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

var LevelLibrary: [LevelSetup] = [
  
  LevelSetup(
    tag: "↑",
    instructions: "Connect the entrance and exit.",
    space: GridSpace(3, 3),
    editModes: [],
    exemplars: [""],
    generationFunction: {n in return [""]},
    acceptFunction: {string in return true}
  ),
  
  LevelSetup(
    tag: "    B",
    instructions: "Accept blue: to the exit.\nReject red: to the floor.",
    space: GridSpace(3, 3),
    editModes: [.PullerBR],
    exemplars: ["r", "b"],
    generationFunction: {n in return ["r", "b"]},
    acceptFunction: {string in return string == "b"}
  ),
  
  LevelSetup(
    tag: "BRB...    ",
    instructions: "Accept any that begin blue red blue.",
    space: GridSpace(5, 5),
    editModes: [.Bridge, .PullerBR],
    exemplars: ["rbrb", "brbr"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {
      s in
      if s.length() < 3 {return false}
      return s[0...2] == "brb"
    }
  ),
  
  LevelSetup(
    tag: "no R",
    instructions: "Reject any red anywhere.",
    space: GridSpace(3, 3),
    editModes: [.Bridge, .PullerBR],
    exemplars: ["bbrb", "bbbb"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {
      s in
      var k = 0
      for c in s {if c == "r" {return false}}
      return true
    }
  ),
  
  LevelSetup(
    tag: ">= 3B",
    instructions: "Accept three or more blues.",
    space: GridSpace(5, 5),
    editModes: [.Bridge, .PullerBR],
    exemplars: ["rbrbr", "brbrb"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {
      s in
      var k = 0
      for c in s {if c == "b" {if ++k >= 3 {return true}}}
      return false
    }
  ),
  
  LevelSetup(
    tag: "first last",
    instructions: "Move the first color to the end.",
    space: GridSpace(5, 5),
    editModes: [.PullerBR, .PusherB, .PusherR],
    exemplars: ["brbr", "rrbb"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {
      s in
      if s.length() > 1 {return s[1 ..< s.length()] + s[0]}
      return s
    }
  ),
  
  LevelSetup(
    tag: "alternating",
    instructions: "Accept only alternating sequences.",
    space: GridSpace(7, 7),
    editModes: [.Bridge, .PullerBR],
    exemplars: ["brbrr", "rbrbr"],
    generationFunction: {n in return generate("br", n, {s in if s.length()<2 {return false}; return true})},
    acceptFunction: {
      s in
      var b = true
      if s[0] == "r" {b = false}
      for c in s.from(1) {
        if b && c == "b" {return false}
        if !b && c == "r" {return false}
        b = !b
      }
      return true
    }
  ),
  
]