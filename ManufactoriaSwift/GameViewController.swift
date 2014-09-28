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

struct Globals {
  static var iconSpan: CGFloat = 36
  static var touchSpan: CGFloat = 72
  static var yellowColor =     UIColor(hue: 0.15, saturation: 1.0, brightness: 0.9, alpha: 1)
  static var greenColor =      UIColor(hue: 0.40, saturation: 1.0, brightness: 0.85, alpha: 1)
  static var blueColor =       UIColor(hue: 0.60, saturation: 1.0, brightness: 1.0, alpha: 1)
  static var redColor =        UIColor(hue: 0.95, saturation: 1.0, brightness: 1.0, alpha: 1)
  static var strokeColor =     UIColor(hue: 0.90, saturation: 1.0, brightness: 0.4, alpha: 1)
  static var highlightColor =  UIColor(hue: 0.90, saturation: 1.0, brightness: 1.0, alpha: 1)
  static var backgroundColor = UIColor.whiteColor()
  static var testCount =       1000
  static var loopTickCount =   10000
  static var loopTapeLength =  500
  static var smallFontSize: CGFloat =  12.5
  static var mediumFontSize: CGFloat = 17.1
  static var largeFontSize: CGFloat =  26.3
  static var smallFont =  "HelveticaNeue"
  static var mediumFont = "HelveticaNeue-Light"
  static var largeFont =  "HelveticaNeue-Thin"
  static var smallEm: CGFloat =  0
  static var mediumEm: CGFloat = 0
  static var largeEm: CGFloat =  0
}

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    
    if IPAD {
      Globals.iconSpan = 64
      Globals.touchSpan = 92
      Globals.smallFontSize = 17.1
      Globals.mediumFontSize = 26.3
      Globals.largeFontSize = 51.2
      Globals.smallFont = "HelveticaNeue-Light"
      Globals.mediumFont = "HelveticaNeue-Thin"
      Globals.largeFont = "HelveticaNeue-UltraLight"
    }
    
    let emLabel = SKLabelNode()
    emLabel.text = "M"
    emLabel.fontSmall()
    Globals.smallEm = emLabel.frame.size.height
    emLabel.fontMedium()
    Globals.mediumEm = emLabel.frame.size.height
    emLabel.fontLarge()
    Globals.largeEm = emLabel.frame.size.height
    
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
