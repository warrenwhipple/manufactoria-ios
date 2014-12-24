//
//  SwipeNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol SwipeNodeDelegate: class {
  func swipeNodeDidSnapToIndex(index: Int)
}

class SwipeNode: SKSpriteNode, DragThroughDelegate {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  var swipeSnapDelegate: SwipeNodeDelegate?
  let wrapper = SKNode()
  var currentIndex = 0
  var pages: [SKNode]
  let leftArrowWrapper = SKNode()
  let rightArrowWrapper = SKNode()
  let leftArrow = SKSpriteNode(imageNamed: "swipeArrow", color: Globals.strokeColor)
  let rightArrow = SKSpriteNode(imageNamed: "swipeArrow", color: Globals.strokeColor)
  var touch: UITouch?
  var wrapperMinX: CGFloat = 0.0
  var arrowHint: SKSpriteNode?
  var span: CGFloat = 0.0
  
  init(pages: [SKNode]) {
    self.pages = pages
    
    super.init(texture: nil, color: nil, size: CGSizeZero)
    userInteractionEnabled = true
    
    for page in pages {wrapper.addChild(page)}
    //leftArrow.anchorPoint.x = 0
    leftArrowWrapper.addChild(leftArrow)
    //rightArrow.anchorPoint.x = 0
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
    span = xScale == 0 ? 1 : size.width / xScale
    touchCancelled()
    for (p, page) in enumerate(pages) {
      page.position.x = CGFloat(p) * span
    }
    wrapperMinX = -CGFloat(pages.count - 1) * span
    goToIndexWithoutSnap(currentIndex)
  }
  
  func updateArrowAlphas() {
    if span == 0 {return}
    let indexFloat = -wrapper.position.x / span
    let closestIndex = round(indexFloat)
    leftArrowWrapper.position.x = (closestIndex - 0.5) * span
    rightArrowWrapper.position.x = (closestIndex + 0.5) * span
    
    if Int(closestIndex) > 0 {
      if indexFloat < closestIndex {
        leftArrow.alpha = max(0, 1 - 3 * abs(indexFloat - closestIndex))
      } else {
        leftArrow.alpha = 1
        }
    } else {
      leftArrow.alpha = 0
    }
    
    if Int(closestIndex) < pages.count - 1 {
      if indexFloat > closestIndex {
        rightArrow.alpha = max(0, 1 - 3 * abs(indexFloat - closestIndex))
      } else {
        rightArrow.alpha = 1
      }
    } else {
      rightArrow.alpha = 0
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
    wrapper.position.x = -CGFloat(index) * span
    updateArrowAlphas()
  }
  
  func snapToIndex(index: Int, initialVelocityX: CGFloat) {
    currentIndex = 0
    var newX: CGFloat = 0
    if index > pages.count - 1 {
      currentIndex = pages.count - 1
      newX = -CGFloat(pages.count - 1) * span
    } else if index > 0 {
      currentIndex = index
      newX = -CGFloat(index) * span
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
    swipeSnapDelegate?.swipeNodeDidSnapToIndex(index)
  }
  
  func snapToClosestWithInitialVelocityX(initialVelocityX: CGFloat) {
    snapToIndex(Int(round(-wrapper.position.x / span)), initialVelocityX: initialVelocityX)
  }
  
  func snapLeftWithInitialVelocityX(initialVelocityX: CGFloat) {
    snapToIndex(Int(ceil((10 - wrapper.position.x) / span)), initialVelocityX: initialVelocityX)
  }
  
  func snapRightWithInitialVelocityX(initialVelocityX: CGFloat) {
    snapToIndex(Int(floor((-10 - wrapper.position.x) / span)), initialVelocityX: initialVelocityX)
  }
  
  var touchBeganTime: NSTimeInterval?
  var lastTouchX: CGFloat?
  var lastLastTouchX: CGFloat?
  var lastTouchTime: NSTimeInterval?
  var lastLastTouchTime: NSTimeInterval?
  
  func touchBegan() {
    if let touch = touch {
      wrapper.removeActionForKey("snap")
      lastTouchX = touch.locationInNode(self).x
      lastLastTouchX = lastTouchX
      touchBeganTime = touch.timestamp
      lastTouchTime = touchBeganTime
      lastLastTouchTime = touchBeganTime
    }
  }
  
  func touchMoved() {
    if let touch = touch {
      if let lastTouchX = lastTouchX {
        let touchX = touch.locationInNode(self).x
        let dX = touchX - lastTouchX
        let newX = wrapper.position.x + dX
        if dX > 0 && newX > 0 {
          wrapper.position.x += dX * (1 - (wrapper.position.x + dX) / span * 4)
        } else if dX < 0 && newX < wrapperMinX {
          wrapper.position.x += dX * (1 - (wrapperMinX - wrapper.position.x - dX) / span * 4)
        } else {
          wrapper.position.x += dX
        }
        lastLastTouchX = lastTouchX
        self.lastTouchX = touchX
        lastLastTouchTime = lastTouchTime
        lastTouchTime = touch.timestamp
        updateArrowAlphas()
      }
    }
  }
  
  func touchEnded() {
    if let touch = touch {
      let touchPoint = touch.locationInNode(self)
      
      var touchVelocityX: CGFloat = 0
      if lastLastTouchTime != nil && lastLastTouchX != nil && touch.timestamp - lastLastTouchTime! < 0.1 {
        touchVelocityX = (lastLastTouchX! - touchPoint.x) / CGFloat(lastLastTouchTime! - touch.timestamp)
      } else if lastTouchTime != nil && lastTouchX != nil {
        touchVelocityX = (lastTouchX! - touchPoint.x) / CGFloat(lastTouchTime! - touch.timestamp)
      }
      
      if touchVelocityX < -200.0 {
        snapLeftWithInitialVelocityX(touchVelocityX)
      } else if touchVelocityX > 200.0 {
        snapRightWithInitialVelocityX(touchVelocityX)
      } else if touchBeganTime != nil && touch.timestamp - touchBeganTime! < 0.5 {
        if touchPoint.x > span / 6 {
          snapLeftWithInitialVelocityX(touchVelocityX)
        } else if touchPoint.x < -span / 6 {
          snapRightWithInitialVelocityX(touchVelocityX)
        } else {
          snapToClosestWithInitialVelocityX(touchVelocityX)
        }
      } else {
        snapToClosestWithInitialVelocityX(touchVelocityX)
      }
      
      self.touch = nil
      lastTouchX = nil
      lastLastTouchX = nil
      touchBeganTime = nil
      lastTouchTime = nil
      lastLastTouchTime = nil
    }
  }
  
  func touchCancelled() {
    touchEnded()
  }
  
  // MARK: - SwipeThroughButtonDelegate Methods
  
  func dragThroughTouchBegan(touch: UITouch) {
    
  }
  
  func dragThroughTouchMoved(dragThroughTouch: UITouch) {
    if userInteractionEnabled {
      if touch == nil {
        touch = dragThroughTouch
        touchBegan()
      } else if touch == dragThroughTouch {
        touchMoved()
      }
    }
  }
  
  func dragThroughTouchEnded(dragThroughTouch: UITouch) {
    if userInteractionEnabled && touch == dragThroughTouch {
      touchEnded()
    }
  }
  
  func dragThroughTouchCancelled(dragThroughTouch: UITouch) {
    if userInteractionEnabled && touch == dragThroughTouch {
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
