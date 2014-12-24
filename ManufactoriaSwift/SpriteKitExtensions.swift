//
//  SpriteKitExtensions.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/27/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

func distributeNodesX(nodes: [SKNode?], #childWidth: CGFloat, #parentWidth: CGFloat, roundPix roundPixBool: Bool) {
  let spacing: CGFloat = (parentWidth - CGFloat(nodes.count) * childWidth) / CGFloat(nodes.count + 1) + childWidth
  let offset: CGFloat = -0.5 * CGFloat(nodes.count - 1) * spacing
  for (i, node) in enumerate(nodes) {
    node?.position.x = roundPixBool ? roundPix(offset + CGFloat(i) * spacing) : (offset + CGFloat(i) * spacing)
  }
}

func distributeNodesY(nodes: [SKNode?], #childHeight: CGFloat, #parentHeight: CGFloat, roundPix roundPixBool: Bool) {
  let spacing: CGFloat = (parentHeight - CGFloat(nodes.count) * childHeight) / CGFloat(nodes.count + 1) + childHeight
  let offset: CGFloat = 0.5 * CGFloat(nodes.count - 1) * spacing
  for (i, node) in enumerate(nodes) {
    node?.position.y = roundPixBool ? roundPix(offset - CGFloat(i) * spacing) : (offset - CGFloat(i) * spacing)
  }
}

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

  func appearWithParent(newParent: SKNode, animate: Bool) {
    appearWithParent(newParent, animate: animate, delay: 0)
  }
  
  func appearWithParent(newParent: SKNode, animate: Bool, delay: NSTimeInterval) {
    if parent != newParent {
      removeFromParent()
      newParent.addChild(self)
    }
    let wait: SKAction? = delay > 0 ? SKAction.waitForDuration(delay) : nil
    if animate {
      alpha = 0
      let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.2)
      if let wait = wait {
        hidden = true
        runAction(SKAction.sequence([
          wait,
          SKAction.customActionWithDuration(0, actionBlock: {n,f in n.hidden = false}),
          fadeIn
          ]), withKey: "appearDisappear")
      } else {
        hidden = false
        runAction(SKAction.sequence([fadeIn]), withKey: "appearDisappear")
      }
    } else {
      alpha = 1
      if let wait = wait {
        hidden = true
        runAction(SKAction.sequence([
          wait,
          SKAction.customActionWithDuration(0, actionBlock: {n,f in n.hidden = false})
          ]), withKey: "appearDisappear")
      } else {
        hidden = false
        removeActionForKey("appearDisappear")
      }
    }
  }
  
  func disappearWithAnimate(animate: Bool) {
    disappearWithAnimate(animate, delay: 0)
  }

  func disappearWithAnimate(animate: Bool, delay: NSTimeInterval) {
    if parent == nil {return}
    let wait: SKAction? = delay > 0 ? SKAction.waitForDuration(delay) : nil
    if animate {
      let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.2)
      if let wait = wait {
        runAction(SKAction.sequence([wait, fadeOut, SKAction.removeFromParent()]), withKey: "appearDisappear")
      } else {
        runAction(SKAction.sequence([fadeOut, SKAction.removeFromParent()]), withKey: "appearDisappear")
      }
    } else {
      if let wait = wait {
        runAction(SKAction.sequence([wait, SKAction.removeFromParent()]), withKey: "appearDisappear")
      } else {
        removeActionForKey("appearDisappear")
        removeFromParent()
      }
    }
  }

}
 
extension SKSpriteNode {
  convenience init(imageNamed: String, color: UIColor) {
    self.init(texture: SKTexture(imageNamed: imageNamed))
    self.color = color
    colorBlendFactor = 1
  }
  convenience init(imageNamed: String, colorBlendFactor: CGFloat) {
    self.init(texture: SKTexture(imageNamed: imageNamed))
    self.colorBlendFactor = colorBlendFactor
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
  func fontSmall()  {fontSize = Globals.smallFontSize; fontName = Globals.smallFont}
  func fontMedium() {fontSize = Globals.mediumFontSize; fontName = Globals.mediumFont}
  func fontLarge()  {fontSize = Globals.largeFontSize; fontName = Globals.largeFont}
}