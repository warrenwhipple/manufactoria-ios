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
  var stageSetups: [(()->())?] = []
  var currentStageIndex = -1
  var hookContinueButton, hookDemoTestButton, hookDidSetState, hookDidSetEditMode, hookCellWasEdited: (()->())?
  var speedControlsShouldSimplify: Bool = true
  var speedControlsShouldHideUntilTouch: Bool = true
  var speedControlShouldAllowCancel = false
  
  let demoTestButton = Button(iconNamed: "testButton")
  let continueButton = Button(text: "continue", fixedWidth: nil)
  
  override init(size: CGSize, var levelKey: String) {
    super.init(size: size, levelKey: levelKey)
    gridNode.clearGridWithAnimate(false)
    continueButton.isSticky = true
    demoTestButton.isSticky = true
    continueButton.touchUpInsideClosure = {[unowned self] in self.continueButtonWasPressed()}
    demoTestButton.touchUpInsideClosure = {[unowned self] in self.demoTestButtonWasPressed()}
  }
  
  func nextTutorialStage() {
    hookContinueButton = nil
    hookDemoTestButton = nil
    hookDidSetEditMode = nil
    hookCellWasEdited = nil
    stopRepeatPulse()
    if currentStageIndex < stageSetups.count - 1 {
      stageSetups[++currentStageIndex]?()
    }
  }
  
  // MARK: - Game Change Listeners
  
  func continueButtonWasPressed() {
    hookContinueButton?()
  }
  
  func demoTestButtonWasPressed() {
    hookDemoTestButton?()
  }
  
  override func didSetState(oldState: State) {
    super.didSetState(oldState)
    if state == .Testing {
      if speedControlsShouldHideUntilTouch && !speedControlShouldAllowCancel {
        speedControlNode.removeFromParent()
      } else {
        speedControlNode.appearWithParent(self, animate: true, delay: Globals.appearDelay)
      }
    }
    hookDidSetState?()
  }
  
  override var editMode: EditMode {
    get {return gridNode.editMode}
    set {
      gridNode.editMode = newValue
      hookDidSetEditMode?()
    }
  }
  
  override func cellWasEdited() {
    super.cellWasEdited()
    hookCellWasEdited?()
  }
  
  override func loadTape(i: Int) {
    super.loadTape(i)
    if speedControlsShouldSimplify {
      speedControlNode.slowerButton.removeFromParent()
      if tapeTestResults[i].kind == TapeTestResult.Kind.FailLoop || speedControlShouldAllowCancel {
        speedControlNode.fasterButton.removeFromParent()
        speedControlNode.skipButton.position.x = 0
        speedControlNode.skipButton.appearWithParent(speedControlNode, animate: false)
      } else {
        speedControlNode.skipButton.removeFromParent()
        speedControlNode.fasterButton.position.x = 0
        speedControlNode.fasterButton.appearWithParent(speedControlNode, animate: false)
      }
    } else {
      speedControlNode.fitToSize()
      speedControlNode.slowerButton.appearWithParent(speedControlNode, animate: false)
      speedControlNode.skipButton.appearWithParent(speedControlNode, animate: false)
      speedControlNode.fasterButton.appearWithParent(speedControlNode, animate: false)
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if state == .Testing && speedControlNode.parent == nil {
      speedControlNode.appearWithParent(self, animate: true)
    }
  }
  
  // MARK: - Tutorial Functions
  
  func startDemoTest() {
    stopBeltFlow()
    instructionNode.disappearWithAnimate(true)
    gridNode.state = .Waiting
    tapeTestResults = [TapeTestResult(input: "", output: nil, correctOutput: nil, kind: .Demo)]
    state = .Testing
    if let buttonParent = demoTestButton.parent {
      let positionOnGridNode = buttonParent.convertPoint(demoTestButton.position, toNode: gridNode.wrapper)
      if let robotNode = robotNode {
        robotNode.lastPosition = positionOnGridNode
        robotNode.lastLastPosition = positionOnGridNode
        demoTestButton.position = CGPointZero
        demoTestButton.removeFromParent()
        robotNode.addChild(demoTestButton)
        demoTestButton.disappearWithAnimate(true)
      }
    }
  }
  
  func labelIconButton(button: Button, text: String, animate: Bool, delay: NSTimeInterval) -> SKLabelNode {
    let label = SKLabelNode()
    label.fontSmall()
    label.fontColor = Globals.strokeColor
    label.position.y = -Globals.iconSpan / 2 - Globals.smallEm * 3
    label.text = text
    label.appearWithParent(button, animate: animate, delay: delay)
    return label
  }
  
  func labelGridCoord(coord: GridCoord, text: String, animate: Bool, delay: NSTimeInterval) -> SKLabelNode {
    let label = SKLabelNode()
    label.fontSmall()
    label.fontColor = Globals.strokeColor
    label.verticalAlignmentMode = .Center
    label.setScale(1 / gridNode.wrapper.xScale)
    label.position = coord.centerPoint
    label.text = text
    label.appearWithParent(gridNode.wrapper, animate: animate, delay: delay)
    return label
  }
  
  func changeInstructions(text: String, animate: Bool) {
    if animate {
      if instructionNode.currentIndex != 1 {instructionNode.instructionsLabel.alpha = 0}
      instructionNode.instructionsLabel.runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: Globals.disappearTime),
        SKAction.runBlock({[unowned self] in self.instructionNode.instructionsLabel.text = text}),
        SKAction.waitForDuration(Globals.disappearAppearGapTime),
        SKAction.fadeAlphaTo(1, duration: Globals.appearTime)
        ]), withKey: "changeText")
      instructionNode.snapToIndex(1, initialVelocityX: 0)
    } else {
      instructionNode.instructionsLabel.removeActionForKey("changeText")
      instructionNode.instructionsLabel.text = text
      instructionNode.instructionsLabel.alpha = 1
      instructionNode.goToIndexWithoutSnap(1)
    }
  }
  
  func removeAndDisconnectAllToolbarButtons() {
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    for button in toolbarNode.toolButtons {
      button.removeFromParent()
      button.dragThroughDelegate = nil
    }
    toolbarNode.swipeNode.removeFromParent()
  }
  
  func displayFullScreenMessage(message: String, animate: Bool, nextStageOnContinue: Bool) -> SKSpriteNode {
    let screenNode = SKSpriteNode(color: Globals.backgroundColor, size: size)
    screenNode.position = frame.center
    screenNode.zPosition = 100
    let label = SmartLabel()
    label.text = message
    let button = Button(text: "continue", fixedWidth: nil)
    button.isSticky = true
    button.touchUpInsideClosure = {
      [unowned self, unowned button] in
      label.disappearWithAnimate(true)
      button.disappearWithAnimate(true)
      screenNode.disappearWithAnimate(true, delay: Globals.appearDelay)
      if nextStageOnContinue {self.nextTutorialStage()}
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
    let pulse = SKSpriteNode(imageNamed: "pulse", color: Globals.highlightColor)
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