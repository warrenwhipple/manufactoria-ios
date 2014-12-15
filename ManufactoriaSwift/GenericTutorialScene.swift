//
//  GenericTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/14/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class GenericTutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let demoRobotButton = Button(iconOffNamed: "robotOff", iconOnNamed: "robotOn")
  
  let introText = "Intro text."
  let demoText = "Demo text."
  let tryText = "Try text."
  let shouldHideIntroGridBackground = true
  let shouldHideMalevolenceEngine = true

  override init(size: CGSize, var levelKey: String) {
    super.init(size: size, levelKey: levelKey)
    
    instructionNode.leftArrowWrapper.removeFromParent()
    instructionNode.instructionsLabel.text = introText
    let demoLabel = SmartLabel()
    demoLabel.text = demoText
    instructionNode.addPageToRight(demoLabel)
    startPulseWithParent(instructionNode.rightArrow)
    
    toolbarNode.removeFromParent()
    demoRobotButton.touchUpInsideClosure = {
      [unowned self] in
      self.demoRobotButton.disappearWithAnimate(true)
      self.testButtonPressed()
    }
    startPulseWithParent(demoRobotButton)
    
    speedControlNode.slowerButton.removeFromParent()
    speedControlNode.skipButton.removeFromParent()
    
    gridNode.state = .EditingLocked
    if shouldHideIntroGridBackground {
      for cellNode in gridNode.cellNodes {cellNode.shimmerNode.zeroShimmer()}
      gridNode.enterArrow.alpha = 0
      gridNode.exitArrow.alpha = 0
    }
    if shouldHideMalevolenceEngine {
      gridNode.animateThinking = false
    }
  }
  
  enum TutorialState {case Intro, Demo, Try}
  
  var tutorialState: TutorialState = .Intro
  
  func nextTutorialState() {
    switch tutorialState {
    case .Intro:
      killPulseWithParent(instructionNode.rightArrow)
      demoRobotButton.appearWithParent(self, animate: true)
      if shouldHideIntroGridBackground {
        gridNode.enterArrow.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        gridNode.exitArrow.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      }
      tutorialState = .Demo
    case .Demo:
      speedControlNode.addChild(speedControlNode.slowerButton)
      speedControlNode.addChild(speedControlNode.skipButton)
      tutorialState = .Try
    case .Try: break
    }
  }
  
  // MARK: - TutorialScene methods for override
  
  func setupIntro() {println("Setup intro.")}
  func setupDemo() {println("Setup demo.")}
  func setupTry() {println("Setup demo.")}
  
  // MARK: - GameScene Overrides
  
  override func fitToSize() {
    super.fitToSize()
    demoRobotButton.position = toolbarNode.position
    if tutorialState != .Try {
      speedControlNode.fasterButton.position.x = 0
    }
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing:
        if tutorialState == .Demo {nextTutorialState()}
      case .Thinking:
        if tutorialState == .Demo {}
      case .Reporting:
        if shouldHideMalevolenceEngine {
          reportNode.disappearWithAnimate(false)
          state = .Testing
        }
      case .Testing:
        if tutorialState == .Demo {speedControlNode.disappearWithAnimate(false)}
      case .Congratulating: break
      }
    }
  }
  
  override func swipeNodeDidSnapToIndex(index: Int) {
    if index != 1 && instructionNode.leftArrowWrapper.parent == nil {
      instructionNode.leftArrowWrapper.alpha = 0
      instructionNode.leftArrowWrapper.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
      instructionNode.wrapper.addChild(instructionNode.leftArrowWrapper)
    }
    if tutorialState == .Intro && index == 2{
      nextTutorialState()
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if tutorialState == .Intro {
      instructionNode.snapToIndex(2, initialVelocityX: 0)
    } else if state == .Testing && speedControlNode.parent == nil {
      speedControlNode.appearWithParent(self, animate: true)
    }
  }
  
  // MARK: Pulse
  
  let singlePulseAction = SKAction.group([
    SKAction.sequence([
      SKAction.scaleTo(0, duration: 0),
      SKAction.scaleTo(2, duration: 1).easeOut()
      ]),
    SKAction.sequence([
      SKAction.fadeAlphaTo(0.5, duration: 0),
      SKAction.fadeAlphaTo(0, duration: 1).easeOut()])
    ])
  
  func startPulseWithParent(parent: SKNode) {
    let pulse = SKSpriteNode("pulse")
    pulse.color = Globals.highlightColor
    pulse.alpha = 0
    pulse.setScale(0)
    pulse.zPosition = -100
    pulse.name = "pulse"
    parent.addChild(pulse)
    parent.runAction(SKAction.repeatActionForever(SKAction.sequence([
      SKAction.waitForDuration(2),
      SKAction.runAction(singlePulseAction, onChildWithName: "pulse")
      ])), withKey: "repeatPulse")
  }
  
  func killPulseWithParent(parent: SKNode) {
    parent.removeActionForKey("repeatPulse")
    if let pulse = parent.childNodeWithName("pulse") {
      pulse.runAction(SKAction.sequence([
        SKAction.waitForDuration(1),
        SKAction.removeFromParent()
        ]))
    }
  }
}