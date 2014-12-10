//
//  ReportNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/8/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol ReportNodeDelegate: class {
  func reportNodeWasTapped()
}

class ReportNode: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var delegate: ReportNodeDelegate?
  let label = SmartLabel()

  override init() {
    super.init(texture: nil, color: Globals.highlightColor, size: CGSizeZero)
    userInteractionEnabled = true
    label.fontMedium()
    label.fontColor = Globals.backgroundColor
    label.text = "The Malevolence Engine\nsees all flaws!"
    addChild(label)
  }
  
  // MARK: - Touch Functions
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    delegate?.reportNodeWasTapped()
  }
  /*
  override var size: CGSize {
    didSet {
      
    }
  }
  */
  
}

