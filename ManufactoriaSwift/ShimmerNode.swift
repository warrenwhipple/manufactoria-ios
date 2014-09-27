//
//  ShimmerNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/20/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class ShimmerNode: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}

  var alphaMin: CGFloat = 0 {didSet {if alphaMin < 0 {alphaMin = 0} else if alphaMin > alphaMax {alphaMin = alphaMax}}}
  var alphaMax: CGFloat = 0.1 {didSet {if alphaMax > 1 {alphaMax = 1} else if alphaMax < alphaMin {alphaMax = alphaMin}}}
  var shimmerSpeed: CGFloat = 1 {didSet {if shimmerSpeed < 0 {shimmerSpeed = 0}}}
  var isShimmering: Bool {get {return actionForKey("shimmer") != nil}}

  convenience override init() {self.init(texture: nil, color: Globals.strokeColor, size: CGSizeZero)}
  convenience init(size: CGSize) {self.init(texture: nil, color: Globals.strokeColor, size: size)}
  
  override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
    alpha = alphaMin
  }
  
  func startShimmer() {
    if isShimmering {return}
    if alpha < alphaMin {alpha = alphaMin}
    else if alpha > alphaMax {alpha = alphaMax}
    if alpha > 0 {
      if randBool() {
        let shimmerAlpha = randCGFloat(alphaMax - alpha) + alpha
        runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(shimmerAlpha, duration: NSTimeInterval((shimmerAlpha - alpha) * 32 / shimmerSpeed)),
          SKAction.fadeAlphaTo(alphaMin, duration: NSTimeInterval((shimmerAlpha - alphaMin) * 32 / shimmerSpeed)),
          SKAction.runBlock({[unowned self] in self.repeatShimmer()})
          ]), withKey: "shimmer")
      } else {
        runAction(SKAction.sequence([
          SKAction.fadeAlphaTo(alphaMin, duration: NSTimeInterval(alpha * 32 / shimmerSpeed)),
          SKAction.runBlock({[unowned self] in self.repeatShimmer()})
          ]), withKey: "shimmer")
      }
    } else {
      repeatShimmer()
    }
  }
  
  func startMidShimmer() {
    removeActionForKey("shimmer")
    alpha = randCGFloat(alphaMax)
    startShimmer()
  }
  
  func stopShimmer() {
    removeActionForKey("shimmer")
    if alpha > alphaMin {
      runAction(SKAction.fadeAlphaTo(alphaMin, duration: NSTimeInterval((alpha - alphaMin) * 32 / shimmerSpeed)))
    }
  }
  
  private func repeatShimmer() {
    let shimmerAlpha = randCGFloat(alphaMax - alphaMin) + alphaMin
    let shimmerDuration = NSTimeInterval(shimmerAlpha * 32 / shimmerSpeed)
    runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(shimmerAlpha, duration: shimmerDuration),
      SKAction.fadeAlphaTo(alphaMin, duration: shimmerDuration),
      SKAction.runBlock({[unowned self] in self.repeatShimmer()})
      ]), withKey: "shimmer")
  }
}