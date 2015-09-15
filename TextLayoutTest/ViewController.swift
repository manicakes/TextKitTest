//
//  ViewController.swift
//  TextLayoutTest
//
//  Created by Mani Ghasemlou on 2015-09-12.
//  Copyright © 2015 Mani Ghasemlou. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var layoutManager : NSLayoutManager!
    var textStore : NSTextStorage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let myString = try NSString(contentsOfURL: NSBundle.mainBundle().URLForResource("Text", withExtension: "txt")!, encoding: NSUTF8StringEncoding)
            let attrString = NSAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleBody) ])
            
            textStore = NSTextStorage(attributedString: attrString)
            layoutManager = NSLayoutManager()
            textStore.addLayoutManager(layoutManager)
        } catch {
            NSLog("Error loading string from file.")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutTextContainers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutTextContainers() {
        // first determine how many columns based on size class.
        let horizontalSizeClass = self.traitCollection.horizontalSizeClass
        var numColumns : Int
        
        switch (horizontalSizeClass) {
        case UIUserInterfaceSizeClass.Compact:
            numColumns = 1
        case UIUserInterfaceSizeClass.Regular:
            numColumns = 2
        default:
            numColumns = 2
        }
        
        // first blow away existing containers
        self.scrollView.subviews.forEach { (aView : UIView) -> () in
            if let textView = aView as? UITextView {
                textView.removeFromSuperview()
                if let indexOfContainer = self.layoutManager.textContainers.indexOf(textView.textContainer) {
                    self.layoutManager.removeTextContainerAtIndex(indexOfContainer)
                }
            }
        }
        self.scrollView.contentSize = self.scrollView.bounds.size
        self.pageControl.currentPage = 0
        
        var lastRenderedGlyph : Int = 0
        var currentXOffset : CGFloat = 0.0
        var numTextViews = 0
        
        while lastRenderedGlyph < layoutManager.numberOfGlyphs {
            let textViewFrame = CGRectMake(currentXOffset, 0,
                CGRectGetWidth(self.view.bounds) / CGFloat(numColumns),
                CGRectGetHeight(self.view.bounds))
            let textContainer = NSTextContainer(size: textViewFrame.size)
            layoutManager.addTextContainer(textContainer)
            let textView = UITextView(frame: textViewFrame, textContainer: textContainer)
            textView.textContainerInset = UIEdgeInsetsMake(20, 20, 60, 20)
            textView.scrollEnabled = false
            textView.backgroundColor = self.view.backgroundColor
            numTextViews += 1
            scrollView.addSubview(textView)
            
            // Increase the current offset
            currentXOffset += CGRectGetWidth(textViewFrame)
            
            // And find the index of the glyph we've just rendered
            lastRenderedGlyph = NSMaxRange(layoutManager.glyphRangeForTextContainer(textContainer))
        }
        
        // add an empty space to make sure we fill a full page for last page
        if numTextViews % numColumns != 0 {
            let textViewFrame = CGRectMake(currentXOffset, 0,
                CGRectGetWidth(self.view.bounds) / CGFloat(numColumns),
                CGRectGetHeight(self.view.bounds))
            currentXOffset += CGRectGetWidth(textViewFrame)
        }
        
        // update scrollview size
        let contentSize = CGSizeMake(currentXOffset, CGRectGetHeight(self.scrollView.bounds))
        self.scrollView.contentSize = contentSize
        self.pageControl.numberOfPages = Int(scrollView.contentSize.width / scrollView.bounds.width)
    }
    
    // MARK - UIScrollViewDelegate
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {

    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let xPos = scrollView.contentOffset.x+10
        
        //Calculate the page we are on based on x coordinate position and width of scroll view
        let value = Int(xPos/width)
        pageControl.currentPage = value
    }
    
}

