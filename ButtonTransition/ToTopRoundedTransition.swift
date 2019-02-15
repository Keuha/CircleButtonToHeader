//
//  ToTopRoundedTransition.swift
//  ButtonTransition
//
//  Created by Franck Petriz on 14/02/2019.
//  Copyright © 2019 Franck Petriz. All rights reserved.
//

import UIKit

class ToTopRoundedTransition: NSObject {
    
    enum ToTopRondedTransitionJob {
     case popover, dismiss, present
    }
    
    var originView = UIView()
    var startPoint: CGPoint = CGPoint.zero {
        didSet {
            originView.center = startPoint
        }
    }
    var destinationPoint : CGPoint?
    var originViewColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    
    var duration : Double = 0.5
    
    var currentTransitionMode : ToTopRondedTransitionJob = .present
    
    var yOffset : CGFloat {
        // height divided by two so the bottom of the circle will be exactly at the top of the view, but not visible anymore
        // so we drag the value a bit down the screen in order to be visible
        return -self.originView.frame.size.height / 2 + distanceFromTop + 12
    }
    
    var viewContraintDistance : CGFloat = 80.0 //equal to the second view controller view constraint top the top

    lazy var distanceFromTop : CGFloat = {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136, 1334, 1920, 2208:
                return viewContraintDistance
            case 2436, 2688, 1792:
               return viewContraintDistance + 24.0 //has notch so we had 24
            default:
                return viewContraintDistance
            }
        }
        return viewContraintDistance
    }()
        
    
}

extension ToTopRoundedTransition : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        // second view controller appearring
        if currentTransitionMode == .present {
            if let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
                let viewCenter = presentedView.center
                let viewSize = presentedView.frame.size
                
                originView = UIView()
                
                originView.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startPoint)
                
                originView.layer.cornerRadius = originView.frame.size.height / 2
                originView.center = startPoint
                originView.backgroundColor = originViewColor
                originView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                containerView.addSubview(originView)
                
                presentedView.center = startPoint
                presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                presentedView.alpha = 0
                containerView.addSubview(presentedView)
                containerView.backgroundColor = .clear
                
                UIView.animate(withDuration: duration, animations: {
                    
                    self.originView.transform =  CGAffineTransform(scaleX: 1, y: 1)
                    self.originView.center.x = viewCenter.x
                    self.originView.center.y = self.yOffset // we define center Y out of the view so we just see the bottom of the circle
                    presentedView.transform = CGAffineTransform.identity
                    presentedView.alpha = 1
                    presentedView.center = viewCenter
                     containerView.backgroundColor = .white
                    
                }, completion: { (success:Bool) in
                    transitionContext.completeTransition(success)
                })
            }
            
        }else{
              // second view controller disappearring
            let transitionModeKey = (currentTransitionMode == .popover) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
            
            if let returningView = transitionContext.view(forKey: transitionModeKey) {
                let viewCenter = returningView.center
                
                originView.layer.cornerRadius = originView.frame.size.height / 2
                originView.center.x = viewCenter.x
                originView.center.y = self.yOffset
                returningView.alpha = 1
                
                
                UIView.animate(withDuration: duration , animations: {
                    self.originView.center = self.startPoint
                    self.originView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    returningView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001) //this way, the second view controller disappear faster, avoiding weird visual effect during transition
                    returningView.center = self.startPoint
                    returningView.alpha = 0
                    
                    if self.currentTransitionMode == .popover {
                        containerView.insertSubview(returningView, belowSubview: returningView)
                        containerView.insertSubview(self.originView, belowSubview: returningView)
                    }
                    
                    
                }, completion: { (success:Bool) in
                    returningView.center = viewCenter
                    returningView.removeFromSuperview()
                    self.originView.removeFromSuperview()
                    transitionContext.completeTransition(success)
                    
                })
                
            }
            
            
        }
    }
    
    
    func frameForCircle (withViewCenter viewCenter:CGPoint, size viewSize:CGSize, startPoint:CGPoint) -> CGRect {
        let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
        let yLength = fmax(startPoint.y, viewSize.height - startPoint.y)
        
        let offset = min(yLength, xLength) * 3 // absolutely abritrary choosen after long iteration finding the best possible size
        let size = CGSize(width: offset, height: offset)
    
        return CGRect(origin: CGPoint.zero, size: size)
    }

}
