//
//  TapeArea.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TapeArea: Area {
  private var wrapper = SKNode()
  private var dots: [SKSpriteNode] = []
  private var deletingDot: SKSpriteNode?
  private let dotTexture = SKTexture(imageNamed: "dot")
  private let dotSpacing, edgeY: CGFloat
  private let paper = SKSpriteNode(color: Globals.backgroundColor, size: CGSizeZero)
  private let topEdge = SKNode()
  private let bottomEdge = SKNode()
  private var firstDotX: CGFloat = 0
  private(set) var robot: RobotNode?
  let printer = SKSpriteNode(imageNamed: "printer", color: Globals.strokeColor, colorBlendFactor: 1)
  
  override init() {
    dotSpacing = dotTexture.size().width * 1.25
    edgeY = dotTexture.size().height - 0.5
    super.init()
    printer.zPosition = 0.2
    paper.zPosition = 0.5
    topEdge.zPosition = 0.7
    bottomEdge.zPosition = 0.7
    paper.size.height = edgeY * 2 + 1
    paper.anchorPoint.x = 0
    paper.alpha = 0.9
    paper.addChild(printer)
    wrapper.addChild(paper)
    wrapper.addChild(topEdge)
    wrapper.addChild(bottomEdge)
    addChild(wrapper)
  }
  
  override func fitToSize() {
    paper.position.x = -size.width / 2
    paper.size.width = size.width + dotSpacing
    let dashSpacing: CGFloat = dotSpacing / 2
    let dashSize = CGSize(width: dashSpacing / 2, height: 1)
    for edge in [topEdge, bottomEdge] as [SKNode] {
      edge.removeAllChildren()
      edge.position.x = paper.position.x
      for i in 0 ..< Int(ceil(paper.size.width / dashSpacing)) {
        let dash = SKSpriteNode(color: Globals.strokeColor, size: dashSize)
        dash.position.x = dashSpacing * (CGFloat(i) + 0.5)
        edge.addChild(dash)
      }
    }
  }
  
  enum State {case Exited, Entering, Waiting, Writing, Deleting, Exiting}
  private var state: State = .Waiting
  
  func update(#tickPercent: CGFloat) {
    switch state {
    case .Exited, .Waiting: break
    case .Entering:
      let easeT = easeOut(tickPercent)
      paper.yScale = easeT
      robot?.yScale = easeT * 2
      topEdge.position.y = easeT * edgeY
      bottomEdge.position.y = -easeT * edgeY
    case .Exiting:
      let easeTLeft = 1 - easeIn(tickPercent)
      paper.yScale = easeTLeft
      robot?.yScale = easeTLeft * 2
      topEdge.position.y = easeTLeft * edgeY
      bottomEdge.position.y = -easeTLeft * edgeY
    case .Writing:
      let lastDot = dots.last
      if tickPercent < 0.5 {
        lastDot?.alpha = tickPercent * 2
      } else {
        lastDot?.alpha = 1
        let easeT: CGFloat = easeInOut(2 * tickPercent - 1)
        let easeTLeft: CGFloat = 1 - easeT
        let lastDotX = lastDot?.position.x ?? 0
        printer.position.x = lastDotX * easeTLeft + (lastDotX + dotSpacing) * easeT
      }
    case .Deleting:
      wrapper.position.x = -easeInOut(tickPercent) * dotSpacing
      deletingDot?.setScale(1 + tickPercent)
      deletingDot?.alpha = 1 - tickPercent
    }
  }
  
  func resetDotPositions() {
    var i = 0
    for dot in dots {dot.position.x = firstDotX + dotSpacing * CGFloat(i++)}
    printer.position.x = firstDotX + dotSpacing * CGFloat(i++)
    dots.last?.alpha = 1
  }
  
  func loadTape(tape: String, robot: RobotNode) {
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
    firstDotX = dotSpacing * 2
    resetDotPositions()
    self.robot = robot
    robot.setScale(2)
    robot.position = CGPoint(x: paper.position.x + firstDotX, y: 0)
    addChild(robot)
    state = .Entering
  }
  
  func unloadTape() {
    completeTick()
    for dot in dots {dot.removeFromParent()}
    dots = []
    robot?.removeFromParent()
    robot = nil
    state = .Exited
  }
  
  func writeColor(color: Color) {
    completeTick()
    let dot = SKSpriteNode(texture: dotTexture)
    dots.append(dot)
    dot.color = color.uiColor()
    dot.colorBlendFactor = 1
    dot.position.x = firstDotX + CGFloat(dots.count - 1) * dotSpacing
    paper.addChild(dot)
    printer.position.x = dot.position.x
    state = .Writing
  }
  
  func deleteColor() {
    completeTick()
    if !dots.isEmpty {
      deletingDot = dots.removeAtIndex(0)
      if let deletingDot = deletingDot {
        deletingDot.removeFromParent()
        deletingDot.zPosition = 0.6
        deletingDot.position.x = paper.position.x + firstDotX
        addChild(deletingDot)
      }
      state = .Deleting
    } else {
      state = .Waiting
    }
  }
  
  func wait() {
    completeTick()
    state = .Waiting
  }
  
  func exit() {
    completeTick()
    state = .Exiting
  }
  
  private func completeTick() {
    if state == .Deleting {
      deletingDot?.removeFromParent()
      deletingDot = nil
      resetDotPositions()
      wrapper.position.x = 0
    } else {
      update(tickPercent: 1)
    }
  }
}