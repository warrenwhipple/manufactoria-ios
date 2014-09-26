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
  var currentIndex = 0
  var pages: [SKNode]
  let leftArrowWrapper = SKNode()
  let rightArrowWrapper = SKNode()
  let leftArrow = SKSpriteNode("swipeArrow")
  let rightArrow = SKSpriteNode("swipeArrow")
  var touch: UITouch?
  var wrapperMinX: CGFloat = 0.0
  var lastTouchX: CGFloat = 0
  var lastLastTouchX: CGFloat = 0
  var lastTouchTime: NSTimeInterval = 0
  var lastLastTouchTime: NSTimeInterval = 0
  
  init(pages: [SKNode]) {
    self.pages = pages
    
    super.init(texture: nil, color: nil, size: CGSizeZero)
    userInteractionEnabled = true
    
    for page in pages {wrapper.addChild(page)}
    leftArrow.anchorPoint.x = 0
    leftArrowWrapper.addChild(leftArrow)
    rightArrow.anchorPoint.x = 0
    rightArrow.xScale = -1
    rightArrowWrapper.addChild(rightArrow)
    wrapper.addChild(leftArrowWrapper)
    wrapper.addChild(rightArrowWrapper)
    addChild(wrapper)
  }

  func addPageToRight(newPage: SKNode) {
    pages.append(newPage)
    wrapper.addChild(newPage)
    fitToSize()
    updateArrowAlphas()
  }
  
  override var size: CGSize {didSet {if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    touch = nil
    for i in 0 ..< pages.count {pages[i].position.x = CGFloat(i) * size.width}
    wrapperMinX = -CGFloat(pages.count - 1) * size.width
    goToIndexWithoutSnap(currentIndex)
  }
  
  func updateArrowAlphas() {
    if size.width == 0 {return}
    let indexFloat = -wrapper.position.x / size.width
    let closestIndex = round(indexFloat)
    leftArrowWrapper.position.x = (closestIndex - 0.5) * size.width
    rightArrowWrapper.position.x = (closestIndex + 0.5) * size.width
    
    if indexFloat > closestIndex {
      leftArrow.alpha = 1
      rightArrow.alpha = max(0, 1 - 3 * abs(indexFloat - closestIndex))
    } else if indexFloat < closestIndex {
      leftArrow.alpha = max(0, 1 - 3 * abs(indexFloat - closestIndex))
      rightArrow.alpha = 1
    } else {
      leftArrow.alpha = 1
      rightArrow.alpha = 1
    }
  }
  
  override var userInteractionEnabled: Bool {
    didSet {
      if userInteractionEnabled {
        leftArrowWrapper.runAction(SKAction.fadeAlphaTo(1, duration: 0.2))
        rightArrowWrapper.runAction(SKAction.fadeAlphaTo(1, duration: 0.2))
      } else {
        leftArrowWrapper.runAction(SKAction.fadeAlphaTo(1, duration: 0.2))
        rightArrowWrapper.runAction(SKAction.fadeAlphaTo(1, duration: 0.2))
        touch = nil
      }
    }
  }
  
  func goToIndexWithoutSnap(index: Int) {
    currentIndex = index
    wrapper.removeActionForKey("snap")
    wrapper.position.x = -CGFloat(index) * size.width
    updateArrowAlphas()
  }
  
  func snapToIndex(index: Int, initialVelocityX: CGFloat) {
    currentIndex = 0
    var newX: CGFloat = 0
    if index > pages.count - 1 {
      currentIndex = pages.count - 1
      newX = -CGFloat(pages.count - 1) * size.width
    } else if index > 0 {
      currentIndex = index
      newX = -CGFloat(index) * size.width
    }
    if wrapper.position.x == newX {
      wrapper.removeActionForKey("snap")
    } else {
      var eta: CGFloat = 0.25
      if initialVelocityX != 0 {
        eta = max(0, min (0.25, abs((newX - wrapper.position.x) / initialVelocityX)))
      }
      wrapper.runAction(SKAction.group([
        SKAction.moveToX(newX, duration: NSTimeInterval(eta)).easeOut(),
        SKAction.customActionWithDuration(NSTimeInterval(eta), actionBlock: {
          [unowned self]
          (node: SKNode!, elapsedTime: CGFloat) -> () in
          self.updateArrowAlphas()})
        ]), withKey: "snap")
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
    updateArrowAlphas()
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
