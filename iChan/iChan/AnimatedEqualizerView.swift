//
//  AnimatedEqualizerView.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/18/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class AnimatedEqualizerView: UIView {

    var containerView: UIView! // this is our view inside storyboard
    let containerLayer = CALayer() // this is a container for all other layers

    var childLayers = [CALayer]() // we will store animated layers inside an array
    let lowBezierPath = UIBezierPath() // to create animation, we use a path as original shape
    let middleBezierPath = UIBezierPath() // our lines will animate low, or high to create random effect
    let highBezierPath = UIBezierPath() // and this is high position of animation

    var animations = [CABasicAnimation]() // finally, an array to store animation objects

    init(containerView: UIView) { //custom initializer
        self.containerView = containerView // reference to container view
        super.init(frame: containerView.frame) // then call super initializer
        self.initCommon() // a function for common init
        self.initContainerLayer() // init the container layer
        self.initBezierPath() // init all paths
        self.initBars() // init child layers which will draw lines
        self.initAnimation() // init animation objects
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initCommon() {
        self.frame = CGRect(x: 0, y: 0, width: containerView!.frame.size.width, height: containerView!.frame.size.height)
    }
    
    func initContainerLayer() {
        containerLayer.frame = CGRect(x: 0, y: 0, width: 60, height: 65)
        containerLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        containerLayer.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.layer.addSublayer(containerLayer)
    }
    
    func initBezierPath() {
        lowBezierPath.move(to: CGPoint(x: 0, y: 55))
        lowBezierPath.addLine(to: CGPoint(x: 0, y: 65))
        lowBezierPath.addLine(to: CGPoint(x: 3, y: 65))
        lowBezierPath.addLine(to: CGPoint(x: 3, y: 55))
        lowBezierPath.addLine(to: CGPoint(x: 0, y: 55))
        lowBezierPath.close()

        middleBezierPath.move(to: CGPoint(x: 0, y: 15));
        middleBezierPath.addLine(to: CGPoint(x: 0, y: 65));
        middleBezierPath.addLine(to: CGPoint(x: 3, y: 65));
        middleBezierPath.addLine(to: CGPoint(x: 3, y: 15));
        middleBezierPath.addLine(to: CGPoint(x: 0, y: 15));
        middleBezierPath.close();
        
        highBezierPath.move(to: CGPoint(x: 0, y: 0));
        highBezierPath.addLine(to: CGPoint(x: 0, y: 65));
        highBezierPath.addLine(to: CGPoint(x: 3, y: 65));
        highBezierPath.addLine(to: CGPoint(x: 3, y: 0));
        highBezierPath.addLine(to: CGPoint(x: 0, y: 0));
        highBezierPath.close();
    }
    
    func initBars() {
        for index in 0...4 {
            let bar = CAShapeLayer()
            bar.frame = CGRect(x: CGFloat(15 * index), y: 0, width: 3, height: 65)
            bar.path = lowBezierPath.cgPath
            bar.fillColor = UIColor.white.cgColor
            containerLayer.addSublayer(bar)
            childLayers.append(bar)
        }
    }

    func initAnimation() {
        for index in 0...4 {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = lowBezierPath.cgPath
            if (index % 2 == 0) {
                animation.toValue = middleBezierPath.cgPath
            } else {
                animation.toValue = highBezierPath.cgPath
            }
            animation.autoreverses = true
            animation.duration = 0.5
            animation.repeatCount = MAXFLOAT
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.77, 0, 0.175, 1)
            animations.append(animation)
        }
    }
    
    func animate() {
        for index in 0...4 {
            let delay = 0.1 * Double(index)
            let deadlineTime = DispatchTime.now() + delay
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.addAnimation(index: index)
            }
        }
    }
    
    func addAnimation(index: Int) {
        let animationKey = "\(index)Animation"
        childLayers[index].add(animations[index], forKey: animationKey)
    }
}
