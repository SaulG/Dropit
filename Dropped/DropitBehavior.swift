//
//  DropitBehavior.swift
//  Dropped
//
//  Created by saul on 06/07/15.
//  Copyright (c) 2015 SaulGausin. All rights reserved.
//

import UIKit

class DropitBehavior: UIDynamicBehavior
{
    //initialize reference of gravity behavior for animations
    let gravity = UIGravityBehavior()
    
    lazy var collision: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        
        //set the reference bounds of the main view to animate into bounday
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = true
        return lazilyCreatedCollider
        }()

    lazy var dropBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedDropBehavior = UIDynamicItemBehavior()
        lazilyCreatedDropBehavior.allowsRotation = false
        lazilyCreatedDropBehavior.elasticity = 0.75
        return lazilyCreatedDropBehavior
    }()
    
    override init() {
        super.init()
        //add to the superview the following behaviors
        addChildBehavior(gravity)
        addChildBehavior(collision)
        addChildBehavior(dropBehavior)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collision.removeBoundaryWithIdentifier(name)
        collision.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addDrop(drop: UIView) {
        //add drop to the superview
        dynamicAnimator?.referenceView?.addSubview(drop)
        
        //add the following behaviors to drop
        gravity.addItem(drop)
        collision.addItem(drop)
        dropBehavior.addItem(drop)
    }
    
    func removeDrop(drop: UIView) {
        //remove the following behaviors from drop
        gravity.removeItem(drop)
        collision.removeItem(drop)
        dropBehavior.removeItem(drop) 
        
        //remove drop from the superview
        drop.removeFromSuperview()
    }
}
