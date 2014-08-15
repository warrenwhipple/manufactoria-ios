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
  enum State {case Editing, Thinking, Testing}
  
  weak var delegate: GameScene?
  let label = BreakingLabel()
  let testButton = TestButton(color: nil, size: CGSize(width: 64, height: 64))
  let ring = SKSpriteNode("ring")
  let ringArrow = SKSpriteNode("playArrow")
  let tapeNode = TapeNode()
  let instructions: String
  let page = SKNode()
  
  var thinkingAnimationDone = false
  
  init(instructions: String) {
    self.instructions = instructions
    
    super.init(pages: [page])
    
    userInteractionEnabled = false
    
    label.fontSize = 16
    label.text = instructions
    page.addChild(label)
    
    tapeNode.alpha = 0
    tapeNode.setScale(0.5)
    tapeNode.delegate = self
    tapeNode.printer.delegate = testButton
    page.addChild(tapeNode)
    
    ring.addChild(ringArrow)
    testButton.delegate = self
    testButton.userInteractionEnabled = true
    testButton.zPosition = 10
    testButton.addChild(ring)
    page.addChild(testButton)
  }
  
  override var size: CGSize {
    didSet{
      label.position = CGPoint(x: 0, y: size.height * (1.0/6.0))
      tapeNode.position = CGPoint(x: 0, y: -size.height * (1.0/6.0))
      testButton.position = convertPoint(tapeNode.dotPositionForIndex(tapeNode.dots.count), fromNode: tapeNode)
    }
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        changeText(instructions)
        testButton.removeAllActions()
        testButton.runAction(SKAction.moveTo(tapeNode.position, duration: 0.5).ease())
        ring.runAction(SKAction.scaleTo(1, duration: 0.5).ease())
        ringArrow.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        tapeNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        userInteractionEnabled = true
        testButton.userInteractionEnabled = true
      case .Thinking:
        userInteractionEnabled = false
        testButton.userInteractionEnabled = false
        thinkingAnimationDone = false
        runAction(SKAction.waitForDuration(0.75), completion: {[weak self] in self!.thinkingAnimationDone = true})
        changeText("")
        ring.runAction(SKAction.scaleTo(0.5, duration: 0.5).ease())
        ringArrow.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
      case .Testing:
        tapeNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
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
  
  func testButtonPressed() {
    delegate?.testButtonPressed()
  }
  
  class TestButton: SKSpriteNode {
    weak var delegate: StatusNode?
    var touch: UITouch?
    
    func printerMoved(printer: SKNode) {
      position = parent.convertPoint(printer.position, fromNode: printer.parent)
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
      delegate?.testButtonPressed()
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
      
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
      
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
      
    }
  }
}