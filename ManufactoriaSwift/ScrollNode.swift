//
//  ScrollNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 11/22/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class ScrollNode: SKNode, DragThroughDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let wrapper = SKNode()
  var touch: UITouch?
  var wrapperMaxY: CGFloat = 0
  var wrapperMinY: CGFloat = 0
  var overScroll: CGFloat = 64
  var touchBeganTouchY: CGFloat = 0
  var touchBeganWrapperY: CGFloat = 0
  override init() {
    super.init()
    userInteractionEnabled = true
    addChild(wrapper)
  }
  
  func touchBegan() {
    if let touch = touch {
      touchBeganTouchY = touch.locationInNode(self).y
      touchBeganWrapperY = wrapper.position.y
    }
  }
  
  func touchMoved() {
    if let touch = touch {
      let newTouchY = touch.locationInNode(self).y
      let newWrapperY = touchBeganWrapperY + newTouchY - touchBeganTouchY
      wrapper.position.y = newWrapperY
    }
  }
  
  func touchEnded() {
    touch = nil
  }
  
  func touchCancelled() {
    touch = nil
  }
  
  // MARK: - SwipeThroughButtonDelegate Methods
  
  func dragThroughTouchBegan(dragThroughTouch: UITouch) {
    if touch != nil {
      touchEnded()
    }
    touch = dragThroughTouch
    touchBegan()
  }
  
  func dragThroughTouchMoved(dragThroughTouch: UITouch) {
    if touch == dragThroughTouch {
      touchMoved()
    }
  }
  
  func dragThroughTouchEnded(dragThroughTouch: UITouch) {
    if touch == dragThroughTouch {
      touchEnded()
    }
  }
  
  func dragThroughTouchCancelled(dragThroughTouch: UITouch) {
    if touch == dragThroughTouch {
      touchCancelled()
    }
  }
  
  // MARK: - Touch Delegate Methods
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if touch != nil {
      touchCancelled()
    }
    touch = touches.anyObject() as? UITouch
    touchBegan()
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