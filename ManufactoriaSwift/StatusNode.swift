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
  func menuButtonPressed()
  func nextButtonPressed()
}

class StatusNode: SwipeNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Testing, Congratulating}
  
  weak var delegate: StatusNodeDelegate!
  let instructionsPage: SKNode
  let label: BreakingLabel
  let testButton, menuButton, nextButton: SwipeThroughButton
  var leftButtonPoint = CGPointZero
  var rightButtonPoint = CGPointZero
  var leftButtonExitPoint = CGPointZero
  var rightButtonExitPoint = CGPointZero
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
    
    testButton = SwipeThroughButton(iconOffNamed: "playIconOff", iconOnNamed: "playIconOn")
    menuButton = SwipeThroughButton(iconOffNamed: "blankIconOff", iconOnNamed: "blankIconOn")
    nextButton = SwipeThroughButton(iconOffNamed: "speedIconOff", iconOnNamed: "speedIconOn")
    
    instructionsPage = SKNode()
    instructionsPage.addChild(label)
    instructionsPage.addChild(tapeNode)
    instructionsPage.addChild(menuButton)
    instructionsPage.addChild(testButton)
    
    failLabel = BreakingLabel()
    failLabel.fontMedium()
    failLabel.fontColor = Globals.strokeColor
    
    failPage = SKNode()
    failPage.addChild(failLabel)
    
    super.init(pages: [instructionsPage, failPage], texture: nil, color: nil, size: CGSizeZero)
    
    testButton.swipeThroughDelegate = self
    testButton.touchUpInsideClosure = {[unowned self] in self.delegate.testButtonPressed()}
    menuButton.swipeThroughDelegate = self
    menuButton.touchUpInsideClosure = {[unowned self] in self.delegate.menuButtonPressed()}
    nextButton.swipeThroughDelegate = self
    nextButton.touchUpInsideClosure = {[unowned self] in self.delegate.nextButtonPressed()}
    
    // can't swipe at first
    userInteractionEnabled = false
    rightArrow.alpha = 0
    rightArrow.removeActionForKey("fade")
  }
  
  override func fitToSize(size: CGSize) {
    super.fitToSize(size)
    let iconSize = Globals.iconRoughSize
    let buttonTouchHeight = min(iconSize.height * 2, size.height / 2)
    let yCenters = distributionForChildren(count: 2, childSize: iconSize.height, parentSize: size.height)
    let buttonXCenters = distributionForChildren(count: 2, childSize: iconSize.width, parentSize: size.width)
    leftButtonPoint = CGPoint(buttonXCenters[0], yCenters[0])
    rightButtonPoint = CGPoint(buttonXCenters[1], yCenters[0])
    leftButtonExitPoint = CGPoint(-size.width - iconSize.width, yCenters[0])
    rightButtonExitPoint = CGPoint(size.width + iconSize.width, yCenters[0])
    
    menuButton.position = leftButtonPoint
    menuButton.size = CGSize(iconSize.width * 2, buttonTouchHeight)
    testButton.position = rightButtonPoint
    testButton.size = menuButton.size
    nextButton.position = rightButtonExitPoint
    nextButton.size = menuButton.size
    
    label.position = CGPoint(0, yCenters[1])
    tapeNode.position = CGPoint(0, yCenters[0])
    tapeNode.width = size.width
    failLabel.position = label.position
    failTapeNode?.position = tapeNode.position
    failTapeNode?.width = tapeNode.width
    leftArrow.position.y = label.position.y
    rightArrow.position.y = label.position.y
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        label.text = instructions
        menuButton.userInteractionEnabled = true
        menuButton.position = leftButtonPoint
        instructionsPage.addChild(menuButton)
        testButton.userInteractionEnabled = true
        testButton.position = rightButtonPoint
        instructionsPage.addChild(testButton)
        tapeNode.dotWrapper.alpha = 0
        goToIndexWithoutSnap(1)
        failLabel.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        failTapeNode?.runAction(SKAction.fadeAlphaTo(1, duration: 0.25))
        userInteractionEnabled = true
      case .Thinking:
        userInteractionEnabled = false
        thinkingAnimationDone = false
        menuButton.userInteractionEnabled = false
        menuButton.runAction(SKAction.sequence([
          SKAction.moveTo(leftButtonExitPoint, duration: 0.6).easeIn(),
          SKAction.removeFromParent()
          ]), withKey: "move")
        testButton.userInteractionEnabled = false
        testButton.runAction(SKAction.sequence([
          SKAction.moveTo(rightButtonExitPoint, duration: 0.6).easeIn(),
          SKAction.removeFromParent()
          ]), withKey: "move")
        runAction(SKAction.waitForDuration(0), completion: {[unowned self] in self.thinkingAnimationDone = true})
        changeText("")
      case .Testing:
        tapeNode.dotWrapper.runAction(SKAction.fadeAlphaTo(1, duration: 0.25))
      case .Congratulating:
        menuButton.userInteractionEnabled = true
        menuButton.position = leftButtonExitPoint
        instructionsPage.addChild(menuButton)
        menuButton.runAction(SKAction.moveTo(leftButtonPoint, duration: 0.6).easeOut(), withKey: "move")
        nextButton.userInteractionEnabled = true
        nextButton.position = rightButtonExitPoint
        instructionsPage.addChild(nextButton)
        nextButton.runAction(SKAction.moveTo(rightButtonPoint, duration: 0.6).easeOut(), withKey: "move")
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
}