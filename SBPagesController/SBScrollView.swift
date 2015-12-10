//
//  SBScrollView.swift
//  Shop
//
//  Created by Salim Braksa on 11/14/15.
//  Copyright © 2015 Braksa. All rights reserved.
//

import UIKit

enum Direction {
   
   case RightToLeft
   case LeftToRight
   case None
   
}

protocol SBScrollViewDelegate: UIScrollViewDelegate {
   
   func movingFromIndex(fromIndex: Int, toIndex: Int, progress: Double)
   
   func willMoveFromIndex(fromIndex: Int, toIndex: Int)
   
}

class SBScrollView: UIScrollView {
   
   /// Self explanatory
   var scrollDirection: Direction = .None
   
   /// Check if the scroll is initially interactive
   var scrollInitiallyInteractive: Bool {
      return decelerating || dragging || tracking
   }
   
   weak var sb_delegate: SBScrollViewDelegate?
   
   // I prefered using closures instead of a custom delegate
   var willMoveFromIndex: ((fromIndex: Int, toIndex: Int) -> ())?
   var movingFromIndex: ( (fromIndex: Int, toIndex: Int, progress: Double) -> () )?
   
   // MARK: Observation
   
   var reverseProgress = false
   override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
      
      if keyPath == "contentOffset" {
         
         // Accessing old x and new x
         guard
            let oldX = (change?["old"] as? NSValue)?.CGPointValue().x,
            let newX = (change?["new"] as? NSValue)?.CGPointValue().x
            else { return }
         
         // Setting direction
         switch (oldX, newX) {
         case let (old, new) where old > new: scrollDirection = .LeftToRight
         case let (old, new) where old < new: scrollDirection = .RightToLeft
         default: scrollDirection = .None
         }
         
         if scrollDirection == .None || !scrollInitiallyInteractive { return }
         
         // Fractions
         let oldFraction = oldX / bounds.width
         let newFraction = newX / bounds.width
         let multiplier = floor(max(oldFraction, newFraction))
         
         // Indexes
         let fromIndex: Int
         let toIndex: Int
         if scrollDirection == .RightToLeft {
            fromIndex = Int(ceil(oldFraction))
            toIndex = Int(ceil(newFraction))
         } else {
            fromIndex = Int(floor(oldFraction))
            toIndex = Int(floor(newFraction))
         }
         
         // Condition
         let condition: Bool
         if scrollDirection == .RightToLeft {
            condition = multiplier * bounds.width < newX && oldX <= multiplier * bounds.width
         } else {
            condition = multiplier * bounds.width <= oldX && newX < multiplier * bounds.width
         }
         
         if condition {
            reverseProgress = scrollDirection == .LeftToRight
            willMoveFromIndex?(fromIndex: fromIndex, toIndex: toIndex)
         }
         
         // Calculate progress
         let modulo = scrollDirection == .LeftToRight ? ( newX % bounds.width ) : ( newX %% bounds.width )
         var progress = modulo / bounds.width
         if reverseProgress {
            progress = 1 - progress
         }
         movingFromIndex?(fromIndex: fromIndex, toIndex: toIndex, progress: Double(progress))
      }
      
   }
   
}
