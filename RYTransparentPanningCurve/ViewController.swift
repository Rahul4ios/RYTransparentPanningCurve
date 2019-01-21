//
//  ViewController.swift
//  TestSwift
//
//  Created by Rahul Yadav on 23/03/18.
//  Copyright © 2018 Rahul Yadav. All rights reserved.
//

import UIKit

let kChildBtm_view_height_fraction:CGFloat  =   0.45
let kMiddleSwipeView_height_fraction:CGFloat    =   0.1
fileprivate let panFractionalDistanceFinal:CGFloat  =   0.35    // if user moves his finger by this distance, we treat it as final so we complete the pending movement if he lifts his finger.

class ViewController: UIViewController {

    @IBOutlet weak var middleView: TransparentCurvedView!
    @IBOutlet weak var middleViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var middleViewHeight: NSLayoutConstraint!
    var middleViewHeightMultiplierInitial:CGFloat!
    static var firstTimeFlagViewDidLayout = true
    static var previousPanUpDistance:CGPoint!  // used to save previous distance during pan up
    static var panInitialDirectionUp = true
    var ignorePan   =   false   // we ignore pan when:
                                //  1. initial direction is downwards and middle view is centered
                                //  or
                                //  2. initial direction is upwards and middle view is not visible
    var maxMiddleViewHeight:CGFloat!    // when it is centered
    var isMiddleViewHidden = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if ViewController.firstTimeFlagViewDidLayout {
            
            initialConfig()
            
            ViewController.firstTimeFlagViewDidLayout = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK -   initial configuration
    
    func initialConfig(){
        
        view.layoutIfNeeded()
        
        // Middle view
        configureMiddleView()
    }
    
    // MARK -   Middle view
    
    func configureMiddleView(){
        
        middleViewHeightMultiplierInitial = middleViewHeight.multiplier
        
        middleView.applyLayersInitially()
        
        maxMiddleViewHeight = middleView.frame.height
    }
    
    /**
     @discussion lets animate the middle curve
     
     Basically used to complete the curve movement through code
     
     - parameter deviation: curve deviation
     */
    func animateMiddleView(with deviation:CGFloat){

        CATransaction.begin()
        UIView.animate(withDuration: kAnimation_duration_curved_layer) {

            [unowned self] in

            self.view.removeConstraint(self.middleViewHeight)

            let middleViewHeightUpdatedMultiplier = self.middleViewHeightMultiplierInitial * ( 1 - deviation)
            let middleViewUpdatedHeight = NSLayoutConstraint(item: self.middleView, attribute: .height, relatedBy: .equal, toItem: self.middleView.superview, attribute: .width, multiplier: middleViewHeightUpdatedMultiplier, constant: 0)
            self.view.addConstraint(middleViewUpdatedHeight)
            self.middleViewHeight = middleViewUpdatedHeight
            
            print("Height multiplier = \(middleViewHeightUpdatedMultiplier)")
            print("Curve deviation = \(deviation)")
            
            self.isMiddleViewHidden = (deviation == 1) ? true : false
            
            self.view.layoutIfNeeded()
            
            self.middleView.animateLayer(with: deviation)
            self.middleView.animateImageLayer(with: deviation)

        }
        CATransaction.commit()
    }
    
    // MARK -   Pan gesture
    
    @IBAction func panGestureRecog(_ sender: UIPanGestureRecognizer) {
        
        let distance = sender.translation(in: view)
        
        print("\n")
        print(sender.state.rawValue)
        print(distance)
        print("Velocity === \(sender.velocity(in: view!))")

        if sender.state == .began {
            // gesture just started
            
            ViewController.panInitialDirectionUp = (sender.velocity(in: view!).y < 0.0) ? true : false
            print("Is initial direction up = \(ViewController.panInitialDirectionUp)")
            
            ignorePan = (((ViewController.panInitialDirectionUp == true) && (isMiddleViewHidden == true)) || ((ViewController.panInitialDirectionUp == false) && (isMiddleViewHidden == false)))
            
            ViewController.previousPanUpDistance = CGPoint(x: 0, y: 0)
        }
        if ignorePan {
            // Case: ignore
            
            print("Ignored pan")
            return
        }
        
        let ignoreThis = ((ViewController.panInitialDirectionUp && (distance.y > 0.0)) || ((ViewController.panInitialDirectionUp == false) && (distance.y < 0.0))) && (sender.state == .changed)
        if ignoreThis {
            // Case: ignore this position. Continue to listen to next position.
            //      1. (Initial direction was up and now finger has gone below the initial position
            //          or
            //      2. Initial direction was downwards and now finger has gone above the initial position)
            //          and
            //          (pan is in progress. We need to process when pan ends to move the curve completely)
            
            print("Ignoring this position")
            return
        }
        
        let maxPanDistance = view.frame.height/2//((view.frame.height/2) + (middleView.frame.height/2))
            
        if (sender.state == .ended) || abs(distance.y) <= maxPanDistance{
            // Case: pan ends
            //      or
            //      pan distance is <= half of the superview
            
            print("we can handle this position")
            
            var middleViewNewCenterY:CGFloat = 0.0
            var curveDeviation:CGFloat! // we take the initial curve as reference, so increase in deviation will reduce the curve and vice-versa
            let middleViewHiddenCenterY = -(view.frame.height/2)
            
            if sender.state == .ended {
                // Case: stopped
                
                // we complete the movement when initial and final direction is same
                let finalDirectionEligible4Completion = (ViewController.panInitialDirectionUp && (distance.y < 0.0)) || ((!ViewController.panInitialDirectionUp) && (distance.y > 0.0))
                
                if (abs(distance.y) >= (maxPanDistance * panFractionalDistanceFinal)) && finalDirectionEligible4Completion{
                    // Case: lets complete the movement ourself
                    
                    middleViewNewCenterY =  ViewController.panInitialDirectionUp ? middleViewHiddenCenterY : 0
                    curveDeviation = ViewController.panInitialDirectionUp ? 1 : (1 - 1)
                }
                else{
                    // Case: lets undo the movement
                    
                    middleViewNewCenterY =  ViewController.panInitialDirectionUp ? 0 : middleViewHiddenCenterY
                    curveDeviation = ViewController.panInitialDirectionUp ? 0 : (1 - 0)
                }
            }
            else{
                // Case: in progress
                
                middleViewNewCenterY =  ViewController.panInitialDirectionUp ? distance.y : (middleViewHiddenCenterY + distance.y)
                let curveDeviation4Up:CGFloat = abs(distance.y)/(view.frame.height/2)
                curveDeviation = ViewController.panInitialDirectionUp ? curveDeviation4Up : (1 - curveDeviation4Up)
            }
            
            print("New centerY === \(middleViewNewCenterY)")
            // move middle view
            middleViewCenterY.constant = middleViewNewCenterY
            
            let minMiddleViewHeight:CGFloat = Utility.dynamicSizePerScreen(for: kImageSize)

            let isMiddleViewHeightAtLimit = ViewController.panInitialDirectionUp ? (middleView.frame.height <= minMiddleViewHeight) : (middleView.frame.height >= maxMiddleViewHeight)
            
            if ((sender.state == .ended) || isMiddleViewHeightAtLimit == false) || (abs(distance.y) < abs(ViewController.previousPanUpDistance.y)){
                // Case: we have room for more layer update:
                //      pan is ended
                //          or
                //      limit is not yet reached
                //          or
                //      movement has just started in opposite direction
                
                print("Lets update the curve")
                
                if sender.state != .ended{
                
                    // adjust height of middle view
                    view.removeConstraint(middleViewHeight)
                    
                    let middleViewHeightUpdatedMultiplier = middleViewHeightMultiplierInitial * ( 1 - curveDeviation)
                    let middleViewUpdatedHeight = NSLayoutConstraint(item: middleView, attribute: .height, relatedBy: .equal, toItem: middleView.superview, attribute: .width, multiplier: middleViewHeightUpdatedMultiplier, constant: 0)
                    view.addConstraint(middleViewUpdatedHeight)
                    middleViewHeight = middleViewUpdatedHeight
                    view.layoutIfNeeded()
                    print("Height multiplier = \(middleViewHeightUpdatedMultiplier)")
                    
                    print("Curve deviation = \(curveDeviation!)")
                    // update the curved layer
                    middleView.updateExistingCurvedLayer(withDeviation: curveDeviation)
                    
                    isMiddleViewHidden = (middleViewNewCenterY == middleViewHiddenCenterY) ? true : false
                }
                else{
                    // Case: we need to complete the animation ourself

                    animateMiddleView(with: curveDeviation)
                }
            }
        }
        
        ViewController.previousPanUpDistance = distance
    }
    
}

