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
  enum State {case OffScreen, Entering, Waiting, Writing, Deleting, Exiting}
  
  var dots: [SKSpriteNode] = []
  var deletingDot: SKSpriteNode?
  let dotTexture = SKTexture(imageNamed: "dot")
  let dotSpacing: CGFloat
  let printer = SKSpriteNode("printer")
  
  override init() {
    dotSpacing = dotTexture.size().width * 1.25
    printer.setScale(0)
    printer.zPosition = 1
    super.init()
    addChild(printer)
  }
  
  var state: State = .OffScreen {didSet {if state != oldValue {fitToWidth()}}}
  
  var width: CGFloat = 0 {didSet {if width != oldValue {fitToWidth()}}}

  
  func fitToWidth() {
    switch state {
    case .OffScreen, .Entering:
      deletingDot?.removeFromParent()
      deletingDot = nil
      let offsetX = -0.5 * CGFloat(dots.count)
      let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count))
      var i = 0
      for dot in dots {
        dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX) - width
        dot.setScale(1)
      }
      dots.last?.alpha = 1
      printer.position.x = 0
    case .Waiting, .Exiting:
      deletingDot?.removeFromParent()
      deletingDot = nil
      let offsetX = -0.5 * CGFloat(dots.count)
      let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count))
      var i = 0
      for dot in dots {
        dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
        dot.setScale(1)
      }
      dots.last?.alpha = 1
      printer.position.x = tapeSpacing * (CGFloat(i) + offsetX)
    case .Writing:
      deletingDot?.removeFromParent()
      deletingDot = nil
      let offsetX = -0.5 * CGFloat(dots.count - 1)
      let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count - 1))
      var i = 0
      for dot in dots {
        dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
        dot.setScale(1)
      }
      dots.last?.alpha = 1
      printer.position.x = tapeSpacing * (CGFloat(i - 1) + offsetX)
    case .Deleting:
      let offsetX = -0.5 * CGFloat(dots.count + 1)
      let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count + 1))
      deletingDot?.position.x = tapeSpacing * offsetX
      deletingDot?.setScale(1)
      var i = 1
      for dot in dots {
        dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
        dot.setScale(1)
      }
      dots.last?.alpha = 1
      printer.position.x = tapeSpacing * (CGFloat(i) + offsetX)
    }
  }
  
  func update(tickPercent: CGFloat) {
    switch state {
    case .OffScreen, .Waiting: break
    case .Entering: break
      // TODO: this
    case .Writing:
      if tickPercent < 0.5 {
        let ease = easeInOut(2 * tickPercent)
        let offsetX = -0.5 * CGFloat(dots.count - 1)
        let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count - 1))
        var i = 0
        for dot in dots {dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)}
        dots.last?.alpha = ease
        printer.position.x = tapeSpacing * (CGFloat(i - 1) + offsetX)
      } else {
        let ease = easeInOut(2 * tickPercent - 1)
        let easeLeft = 1 - ease
        let offsetX = -0.5 * (easeLeft * CGFloat(dots.count - 1) + ease * CGFloat(dots.count))
        let tapeSpacing = easeLeft * min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count - 1)) + ease * min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count))
        var i = 0
        for dot in dots {
          dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
        }
        dots.last?.alpha = 1
        printer.position.x = tapeSpacing * ((easeLeft * CGFloat(i - 1) + ease * CGFloat(i)) + offsetX)
      }
    case .Deleting:
      if tickPercent < 0.5 {
        let easeLeft = 1 - easeInOut(2 * tickPercent)
        let offsetX = -0.5 * CGFloat(dots.count + 1)
        let tapeSpacing = min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count + 1))
        deletingDot?.position.x = tapeSpacing * offsetX
        deletingDot?.setScale(easeLeft)
        var i = 1
        for dot in dots {
          dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
        }
        printer.position.x = tapeSpacing * (CGFloat(i) + offsetX)
      } else {
        let ease = easeInOut(2 * tickPercent - 1)
        let easeLeft = 1 - ease
        let offsetX = -0.5 * (easeLeft * CGFloat(dots.count - 1) + ease * CGFloat(dots.count))
        let tapeSpacing = easeLeft * min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count + 1)) + ease * min(dotSpacing, (width - dotSpacing) / CGFloat(dots.count))
        deletingDot?.setScale(0)
        var i = 0
        for dot in dots {
          dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)
          dot.setScale(1)
        }
        printer.position.x = tapeSpacing * (CGFloat(i) + offsetX)
        printer.setScale(1)
      }
    case .Exiting: break
      // TODO: this
    }
  }
  
  func loadTape(tape: String) {
    unloadTape()
    var i = 0
    let dotCount = tape.length()
    for character in tape {
      let dot = SKSpriteNode(texture: dotTexture)
      dot.color = character.color().uiColor()
      dot.colorBlendFactor = 1
      dot.setScale(0)
      addChild(dot)
      dots.append(dot)
    }
    fitToWidth()
  }
  
  func unloadTape() {
    deletingDot?.removeFromParent()
    deletingDot = nil
    for dot in dots {dot.removeFromParent()}
    dots = []
    state = .OffScreen
    fitToWidth()
  }
  
  func writeColor(color: Color) {
    deletingDot?.removeFromParent()
    deletingDot = nil
    let dot = SKSpriteNode(texture: dotTexture)
    dot.color = color.uiColor()
    dot.colorBlendFactor = 1
    dot.setScale(0)
    dots.append(dot)
    addChild(dot)
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
}