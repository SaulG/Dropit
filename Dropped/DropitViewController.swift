//
//  DroppedViewController.swift
//  Dropped
//
//  Created by saul on 06/07/15.
//  Copyright (c) 2015 SaulGausin. All rights reserved.
//

import UIKit

class DropitViewController: UIViewController, UIDynamicAnimatorDelegate
{
   //MARK: - Outlets
    
    @IBOutlet weak var gameView: BezierPathsView!
    
    
    // MARK: - Animation
    
    //load lazy: it is call asing to UIDynamicAnimator when is used the variable
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
    }()
    
    //custom dynamic behavior
    let dropitBehavior = DropitBehavior()
    
    var attachment: UIAttachmentBehavior? {
        willSet {
            animator.removeBehavior(attachment)
            gameView.setPath(nil, named: PathNames.Attachment)
        }
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment)
                attachment?.action = { [unowned self] in
                    if let attachedView = self.attachment?.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint(self.attachment!.anchorPoint)
                        path.addLineToPoint(attachedView.center)
                        self.gameView.setPath(path, named: PathNames.Attachment)
                    }
                }
            }
        }
    }


    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add the custom dynamic behavior to the superview
        animator.addBehavior(dropitBehavior)
    }
    
    // creates a circular barrier in the center of the gameView
    // the barrier is currently sized to be the same as the size of a drop
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let barrierSize = dropSize
        let barrierOrigin = CGPoint(x: gameView.bounds.midX-barrierSize.width/2, y: gameView.bounds.midY-barrierSize.height/2)
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
        dropitBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
        gameView.setPath(path, named: PathNames.MiddleBarrier)
    }
    
    
    // MARK: - UIDynamicAnimatorDelegate
    
    //if the animation stops, then remove the completed rows 
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
    // MARK: - Gestures
    
    @IBAction func drop(sender: UITapGestureRecognizer) {
        //call a function, to get computed properties, etc.
        drop()
    }
    
    @IBAction func grapDrop(sender: UIPanGestureRecognizer) {
        let gesturePoint = sender.locationInView(gameView)
        
        switch sender.state {
        case .Began:
            if let viewToAttachTo = lastDroppedView {
                attachment = UIAttachmentBehavior(item: viewToAttachTo, attachedToAnchor: gesturePoint)
                lastDroppedView = nil
            }
        case .Changed:
            attachment?.anchorPoint = gesturePoint
        case .Ended:
            attachment = nil
        default: break
        }
    }
    
    // MARK: - Dropping
    
    
    var dropsPerRow: Int = 10
    
    var dropSize: CGSize {
        let size = gameView.bounds.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }

    var lastDroppedView: UIView?
    
    func drop () {
        //set the origin of the frame and the size of the box
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        
        //take a random number from the extension CGFloat and set it in the axis x
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        //create a view with a frame
        let dropView = UIView(frame: frame)
        //set the backgroundcolor randomly, by using the extension
        dropView.backgroundColor = UIColor.random
        
        //asign the last drop view
        lastDroppedView = dropView
        
        //add drop to the view and behaviors
        dropitBehavior.addDrop(dropView)
        
    }

    
    // removes a single, completed row
    // allows for a little "wiggle room" for mostly complete rows
    // in the end, does nothing more than call removeDrop() in DropitBehavior
    
    func removeCompletedRow()
    {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize.width, height: dropSize.height)
        
        do {
            dropFrame.origin.y -= dropSize.height
            dropFrame.origin.x = 0
            var dropsFound = [UIView]()
            var rowIsComplete = true
            for _ in 0 ..< dropsPerRow {
                if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil) {
                    if hitView.superview == gameView {
                        dropsFound.append(hitView)
                    } else {
                        rowIsComplete = false
                    }
                }
                dropFrame.origin.x += dropSize.width
            }
            if rowIsComplete {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && dropFrame.origin.y > 0
        
        for drop in dropsToRemove {
            dropitBehavior.removeDrop(drop)
        }
    }
    
    
    //MARK: - Constants
    
    struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
}

//MARK: - Extensions

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}


private extension UIColor {
    class var random: UIColor {
        switch arc4random() % 5 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        default: return UIColor.blackColor()
        }
    }

}
