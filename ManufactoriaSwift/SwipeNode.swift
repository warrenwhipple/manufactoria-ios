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
    swipeNode.position = CGPoint(x: 0.5 * size.width, y: 0.5 * size.height)
    swipeNode.size = size * 0.5
    addChild(swipeNode)
  }
}

class SwipeNode: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let wrapper = SKNode()
  var touch: UITouch?
  var wrapperDragOffsetX: CGFloat = 0.0
  var lastTouchX: CGFloat = 0
  var lastLastTouchX: CGFloat = 0
  var lastTouchTime: NSTimeInterval = 0
  var lastLastTouchTime: NSTimeInterval = 0
  
  init(pages: [SKNode], texture: SKTexture!, color: UIColor!, size: CGSize) {
    self.pages = pages
    super.init(texture: nil, color: UIColor.redColor(), size: CGSizeZero)
    userInteractionEnabled = true
    for i in 0 ..< pages.count {
      let page = pages[i]
      page.position.x = CGFloat(i) * size.width
      wrapper.addChild(page)
    }
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
      snapToClosest()
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
      snapToClosest()
    }
  }
  
  func snapToIndex(index: Int) {
    var newX: CGFloat = 0
    if index > pages.count - 1 {
      newX = -CGFloat(pages.count - 1) * size.width
    } else if index > 0 {
      newX = -CGFloat(index) * size.width
    }
    if wrapper.position.x == newX {
      wrapper.removeActionForKey("snap")
    } else {
      wrapper.runAction(SKAction.moveToX(newX, duration: 0.25).easeOut())
    }
  }
  
  func snapToClosest() {
    snapToIndex(Int(round(-wrapper.position.x / size.width)))
  }
  
  func snapLeft() {
    snapToIndex(Int(ceil(-wrapper.position.x / size.width)))
  }
  
  func snapRight() {
    snapToIndex(Int(floor(-wrapper.position.x / size.width)))
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    if touch != nil {return}
    touch = touches.anyObject() as? UITouch
    wrapperDragOffsetX = wrapper.position.x - touch!.locationInNode(self).x
    lastTouchX = touch!.locationInView(scene.view).x
    lastLastTouchX = lastTouchX
    lastTouchTime = touch!.timestamp
    lastLastTouchTime = lastTouchTime
  }
  
  override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    wrapper.position.x = wrapperDragOffsetX + touch!.locationInNode(self).x
    lastLastTouchX = lastTouchX
    lastTouchX = touch!.locationInView(scene.view).x
    lastLastTouchTime = lastTouchTime
    lastTouchTime = touch!.timestamp
  }
  
  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    
    let touchX = touch!.locationInView(scene.view).x
    let touchTime = touch!.timestamp
    let deltaTouchTimeShort = touchTime - lastTouchTime
    let deltaTouchTimeLong = touchTime - lastLastTouchTime
    if deltaTouchTimeShort == 0.0 {
      snapToClosest()
    } else if deltaTouchTimeLong == 0.0 {
      snapToClosest()
    } else {
      let touchVelocityX = ((touchX - lastTouchX) / CGFloat(deltaTouchTimeShort) + (touchX - lastLastTouchX) / CGFloat(deltaTouchTimeLong)) * 0.5
      if touchVelocityX < -200.0 {
        snapLeft()
      } else if touchVelocityX > 200.0 {
        snapRight()
      } else {
        snapToClosest()
      }
    }
    touch = nil
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    touchesEnded(touches, withEvent: event)
  }
}
