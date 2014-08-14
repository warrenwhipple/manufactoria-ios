//
//  StatusNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/2/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class StatusNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Testing}
  
  weak var delegate: GameScene? {didSet{ringTouchArea.delegate = delegate}}
  let label = BreakingLabel()
  let ringTouchArea = RingTouchArea(color: nil, size: CGSize(width: 64, height: 64))
  let ring = SKSpriteNode("ring")
  let ringArrow = SKSpriteNode("playArrow")
  let tapeNode = TapeNode()
  let instructions: String
  
  var thinkingAnimationDone = false
  
  init(instructions: String) {
    self.instructions = instructions
    
    super.init()
    
    label.fontSize = 16
    label.text = instructions
    addChild(label)
    
    tapeNode.alpha = 0
    tapeNode.setScale(0.5)
    tapeNode.delegate = self
    addChild(tapeNode)
    
    ring.setScale(0.5)
    ring.addChild(ringArrow)
    ringTouchArea.userInteractionEnabled = true
    ringTouchArea.zPosition = 10
    ringTouchArea.addChild(ring)
    addChild(ringTouchArea)
  }
  
  var size: CGSize = CGSizeZero {
    didSet{
      label.position = CGPoint(x: 0, y: size.height * (1.0/6.0))
      tapeNode.position = CGPoint(x: 0, y: -size.height * (1.0/6.0))
      ringTouchArea.position = convertPoint(tapeNode.dotPositionForIndex(tapeNode.dots.count), fromNode: tapeNode)
    }
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        changeText(instructions)
        ringTouchArea.removeAllActions()
        ringTouchArea.runAction(SKAction.moveTo(tapeNode.position, duration: 0.5).ease())
        ringArrow.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        tapeNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        ringTouchArea.userInteractionEnabled = true
      case .Thinking:
        ringTouchArea.userInteractionEnabled = false
        thinkingAnimationDone = false
        runAction(SKAction.waitForDuration(0.75), completion: {[weak self] in self!.thinkingAnimationDone = true})
        changeText("")
        ringArrow.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
      case .Testing:
        tapeNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      }
    }
  }
  
  func changeText(text: String) {
    label.runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(0, duration: 0.25),
      SKAction.runBlock({[weak self] in self!.label.text = text}),
      SKAction.fadeAlphaTo(1, duration: 0.25)
      ]), withKey: "changeText")
  }
  
  class RingTouchArea: SKSpriteNode {
    weak var delegate: GameScene?
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
      delegate?.testButtonPressed()
    }
  }
}