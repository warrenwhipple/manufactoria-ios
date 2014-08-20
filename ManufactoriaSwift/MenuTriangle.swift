//
//  MenuTriangle.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/19/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class MenuTriangle: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var delegate: GameScene?
  var triangle = SKSpriteNode("menuTriangle")
  
  override init()  {
    super.init(texture: nil, color: nil, size: CGSize(64))
    userInteractionEnabled = true
    anchorPoint = CGPoint(1, 1)
    triangle.size = CGSize(16)
    triangle.anchorPoint = CGPoint(1, 1)
    triangle.alpha = 0.2
    addChild(triangle)
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    delegate?.menuTrianglePressed()
  }
}