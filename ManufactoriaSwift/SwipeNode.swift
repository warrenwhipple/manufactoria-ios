//
//  SwipeNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SwipeNodeScene: SKScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  override init(size: CGSize) {
    super.init(size: size)
    let swipeNode = SwipeNode(pages: [
      SKSpriteNode("beltButton"),
      SKSpriteNode("ring"),
      SKSpriteNode("robut")
      ])
    swipeNode.position = CGPoint(0.5 * size.width, 0.5 * size.height)
    swipeNode.size = size
    addChild(swipeNode)
  }
}

class SwipeNode: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let wrapper = SKNode()
  var touch: UITouch?
  var wrapperMinX: CGFloat = 0.0
  var lastTouchX: CGFloat = 0
  var lastLastTouchX: CGFloat = 0
  var lastTouchTime: NSTimeInterval = 0
  var lastLastTouchTime: NSTimeInterval = 0
  
  init(pages: [SKNode], texture: SKTexture!, color: UIColor!, size: CGSize) {
    self.pages = pages
    super.init(texture: texture, color: color, size: size)
    userInteractionEnabled = true
    for i in 0 ..< pages.count {
      let page = pages[i]
      page.position.x = CGFloat(i) * size.width
      wrapper.addChild(page)
    }
    addChild(wrapper)
  }
  
  init(pages: [SKNode]) {
    self.pages = pages
    super.init(texture: nil, color: nil, size: CGSizeZero)
    userInteractionEnabled = true
    for i in 0 ..< pages.count {
      let page = pages[i]
      page.position.x = CGFloat(i) * size.width
      wrapper.addChild(page)
    }
    addChild(wrapper)
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
    }
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
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    if touch != nil {return}
    wrapper.removeActionForKey("snap")
    touch = touches.anyObject() as? UITouch
    lastTouchX = touch!.locationInNode(self).x
    lastLastTouchX = lastTouchX
    lastTouchTime = touch!.timestamp
    lastLastTouchTime = lastTouchTime
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