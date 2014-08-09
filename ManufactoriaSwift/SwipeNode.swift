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
  
  var pages: [SKNode] {didSet {layOutPages(size.width)}}
  let wrapper = SKNode()
  override var size: CGSize {didSet {layOutPages(oldValue.width)}}
  var touch: UITouch?
  var touchStartX: CGFloat = 0.0
  var wrapperStartX: CGFloat = 0.0
  
  init(pages: [SKNode]) {
    self.pages = pages
    super.init(texture: nil, color: nil, size: CGSizeZero)
    userInteractionEnabled = true
    wrapper.addChildren(pages)
    addChild(wrapper)
  }
  
  func layOutPages(oldWidth: CGFloat) {
    touch = nil
    if oldWidth != 0 {
      wrapper.position.x = wrapper.position.x / oldWidth * size.width
    }
    for i in 0 ..< pages.count {
      pages[i].position = CGPoint(x: size.width * (0.5 + CGFloat(i)), y: size.height * 0.5)
    }
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    if touch != nil {return}
    touch = touches.anyObject() as? UITouch
    wrapperStartX = wrapper.position.x
    touchStartX = touch!.locationInNode(self).x
  }
  
  override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    wrapper.position.x = wrapperStartX - touchStartX + touch!.locationInNode(self).x
  }
  
  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    if touch == nil {return}
    if !touches.containsObject(touch!) {return}
    touch = nil
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    touchesEnded(touches, withEvent: event)
  }
}
