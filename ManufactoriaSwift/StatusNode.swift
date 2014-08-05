//
//  StatusNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/2/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

enum StatusNodeState {
  case Editing, Thinking, Testing
}

class StatusNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var delegate: GameScene? {didSet{testTouchArea.delegate = delegate}}
  let testTouchArea = TestTouchArea(color: nil, size: CGSize(width: 64, height: 64))
  let tapeNode = TapeNode()
  let ring = SKSpriteNode("ring")
  let ringArrow = SKSpriteNode("playArrow")
  let instructions = BreakingLabel()
  let resultMessage = SKLabelNode()
  var thinkingAnimationDone = false
  
  override init()  {
    super.init()
    
    testTouchArea.userInteractionEnabled = true
    testTouchArea.zPosition = 100
    addChild(testTouchArea)
    
    ring.zPosition = 10
    ring.setScale(0.5)
    ring.addChild(ringArrow)
    addChild(ring)
    
    tapeNode.alpha = 0
    tapeNode.setScale(0.5)
    tapeNode.delegate = self
    addChild(tapeNode)
    
    instructions.fontName = "HelveticaNeue-Thin"
    instructions.fontSize = 16
    instructions.horizontalAlignmentMode = .Center
    instructions.verticalAlignmentMode = .Center
    addChild(instructions)
    
    resultMessage.fontName = "HelveticaNeue-Thin"
    resultMessage.fontSize = 16
    resultMessage.horizontalAlignmentMode = .Center
    resultMessage.verticalAlignmentMode = .Center
    resultMessage.alpha = 0
    addChild(resultMessage)
  }
  
  var rect: CGRect {
  get {
    return CGRect(origin: position, size: size)
  }
  set {
    position = newValue.origin
    size = newValue.size
  }
  }
  
  var size: CGSize = CGSizeZero {
  didSet{
    testTouchArea.position = CGPoint(x: size.width * 0.5, y: size.height * (1.0/3.0))
    ring.position = testTouchArea.position
    tapeNode.position = testTouchArea.position
    instructions.position = CGPoint(x: size.width * 0.5, y: size.height * (2.0/3.0))
    resultMessage.position = instructions.position
  }
  }
  
  var state: StatusNodeState = .Editing {
  didSet {
    if state == oldValue {return}
    switch state {
    case .Editing:
      ring.removeAllActions()
      ring.runEasedAction(SKAction.moveTo(testTouchArea.position, duration: 0.5))
      ringArrow.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      tapeNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
      instructions.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      resultMessage.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
      testTouchArea.userInteractionEnabled = true
    case .Thinking:
      testTouchArea.userInteractionEnabled = false
      thinkingAnimationDone = false
      self.runAction(SKAction.waitForDuration(0.75), completion: {[weak self] in self!.thinkingAnimationDone = true})
      ring.runEasedAction(SKAction.moveTo(tapeNode.position, duration: 0.5))
      ringArrow.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
      instructions.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
    case .Testing:
      tapeNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      resultMessage.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
    }
  }
  }
    
  class TestTouchArea: SKSpriteNode {
    weak var delegate: GameScene?
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
      delegate?.testButtonPressed()
    }
  }
}