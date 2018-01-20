//
//  DPTransparentEdgesTableView.swift
//  DPTransparentEdgesScrollViewExample
//
//  Created by Denis Prokopchuk on 03.07.14.
//  Copyright (c) 2014 Denis Prokopchuk. All rights reserved.
//

import UIKit
import QuartzCore

class DPTransparentEdgesTableView: UITableView {
    var showTopMask = false
    var showBottomMask = false
    var bottomMaskDisabled = false
    var topMaskDisabled = false
    
    // Factor that describe length of the gradient
    // length = viewHeight * gradientFactor
    var gradientLengthFactor = 0.1
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        addObserver(self, forKeyPath: "contentOffset", options: .init(rawValue: 0), context: nil)
    }
    
    //    init(frame: CGRect) {
    //        super.init(frame: frame)
    //        addObserver(self, forKeyPath: "contentOffset", options: nil, context: nil)
    //    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        addObserver(self, forKeyPath: "contentOffset", options: .init(rawValue: 0), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
        maskLayer.anchorPoint = CGPoint.zero
        
        // The line between these two points is the line our gradient uses as a guide
        // Starts in bottom left
        maskLayer.startPoint = CGPoint(x : 0, y : 0)
        // Ends in top left
        maskLayer.endPoint = CGPoint(x : 0, y : 1)
        
        // Setting our colors - since this is a mask the color itself is irrelevant - all that matters is the alpha. A clear color will completely hide the layer we're masking, an alpha of 1.0 will completely show the masked view
        let outerColor = UIColor.clear.withAlphaComponent(0.0)
        let innerColor = UIColor.black.withAlphaComponent(1.0)

        // Setting colors for maskLayer for each scrollView state
        if !showTopMask && !showBottomMask {
            maskLayer.colors = [innerColor.cgColor, innerColor.cgColor, innerColor.cgColor, innerColor.cgColor]
        } else if showTopMask && !showBottomMask {
            maskLayer.colors = [outerColor.cgColor, innerColor.cgColor, innerColor.cgColor, innerColor.cgColor]
        } else if !showTopMask && showBottomMask {
            maskLayer.colors = [innerColor.cgColor, innerColor.cgColor, innerColor.cgColor, outerColor.cgColor]
        } else if showTopMask && showBottomMask {
            maskLayer.colors = [outerColor.cgColor, innerColor.cgColor, innerColor.cgColor, outerColor.cgColor]
        }
        
        // Defining the location of each gradient stop. Top gradient runs from 0 to gradientLengthFactor, bottom gradient from 1 - gradientLengthFactor to 1.0
        if bottomMaskDisabled {
            maskLayer.locations = [0, NSNumber(value : gradientLengthFactor)]
        } else if topMaskDisabled {
            maskLayer.locations = [0, 0, NSNumber( value : 1 - gradientLengthFactor), 1]
        }
        else {
            maskLayer.locations = [0, NSNumber(value : gradientLengthFactor), NSNumber(value : 1 - gradientLengthFactor), 1]
        }
        
        maskLayer.frame = bounds
        layer.masksToBounds = true;
        layer.mask = maskLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

