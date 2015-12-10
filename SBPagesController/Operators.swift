//
//  Operators.swift
//  Shop
//
//  Created by Salim Braksa on 11/18/15.
//  Copyright © 2015 Braksa. All rights reserved.
//

import UIKit

infix operator %% {}

func %% (left: CGFloat, right: CGFloat) -> CGFloat {
    
    // Self explanatory
    let fraction = left / right
    
    // Test if the fraction is an integer
    if floor(fraction) != fraction {
        return left % right
    }
    
    // If it's no the case, return this
    return left == 0 ? 0 : left / fraction
    
}
