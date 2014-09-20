//
//  GameViewController.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import UIKit
import SpriteKit

let IPAD: Bool = UIDevice.currentDevice().userInterfaceIdiom == .Pad

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    let skView = view as SKView
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.ignoresSiblingOrder = true
    skView.backgroundColor = Globals.backgroundColor
    skView.frameInterval = 1
    
    let scene = TitleScene(size: skView.bounds.size)
    scene.scaleMode = .AspectFill
    
    skView.presentScene(scene)
  }
  
  override func shouldAutorotate() -> Bool {
    return true
  }
  
  override func supportedInterfaceOrientations() -> Int {
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
      return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
    } else {
      return Int(UIInterfaceOrientationMask.All.toRaw())
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
}
