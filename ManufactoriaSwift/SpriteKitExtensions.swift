//
//  SpriteKitExtensions.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/27/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

extension UIColor {
  func blend(color: UIColor, var blendFactor: CGFloat) -> UIColor {
    let f2 = max(0, min(1, blendFactor))
    let f1 = 1 - f2
    var r1, g1, b1, a1, r2, g2, b2, a2: CGFloat
    r1=0; g1=0; b1=0; a1=0; r2=0; g2=0; b2=0; a2=0
    getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    return UIColor(
      red:   r1 * f1 + r2 * f2,
      green: g1 * f1 + g2 * f2,
      blue:  b1 * f1 + b2 * f2,
      alpha: a1 * f1 + a2 * f2
    )
  }
}

extension SKNode {
  func addChildren(nodes: [SKNode]) {
    for node in nodes {
      addChild(node)
    }
  }
}
 
extension SKSpriteNode {
  convenience init(_ string: String) {
    self.init(texture: SKTexture(imageNamed: string))
    color = Globals.strokeColor
    colorBlendFactor = 1
  }
}

extension SKAction {
  func ease() -> SKAction {timingMode = .EaseInEaseOut; return self}
  func easeIn() -> SKAction {timingMode = .EaseIn; return self}
  func easeOut() -> SKAction {timingMode = .EaseOut; return self}
}

extension SKTransition {
  func outPlay() -> SKTransition {pausesOutgoingScene = false; return self}
  func inPlay() -> SKTransition {pausesIncomingScene = false; return self}
  func outInPlay() -> SKTransition {pausesOutgoingScene = false; pausesIncomingScene = false; return self}
}

extension SKLabelNode {
  //func fontSmall()  {fontSize = 16; fontName = "HelveticaNeue-Light"}
  func fontMedium() {fontSize = 17; fontName = "HelveticaNeue-Light"}
  func fontLarge()  {fontSize = 28; fontName = "HelveticaNeue-Thin"}
}

extension BreakingLabel {
  //func fontSmall()  {fontSize = 16; fontName = "HelveticaNeue-Light"}
  func fontMedium() {fontSize = 17; fontName = "HelveticaNeue-Light"}
  func fontLarge()  {fontSize = 28; fontName = "HelveticaNeue-Thin"}
}