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
  
  weak var delegate: StatusNode?
  var state: State = .Loading
  let dotWrapper = SKNode()
  var dots: [SKSpriteNode] = []
  var deletingDot: SKSpriteNode?
  var maxDotsAcross: Int = 8
  let dotTexture = SKTexture(imageNamed: "dot")
  let dotSpacing: CGFloat
  let printer = SKNode()
  
  override init() {
    dotSpacing = dotTexture.size().width * 1.25
    super.init()
    addChild(printer)
    addChild(dotWrapper)
  }
  
  func update(tickPercent: CGFloat) {
    switch state {
    case .Loading:
      let ease = easeInOut(tickPercent)
      let offsetX = -0.5 * dotSpacing * CGFloat(dots.count) * ease
      var i = 0
      for dot in dots {dot.position.x = CGFloat(i++) * dotSpacing * ease + offsetX}
      printer.position.x = CGFloat(i) * dotSpacing * ease + offsetX
    case .Waiting:
      let offsetX = -0.5 * dotSpacing * CGFloat(dots.count)
      var i = 0
      for dot in dots {dot.position.x = CGFloat(i++) * dotSpacing + offsetX}
      printer.position.x = CGFloat(i) * dotSpacing + offsetX
    case .Writing:
      if tickPercent < 0.5 {
        let ease = easeInOut(2 * tickPercent)
        let offsetX = -0.5 * dotSpacing * CGFloat(dots.count - 1)
        var i = 0
        for dot in dots {dot.position.x = CGFloat(i++) * dotSpacing + offsetX}
        if let lastDot = dots.last {lastDot.alpha = ease}
        printer.position.x = CGFloat(i - 1) * dotSpacing + offsetX
      } else {
        let ease = easeInOut(2 * tickPercent - 1)
        let easeLeft = 1 - ease
        let offsetX = -0.5 * dotSpacing * (easeLeft * CGFloat(dots.count - 1) + ease * CGFloat(dots.count))
        var i = 0
        for dot in dots {dot.position.x = CGFloat(i++) * dotSpacing + offsetX}
        printer.position.x = dotSpacing * (easeLeft * CGFloat(i - 1) + ease * CGFloat(i)) + offsetX
      }
    case .Deleting:
      if tickPercent < 0.5 {
        let easeLeft = 1 - easeInOut(2 * tickPercent)
        let offsetX = -0.5 * dotSpacing * CGFloat(dots.count + 1)
        if let dot = deletingDot {dot.position.x = offsetX; dot.setScale(easeLeft)}
        var i = 1
        for dot in dots {dot.position.x = CGFloat(i++) * dotSpacing + offsetX}
        printer.position.x = CGFloat(i) * dotSpacing + offsetX
      } else {
        let ease = easeInOut(2 * tickPercent - 1)
        let easeLeft = 1 - ease
        if let dot = deletingDot {dot.setScale(0)}
        let offsetX = -0.5 * dotSpacing * (easeLeft * CGFloat(dots.count - 1) + ease * CGFloat(dots.count))
        var i = 0
        for dot in dots {dot.position.x = CGFloat(i++) * dotSpacing + offsetX}
        printer.position.x = CGFloat(i) * dotSpacing + offsetX
      }
    case .Clearing:
      let easeLeft = 1 - easeInOut(tickPercent)
      let offsetX = -0.5 * dotSpacing * CGFloat(dots.count) * easeLeft
      var i = 0
      for dot in dots {dot.position.x = CGFloat(i++) * dotSpacing * easeLeft + offsetX}
      printer.position.x = CGFloat(i) * dotSpacing * easeLeft + offsetX
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
    case .Clearing: state = .Waiting
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
    dots.append(dot)
    dotWrapper.addChild(dot)
    state = .Writing
  }
  
  func deleteColor() {
    deletingDot?.removeFromParent()
    deletingDot = nil
    if !dots.isEmpty {
      deletingDot = dots[0]
      dots.removeFirst()
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