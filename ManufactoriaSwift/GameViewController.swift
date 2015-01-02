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

/*
font sizes conversions for all HelveticaNeue
size 13 : 12em 9ex
size 19 : 16em 12ex
size 30 : 24em 18ex
size 52 : 40em 29ex
*/

struct Globals {
  static let iconSpan: CGFloat =       IPAD ? 64 : 36
  static let touchSpan: CGFloat =      IPAD ? 92 : 72
  static let smallFontSize: CGFloat =  IPAD ? 19 : 13
  static let mediumFontSize: CGFloat = IPAD ? 30 : 19
  static let largeFontSize: CGFloat =  IPAD ? 52 : 30
  static let smallFont =  IPAD ? "HelveticaNeue-Light"      : "HelveticaNeue"
  static let mediumFont = IPAD ? "HelveticaNeue-Thin"       : "HelveticaNeue-Light"
  static let largeFont =  IPAD ? "HelveticaNeue-UltraLight" : "HelveticaNeue-Thin"
  private(set) static var smallEm: CGFloat =  0
  private(set) static var mediumEm: CGFloat = 0
  private(set) static var largeEm: CGFloat =  0
  private(set) static var smallEx: CGFloat =  0
  private(set) static var mediumEx: CGFloat = 0
  private(set) static var largeEx: CGFloat =  0
  private(set) static var yellowColor =     UIColor(hue: 0.15, saturation: 1.0, brightness: 0.9, alpha: 1)
  private(set) static var greenColor =      UIColor(hue: 0.40, saturation: 1.0, brightness: 0.85, alpha: 1)
  private(set) static var blueColor =       UIColor(hue: 0.60, saturation: 1.0, brightness: 1.0, alpha: 1)
  private(set) static var redColor =        UIColor(hue: 0.95, saturation: 1.0, brightness: 1.0, alpha: 1)
  private(set) static var strokeColor =     UIColor(hue: 0.90, saturation: 1.0, brightness: 0.4, alpha: 1)
  private(set) static var highlightColor =  UIColor(hue: 0.90, saturation: 1.0, brightness: 1.0, alpha: 1)
  private(set) static var backgroundColor = UIColor.whiteColor()
  static let testCount =       1000
  static let loopTickCount =   10000
  static let loopTapeLength =  1000
  static let disappearTime: NSTimeInterval = 0.4
  static let appearDelay: NSTimeInterval = 0.6
  static let appearTime: NSTimeInterval = 0.2
  static let disappearAppearGapTime: NSTimeInterval = 0.2
}

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    
    let testLabel = SKLabelNode()
    testLabel.text = "M"
    testLabel.fontSmall()
    Globals.smallEm = testLabel.frame.height
    testLabel.fontMedium()
    Globals.mediumEm = testLabel.frame.height
    testLabel.fontLarge()
    Globals.largeEm = testLabel.frame.height
    testLabel.text = "x"
    testLabel.fontSmall()
    Globals.smallEx = testLabel.frame.height
    testLabel.fontMedium()
    Globals.mediumEx = testLabel.frame.height
    testLabel.fontLarge()
    Globals.largeEx = testLabel.frame.height
    
    super.viewDidLoad()
    let skView = view as SKView
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.ignoresSiblingOrder = false
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
      return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    } else {
      return Int(UIInterfaceOrientationMask.All.rawValue)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
}
