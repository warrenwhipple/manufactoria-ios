//
//  ScrollNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 11/22/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class ScrollNode: SKNode, SwipeThroughDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let wrapper = SKNode()
  var touch: UITouch?
  var wrapperMaxY: CGFloat = 0
  var wrapperMinY: CGFloat = 0
  var overScroll: CGFloat = 64
  var lastTouchY: CGFloat = 0
  var lastLastTouchY: CGFloat = 0
  var lastTouchTime: NSTimeInterval = 0
  var lastLastTouchTime: NSTimeInterval = 0
  
  override init() {
    super.init()
    userInteractionEnabled = true
    addChild(wrapper)
  }
  
  func touchBegan() {
    lastTouchY = touch!.locationInNode(self).y
    lastLastTouchY = lastTouchY
    lastTouchTime = touch!.timestamp
    lastLastTouchTime = lastTouchTime
  }
  
  func touchMoved() {
    let touchY = touch!.locationInNode(self).y
    let dY = (touchY - lastTouchY)
    let newY = wrapper.position.y + dY
    if newY > wrapperMaxY {
      if newY < wrapperMaxY + overScroll {
        wrapper.position.y += dY * (1 - (newY - wrapperMaxY) / overScroll)
      }
    } else if newY < wrapperMinY {
      if newY > wrapperMinY - overScroll {
        wrapper.position.y += dY * (1 - (wrapperMinY - newY) / overScroll)
      }
    } else {
      wrapper.position.y = newY
    }
    lastLastTouchY = lastTouchY
    lastTouchY = touchY
    lastLastTouchTime = lastTouchTime
    lastTouchTime = touch!.timestamp
  }
  
  func touchEnded() {
    let touchY = touch!.locationInNode(self).y
    let dY = (touchY - lastTouchY)
    let newY = max(wrapperMinY - overScroll, min(wrapperMaxY + overScroll, wrapper.position.y + dY))
    if newY > wrapperMaxY {
      wrapper.position.y += dY * (1 - (newY - wrapperMaxY) / overScroll)
    } else if newY < wrapperMinY {
      wrapper.position.y += dY * (1 - (wrapperMinY - newY) / overScroll)
    } else {
      wrapper.position.y = newY
    }
    let touchTime = touch!.timestamp
    var touchVelocityY: CGFloat = 0
    if touchTime - lastLastTouchTime < 0.1 {
      touchVelocityY = (touchY - lastLastTouchY) / CGFloat(touchTime - lastLastTouchTime)
    } else {
      touchVelocityY = (touchY - lastTouchY) / CGFloat(touchTime - lastTouchTime)
    }
    touch = nil
  }
  
  func touchCancelled() {
    touchEnded()
  }
  
  // MARK: - SwipeThroughButtonDelegate Methods
  
  func swipeThroughTouchMoved(swipeThroughTouch: UITouch) {
    if userInteractionEnabled {
      if touch == nil {
        touch = swipeThroughTouch
        touchBegan()
      } else if touch == swipeThroughTouch {
        touchMoved()
      }
    }
  }
  
  func swipeThroughTouchEnded(swipeThroughTouch: UITouch) {
    if userInteractionEnabled && touch == swipeThroughTouch {
      touchEnded()
    }
  }
  
  func swipeThroughTouchCancelled(swipeThroughTouch: UITouch) {
    if userInteractionEnabled && touch == swipeThroughTouch {
      touchCancelled()
    }
  }
  
  // MARK: - Touch Delegate Methods
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if touch == nil {
      touch = touches.anyObject() as? UITouch
      touchBegan()
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!) {
      touchMoved()
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!) {
      touchEnded()
    }
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil && touches.containsObject(touch!) {
      touchCancelled()
    }
  }
}