//
//  BeltFlowController.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 1/4/15.
//  Copyright (c) 2015 Warren Whipple. All rights reserved.
//

import SpriteKit

class BeltFlowController {
  private let gridArea: GridArea
  private var flowPercent: CGFloat = 0
  private var flowVelocity: CGFloat = 0.25
  
  init(gridArea: GridArea) {
    self.gridArea = gridArea
  }
  
  func update(dt: NSTimeInterval) -> CGFloat {
    flowPercent += CGFloat(dt) * flowVelocity
    while flowPercent >= 1 {flowPercent -= 1}
    return flowPercent
  }
  
  func startFlow() {
    if flowVelocity == 0.25 {
      gridArea.removeActionForKey("startStopFlow")
      return
    }
    gridArea.runAction(SKAction.customActionWithDuration(1) {
      [unowned self] node, t in
      self.flowVelocity = t * 0.25
      }, withKey: "startStopFlow")
  }
  
  func stopFlow() {
    if flowVelocity == 0 {
      gridArea.removeActionForKey("startStopFlow")
      return
    }
    flowVelocity = 0
    if flowPercent < 0.375 {flowPercent += 0.5}
    else if flowPercent >= 0.875 {flowPercent -= 0.5}
    let p0 = flowPercent
    let t1 = (0.875 - flowPercent) * 4
    let t2 = t1 + 1
    gridArea.runAction(SKAction.customActionWithDuration(NSTimeInterval(t2)) {
      [unowned self] node, t in
      if t < t1 {
        self.flowPercent = p0 + t * 0.25
      } else if t < t2 {
        self.flowPercent = 0.875 + easeOut(t - t1) * 0.125
      } else {
        self.flowPercent = 0
      }
      }, withKey: "startStopFlow")
  }
}