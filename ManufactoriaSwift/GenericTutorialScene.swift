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
    gridArea.clearGridWithAnimate(false)
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
        speedControlArea.removeFromParent()
      } else {
        speedControlArea.appearWithParent(self, animate: true, delay: Globals.appearDelay)
      }
    }
    hookDidSetState?()
  }
  
  override var editMode: EditMode {
    get {return gridArea.editMode}
    set {
      gridArea.editMode = newValue
      hookDidSetEditMode?()
    }
  }
  
  override func cellWasEdited() {
    super.cellWasEdited()
    hookCellWasEdited?()
  }
  
  func loadTape(i: Int) {
  //  super.loadTape(i)
    if speedControlsShouldSimplify {
      speedControlArea.slowerButton.removeFromParent()
      if tapeTestResults[i].kind == TapeTestResult.Kind.Loop || speedControlShouldAllowCancel {
        speedControlArea.fasterButton.removeFromParent()
        speedControlArea.skipButton.position.x = 0
        speedControlArea.skipButton.appearWithParent(speedControlArea, animate: false)
      } else {
        speedControlArea.skipButton.removeFromParent()
        speedControlArea.fasterButton.position.x = 0
        speedControlArea.fasterButton.appearWithParent(speedControlArea, animate: false)
      }
    } else {
      speedControlArea.fitToSize()
      speedControlArea.slowerButton.appearWithParent(speedControlArea, animate: false)
      speedControlArea.skipButton.appearWithParent(speedControlArea, animate: false)
      speedControlArea.fasterButton.appearWithParent(speedControlArea, animate: false)
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if state == .Testing && speedControlArea.parent == nil {
      speedControlArea.appearWithParent(self, animate: true)
    }
  }
  
  // MARK: - Tutorial Functions
  
  func startDemoTest() {
    beltFlowController.stopFlow(animate: true)
    instructionArea.disappearWithAnimate(true)
    gridArea.state = .Waiting
    tapeTestResults = [TapeTestResult(input: "", output: nil, correctOutput: nil, kind: .Demo)]
    state = .Testing
    if let buttonParent = demoTestButton.parent {
      let positionOnGridArea = buttonParent.convertPoint(demoTestButton.position, toNode: gridArea.wrapper)
      if let robot = testController.robot {
        robot.lastPosition = positionOnGridArea
        demoTestButton.position = CGPointZero
        demoTestButton.removeFromParent()
        robot.addChild(demoTestButton)
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
    label.setScale(1 / gridArea.wrapper.xScale)
    label.position = coord.centerPoint
    label.text = text
    label.appearWithParent(gridArea.wrapper, animate: animate, delay: delay)
    return label
  }
  
  func changeInstructions(text: String, animate: Bool) {
    if animate {
      if instructionArea.swipeNode.currentIndex != 1 {instructionArea.instructionsLabel.alpha = 0}
      instructionArea.instructionsLabel.runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: Globals.disappearTime),
        SKAction.runBlock({[unowned self] in self.instructionArea.instructionsLabel.text = text}),
        SKAction.waitForDuration(Globals.disappearAppearGapTime),
        SKAction.fadeAlphaTo(1, duration: Globals.appearTime)
        ]), withKey: "changeText")
      instructionArea.swipeNode.snapToIndex(1, initialVelocityX: 0)
    } else {
      instructionArea.instructionsLabel.removeActionForKey("changeText")
      instructionArea.instructionsLabel.text = text
      instructionArea.instructionsLabel.alpha = 1
      instructionArea.swipeNode.goToIndexWithoutSnap(1)
    }
  }
  
  func removeAndDisconnectAllToolbarButtons() {
    toolbarArea.undoCancelSwapper.removeFromParent()
    toolbarArea.redoConfirmSwapper.removeFromParent()
    for button in toolbarArea.toolButtons {
      button.removeFromParent()
      button.dragThroughDelegate = nil
    }
    toolbarArea.swipeNode.removeFromParent()
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
    let pulse = SKSpriteNode(imageNamed: "pulse", color: Globals.highlightColor, colorBlendFactor: 1)
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