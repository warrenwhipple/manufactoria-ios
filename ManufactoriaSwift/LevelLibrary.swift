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
  let cleanBinaryOutput: Bool
  
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
      self.cleanBinaryOutput = false
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
      self.cleanBinaryOutput = false
  }

  init(tag: String, instructions: String, space: GridSpace, editModes: [EditMode], exemplars: [String],
    generationFunction: GenerationFunction, transformFunction: TransformFunction, cleanBinaryOutput: Bool) {
      self.tag = tag
      self.instructions = instructions
      self.space = space
      self.editModes = editModes
      self.exemplars = exemplars
      self.generationFunction = generationFunction
      self.acceptFunction = nil
      self.transformFunction = transformFunction
      self.cleanBinaryOutput = cleanBinaryOutput
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
    if c == "b" {
      n += i
    }
    i *= 2
  }
  return n
}

private func toStr(var n: Int) -> String {
  assert(n >= 0, "Only non-negative integers can convert to binary strings.")
  if n == 0 {return "r"}
  var s = ""
  var i = 1
  while n > 0 {
    if n % (2 * i) == 0 {
      s += "r"
    } else {
      n -= i
      s += "b"
    }
    i *= 2
  }
  return s
}

var LevelLibrary: [LevelSetup] = [
  
  LevelSetup(
    tag: "all",
    instructions: "Connect the entrance to the exit.",
    space: GridSpace(3),
    editModes: [],
    exemplars: [""],
    generationFunction: {n in return [""]},
    acceptFunction: {s in return true}
  ),
  
  LevelSetup(
    tag: "B",
    instructions: "Accept blue: Send to the exit.\nReject red: Dump on the floor.",
    space: GridSpace(3),
    editModes: [.PullerBR],
    exemplars: ["r", "b"],
    generationFunction: {n in return ["r", "b"]},
    acceptFunction: {s in return s == "b"}
  ),
  
  LevelSetup(
    tag: "BRB...    ",
    instructions: "Accept any that begin blue red blue.",
    space: GridSpace(5),
    editModes: [.PullerBR],
    exemplars: ["rbrb", "brbr"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      if s.length() < 3 {return false}
      return s[0...2] == "brb"
    }
  ),
  
  LevelSetup(
    tag: "no R",
    instructions: "Reject any red anywhere.",
    space: GridSpace(3),
    editModes: [.PullerBR],
    exemplars: ["bbrb", "bbbb"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      var k = 0
      for c in s {if c == "r" {return false}}
      return true
    }
  ),
  
  LevelSetup(
    tag: ">= 3B",
    instructions: "Accept three or more blues.",
    space: GridSpace(5),
    editModes: [.PullerBR],
    exemplars: ["rbrbr", "brbrb"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      var k = 0
      for c in s {if c == "b" {if ++k >= 3 {return true}}}
      return false
    }
  ),
  
  LevelSetup(
    tag: "first last",
    instructions: "Move the first color to the end.",
    space: GridSpace(5),
    editModes: [.PullerBR, .PusherB, .PusherR],
    exemplars: ["brbr"],
    generationFunction: {n in return generate("br", n, {$0 != ""})},
    transformFunction: {s in
      if s.length() > 1 {return s[1 ..< s.length()] + s[0]}
      return s
    }
  ),
  
  LevelSetup(
    tag: "alternates",
    instructions: "Accept sequences that alternate.",
    space: GridSpace(7),
    editModes: [.PullerBR],
    exemplars: ["brbb", "rbrb"],
    generationFunction: {n in return generate("br", n, {$0.length() >= 2})},
    acceptFunction: {s in
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
  
  LevelSetup(
    tag: "B → G\nR → Y",
    instructions: "Change blue to green and red to yellow.",
    space: GridSpace(5),
    editModes: [.PullerBR, .PusherG, .PusherY],
    exemplars: ["brbbrr"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {s in
      var out = ""
      for c in s {
        if c == "b" {out += "g"}
        else {out += "y"}
      }
      return out
    }
  ),
  
  LevelSetup(
    tag: "...BB",
    instructions: "Accept sequences ending with two blues.",
    space: GridSpace(7),
    editModes: [.PullerBR],
    exemplars: ["bbrb", "rbbb"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      if s.length() < 2 {return false}
      if s[-2] == "b" && s[-1] == "b" {return true}
      return false
    }
  ),

  LevelSetup(
    tag: "G + ... + Y",
    instructions: "Add green to the start\nand yellow to the end.",
    space: GridSpace(5),
    editModes: [.PullerBR, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["brbbrr"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {s in return "g" + s + "y"}
  ),
  
  LevelSetup(
    tag: "first = last",
    instructions: "Accept sequences in which\nthe first and last colors are the same.",
    space: GridSpace(7),
    editModes: [.PullerBR],
    exemplars: ["brrbr", "rbbbr"],
    generationFunction: {n in return generate("br", n, {$0 != ""})},
    acceptFunction: {s in return s[0] == s[-1]}
  ),

  LevelSetup(
    tag: "xB = xR",
    instructions: "Accept sequences with\nthe same number of blues and reds.",
    space: GridSpace(7),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["brrbr", "rbbrbr"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      var b = 0, r = 0
      for c in s {
        if c == "b" {b++}
        else {r++}
      }
      return b == r
    }
  ),
  
  LevelSetup(
    tag: "no R",
    instructions: "Remove all reds.",
    space: GridSpace(7),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["brbbrr"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {s in
      var out = ""
      for c in s {if c == "b" {out += "b"}
      }
      return out}
  ),
  
  LevelSetup(
    tag: "swap",
    instructions: "Swap blues and reds.",
    space: GridSpace(7),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["brbbrr"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {s in
      var out = ""
      for c in s {
        if c == "b" {out += "r"}
        else {out += "b"}
      }
      return out}
  ),

  LevelSetup(
    tag: "last first",
    instructions: "Move the last color to the front.",
    space: GridSpace(7),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["brbbrr"],
    generationFunction: {n in return generate("br", n, {$0 != ""})},
    transformFunction: {s in
      if s.length() > 1 {
        return s[-1] + s[0 ..< (s.length()-1)]
      }
      return s
    }
  ),
  
  LevelSetup(
    tag: "xB xR",
    instructions: "Accept a number of blues\nfollowed by the same number of reds.",
    space: GridSpace(9),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["bbrrbb", "bbbrrr"],
    generationFunction: {n in return generate("br", n, {$0 != ""})},
    acceptFunction: {s in
      let len = s.length()
      if len % 2 != 0 {return false}
      let s1 = s[0 ..< len % 2]
      for c in s1 {if c == "r"{return false}}
      let s2 = s[len % 2 ..< len]
      for c in s2 {if c == "b"{return false}}
      return true
    }
  ),
  
  LevelSetup(
    tag: "xB xR xB",
    instructions: "Accept a number of blues followed by the same\nnumber of reds followed by the same number of blues.",
    space: GridSpace(9),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["bbbrrb", "bbrrbb"],
    generationFunction: {n in return generate("br", n, {$0 != ""})},
    acceptFunction: {s in
      let len = s.length()
      if len % 3 != 0 {return false}
      let s1 = s[0 ..< len % 3]
      for c in s1 {if c == "r"{return false}}
      let s2 = s[len % 3 ..< len % 3 * 2]
      for c in s2 {if c == "b"{return false}}
      let s3 = s[len % 3 * 2 ..< len]
      for c in s3 {if c == "r"{return false}}
      return true
    }
  ),

  LevelSetup(
    tag: "middle",
    instructions: "Insert a green in the middle of the sequence.",
    space: GridSpace(9),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["brbbrr"],
    generationFunction: {n in return generate("br", n, {$0.length() % 2 == 0})},
    transformFunction: {s in
      let len = s.length()
      return s[0 ..< len/2] + "g" + s[len/2 ..< len]
    }
  ),
  
  LevelSetup(
    tag: "B → front",
    instructions: "Move all the blues\nto the front of the sequence.",
    space: GridSpace(9),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["rbbrrbbrbr"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {s in
      var b = "", r = ""
      for c in s {
        if c == "b" {b += "b"}
        else {r += "r"}
      }
      return b + r
    }
  ),
  
  LevelSetup(
    tag: "repeats",
    instructions: "Accept sequences that repeat\nmid way through.",
    space: GridSpace(11),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["rbbrrbrb", "brrbbrrb"],
    generationFunction: {n in return generate("br", n, {$0 != ""})},
    acceptFunction: {s in
      let len = s.length()
      if len % 2 != 0 {return false}
      return s[0 ..< len/2] == s[len/2 ..< len]
    }
  ),
  
  LevelSetup(
    tag: "xB = 2xR",
    instructions: "Accept sequences with\ntwice as many blues as reds.",
    space: GridSpace(11),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["brrbr", "rbbrbr"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      var b = 0, r = 0
      for c in s {
        if c == "b" {b++}
        else {r++}
      }
      return b == 2 * r
    }
  ),
  
  LevelSetup(
    tag: "symmetric",
    instructions: "Accept symmetric sequences.",
    space: GridSpace(11),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["rbbrrbrb", "brrbbrrb"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      let len = s.length()
      var r = ""
      for c in s[len - len/2 ..< len] {r = String(c) + r}
      return s[0 ..< len/2] == r
    }
  ),
  
  LevelSetup(
    tag: "reverse",
    instructions: "Reverse the sequence.",
    space: GridSpace(11),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["rbbrrbbrbr"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {s in
      var r = ""
      for c in s {r = String(c) + r}
      return r
    }
  ),

  LevelSetup(
    tag: "copy",
    instructions: "Copy the sequence.",
    space: GridSpace(11),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["rbbrrbbrbr"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {s in return s + s}
  ),

]