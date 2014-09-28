//
//  StatusNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/2/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol StatusNodeDelegate: class {
  func menuButtonPressed()
}

class StatusNode: SwipeNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Testing, Congratulating}
  
  weak var delegate: StatusNodeDelegate!
  let optionsPage = SKNode()
  let menuButton = Button(iconOffNamed: "menuIconOff", iconOnNamed: "menuIconOn", labelText: "menu")
  let instructionsPage = SKNode()
  let instructionsLabel = BreakingLabel()
  let tapeLabel = BreakingLabel()
  let tapeNode = TapeNode()
  let instructions: String
  let failPage = SKNode()
  let failLabel = BreakingLabel()
  var failTapeNode: FailTapeNode?
  var thinkingAnimationDone = false
  
  init(instructions: String) {
    self.instructions = instructions
    
    super.init(pages: [optionsPage, instructionsPage])
    
    tapeNode.printer.setScale(0)
    tapeLabel.fontMedium()
    tapeLabel.fontColor = Globals.strokeColor
    tapeLabel.alpha = 0
    addChild(tapeLabel)
    addChild(tapeNode)
    
    optionsPage.addChild(menuButton)
    
    instructionsLabel.fontMedium()
    instructionsLabel.fontColor = Globals.strokeColor
    instructionsLabel.text = instructions
    
    instructionsPage.addChild(instructionsLabel)
    
    failLabel.fontMedium()
    failLabel.fontColor = Globals.strokeColor
    
    failPage.addChild(failLabel)
    
    
    menuButton.swipeThroughDelegate = self
    menuButton.touchUpInsideClosure = {[unowned self] in self.delegate.menuButtonPressed()}
    
    goToIndexWithoutSnap(1)
  }
  
  override func fitToSize() {
    super.fitToSize()
    menuButton.position.y = roundPix(Globals.mediumEm)
    let yOffset = roundPix(size.height / 6)
    tapeLabel.position.y = yOffset
    tapeNode.position.y = -yOffset
    tapeNode.width = size.width
    failLabel.position.y = yOffset
    failTapeNode?.position.y = -yOffset
    failTapeNode?.width = size.width
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        tapeNode.unloadTape()
        tapeLabel.runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(0, duration: 0.2),
          SKAction.removeFromParent()
          ]), withKey: "fade")
        tapeNode.runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(0, duration: 0.2),
          SKAction.removeFromParent()
          ]), withKey: "fade")
        if failPage.parent == nil {addPageToRight(failPage)}
        goToIndexWithoutSnap(2)
        wrapper.alpha = 0
        wrapper.runAction(SKAction.sequence([
          SKAction.waitForDuration(0.2),
          SKAction.fadeAlphaTo(1, duration: 0.2)
          ]), withKey: "fade")
        if wrapper.parent == nil {addChild(wrapper)}
        userInteractionEnabled = true
      case .Thinking:
        userInteractionEnabled = false
        thinkingAnimationDone = false
        wrapper.runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(0, duration: 0.2),
          SKAction.removeFromParent()
          ]), withKey: "fade")
        tapeNode.printer.setScale(0)
        tapeNode.printer.runAction(SKAction.sequence([
          SKAction.waitForDuration(0.2),
          SKAction.scaleTo(1, duration: 0.2),
          SKAction.runBlock({[unowned self] in self.thinkingAnimationDone = true})
          ]), withKey: "scale")
        tapeNode.alpha = 1
        if tapeNode.parent == nil {addChild(tapeNode)}
      case .Testing:
        tapeLabel.alpha = 0
        tapeLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
        if tapeLabel.parent == nil {addChild(tapeLabel)}
      case .Congratulating:
        tapeNode.unloadTape()
        tapeNode.printer.runAction(SKAction.scaleTo(0, duration: 0.2), withKey: "scale")
      }
    }
  }
  
  func resetFailPageForTestResult(result: TapeTestResult) {
    switch result.kind {
    case .Pass:
      assertionFailure("StatusNode cannot generate fail page for result.kind.Pass")
    case .FailLoop:
      if result.input == "" {failLabel.text = "The blank sequence caused a loop."}
      else {failLabel.text = "This sequence caused a loop."}
    case .FailShouldAccept:
      if result.input == "" {failLabel.text = "A blank sequence should be accepted."}
      else {failLabel.text = "This sequence should be accepted."}
    case .FailShouldReject:
      if result.input == "" {failLabel.text = "A blank sequence should be rejected."}
      else {failLabel.text = "This sequence should be rejected."}
    case .FailWrongTransform:
      if result.input == "" {failLabel.text = "The blank sequence was processed incorrectly."}
      else {failLabel.text = "This sequence was was transformed incorrectly."}
    case .FailDroppedTransform:
      if result.input == "" {failLabel.text = "The blank sequence must be processed."}
      else {failLabel.text = "This sequence was dropped."}
    }
    
    failTapeNode?.removeFromParent()
    failTapeNode = FailTapeNode(tape: result.input)
    failTapeNode?.position = tapeNode.position
    failTapeNode?.width = tapeNode.width
    failPage.addChild(failTapeNode!)
  }
}