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
  
  weak var delegate: GameScene? {
    didSet{
      for page in pages {
        (page as StatusPage).ringTouchArea.delegate = delegate
      }
    }
  }
  
  
  var firstPage: StatusPage
  var secondPage: StatusPage?
  let instructions: String
  var thinkingAnimationDone = false
  
  init(instructions: String) {
    self.instructions = instructions
    firstPage = StatusPage()
    firstPage.label.text = instructions
    super.init(pages: [firstPage], texture: nil, color: nil, size: CGSizeZero)
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
    
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        firstPage.userInteractionEnabled = true
        firstPage.ringArrow.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        secondPage = firstPage
        firstPage = StatusPage()
        firstPage.label.text = instructions
        pages = [firstPage, secondPage!]
        wrapper.position.x += size.width
      case .Thinking:
        touch = nil
        userInteractionEnabled = false
        if secondPage != nil {
          if wrapper.position.x > size.width * 0.5 {
            wrapper.position.x -= size.width
            firstPage = secondPage!
          }
          pages = [firstPage]
        }
        thinkingAnimationDone = false
        runAction(SKAction.waitForDuration(0.5), completion: {[weak self] in self!.thinkingAnimationDone = true})
        wrapper.runAction(SKAction.moveToX(0, duration: 0.5).ease())
        firstPage.label.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        firstPage.ringTouchArea.userInteractionEnabled = false
        firstPage.ringTouchArea.runAction(SKAction.moveTo(firstPage.tapeNode.position, duration: 0.5).ease())
        firstPage.ring.runAction(SKAction.scaleTo(0.5, duration: 0.5))
        firstPage.ringArrow.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        firstPage.tapeNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
      case .Testing:
        firstPage.label.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        firstPage.tapeNode.alpha = 1
      }
    }
  }
  
  class StatusPage: SKNode {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    let label = BreakingLabel()
    let tapeNode = TapeNode()
    let ringTouchArea = RingTouchArea(color: nil, size: CGSize(width: 64, height: 64))
    let ring = SKSpriteNode("ring")
    let ringArrow = SKSpriteNode("playArrow")
    
    override init() {
      super.init()
      label.fontSize = 16
      addChild(label)
      tapeNode.alpha = 0
      tapeNode.setScale(0.5)
      addChild(tapeNode)
      ring.setScale(0.5)
      ring.addChild(ringArrow)
      ringTouchArea.userInteractionEnabled = true
      ringTouchArea.zPosition = 100
      ringTouchArea.addChild(ring)
      addChild(ringTouchArea)
    }
    
    var size: CGSize = CGSizeZero {
      didSet{
        label.position.y = size.height * (1.0/6.0)
        tapeNode.position.y = size.height * (-1.0/6.0)
        ringTouchArea.position = tapeNode.position
      }
    }
    
  }
  
  class RingTouchArea: SKSpriteNode {
    weak var delegate: GameScene?
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
      delegate?.testButtonPressed()
    }
  }
}