//
//  MenuTriangle.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/19/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol MenuTriangleDelegate {
  func menuTrianglePressed()
}

class MenuTriangle: SKSpriteNode {
  var delegate: MenuTriangleDelegate?
  
  init()  {
    let texture = SKTexture(imageNamed: "menuTriangle.png")
    super.init(texture: texture, color: UIColor(white: 0.25, alpha: 1.0), size: texture.size())
    self.colorBlendFactor = 1.0
    self.userInteractionEnabled = true
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    delegate?.menuTrianglePressed()
  }
}