//
//  DPTransparentEdgesTableView.swift
//  DPTransparentEdgesScrollViewExample
//
//  Created by Denis Prokopchuk on 03.07.14.
//  Copyright (c) 2014 Denis Prokopchuk. All rights reserved.
//

import UIKit
import QuartzCore

class DPTransparentEdgesScrollView: UIScrollView {
    var showTopMask = false
    var showBottomMask = false
    var bottomMaskDisabled = false
    var topMaskDisabled = false
    
    // Factor that describe length of the gradient
    // length = viewHeight * gradientFactor
    var gradientLengthFactor = 0.1
    
    init(frame: CGRect) {
        super.init(frame: frame)
        addObserver(self, forKeyPath: "contentOffset", options: nil, context: nil)
    }
    
    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
        addObserver(self, forKeyPath: "contentOffset", options: nil, context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: NSDictionary!, context: CMutableVoidPointer) {
        refresh()
    }
    
    func refresh() {
        let offsetY = contentOffset.y;
        if offsetY > 0 {
            if !showTopMask {
                showTopMask = true;
            }
        } else {
            showTopMask = false;
        }
        
        let bottomEdge = contentOffset.y + frame.size.height
        if bottomEdge >= contentSize.height {
            showBottomMask = false
        } else {
            if !showBottomMask {
                showBottomMask = true
            }
        }
        
        refreshGradient()
    }
    
    func refreshGradient() {
        // Creating our gradient mask
        let maskLayer = CAGradientLayer()
        
        // This is the anchor point for our gradient, in our case top left. setting it in the middle (.5, .5) will produce a radial gradient. our startPoint and endPoints are based off the anchorPoint
        maskLayer.anchorPoint = CGPointZero
        
        // The line between these two points is the line our gradient uses as a guide
        // Starts in bottom left
        maskLayer.startPoint = CGPointMake(0, 0)
        // Ends in top left
        maskLayer.endPoint = CGPointMake(0, 1)
        
        // Setting our colors - since this is a mask the color itself is irrelevant - all that matters is the alpha. A clear color will completely hide the layer we're masking, an alpha of 1.0 will completely show the masked view
        let outerColor = UIColor(white: 1.0, alpha: 0.0)
        let innerColor = UIColor(white: 1.0, alpha: 1.0)
        
        // Setting colors for maskLayer for each scrollView state
        if !showTopMask && !showBottomMask {
            maskLayer.colors = [innerColor.CGColor, innerColor.CGColor, innerColor.CGColor, innerColor.CGColor]
        } else if showTopMask && !showBottomMask {
            maskLayer.colors = [outerColor.CGColor, innerColor.CGColor, innerColor.CGColor, innerColor.CGColor]
        } else if !showTopMask && showBottomMask {
            maskLayer.colors = [innerColor.CGColor, innerColor.CGColor, innerColor.CGColor, outerColor.CGColor]
        } else if showTopMask && showBottomMask {
            maskLayer.colors = [outerColor.CGColor, innerColor.CGColor, innerColor.CGColor, outerColor.CGColor]
        }
        
        // Defining the location of each gradient stop. Top gradient runs from 0 to gradientLengthFactor, bottom gradient from 1 - gradientLengthFactor to 1.0
        if bottomMaskDisabled {
            maskLayer.locations = [0, gradientLengthFactor]
        } else if topMaskDisabled {
            maskLayer.locations = [0, 0, 1 - gradientLengthFactor, 1]
        }
        else {
            maskLayer.locations = [0, gradientLengthFactor, 1 - gradientLengthFactor, 1]
        }
        
        maskLayer.frame = bounds
        layer.masksToBounds = true;
        layer.mask = maskLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refresh()
    }
}