//
//  MenuTriangle.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/19/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

/*
@class_protocol protocol MenuTriangleDelegate {
  func menuTrianglePressed()
}
*/

class MenuTriangle: SKSpriteNode {
  weak var delegate: GameScene?
  var triangle = SKSpriteNode(texture: SKTexture(imageNamed: "menuTriangle.png"))
  
  init()  {
    super.init(texture: nil, color: nil, size: CGSize(width: 64, height: 64))
    userInteractionEnabled = true
    anchorPoint = CGPoint(x: 1, y: 1)
    triangle.size = CGSize(width: 16, height: 16)
    triangle.anchorPoint = CGPoint(x: 1, y: 1)
    triangle.alpha = 0.2
    addChild(triangle)
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    delegate?.menuTrianglePressed()
  }
}