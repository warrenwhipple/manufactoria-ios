//
//  CoreGraphicsExtensions.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/19/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import CoreGraphics

extension CGRect {
  init(center: CGPoint, size: CGSize) {
    origin = CGPoint(x: center.x - 0.5 * size.width, y: center.y - 0.5 * size.height)
    self.size = size
  }
  init(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) {
    origin = CGPoint(x: centerX - 0.5 * width, y: centerY - 0.5 * height)
    self.size = CGSize(width: width, height: height)
  }
  var center: CGPoint {
    get {return CGPoint(x: origin.x + 0.5 * size.width, y: origin.y + 0.5 * size.height)}
    set {origin = CGPoint(x: newValue.x - 0.5 * size.width, y: newValue.y - 0.5 * size.height)}
  }
}

let CGSizeUnit = CGSize(width: 1.0, height: 1.0)

func + (left: CGPoint, right: CGPoint) -> CGPoint {return CGPoint(x: left.x + right.x, y: left.y + right.y)}
func - (left: CGPoint, right: CGPoint) -> CGPoint {return CGPoint(x: left.x - right.x, y: left.y - right.y)}
func + (left: CGSize, right: CGFloat) -> CGSize {return CGSize(width: left.width + right, height: left.height + right)}
func - (left: CGSize, right: CGFloat) -> CGSize {return CGSize(width: left.width - right, height: left.height - right)}
func * (left: CGSize, right: CGFloat) -> CGSize {return CGSize(width: left.width * right, height: left.height * right)}
func / (left: CGSize, right: CGFloat) -> CGSize {return CGSize(width: left.width / right, height: left.height / right)}