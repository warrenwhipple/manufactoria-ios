//
//  TapeArea.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TapeArea: Area {
  var wrapper = SKNode()
  var dots: [SKSpriteNode] = []
  var deletingDot: SKSpriteNode?
  let dotTexture = SKTexture(imageNamed: "dot")
  let dotSpacing: CGFloat
  let scanner = SKSpriteNode(imageNamed: "scanner", color: Globals.strokeColor, colorBlendFactor: 1)
  let printer = SKSpriteNode(imageNamed: "printer", color: Globals.strokeColor, colorBlendFactor: 1)
  let paper = SKSpriteNode(color: Globals.backgroundColor, size: CGSizeZero)
  let topEdge = SKNode()
  let bottomEdge = SKNode()
  
  override init() {
    dotSpacing = dotTexture.size().width * 1.25
    super.init()
    scanner.zPosition = 1
    paper.addChild(scanner)
    printer.zPosition = 1
    paper.addChild(printer)
    
    wrapper.addChild(paper)
    wrapper.addChild(topEdge)
    wrapper.addChild(bottomEdge)
    addChild(wrapper)
  }
  
  override func fitToSize() {
    updateAfterStateChange()
    update(0)
    
    paper.size = CGSize(width: size.width + 16, height: dotTexture.size().height * 2 - 2)
    topEdge.position.y = paper.size.height / 2 - 0.5
    bottomEdge.position.y = -topEdge.position.y
    for edge in [topEdge, bottomEdge] as [SKNode] {
      edge.removeAllChildren()
      for i in 0 ... (Int(size.width) / 16) {
        let dash = SKSpriteNode(color: Globals.strokeColor, size: CGSize(width: 8, height: 1))
        dash.position.x = -size.width / 2 + 8 + 16 * CGFloat(i)
        edge.addChild(dash)
      }
    }
  }
  
  enum State {case OffScreen, Entering, Waiting, Writing, Deleting, Exiting}
  var state: State = .OffScreen {didSet {if state != oldValue {updateAfterStateChange()}}}
  
  func updateAfterStateChange() {
    switch state {
    case .OffScreen, .Entering:
      deletingDot?.removeFromParent()
      deletingDot = nil
      let offsetX: CGFloat = -0.5 * CGFloat(dots.count + 1)
      let tapeSpacing: CGFloat = min(dotSpacing, (size.width - dotSpacing) / CGFloat(dots.count + 1))
      scanner.position.x = tapeSpacing * offsetX - size.width
      var i = 1
      for dot in dots {dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX) - size.width}
      printer.position.x = tapeSpacing * (CGFloat(i) + offsetX) - size.width
      dots.last?.alpha = 1
    case .Waiting, .Exiting:
      deletingDot?.removeFromParent()
      deletingDot = nil
      let offsetX: CGFloat = -0.5 * CGFloat(dots.count + 1)
      let tapeSpacing: CGFloat = min(dotSpacing, (size.width - dotSpacing) / CGFloat(dots.count + 1))
      scanner.position.x = tapeSpacing * offsetX
      var i = 1
      for dot in dots {dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)}
      printer.position.x = tapeSpacing * (CGFloat(i) + offsetX)
      dots.last?.alpha = 1
    case .Writing:
      deletingDot?.removeFromParent()
      deletingDot = nil
    case .Deleting:
      dots.last?.alpha = 1
    }
  }
  
  func update(tickPercent: CGFloat) {
    switch state {
    case .OffScreen, .Waiting: break
    case .Entering:
      let easeOutTLeft: CGFloat = 1 - easeOut(tickPercent)
      let offsetX: CGFloat = -0.5 * CGFloat(dots.count + 1)
      let tapeSpacing: CGFloat = min(dotSpacing, (size.width - dotSpacing) / CGFloat(dots.count + 1))
      scanner.position.x = tapeSpacing * offsetX + size.width * easeOutTLeft
      var i = 1
      for dot in dots {dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX) + size.width * easeOutTLeft}
      printer.position.x = tapeSpacing * (CGFloat(i) + offsetX) + size.width * easeOutTLeft
    case .Writing:
      if tickPercent < 0.5 {
        let easeT: CGFloat = easeInOut(2 * tickPercent)
        let offsetX: CGFloat = -0.5 * CGFloat(dots.count)
        let tapeSpacing: CGFloat = min(dotSpacing, (size.width - dotSpacing) / CGFloat(dots.count))
        var i = 1
        for dot in dots {dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)}
        dots.last?.alpha = easeT
        scanner.position.x = tapeSpacing * offsetX
        printer.position.x = tapeSpacing * (CGFloat(i - 1) + offsetX)
      } else {
        let easeT: CGFloat = easeInOut(2 * tickPercent - 1)
        let easeTLeft: CGFloat = 1 - easeT
        let offsetX: CGFloat = -0.5 * (easeTLeft * CGFloat(dots.count) + easeT * CGFloat(dots.count + 1))
        let tapeSpacingT0: CGFloat =  min(dotSpacing, (size.width - dotSpacing) / CGFloat(dots.count))
        let tapeSpacingT1: CGFloat =  min(dotSpacing, (size.width - dotSpacing) / CGFloat(dots.count + 1))
        let tapeSpacing: CGFloat = easeTLeft * tapeSpacingT0 + easeT * tapeSpacingT1
        var i = 1
        for dot in dots {dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)}
        dots.last?.alpha = 1
        scanner.position.x = tapeSpacing * offsetX
        printer.position.x = tapeSpacing * ((easeTLeft * CGFloat(i - 1) + easeT * CGFloat(i)) + offsetX)
      }
    case .Deleting:
      if tickPercent < 0.5 {
        let easeT: CGFloat = easeInOut(2 * tickPercent)
        let easeTLeft: CGFloat = 1 - easeT
        let offsetX: CGFloat = -0.5 * (easeTLeft * CGFloat(dots.count) + easeT * CGFloat(dots.count + 1))
        let tapeSpacingT0: CGFloat =  min(dotSpacing, (size.width - dotSpacing) / CGFloat(dots.count + 2))
        let tapeSpacingT1: CGFloat =  min(dotSpacing, (size.width - dotSpacing) / CGFloat(dots.count + 1))
        let tapeSpacing: CGFloat =  easeTLeft * tapeSpacingT0 + easeT * tapeSpacingT1
        var i = 1
        for dot in dots {dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)}
        deletingDot?.position.x = tapeSpacing * offsetX
        scanner.position.x = tapeSpacing * (offsetX - 1) * easeTLeft + tapeSpacing * (offsetX) * easeT
        printer.position.x = tapeSpacing * (CGFloat(i) + offsetX)
        deletingDot?.setScale(1)
        deletingDot?.alpha = 1
      } else {
        let easeT: CGFloat = easeInOut(2 * tickPercent - 1)
        let offsetX: CGFloat = -0.5 * CGFloat(dots.count + 1)
        let tapeSpacing: CGFloat = min(dotSpacing, (size.width - dotSpacing) / CGFloat(dots.count + 1))
        var i = 1
        for dot in dots {dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX)}
        deletingDot?.position.x = tapeSpacing * offsetX
        scanner.position.x = tapeSpacing * (offsetX)
        printer.position.x = tapeSpacing * (CGFloat(i) + offsetX)
        deletingDot?.setScale(1 + easeT)
        deletingDot?.alpha = (1 - easeT)
      }
    case .Exiting:
      let easeInT: CGFloat = easeIn(tickPercent)
      let offsetX: CGFloat = -0.5 * CGFloat(dots.count + 1)
      let tapeSpacing: CGFloat = min(dotSpacing, (size.width - dotSpacing) / CGFloat(dots.count + 1))
      scanner.position.x = tapeSpacing * offsetX - size.width * easeInT
      var i = 1
      for dot in dots {dot.position.x = tapeSpacing * (CGFloat(i++) + offsetX) - size.width * easeInT}
      printer.position.x = tapeSpacing * (CGFloat(i) + offsetX) - size.width * easeInT
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
      paper.addChild(dot)
      dots.append(dot)
    }
    state = .Entering
    fitToSize()
  }
  
  func unloadTape() {
    deletingDot?.removeFromParent()
    deletingDot = nil
    for dot in dots {dot.removeFromParent()}
    dots = []
    state = .OffScreen
    fitToSize()
  }
  
  func writeColor(color: Color) {
    deletingDot?.removeFromParent()
    deletingDot = nil
    let dot = SKSpriteNode(texture: dotTexture)
    dot.color = color.uiColor()
    dot.colorBlendFactor = 1
    dots.append(dot)
    paper.addChild(dot)
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