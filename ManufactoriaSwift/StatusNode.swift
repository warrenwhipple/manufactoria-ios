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
    
    optionsPage.addChild(menuButton)
    
    instructionsLabel.fontMedium()
    instructionsLabel.fontColor = Globals.strokeColor
    instructionsLabel.text = instructions
    tapeNode.printer.setScale(0)
    tapeLabel.fontMedium()
    tapeLabel.fontColor = Globals.strokeColor
    tapeLabel.alpha = 0
    
    instructionsPage.addChild(instructionsLabel)
    instructionsPage.addChild(tapeLabel)
    instructionsPage.addChild(tapeNode)
    
    failLabel.fontMedium()
    failLabel.fontColor = Globals.strokeColor
    
    failPage.addChild(failLabel)
    
    
    menuButton.swipeThroughDelegate = self
    menuButton.touchUpInsideClosure = {[unowned self] in self.delegate.menuButtonPressed()}
    
    goToIndexWithoutSnap(1)
  }
  
  override func fitToSize() {
    super.fitToSize()
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
        tapeNode.printer.setScale(0)
        tapeLabel.removeActionForKey("fade")
        tapeLabel.alpha = 0
        instructionsLabel.removeActionForKey("fade")
        instructionsLabel.alpha = 1
        if failPage.parent == nil {addPageToRight(failPage)}
        goToIndexWithoutSnap(2)
        failLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.2))
        failTapeNode?.runAction(SKAction.fadeAlphaTo(1, duration: 0.2))
        userInteractionEnabled = true
      case .Thinking:
        userInteractionEnabled = false
        thinkingAnimationDone = false
        instructionsLabel.runAction(SKAction.fadeAlphaTo(0, duration: 0.2))
        tapeNode.printer.runAction(SKAction.sequence([
          SKAction.waitForDuration(0.2),
          SKAction.scaleTo(1, duration: 0.2)
          ]), withKey: "scale")
        runAction(SKAction.waitForDuration(0.4), completion: {[unowned self] in self.thinkingAnimationDone = true})
      case .Testing:
        break
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
    
    failLabel.alpha = 0
    failTapeNode?.removeFromParent()
    failTapeNode = FailTapeNode(tape: result.input)
    failTapeNode?.alpha = 0
    failTapeNode?.position = tapeNode.position
    failTapeNode?.width = tapeNode.width
    failPage.addChild(failTapeNode!)
  }
}