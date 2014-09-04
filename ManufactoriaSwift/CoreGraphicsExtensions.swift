//
//  CoreGraphicsExtensions.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/19/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import CoreGraphics

extension CGSize {
  init(_ square: CGFloat) {
    width = square
    height = square
  }
  init(_ width: CGFloat, _ height: CGFloat) {
    self.width = width
    self.height = height
  }
  var center: CGPoint {
    get {return CGPoint(x: 0.5 * width, y: 0.5 * height)}
  }
}

extension CGPoint {
  init(_ x: CGFloat, _ y: CGFloat) {
    self.x = x
    self.y = y
  }
}

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

func CGPointDistSq(#p1: CGPoint, #p2: CGPoint) -> CGFloat {
  let dx = p1.x - p2.x
  let dy = p1.y - p2.y
  return dx * dx + dy * dy
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {return CGPoint(x: left.x + right.x, y: left.y + right.y)}
func - (left: CGPoint, right: CGPoint) -> CGPoint {return CGPoint(x: left.x - right.x, y: left.y - right.y)}
func * (left: CGPoint, right: CGFloat) -> CGPoint {return CGPoint(x: left.x * right, y: left.y * right)}
func * (left: CGFloat, right: CGPoint) -> CGPoint {return CGPoint(x: left * right.x, y: left * right.y)}
func / (left: CGPoint, right: CGFloat) -> CGPoint {return CGPoint(x: left.x / right, y: left.y / right)}
func / (left: CGFloat, right: CGPoint) -> CGPoint {return CGPoint(x: left / right.x, y: left / right.y)}

func * (left: CGSize, right: CGFloat) -> CGSize {return CGSize(width: left.width * right, height: left.height * right)}
func * (left: CGFloat, right: CGSize) -> CGSize {return CGSize(width: left * right.width, height: left * right.height)}
func / (left: CGSize, right: CGFloat) -> CGSize {return CGSize(width: left.width / right, height: left.height / right)}
func / (left: CGFloat, right: CGSize) -> CGSize {return CGSize(width: left / right.width, height: left / right.height)}