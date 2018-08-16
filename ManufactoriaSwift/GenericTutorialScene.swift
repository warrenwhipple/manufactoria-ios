//
//  GenericTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/14/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

private let unhideAction = SKAction.customActionWithDuration(0, actionBlock: {node, time in node.hidden = false})

class GenericTutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var stageSetups: [(()->())?] = []
  var currentStageIndex = -1
  var hookContinueButton, hookDemoTestButton, hookDidSetState, hookDidSetEditMode, hookCellWasEdited: (()->())?
  var speedControlsShouldSimplify = true
  var speedControlsShouldHideUntilTouch = true
  var speedControlShouldAllowCancel = false
  var tapeAreaShouldStayHidden = false
  let continueButton = Button(text: "continue", fixedWidth: nil)
  var testButtonMiddlePosition = CGPointZero
  var testButtonTopPosition = CGPointZero
  
  override init(size: CGSize, var levelKey: String) {
    super.init(size: size, levelKey: levelKey)
    gridArea.clearGridWithAnimate(false)
    continueButton.parentMemory = self
    continueButton.isSticky = true
    continueButton.zPosition = testButton.zPosition
    continueButton.touchUpInsideClosure = {[unowned self] in self.continueButtonPressed()}
    for button in speedControlArea.buttons {
      button.parentMemory = speedControlArea
    }
  }
  
  override func fitToSize() {
    super.fitToSize()
    testButtonTopPosition = testButton.position
    testButtonMiddlePosition = toolbarArea.rect.center
    continueButton.position = testButtonMiddlePosition
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
  
  func continueButtonPressed() {
    hookContinueButton?()
  }
  
  func demoTestButtonPressed() {
    hookDemoTestButton?()
  }
  
  override func didSetState(oldState: State) {
    super.didSetState(oldState)
    if state == .Testing {
      if tapeAreaShouldStayHidden {
        tapeArea.disappear(animate: false)
      }
      if speedControlsShouldSimplify {
        speedControlArea.slowerButton.removeFromParent()
        if testController.result.kind == TapeTestResult.Kind.Loop || speedControlShouldAllowCancel {
          speedControlArea.fasterButton.removeFromParent()
          speedControlArea.skipButton.position.x = 0
          speedControlArea.skipButton.appear(animate: false, delay: false)
        } else {
          speedControlArea.skipButton.removeFromParent()
          speedControlArea.fasterButton.position.x = 0
          speedControlArea.fasterButton.appear(animate: false, delay: false)
        }
      } else {
        speedControlArea.fitToSize()
        speedControlArea.slowerButton.appear(animate: false, delay: false)
        speedControlArea.skipButton.appear(animate: false, delay: false)
        speedControlArea.fasterButton.appear(animate: false, delay: false)
      }
      if speedControlsShouldHideUntilTouch && !speedControlShouldAllowCancel {
        speedControlArea.removeFromParent()
      } else {
        speedControlArea.appear(animate: true, delay: true)
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
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    if state == .Testing && speedControlArea.parent == nil {
      speedControlArea.appear(animate: true, delay: false)
    }
  }
  
  // MARK: - Tutorial Functions
  
  func appearNode(node: SKNode, parent: SKNode, animate: Bool, delay: Bool) {
    if node.parent !== parent {
      node.removeFromParent()
    }
    if node.parent == nil {
      parent.addChild(node)
    }
    if animate {
      node.alpha = 0
      let fadeInAction = SKAction.fadeAlphaTo(1, duration: Globals.appearTime)
      if delay {
        node.hidden = true
        node.runAction(SKAction.sequence([
          SKAction.waitForDuration(Globals.appearDelay),
          unhideAction,
          fadeInAction
          ]), withKey: "appearDisappear")
      } else {
        node.hidden = false
        node.runAction(fadeInAction, withKey: "appearDisappear")
      }
    } else {
      node.alpha = 1
      if delay {
        node.hidden = true
        node.runAction(SKAction.sequence([
          SKAction.waitForDuration(Globals.appearDelay),
          unhideAction
          ]), withKey: "appearDisappear")
      } else {
        node.hidden = false
        node.removeActionForKey("appearDisappear")
      }
    }
  }
  
  func disappearNode(node: SKNode, animate: Bool) {
    if node.parent == nil {return}
    if animate {
      node.runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(0, duration: Globals.disappearTime),
        SKAction.removeFromParent()
        ]), withKey: "appearDisappear")
    } else {
      node.removeFromParent()
      node.removeActionForKey("appearDisappear")
    }
  }
  
  func startDemoTest(resultQueue: [TapeTestResult]) {
    beltFlowController.stopFlow(animate: true)
    instructionArea.disappear(animate: true)
    gridArea.state = .Waiting
    toolbarArea.disappear(animate: true)
    tapeTestResultQueue = resultQueue
    testButton.disappear(animate: true)
    state = .Testing
  }
  
  func labelIconButton(button: Button, text: String, animate: Bool, delay: Bool) -> SKLabelNode {
    let label = SKLabelNode()
    label.fontSmall()
    label.fontColor = Globals.strokeColor
    label.position.y = -Globals.iconSpan / 2 - Globals.smallEm * 3
    label.text = text
    appearNode(label, parent: button, animate: animate, delay: delay)
    return label
  }
  
  func labelGridCoord(coord: GridCoord, text: String, animate: Bool, delay: Bool) -> SKLabelNode {
    let label = SKLabelNode()
    label.fontSmall()
    label.fontColor = Globals.strokeColor
    label.verticalAlignmentMode = .Center
    label.setScale(1 / gridArea.wrapper.xScale)
    label.position = coord.centerPoint
    label.text = text
    appearNode(label, parent: gridArea.wrapper, animate: animate, delay: delay)
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
    toolbarArea.undoCancelSwapper.parentMemory = toolbarArea
    toolbarArea.redoConfirmSwapper.parentMemory = toolbarArea
    for button in toolbarArea.toolButtons {
      button.removeFromParent()
      button.dragThroughDelegate = nil
      button.parentMemory = toolbarArea
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
      self.disappearNode(label, animate: true)
      self.disappearNode(button, animate: true)
      self.disappearNode(screenNode, animate: true)
      screenNode.runAction(SKAction.sequence([
        SKAction.waitForDuration(Globals.appearDelay),
        SKAction.fadeAlphaTo(0, duration: Globals.disappearTime),
        SKAction.removeFromParent()
        ]), withKey: "appearDisappear")
      if nextStageOnContinue {self.nextTutorialStage()}
    }
    label.position.y = 2 * Globals.mediumEm
    button.position.y = -(label.paragraphHeight() / 2) - Globals.mediumEm
    screenNode.addChild(label)
    screenNode.addChild(button)
    appearNode(screenNode, parent: self, animate: animate, delay: false)
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