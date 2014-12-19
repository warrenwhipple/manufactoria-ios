//
//  GenericTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/14/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

struct TutorialStage {
  let setupClosure, editingClosure, thinkingClosure, reportingClosure, testingClosure, congratulatingClosure: (()->())?
  init(
    setupClosure: (()->())? = nil,
    editingClosure: (()->())? = nil,
    thinkingClosure: (()->())? = nil,
    reportingClosure: (()->())? = nil,
    testingClosure: (()->())? = nil,
    congratulatingClosure: (()->())? = nil
    ) {
      self.setupClosure = setupClosure
      self.editingClosure = editingClosure
      self.thinkingClosure = thinkingClosure
      self.reportingClosure = reportingClosure
      self.testingClosure = testingClosure
      self.congratulatingClosure = congratulatingClosure
  }
}

class GenericTutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var stages: [TutorialStage] = []
  var currentStageIndex = 0
  
  let demoRobotButton = Button(iconOffNamed: "robotOff", iconOnNamed: "robotOn")
  
  override init(size: CGSize, var levelKey: String) {
    super.init(size: size, levelKey: levelKey)
    let stage1 = TutorialStage()
  }
  
  func nextTutorialStage() {
    if currentStageIndex < stages.count - 1 {
      stages[++currentStageIndex].setupClosure?()
    }
  }
  
  // MARK: - Tutorial Functions
  
  func changeInstructions(text: String, animate: Bool) {
    if animate {
      instructionNode.instructionsLabel.runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: 0.2),
        SKAction.runBlock({[unowned self] in self.instructionNode.instructionsLabel.text = text}),
        SKAction.fadeAlphaTo(1, duration: 0.2)
        ]), withKey: "changeText")
    } else {
      instructionNode.instructionsLabel.removeActionForKey("changeText")
      instructionNode.instructionsLabel.text = text
      instructionNode.instructionsLabel.alpha = 1
    }
  }
  
  func removeAndDisconnectAllToolbarButtons() {
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    toolbarNode.robotButton.removeFromParent()
    for button in toolbarNode.toolButtons {
      button.removeFromParent()
      button.dragThroughDelegate = nil
    }
    toolbarNode.swipeNode.removeFromParent()
  }
  
  func displayFullScreenMessage(message: String, animate: Bool) -> SKSpriteNode {
    let screenNode = SKSpriteNode(color: Globals.backgroundColor, size: size)
    screenNode.position = frame.center
    screenNode.zPosition = 100
    let label = SmartLabel()
    label.text = message
    let button = Button(text: "continue", fixedWidth: nil)
    button.shouldStickyOn = true
    button.touchUpInsideClosure = {
      [unowned self] in
      label.disappearWithAnimate(true)
      button.disappearWithAnimate(true)
      screenNode.disappearWithAnimate(true, delayMultiplier: 3)
      self.nextTutorialStage()
    }
    label.position.y = 2 * Globals.mediumEm
    button.position.y = -(label.paragraphHeight() / 2) - Globals.mediumEm
    screenNode.addChild(label)
    screenNode.addChild(button)
    screenNode.appearWithParent(self, animate: animate)
    return screenNode
  }
  
  // MARK: - Pulse
  
  private let pulseTexture = SKTexture(imageNamed: "pulse")
  private let singlePulseAction = SKAction.sequence([SKAction.group([
    SKAction.sequence([
      SKAction.scaleTo(0, duration: 0),
      SKAction.scaleTo(2, duration: 1).easeOut()
      ]),
    SKAction.sequence([
      SKAction.fadeAlphaTo(0.5, duration: 0),
      SKAction.fadeAlphaTo(0, duration: 1).easeOut()])
    ]), SKAction.removeFromParent()])

  func singlePulseWithParent(parent: SKNode, position: CGPoint) {
    let pulse = SKSpriteNode(texture: pulseTexture)
    pulse.color = Globals.highlightColor
    pulse.colorBlendFactor = 1
    pulse.alpha = 0
    pulse.setScale(0)
    pulse.zPosition = -100
    pulse.position = position
    pulse.runAction(singlePulseAction)
    parent.addChild(pulse)
  }
  
  func repeatPulseWithParent(parent: SKNode, position: CGPoint, delay: NSTimeInterval) {
    runAction(SKAction.sequence([
      SKAction.waitForDuration(delay),
      SKAction.repeatActionForever(SKAction.sequence([
        SKAction.runBlock({[unowned self] in self.singlePulseWithParent(parent, position: position)}),
        SKAction.waitForDuration(5)
        ]))
      ]), withKey: "repeatPulse")
  }
  
  func stopRepeatPulse() {
    removeActionForKey("repeatPulse")
  }
  
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
  
  // MARK: - GameScene Overrides
    
  func didSetEditMode(newEditMode: EditMode, oldEditMode: EditMode) {}
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if state == .Testing && speedControlNode.parent == nil {
      speedControlNode.appearWithParent(self, animate: true)
    }
  }
}