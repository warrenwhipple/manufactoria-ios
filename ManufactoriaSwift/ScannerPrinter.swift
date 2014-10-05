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
      case .Hiding:
        runAction(SKAction.scaleXTo(0, duration: 0.2).easeIn(), withKey: "scale")
        if oldValue == .Spinning {
          runAction(SKAction.sequence([
            SKAction.rotateByAngle(-PI, duration: 0.2),
            SKAction.rotateToAngle(0, duration: 0)
            ]), withKey: "rotate")
        }
      case .Waiting:
        runAction(SKAction.scaleXTo(1, duration: 0.2).easeOut(), withKey: "scale")
        if oldValue == .Spinning {
          runAction(SKAction.sequence([
            SKAction.rotateToAngle(-PI, duration: 0.2 * NSTimeInterval((PI + zRotation) / PI)),
            SKAction.rotateToAngle(-3*PI, duration: 0.6).easeOut(),
            SKAction.rotateToAngle(0, duration: 0)
            ]), withKey: "rotate")
        }
      case .Spinning:
        runAction(SKAction.scaleXTo(1, duration: 0.2).easeOut(), withKey: "scale")
        let rotateForeverAction = SKAction.repeatActionForever(SKAction.sequence([
          SKAction.rotateToAngle(-PI, duration: 0.2),
          SKAction.rotateToAngle(0, duration: 0)
          ]))
        if oldValue == .Waiting {
          runAction(SKAction.sequence([
            SKAction.rotateToAngle(-2*PI, duration: 0.6).easeIn(),
            SKAction.rotateToAngle(0, duration: 0),
            rotateForeverAction
            ]), withKey: "rotate")
        } else {
          zRotation = 0
          runAction(rotateForeverAction, withKey: "rotate")
        }
      }
    }
  }
  
  func resetHiding() {
    state = .Hiding
    xScale = 0
    removeActionForKey("scale")
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
      case .Hiding:
        runAction(SKAction.scaleTo(0, duration: 0.2).easeIn(), withKey: "scale")
      case .Waiting:
        runAction(SKAction.scaleTo(1, duration: 0.2).easeOut(), withKey: "scale")
      }
    }
  }
  
  func resetHiding() {
    state = .Hiding
    setScale(0)
    removeActionForKey("scale")
  }
}