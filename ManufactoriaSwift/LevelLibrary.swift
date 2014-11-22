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

var PassCommentCounter = 0
var FailCommentCounter = 0
var LoopCommentCounter = 0
let PassComments = ["sees no flaw!", "approves!", "is pleased!", "finds this acceptable!", "is pleasantly surprised!"]
let FailComments = ["sees all flaws!", "is not happy!", "finds this disturbing!", "is displeased by failure!", "expects better than this!", "is not amused!", "is unimpressed!"]
let LoopComments = ["is out of patience!", "does not like waiting!", "is DIV BY ZERO OVERFLOW", "is getting bored!", "has fallen asleep!"]

struct LevelSetup {
  let unlockKeys: [String]
  let tag: String
  let instructions: String
  let space: GridSpace
  let editModes: [EditMode]
  let exemplars: [String]
  let generationFunction: GenerationFunction
  let acceptFunction: AcceptFunction?
  let transformFunction: TransformFunction?
  let cleanBinaryOutput: Bool
  
  init(unlockKeys: [String] = [], tag: String, instructions: String, space: GridSpace, editModes: [EditMode], exemplars: [String],
    generationFunction: GenerationFunction, acceptFunction: AcceptFunction? = nil, transformFunction: TransformFunction? = nil, cleanBinaryOutput: Bool = false) {
      self.unlockKeys = unlockKeys
      self.tag = tag
      self.instructions = instructions
      self.space = space
      self.editModes = editModes
      self.exemplars = exemplars
      self.generationFunction = generationFunction
      self.acceptFunction = acceptFunction
      self.transformFunction = transformFunction
      self.cleanBinaryOutput = cleanBinaryOutput
  }
}

// Helper functions for generating string inputs

private func generate(characters: String, count: Int, filter: ((String) -> (Bool))) -> [String] {
  var list: [String] = []
  //if filter("") {list.append("")}
  //if characters == "" {return list}
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

var LevelLibrary: [String:LevelSetup] = [
  
  "all":
  LevelSetup(
    unlockKeys: ["sort"],
    tag: "all",
    instructions: "Accept everything.",
    space: GridSpace(3),
    editModes: [],
    exemplars: [""],
    generationFunction: {n in return [""]},
    acceptFunction: {s in return true}
  ),
  
  "sort":
  LevelSetup(
    unlockKeys: ["sequence"],
    tag: "#B",
    instructions: "Accept #b. Reject #r.",
    space: GridSpace(3),
    editModes: [.PullerBR],
    exemplars: ["r", "b"],
    generationFunction: {n in return ["r", "b"]},
    acceptFunction: {s in return s == "b"}
  ),
  
  "sequence":
  LevelSetup(
    unlockKeys: ["nor"],
    tag: "#BRB...",
    instructions: "Robots are programmed\nwith sequences of colors.\n\nAccept if begins #b#r#b.",
    space: GridSpace(5),
    editModes: [.PullerBR],
    exemplars: ["brr", "brb"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      if s.length() < 3 {return false}
      return s[0...2] == "brb"
    }
  ),
  
  "nor":
  LevelSetup(
    unlockKeys: ["norr", "3ormoreb", "endsb"],
    tag: "no #R",
    instructions: "Reject if #r anywhere.",
    space: GridSpace(3),
    editModes: [.PullerBR],
    exemplars: ["bbrb", "bbbb"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      for c in s {if c == "r" {return false}}
      return true
    }
  ),
  
  "norr":
  LevelSetup(
    tag: "no #RR",
    instructions: "Reject if #r#r anywhere.",
    space: GridSpace(5),
    editModes: [.PullerBR],
    exemplars: ["brrb", "bbbb"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      var lastR = false
      for c in s {
        if c == "r" {
          if lastR {
            return false
          } else {
            lastR = true
          }
        } else {
          lastR = false
        }
      }
      return true
    }
  ),
  
  "3ormoreb":
  LevelSetup(
    unlockKeys: ["write"],
    tag: ">= 3B",
    instructions: "Accept if three or more #b.",
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
  
  "write":
  LevelSetup(
    unlockKeys: ["firstlast", "btogrtoy"],
    tag: "BRBBR",
    instructions: "Write #b#r#b#b#r.",
    space: GridSpace(3),
    editModes: [.PusherB, .PusherR],
    exemplars: [""],
    generationFunction: {n in return [""]},
    transformFunction: {s in return "brbbr"}
  ),
  
  "firstlast":
  LevelSetup(
    tag: "first last",
    instructions: "Move the first to the end.",
    space: GridSpace(5),
    editModes: [.PullerBR, .PusherB, .PusherR],
    exemplars: ["brbr"],
    generationFunction: {n in return generate("br", n, {$0 != ""})},
    transformFunction: {s in
      if s.length() > 1 {return s[1 ..< s.length()] + s[0]}
      return s
    }
  ),
  
  "alternates":
  LevelSetup(
    tag: "alternates",
    instructions: "Accept if alternating.",
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
  
  "btogrtoy":
  LevelSetup(
    unlockKeys: ["gstartyend"],
    tag: "B → G\nR → Y",
    instructions: "Change #b → #g and #r → #y.",
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
  
  "endsb":
  LevelSetup(
    unlockKeys: ["endsbb", "firstislast", "alternates"],
    tag: "...B",
    instructions: "Accept if ends #b.",
    space: GridSpace(5),
    editModes: [.PullerBR],
    exemplars: ["bbr", "rbb"],
    generationFunction: {n in return generate("br", n)},
    acceptFunction: {s in
      if s.length() < 1 {return false}
      if s[-1] == "b" {return true}
      return false
    }
  ),
  
  "endsbb":
  LevelSetup(
    tag: "...BB",
    instructions: "Accept if ends #b#b.",
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
  
  "gstartyend":
  LevelSetup(
    unlockKeys: ["remover", "swap", "odd"],
    tag: "G + ... + Y",
    instructions: "Add #g to the start\nand #y to the end.",
    space: GridSpace(5),
    editModes: [.PullerBR, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["brbbrr"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {s in return "g" + s + "y"}
  ),
  
  "firstislast":
  LevelSetup(
    tag: "first = last",
    instructions: "Accept if first and\nlast are the same.",
    space: GridSpace(7),
    editModes: [.PullerBR],
    exemplars: ["brrbr", "rbbbr"],
    generationFunction: {n in return generate("br", n, {$0 != ""})},
    acceptFunction: {s in return s[0] == s[-1]}
  ),

  "xbisxr":
  LevelSetup(
    unlockKeys: ["xbis2xr"],
    tag: "xB = xR",
    instructions: "Accept if same\nnumber of #b as #r.",
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
  
  "remover":
  LevelSetup(
    unlockKeys: ["btofront", "xbxr"],
    tag: "remove R",
    instructions: "Remove all #r.",
    space: GridSpace(5),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["brbbrr"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {s in
      var out = ""
      for c in s {if c == "b" {out += "b"}
      }
      return out}
  ),
  
  "swap":
  LevelSetup(
    unlockKeys: ["lastfirst", "copy"],
    tag: "swap",
    instructions: "Swap #b and #r.",
    space: GridSpace(5),
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
  
  "lastfirst":
  LevelSetup(
    unlockKeys: ["reverse"],
    tag: "last first",
    instructions: "Move the last color to the front.",
    space: GridSpace(9),
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
  
  "xbxr":
  LevelSetup(
    unlockKeys: ["xbxrxb", "xbisxr"],
    tag: "xB xR",
    instructions: "Accept a number of #b\nfollowed by the same number of #r.",
    space: GridSpace(9),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["bbrrbb", "bbbrrr"],
    generationFunction: {n in return generate("br", n, {$0 != ""})},
    acceptFunction: {s in
      let len = s.length()
      if len % 2 != 0 {return false}
      let s1 = s[0 ..< len / 2]
      for c in s1 {if c == "r"{return false}}
      let s2 = s[len / 2 ..< len]
      for c in s2 {if c == "b"{return false}}
      return true
    }
  ),
  
  "xbxrxb":
  LevelSetup(
    unlockKeys: ["symmetric", "middle"],
    tag: "xB xR xB",
    instructions: "Accept a number of #b followed by the same\nnumber of #r followed by the same number of #b.",
    space: GridSpace(9),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["bbbrrb", "bbrrbb"],
    generationFunction: {n in return generate("br", n, {$0 != ""})},
    acceptFunction: {s in
      let len = s.length()
      if len % 3 != 0 {return false}
      let s1 = s[0 ..< len / 3]
      for c in s1 {if c == "r"{return false}}
      let s2 = s[len / 3 ..< 2 * len / 3]
      for c in s2 {if c == "b"{return false}}
      let s3 = s[2 * len / 3 ..< len]
      for c in s3 {if c == "r"{return false}}
      return true
    }
  ),

  "middle":
  LevelSetup(
    unlockKeys: ["copied", "thirds"],
    tag: "middle",
    instructions: "Insert a #g in the middle of the sequence.",
    space: GridSpace(11),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["brbbrr"],
    generationFunction: {n in return generate("br", n, {$0.length() % 2 == 0})},
    transformFunction: {s in
      let len = s.length()
      return s[0 ..< len/2] + "g" + s[len/2 ..< len]
    }
  ),
  
  "btofront":
  LevelSetup(
    tag: "B → front",
    instructions: "Move all #b\nto the front of the sequence.",
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
  
  "copied":
  LevelSetup(
    unlockKeys: ["thirds"],
    tag: "copied",
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
  
  "xbis2xr":
  LevelSetup(
    tag: "xB = 2xR",
    instructions: "Accept sequences with\ntwice as many #b as #r.",
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
  
  "symmetric":
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
  
  "reverse":
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

  "copy":
  LevelSetup(
    tag: "copy",
    instructions: "Copy the sequence.",
    space: GridSpace(11),
    editModes: [.PullerBR, .PullerGY, .PusherB, .PusherR, .PusherG, .PusherY],
    exemplars: ["rbbrrbbrbr"],
    generationFunction: {n in return generate("br", n)},
    transformFunction: {s in return s + s}
  )
]