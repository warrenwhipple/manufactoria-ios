//
//  SwipeNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SwipeNode: SKSpriteNode, SwipeThroughDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let wrapper = SKNode()
  let pages: [SKNode]
  let arrows: [SKSpriteNode]
  var touch: UITouch?
  var wrapperMinX: CGFloat = 0.0
  var lastTouchX: CGFloat = 0
  var lastLastTouchX: CGFloat = 0
  var lastTouchTime: NSTimeInterval = 0
  var lastLastTouchTime: NSTimeInterval = 0
  
  init(pages: [SKNode], texture: SKTexture!, color: UIColor!, size: CGSize) {
    self.pages = pages
    for i in 0 ..< pages.count {
      let page = pages[i]
      wrapper.addChild(page)
    }
    var tempArrows: [SKSpriteNode] = []
    if pages.count > 1 {
      for i in 0 ..< pages.count - 1 {
        let arrow = SKSpriteNode("swipeArrow")
        arrow.setScale(0)
        arrow.runAction(SKAction.scaleTo(1, duration: 0.2), withKey: "scale")
        tempArrows.append(arrow)
        wrapper.addChild(arrow)
      }
    }
    arrows = tempArrows
    super.init(texture: texture, color: color, size: size)
    userInteractionEnabled = true
    addChild(wrapper)
  }
  
  convenience init(pages: [SKNode]) {
    self.init(pages: pages, texture: nil, color: nil, size: CGSizeZero)
  }
  
  override var size: CGSize {didSet {if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    touch = nil
    for i in 0 ..< pages.count {pages[i].position.x = CGFloat(i) * size.width}
    for i in 0 ..< arrows.count {arrows[i].position.x = (CGFloat(i) + 0.5) * size.width}
    wrapperMinX = -CGFloat(pages.count - 1) * size.width
    snapToClosestWithInitialVelocityX(0)
  }
  
  override var userInteractionEnabled: Bool {
    didSet {
      if userInteractionEnabled {
        if touch == nil && size.width != 0 {
          for arrow in arrows {arrow.runAction(SKAction.scaleTo(1, duration: 0.2), withKey: "scale")}
        }
      } else {
        let fadeAction = SKAction.fadeAlphaTo(0, duration: 0.25)
        for arrow in arrows {arrow.runAction(SKAction.scaleTo(0, duration: 0.2), withKey: "scale")}
        touch = nil
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
  
  func touchBegan() {
    wrapper.removeActionForKey("snap")
    lastTouchX = touch!.locationInNode(self).x
    lastLastTouchX = lastTouchX
    lastTouchTime = touch!.timestamp
    lastLastTouchTime = lastTouchTime
  }
  
  func touchMoved() {
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
  
  func touchEnded() {
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
