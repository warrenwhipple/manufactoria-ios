//
//  StatusNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/2/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class StatusNode: SwipeNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Testing, Congratulating}
  
  weak var delegate: GameScene?
  let instructionsPage: SKNode
  let failResultsPage: SKNode
  
  let label: BreakingLabel
  let testButton: RingButton
  let tapeNode: TapeNode
  let instructions: String
  
  
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
    
    failResultsPage = SKNode()
    
    super.init(pages: [instructionsPage, failResultsPage])
    
    tapeNode.delegate = self
    
    testButton.touchUpInsideClosure = {[unowned self] in self.testButtonPressed()}
  }
  
  override var size: CGSize {
    didSet{
      label.position = CGPoint(0, round(size.height * (1.0/6.0)))
      tapeNode.position = CGPoint(0, -round(size.height * (1.0/6.0)))
      tapeNode.width = size.width
      testButton.position = tapeNode.position
    }
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        changeText(instructions)
        testButton.removeFromParent()
        testButton.position = convertPoint(tapeNode.printer.position, fromNode: tapeNode.printer.parent)
        instructionsPage.addChild(testButton)
        testButton.runAction(SKAction.moveTo(tapeNode.position, duration: 0.5).ease())
        testButton.state = .Button
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
  
  func generateFailPageForTestResult(result: TapeTestResult) {
    // TODO: finish this function
    
  }
  
  func testButtonPressed() {
    delegate?.testButtonPressed()
  }
}