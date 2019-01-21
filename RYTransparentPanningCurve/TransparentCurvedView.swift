//
//  TransparentCurvedView.swift
//  TestSwift
//
//  Created by Rahul Yadav on 18/10/18.
//  Copyright © 2018 Rahul Yadav. All rights reserved.
//

import Foundation
import UIKit

fileprivate let kImage_arrow    =   "arrow"
let kImageSize:CGFloat  =   10.5
let kCurvedHeightFraction_initial:CGFloat   =   0.55
let kAnimation_duration_curved_layer:Double = 0.5

@IBDesignable
class TransparentCurvedView: UIView {
    
    var curvedLayer:CAShapeLayer!   // reference to existing curved layer. Used to replace it with new one.
    @IBOutlet weak var height:NSLayoutConstraint!
    var imageLayerParent:CALayer!
    var imageLayer:CALayer!
    lazy var image:CGImage = {
       
        return UIImage(named: kImage_arrow, in: Bundle(for: TransparentCurvedView.self), compatibleWith: nil)!.cgImage!
    }()
    lazy var imageWidth:CGFloat = {
        
        return Utility.dynamicSizePerScreen(for: kImageSize)
    }()

    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        
    }
    
    override func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        
//        applyLayersInitially()
    }
    
    func returnCurvedHeight(from deviation:CGFloat) -> CGFloat{
        
        return frame.height * (kCurvedHeightFraction_initial * (1 - deviation))
    }
    
    /**
     I apply the 2 layers viz. curved and image initially.
     */
    func applyLayersInitially(){
        
        // Add white curved layer
        
        curvedLayer = returnCurvedLayer(withDeviation: 0)
        layer.addSublayer(curvedLayer)
        
        // Add arrow image layer
        
        imageLayerParent = returnImageLayer(withDeviation: 0)
        layer.addSublayer(imageLayerParent)
    }
    
    /**
     I update existing curved layer and image layer's position
     @param withDeviation   -   it is in fraction. 0 means no deviation i.e initial state while 1 means complete deviation.
     */
    func updateExistingCurvedLayer(withDeviation deviation:CGFloat){
        
        let newCurvedPath = returnCurvedPath(deviation: deviation)
        curvedLayer.path = newCurvedPath.cgPath
        
        let newImageLayerParent = returnImageLayer(withDeviation: deviation)
        // To move the arrow quickly, we are replacing the layer instead of updating existing layer
        layer.replaceSublayer(imageLayerParent, with: newImageLayerParent)
        imageLayerParent = newImageLayerParent
    }
    
    /**
     Create curved layer and return it
     @param withDeviation   -   it is in fraction. 0 means no deviation i.e initial state while 1 means complete deviation.
     */
    func returnCurvedLayer(withDeviation deviation:CGFloat) -> CAShapeLayer{
     
        let path = returnCurvedPath(deviation: deviation)
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        
        return layer
    }
    
    /**
     @discussion I create and return curved path
     @param deviation   -   curve deviation 0 at center and 1 at top
     @return curved path in this deviation
 */
    func returnCurvedPath(deviation: CGFloat) -> UIBezierPath{
        
        let viewHeight = frame.height
        let curveHeight = viewHeight * (kCurvedHeightFraction_initial * (1 - deviation))
        let viewWidth = frame.width
        print("viewHeight: \(viewHeight), curvedHeight: \(curveHeight)")
        // Draw white curved layer
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: viewHeight))
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        path.addLine(to: CGPoint(x: viewWidth, y: 0))
        
        let controlPoint1X:CGFloat = viewWidth * ( 1 + (0.015 * (1.0 + deviation)))
        let controlPoint1Y:CGFloat = viewHeight * (0.05 * (1 - deviation))
        let controlPoint1:CGPoint = CGPoint(x: controlPoint1X, y: controlPoint1Y)
        
        let controlPoint2X:CGFloat = viewWidth * ( 0.5 + (0.25 * (1.0 + deviation)))
        let controlPoint2Y:CGFloat = curveHeight
        let controlPoint2:CGPoint = CGPoint(x: controlPoint2X, y: controlPoint2Y)
        
        path.addCurve(to: CGPoint(x: viewWidth/2, y: curveHeight), controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        let controlPoint3X:CGFloat = viewWidth * (0.25 * (1 - deviation))
        let controlPoint3Y:CGFloat = curveHeight
        let controlPoint3:CGPoint = CGPoint(x: controlPoint3X, y: controlPoint3Y)
        
        let controlPoint4X:CGFloat = -viewWidth * (0.015 * (1 + deviation))
        let controlPoint4Y:CGFloat = viewHeight * (0.05 * (1 - deviation))
        let controlPoint4:CGPoint = CGPoint(x: controlPoint4X, y: controlPoint4Y)
        
        path.addCurve(to: CGPoint(x: 0, y: 0), controlPoint1: controlPoint3, controlPoint2: controlPoint4)
        
        path.close()
        
        return path
    }
    
//    /**
//     Updates image layer's position
//     @param withDeviation   -   it is in fraction. 0 means no deviation i.e initial state while 1 means complete deviation.
//     */
//    func updateImageLayerPosition(withDeviation deviation:CGFloat){
//
//        let viewHeight = frame.height
//        let curveHeight = viewHeight * (kCurvedHeightFraction_initial * (1 - deviation))
//        let viewWidth = frame.width
//
//        let viewBottomHeight:CGFloat = viewHeight - curveHeight
//        let imageWidth:CGFloat = Utility.dynamicSizePerScreen(for: kImageSize)
//        let imageLayerCenterX:CGFloat = (viewWidth/2)
//        let imageLayerCenterY:CGFloat = curveHeight + (viewBottomHeight/2)
//
//        imageLayerParent.bounds.origin = CGPoint(x: imageLayerCenterX, y: imageLayerCenterY)
//        imageLayerParent.bounds.size = CGSize(width: imageWidth, height: imageWidth)
//        imageLayerParent.position = CGPoint(x: imageLayerCenterX, y: imageLayerCenterY)
//
//        imageLayer.frame = imageLayerParent.bounds  // Important. Bounds will not work.
//    }
    
    /**
     I create image layer and return it
     @param withDeviation   -   it is in fraction. 0 means no deviation i.e initial state while 1 means complete deviation.
     @return image parent layer
    */
    func returnImageLayer(withDeviation deviation:CGFloat) -> CALayer{

        let viewHeight = frame.height
        let curveHeight = viewHeight * (kCurvedHeightFraction_initial * (1 - deviation))
        let viewWidth = frame.width
        
        let viewBottomHeight:CGFloat = viewHeight - curveHeight
        let imageWidth:CGFloat = Utility.dynamicSizePerScreen(for: kImageSize)
        let imageLayerCenterX:CGFloat = (viewWidth/2)
        let imageLayerCenterY:CGFloat = curveHeight + (viewBottomHeight/2)
        
        imageLayer = CALayer()
        imageLayer.contents = image
        imageLayer.contentsGravity = CALayerContentsGravity.resizeAspect
        
        let imageLayerParent = CALayer()
        imageLayerParent.bounds.origin = CGPoint(x: imageLayerCenterX, y: imageLayerCenterY)
        imageLayerParent.bounds.size = CGSize(width: imageWidth, height: imageWidth)
        imageLayerParent.position = CGPoint(x: imageLayerCenterX, y: imageLayerCenterY)
        imageLayerParent.backgroundColor = UIColor(red: 0, green: 164.0/255, blue: 255.0/255, alpha: 1).cgColor
        imageLayerParent.mask = imageLayer
        
        imageLayer.frame = imageLayerParent.bounds  // Important. Bounds will not work.
        
        return imageLayerParent
    }
    
    /**
     Lets animate the curve layer
     
     Basically used to complete the curve movement through code
     
     - parameter deviation: curve deviation
     */
    func animateLayer(with deviation:CGFloat){
        
        let newCurvedPath = returnCurvedPath(deviation: deviation)  // deviation is hard coded
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = kAnimation_duration_curved_layer
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fromValue = curvedLayer.path
        animation.toValue = newCurvedPath.cgPath
        curvedLayer.add(animation, forKey: nil)
        
        curvedLayer.path = newCurvedPath.cgPath
    }
    
    /**
     Lets animate the image layer
     
     Basically used to complete the curve movement through code
     
     - parameter deviation: curve deviation
     */
    func animateImageLayer(with deviation:CGFloat){
        
        let curvedHeight = returnCurvedHeight(from: deviation)
        let viewBottomHeight = frame.height - curvedHeight
        
        let imageLayerCenterX:CGFloat = (frame.width/2)
        let imageLayerCenterY:CGFloat = curvedHeight + (viewBottomHeight/2)
        let newPosition = CGPoint(x: imageLayerCenterX, y: imageLayerCenterY)
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = kAnimation_duration_curved_layer
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fromValue = imageLayerParent.position
        animation.toValue = newPosition
        
        imageLayerParent.position = newPosition
        
        imageLayerParent.add(animation, forKey: nil)
    }
}
