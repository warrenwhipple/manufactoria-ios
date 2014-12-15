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
  var shimmerDurationMax: NSTimeInterval = 4 {didSet {if shimmerDurationMax < 0 {shimmerDurationMax = 0}}}
  var isShimmering: Bool {return actionForKey("shimmer") != nil}

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
    if alpha == alphaMin {
      runAction(SKAction.sequence([
        SKAction.waitForDuration(NSTimeInterval(randCGFloat(CGFloat(shimmerDurationMax)))),
        SKAction.runBlock({[unowned self] in self.repeatShimmer()})
        ]), withKey: "shimmer")
    } else if randBool() {
      let shimmerAlpha = randCGFloat(alphaMax - alpha) + alpha
      let alphaGap = alphaMax - alphaMin
      runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(shimmerAlpha, duration: NSTimeInterval((shimmerAlpha - alpha) / alphaGap) * shimmerDurationMax),
        SKAction.fadeAlphaTo(alphaMin, duration: NSTimeInterval((shimmerAlpha - alphaMin) / alphaGap) * shimmerDurationMax),
        SKAction.runBlock({[unowned self] in self.repeatShimmer()})
        ]), withKey: "shimmer")
    } else {
      runAction(SKAction.sequence([
        SKAction.fadeAlphaTo(alphaMin, duration: NSTimeInterval((alpha - alphaMin) / (alphaMax - alphaMin)) * shimmerDurationMax),
        SKAction.runBlock({[unowned self] in self.repeatShimmer()})
        ]), withKey: "shimmer")
    }
  }
  
  func startMidShimmer() {
    removeActionForKey("shimmer")
    alpha = randCGFloat(alphaMax - alphaMin) + alphaMin
    startShimmer()
  }
  
  func stopShimmer() {
    removeActionForKey("shimmer")
    if alpha > alphaMin {
      runAction(SKAction.fadeAlphaTo(alphaMin, duration:NSTimeInterval((alpha - alphaMin) / (alphaMax - alphaMin)) * shimmerDurationMax))
    }
  }
  
  func zeroShimmer() {
    removeActionForKey("shimmer")
    alpha = 0
  }
  
  private func repeatShimmer() {
    let alphaGap = alphaMax - alphaMin
    let alphaAdd = randCGFloat(alphaGap)
    let shimmerDuration = NSTimeInterval(alphaAdd / alphaGap) * shimmerDurationMax
    runAction(SKAction.sequence([
      SKAction.fadeAlphaTo(alphaMin + alphaAdd, duration: shimmerDuration),
      SKAction.fadeAlphaTo(alphaMin, duration: shimmerDuration),
      SKAction.runBlock({[unowned self] in self.repeatShimmer()})
      ]), withKey: "shimmer")
  }
}