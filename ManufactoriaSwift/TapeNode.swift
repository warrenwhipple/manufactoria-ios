//
//  TapeNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TapeNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Loading, Waiting, Writing, Deleting, Clearing}
  
  let dotWrapper = SKNode()
  var dots: [SKSpriteNode] = []
  var deletingDot: SKSpriteNode?
  let dotTexture = SKTexture(imageNamed: "dot")
  let dotSpacing: CGFloat
  let printer = SKSpriteNode("printer")
  var width: CGFloat = 0
  
  override init() {
    dotSpacing = dotTexture.size().width * 1.25
    printer.setScale(0)
    printer.zPosition = 1
    super.init()
    addChild(printer)
    addChild(dotWrapper)
  }
  
  var state: State = .Loading
  
  func update(tickPercent: CGFloat) {
    switch state {
    case .Loading:
      if tickPercent < 0.5 {
        let ease = easeInOut(2 * tickPercent)
        for dot in dots {
          dot.position.x = 0
          dot.setScale(ease)
        }
        printer.position.x = 0
      } else {
        let ease = easeInOut(2 * tickPercent - 1)
        let offsetX = -0.5 * CGFloat(dots.count) * ease
        let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count))
        var i = 0
        for dot in dots {
          dot.position.x = tapeSpacing * (CGFloat(i++) * ease + offsetX)
          dot.setScale(1)
        }
        printer.position.x = tapeSpacing * (CGFloat(i) * ease + offsetX)
      }
    case .Waiting:
      let offsetX = -0.5 * CGFloat(dots.count)
      let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count))
      var i = 0
      for dot in dots {
        dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
        dot.setScale(1)
      }
      printer.position.x = tapeSpacing * (CGFloat(i) + offsetX)
    case .Writing:
      if tickPercent < 0.5 {
        let ease = easeInOut(2 * tickPercent)
        let offsetX = -0.5 * CGFloat(dots.count - 1)
        let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count - 1))
        var i = 0
        for dot in dots {
          dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
          dot.setScale(1)
        }
        if let lastDot = dots.last {lastDot.alpha = ease}
        printer.position.x = tapeSpacing * (CGFloat(i - 1) + offsetX)
      } else {
        let ease = easeInOut(2 * tickPercent - 1)
        let easeLeft = 1 - ease
        let offsetX = -0.5 * (easeLeft * CGFloat(dots.count - 1) + ease * CGFloat(dots.count))
        let tapeSpacing = easeLeft * min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count - 1)) + ease * min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count))
        var i = 0
        for dot in dots {
          dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
          dot.setScale(1)
        }
        printer.position.x = tapeSpacing * ((easeLeft * CGFloat(i - 1) + ease * CGFloat(i)) + offsetX)
      }
    case .Deleting:
      if tickPercent < 0.5 {
        let easeLeft = 1 - easeInOut(2 * tickPercent)
        let offsetX = -0.5 * CGFloat(dots.count + 1)
        let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count + 1))
        if let dot = deletingDot {
          dot.position.x = tapeSpacing * offsetX
          dot.setScale(easeLeft)
        }
        var i = 1
        for dot in dots {
          dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
          dot.setScale(1)
        }
        printer.position.x = tapeSpacing * (CGFloat(i) + offsetX)
      } else {
        let ease = easeInOut(2 * tickPercent - 1)
        let easeLeft = 1 - ease
        if let dot = deletingDot {dot.setScale(0)}
        let offsetX = -0.5 * (easeLeft * CGFloat(dots.count - 1) + ease * CGFloat(dots.count))
        let tapeSpacing = easeLeft * min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count + 1)) + ease * min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count))
        var i = 0
        for dot in dots {
          dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
          dot.setScale(1)
        }
        printer.position.x = tapeSpacing * (CGFloat(i) + offsetX)
        printer.setScale(1)
      }
    case .Clearing:
      if tickPercent < 0.5 {
        let easeLeft = 1 - easeInOut(2 * tickPercent)
        let offsetX = -0.5 * CGFloat(dots.count) * easeLeft
        var i = 0
        let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count))
        for dot in dots {
          dot.position.x = tapeSpacing * (CGFloat(i++) * easeLeft + offsetX)
        }
        printer.position.x = tapeSpacing * (CGFloat(i) * easeLeft + offsetX)
      } else {
        let easeLeft = 1 - easeInOut(2 * tickPercent - 1)
        for dot in dots {
          dot.position.x = 0
          dot.setScale(easeLeft)
        }
        printer.position.x = 0
      }
    }
  }
  
  func tickComplete() {
    switch state {
    case .Waiting: break
    case .Writing:
      dots.last?.alpha = 1
      state = .Waiting
    case .Deleting:
      deletingDot?.removeFromParent()
      deletingDot = nil
      state = .Waiting
    case .Loading: state = .Waiting
    case .Clearing:
      for dot in dots {dot.removeFromParent()}
      dots = []
      state = .Waiting
    }
  }
  
  func loadTape(tape: String) {
    // remove old dots
    deletingDot?.removeFromParent()
    deletingDot = nil
    for dot in dots {dot.removeFromParent()}
    dots = []
    
    // add new dots
    var i = 0
    let dotCount = tape.length()
    for character in tape {
      let dot = SKSpriteNode(texture: dotTexture)
      dot.color = character.color().uiColor()
      dot.colorBlendFactor = 1
      dot.setScale(0)
      dotWrapper.addChild(dot)
      dots.append(dot)
    }
    printer.position = CGPointZero
    state = .Loading
  }
  
  func writeColor(color: Color) {
    deletingDot?.removeFromParent()
    deletingDot = nil
    let dot = SKSpriteNode(texture: dotTexture)
    dot.color = color.uiColor()
    dot.colorBlendFactor = 1
    dot.setScale(0)
    dots.append(dot)
    dotWrapper.addChild(dot)
    state = .Writing
  }
  
  func deleteColor() {
    deletingDot?.removeFromParent()
    deletingDot = nil
    if !dots.isEmpty {
      deletingDot = dots.removeAtIndex(0)      
      state = .Deleting
    } else {
      state = .Waiting
    }
  }
  
  func clearTape() {
    deletingDot?.removeFromParent()
    deletingDot = nil
    state = .Clearing
  }
}