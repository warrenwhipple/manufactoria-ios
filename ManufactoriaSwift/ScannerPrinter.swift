//
//  ScannerPrinter.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/28/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class Scanner: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Hiding, Waiting, Spinning}
  
  override init() {
    let loadTexture = SKTexture(imageNamed: "scanner")
    super.init(texture: loadTexture, color: Globals.strokeColor, size: loadTexture.size())
    colorBlendFactor = 1
    xScale = 0
  }
  
  var state: State = .Hiding {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Hiding: xScale = 0
      case .Waiting: xScale = 1
      case .Spinning: xScale = 1
      }
    }
  }
}

class Printer: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Hiding, Waiting}
  
  override init() {
    let loadTexture = SKTexture(imageNamed: "printer")
    super.init(texture: loadTexture, color: Globals.strokeColor, size: loadTexture.size())
    colorBlendFactor = 1
    setScale(0)
  }
  
  var state: State = .Hiding {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Hiding: setScale(0)
      case .Waiting: setScale(1)
      }
    }
  }
}