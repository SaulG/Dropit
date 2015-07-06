//
//  BezierPathsView.swift
//  Dropped
//
//  Created by saul on 06/07/15.
//  Copyright (c) 2015 SaulGausin. All rights reserved.
//

import UIKit

class BezierPathsView: UIView
{
    
    private var bezierPaths = [String:UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }
    
}
