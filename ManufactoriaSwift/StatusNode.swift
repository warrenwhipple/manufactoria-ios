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
  func statusNodeDidSnapToIndex(index: Int)
}

class StatusNode: SwipeNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Testing, Congratulating}
  
  weak var delegate: StatusNodeDelegate!
  let optionsPage = SKNode()
  let menuButton = Button(text: "menu", fixedWidth: Globals.mediumEm * 8)
  let instructionsPage = SKNode()
  let instructionsLabel = SmartLabel()
  let engineLabel = SKLabelNode()
  let tapeLabel = SKLabelNode()
  let tapeNode = TapeNode()
  let instructions: String
  let failPage = SKNode()
  
  init(instructions: String) {
    self.instructions = instructions
    
    super.init(pages: [optionsPage, instructionsPage])
    
    engineLabel.fontMedium()
    engineLabel.fontMedium()
    engineLabel.fontColor = Globals.strokeColor
    engineLabel.alpha = 0
    engineLabel.text = "The malevolence engine"
    
    tapeLabel.fontMedium()
    tapeLabel.fontColor = Globals.strokeColor
    tapeLabel.alpha = 0
    
    optionsPage.addChild(menuButton)
    
    instructionsLabel.text = instructions
    
    instructionsPage.addChild(instructionsLabel)
    
    menuButton.swipeThroughDelegate = self
    menuButton.touchUpInsideClosure = {[unowned self] in self.delegate.menuButtonPressed()}
    
    goToIndexWithoutSnap(1)
  }
  
  override func fitToSize() {
    super.fitToSize()
    let labelOffset = SKTexture(imageNamed: "dot").size().height * 0.75
    let yOffset = roundPix(size.height / 6)
    engineLabel.position.y = yOffset + labelOffset
    tapeLabel.position.y = yOffset - labelOffset
    tapeNode.position.y = -yOffset
    tapeNode.width = size.width
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        engineLabel.runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(0, duration: 0.2),
          SKAction.removeFromParent()
          ]), withKey: "fade")
        tapeLabel.runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(0, duration: 0.2),
          SKAction.removeFromParent()
          ]), withKey: "fade")
        tapeNode.removeFromParent()
        tapeNode.unloadTape()
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
        wrapper.runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(0, duration: 0.2),
          SKAction.removeFromParent()
          ]), withKey: "fade")
        if engineLabel.parent == nil {
          engineLabel.alpha = 0
          addChild(engineLabel)
        }
        engineLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
      case .Testing:
        if tapeLabel.parent == nil {
          tapeLabel.alpha = 0
          addChild(tapeLabel)
        }
        tapeLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
        if tapeNode.parent == nil {addChild(tapeNode)}
      case .Congratulating:
        tapeNode.unloadTape()
      }
    }
  }
  
  override func snapToIndex(index: Int, initialVelocityX: CGFloat) {
    super.snapToIndex(index, initialVelocityX: initialVelocityX)
    delegate.statusNodeDidSnapToIndex(index)
  }
  
  func resetFailPageForTestResult(result: TapeTestResult) {
    failPage.removeAllChildren()
    let lineHeight = SKTexture(imageNamed: "dot").size().height * 1.5
    switch result.kind {
    case .Pass:
      assertionFailure("StatusNode cannot generate fail page for result.kind.Pass")
    case .FailLoop:
      if result.input == "" {
        let label = SmartLabel()
        label.text = "The blank sequence\ncaused a loop."
        failPage.addChild(label)
      } else {
        let tape = FailTapeNode(tape: result.input)
        tape.position.y = lineHeight * 0.5
        failPage.addChild(tape)
        let label = SmartLabel()
        label.text = "caused a loop."
        label.position.y = -lineHeight * 0.5
        failPage.addChild(label)
      }
    case .FailShouldAccept:
      if result.input == "" {
        let label = SmartLabel()
        label.text = "The blank sequence\nshould be accepted."
        failPage.addChild(label)
      } else {
        let tape = FailTapeNode(tape: result.input)
        tape.position.y = lineHeight * 0.5
        failPage.addChild(tape)
        let label = SmartLabel()
        label.text = "should be accepted."
        label.position.y = -lineHeight * 0.5
        failPage.addChild(label)
      }
    case .FailShouldReject:
      if result.input == "" {
        let label = SmartLabel()
        label.text = "The blank sequence\nshould be rejected."
        failPage.addChild(label)
      } else {
        let tape = FailTapeNode(tape: result.input)
        tape.position.y = lineHeight * 0.5
        failPage.addChild(tape)
        let label = SmartLabel()
        label.text = "should be rejected."
        label.position.y = -lineHeight * 0.5
        failPage.addChild(label)
      }
    case .FailWrongTransform:
      let tapeOut = FailTapeNode(tape: result.correctOutput ?? "")
      if result.input == "" {
        let label = SmartLabel()
        label.text = "The blank sequence\nshould be transformed to"
        label.position.y = lineHeight * 0.5
        failPage.addChild(label)
        tapeOut.position.y = -lineHeight * 0.5
      } else {
        let tapeIn = FailTapeNode(tape: result.input)
        tapeIn.position.y = lineHeight
        failPage.addChild(tapeIn)
        let label = SmartLabel()
        label.text = "should be transformed to"
        failPage.addChild(label)
        tapeOut.position.y = -lineHeight
      }
      failPage.addChild(tapeOut)
    case .FailDroppedTransform:
      if result.input == "" {
        let label = SmartLabel()
        label.text = "The blank sequence\nshould not be dropped."
        failPage.addChild(label)
      } else {
        let tape = FailTapeNode(tape: result.input)
        tape.position.y = lineHeight * 0.5
        failPage.addChild(tape)
        let label = SmartLabel()
        label.text = "should not be dropped."
        label.position.y = -lineHeight * 0.5
        failPage.addChild(label)
      }
    }
    if failPage.parent == nil {addPageToRight(failPage)}
  }
}