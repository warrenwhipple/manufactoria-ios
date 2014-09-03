//
//  StatusNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/2/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol StatusNodeDelegate: class {
  func testButtonPressed()
}

class StatusNode: SwipeNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Testing, Congratulating}
  
  weak var delegate: StatusNodeDelegate!
  let instructionsPage: SKNode
  let label: BreakingLabel
  let testButton: RingButton
  let tapeNode: TapeNode
  let instructions: String
  
  let failPage: SKNode
  let failLabel: BreakingLabel
  var failTapeNode: FailTapeNode?
  
  var thinkingAnimationDone = false
  
  init(instructions: String) {
    self.instructions = instructions

    label = BreakingLabel()
    label.fontMedium()
    label.fontColor = Globals.strokeColor
    label.text = instructions

    tapeNode = TapeNode()
    
    testButton = RingButton(icon: SKSpriteNode("playIcon"), state: .Button)
    testButton.zPosition = 10
    
    instructionsPage = SKNode()
    instructionsPage.addChild(label)
    instructionsPage.addChild(tapeNode)
    instructionsPage.addChild(testButton)
    
    failLabel = BreakingLabel()
    failLabel.fontMedium()
    failLabel.fontColor = Globals.strokeColor
    
    failPage = SKNode()
    failPage.addChild(failLabel)
    
    super.init(pages: [instructionsPage, failPage], texture: nil, color: nil, size: CGSizeZero)
    
    testButton.touchUpInsideClosure = {[unowned self] in self.testButtonPressed()}
    
    userInteractionEnabled = false
    rightArrow.alpha = 0
    rightArrow.removeActionForKey("fade")
  }
  
  override var size: CGSize {
    didSet{
      label.position = CGPoint(0, round(size.height * (1.0/6.0)))
      tapeNode.position = CGPoint(0, -round(size.height * (1.0/6.0)))
      tapeNode.width = size.width
      testButton.position = tapeNode.position
      failLabel.position = label.position
      failTapeNode?.position = tapeNode.position
      failTapeNode?.width = tapeNode.width
      leftArrow.position.y = label.position.y
      rightArrow.position.y = label.position.y
    }
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        label.text = instructions
        testButton.removeFromParent()
        testButton.position = tapeNode.position
        instructionsPage.addChild(testButton)
        testButton.state = .Button
        tapeNode.dotWrapper.alpha = 0
        goToIndexWithoutSnap(1)
        failLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        failTapeNode?.runAction(SKAction.fadeAlphaTo(1, duration: 0.25))
        userInteractionEnabled = true
      case .Thinking:
        userInteractionEnabled = false
        thinkingAnimationDone = false
        testButton.state = .Printer
        testButton.runAction(SKAction.moveTo(tapeNode.position, duration: 0.5))
        runAction(SKAction.waitForDuration(0.75), completion: {[weak self] in self!.thinkingAnimationDone = true})
        changeText("")
      case .Testing:
        testButton.removeFromParent()
        testButton.position = CGPointZero
        tapeNode.dotWrapper.runAction(SKAction.fadeAlphaTo(1, duration: 0.25))
        tapeNode.printer.addChild(testButton)
      case .Congratulating:
        testButton.state = .Hidden
      }
    }
  }
  
  func changeText(text: String?) {
    var sequence: [SKAction] = []
    if label.alpha != 0 {
      sequence.append(SKAction.fadeAlphaTo(0, duration: 0.5))
    }
    sequence.append(SKAction.runBlock({[weak self] in self!.label.text = text}))
    if text != nil && text! != "" {
      sequence.append(SKAction.fadeAlphaTo(1, duration: 0.5))
    }
    label.runAction(SKAction.sequence(sequence), withKey: "changeText")
  }
  
  func changeText(text: String?, textPosition: CGPoint) {
    var sequence: [SKAction] = []
    if label.alpha != 0 {
      sequence.append(SKAction.fadeAlphaTo(0, duration: 0.5))
    }
    sequence.append(SKAction.runBlock({[weak self] in self!.label.text = text}))
    sequence.append(SKAction.runBlock({[weak self] in self!.label.position = textPosition}))
    if text != nil && text! != "" {
      sequence.append(SKAction.fadeAlphaTo(1, duration: 0.5))
    }
    label.runAction(SKAction.sequence(sequence), withKey: "changeText")
  }
  
  func resetFailPageForTestResult(result: TapeTestResult) {
    switch result.kind {
    case .Pass:
      assertionFailure("StatusNode cannot generate fail page for result.kind.Pass")
    case .FailLoop:
      failLabel.text = "This looped."
    case .FailShouldAccept:
      failLabel.text = "This should be accepted."
    case .FailShouldReject:
      failLabel.text = "This should be rejected."
    case .FailWrongTransform:
      failLabel.text = "Wrong output."
    case .FailDroppedTransform:
      failLabel.text = "This got dropped."
    }
    
    failLabel.alpha = 0
    failTapeNode?.removeFromParent()
    failTapeNode = FailTapeNode(tape: result.input)
    failTapeNode?.alpha = 0
    failTapeNode?.position = tapeNode.position
    failTapeNode?.width = tapeNode.width
    failPage.addChild(failTapeNode!)
  }
  
  func testButtonPressed() {
    delegate.testButtonPressed()
  }
}