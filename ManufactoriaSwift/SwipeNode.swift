//
//  SwipeNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SwipeNode: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let wrapper: SKNode
  let leftArrow, rightArrow: SKSpriteNode
  var touch: UITouch?
  var wrapperMinX: CGFloat = 0.0
  var lastTouchX: CGFloat = 0
  var lastLastTouchX: CGFloat = 0
  var lastTouchTime: NSTimeInterval = 0
  var lastLastTouchTime: NSTimeInterval = 0
  
  init(pages: [SKNode], texture: SKTexture!, color: UIColor!, size: CGSize) {
    leftArrow = SKSpriteNode("swipeArrow")
    leftArrow.anchorPoint.x = 0
    leftArrow.alpha = 0
    rightArrow = SKSpriteNode("swipeArrow")
    rightArrow.anchorPoint.x = 0
    rightArrow.zRotation = CGFloat(M_PI)
    if pages.count <= 1 {rightArrow.alpha = 0}
    wrapper = SKNode()
    self.pages = pages
    super.init(texture: texture, color: color, size: size)
    userInteractionEnabled = true
    for i in 0 ..< pages.count {
      let page = pages[i]
      page.position.x = CGFloat(i) * size.width
      wrapper.addChild(page)
    }
    addChild(leftArrow)
    addChild(rightArrow)
    addChild(wrapper)
  }
  
  convenience init(pages: [SKNode]) {
    self.init(pages: pages, texture: nil, color: nil, size: CGSizeZero)
  }
  
  var pages: [SKNode] {
    didSet {
      touch = nil
      removeChildrenInArray(oldValue)
      for i in 0 ..< pages.count {
        let page = pages[i]
        page.position.x = CGFloat(i) * size.width
        wrapper.addChild(page)
      }
      wrapperMinX = -CGFloat(pages.count - 1) * size.width
      snapToClosestWithInitialVelocityX(0)
    }
  }
  
  override var size: CGSize {
    didSet {
      touch = nil
      for i in 0 ..< pages.count {
        pages[i].position.x = CGFloat(i) * size.width
      }
      if oldValue.width != 0 {
        wrapper.position.x *= size.width / oldValue.width
      }
      wrapperMinX = -CGFloat(pages.count - 1) * size.width
      snapToClosestWithInitialVelocityX(0)
      leftArrow.position.x = -0.5 * size.width + 4
      rightArrow.position.x = 0.5 * size.width - 4
    }
  }
  
  override var userInteractionEnabled: Bool {
    didSet {
      if userInteractionEnabled {
        if touch == nil && size.width != 0 {
          fadeInArrowsForIndex(Int(round(-wrapper.position.x / size.width)))
        }
      } else {
        let fadeAction = SKAction.fadeAlphaTo(0, duration: 0.25)
        leftArrow.runAction(fadeAction, withKey: "fade")
        rightArrow.runAction(fadeAction, withKey: "fade")
      }
    }
  }
  
  func goToIndexWithoutSnap(index: Int) {
    wrapper.removeActionForKey("snap")
    wrapper.position.x = -CGFloat(index) * size.width
  }
  
  func snapToIndex(index: Int, initialVelocityX: CGFloat) {
    var newX: CGFloat = 0
    if index > pages.count - 1 {
      newX = -CGFloat(pages.count - 1) * size.width
    } else if index > 0 {
      newX = -CGFloat(index) * size.width
    }
    if wrapper.position.x == newX {
      wrapper.removeActionForKey("snap")
    } else {
      if initialVelocityX == 0 {
        wrapper.runAction(SKAction.moveToX(newX, duration: 0.25).easeOut(), withKey: "snap")
      } else {
        let eta = (newX - wrapper.position.x) / initialVelocityX
        if eta < 0 || eta > 0.25 {
          wrapper.runAction(SKAction.moveToX(newX, duration: 0.25).easeOut(), withKey: "snap")
        } else {
          wrapper.runAction(SKAction.moveToX(newX, duration: NSTimeInterval(eta)).easeOut(), withKey: "snap")
        }
      }
    }
    if userInteractionEnabled == true {fadeInArrowsForIndex(index)}
  }
  
  func snapToClosestWithInitialVelocityX(initialVelocityX: CGFloat) {
    snapToIndex(Int(round(-wrapper.position.x / size.width)), initialVelocityX: initialVelocityX)
  }
  
  func snapLeftWithInitialVelocityX(initialVelocityX: CGFloat) {
    snapToIndex(Int(ceil(-wrapper.position.x / size.width)), initialVelocityX: initialVelocityX)
  }
  
  func snapRightWithInitialVelocityX(initialVelocityX: CGFloat) {
    snapToIndex(Int(floor(-wrapper.position.x / size.width)), initialVelocityX: initialVelocityX)
  }
  
  func fadeInArrowsForIndex(index: Int) {
    let fadeAction = SKAction.fadeAlphaTo(1, duration: 0.25)
    if index > 0 {
      leftArrow.runAction(fadeAction, withKey: "fade")
    }
    if index < pages.count - 1 {
      rightArrow.runAction(fadeAction, withKey: "fade")
    }
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    if touch != nil {return}
    wrapper.removeActionForKey("snap")
    touch = touches.anyObject() as? UITouch
    lastTouchX = touch!.locationInNode(self).x
    lastLastTouchX = lastTouchX
    lastTouchTime = touch!.timestamp
    lastLastTouchTime = lastTouchTime
    let fadeAction = SKAction.fadeAlphaTo(0, duration: 0.25)
    leftArrow.runAction(fadeAction, withKey: "fade")
    rightArrow.runAction(fadeAction, withKey: "fade")
  }
  
  override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    let touchX = touch!.locationInNode(self).x
    let dX = (touchX - lastTouchX)
    let newX = wrapper.position.x + dX
    if newX > 0 {
      wrapper.position.x += dX * (1 - (wrapper.position.x + dX) / size.width * 4)
    } else if newX < wrapperMinX {
      wrapper.position.x += dX * (1 - (wrapperMinX - wrapper.position.x - dX) / size.width * 4)
    } else {
      wrapper.position.x += dX
    }
    lastLastTouchX = lastTouchX
    lastTouchX = touchX
    lastLastTouchTime = lastTouchTime
    lastTouchTime = touch!.timestamp
  }
  
  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    let touchX = touch!.locationInNode(self).x
    let dX = (touchX - lastTouchX)
    let newX = wrapper.position.x + dX
    if newX > 0 {
      wrapper.position.x += dX * (1 - (wrapper.position.x + dX) / size.width * 4)
    } else if newX < wrapperMinX {
      wrapper.position.x += dX * (1 - (wrapperMinX - wrapper.position.x - dX) / size.width * 4)
    } else {
      wrapper.position.x += dX
    }
    let touchTime = touch!.timestamp
    var touchVelocityX: CGFloat = 0
    if touchTime - lastLastTouchTime < 0.1 {
      touchVelocityX = (touchX - lastLastTouchX) / CGFloat(touchTime - lastLastTouchTime)
    } else {
      touchVelocityX = (touchX - lastTouchX) / CGFloat(touchTime - lastTouchTime)
    }
    if touchVelocityX < -200.0 {
      snapLeftWithInitialVelocityX(touchVelocityX)
    } else if touchVelocityX > 200.0 {
      snapRightWithInitialVelocityX(touchVelocityX)
    } else {
      snapToClosestWithInitialVelocityX(touchVelocityX)
    }
    touch = nil
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    touchesEnded(touches, withEvent: event)
  }
}
