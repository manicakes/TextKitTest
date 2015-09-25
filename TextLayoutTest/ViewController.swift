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
//            let myString = try NSString(contentsOfURL: NSBundle.mainBundle().URLForResource("Text", withExtension: "txt")!, encoding: NSUTF8StringEncoding)
//            let ppStyle = NSMutableParagraphStyle()
//            ppStyle.alignment = NSTextAlignment.Justified
//            ppStyle.firstLineHeadIndent = CGFloat(20.0)
//            let attrString = NSAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSParagraphStyleAttributeName:ppStyle, NSForegroundColorAttributeName:UIColor.blackColor(), NSBackgroundColorAttributeName:UIColor.whiteColor()])
//            
//            textStore = NSTextStorage(attributedString: attrString)
//            layoutManager = NSLayoutManager()
//            textStore.addLayoutManager(layoutManager)
            let articleDict : [String:String] = NSDictionary(contentsOfURL: NSBundle.mainBundle().URLForResource("Article", withExtension: "plist")!) as! [String:String]
            let headlineStr = articleDict["headline"]! + "\n"
            let subheadStr = articleDict["subhead"]! + "\n\n"
            let authorStr = articleDict["author"]
            let dateStr = articleDict["date"]
            let bodyStr = articleDict["body"]
            
            let headline = NSAttributedString(string: headlineStr, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1), NSForegroundColorAttributeName:UIColor.blueColor()])
            let subhead = NSAttributedString(string: subheadStr, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)])
            let ppStyle = NSMutableParagraphStyle()
            ppStyle.alignment = NSTextAlignment.Justified
            ppStyle.firstLineHeadIndent = CGFloat(20.0)
            let body = NSAttributedString(string: bodyStr!, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSParagraphStyleAttributeName:ppStyle])
            
            var article = NSMutableAttributedString(attributedString: headline)
            article.appendAttributedString(subhead)
            article.appendAttributedString(body)

            textStore = NSTextStorage(attributedString: article)
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
    
    class func numColumnsForViewSize(viewSize : CGSize) -> Int {
        var numColumns = 1
        let minColumnWidth : CGFloat = 240
        let maxColumnWidth : CGFloat = 320
        
        while (viewSize.width/(CGFloat(numColumns + 1)) > minColumnWidth
            && viewSize.width/CGFloat(numColumns) > maxColumnWidth) {
            ++numColumns
        }
        
        return numColumns
    }
    
    func layoutTextContainers() {
        // first determine how many columns based on size class.
        let numColumns = ViewController.numColumnsForViewSize(self.scrollView.bounds.size)
        
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
            textView.textContainerInset = UIEdgeInsetsMake(10, 10, 50, 10)
            textView.scrollEnabled = false
            textView.backgroundColor = self.view.backgroundColor
            numTextViews += 1
            scrollView.addSubview(textView)
            
            // Increase the current offset
            currentXOffset += CGRectGetWidth(textViewFrame)
            
            // And find the index of the glyph we've just rendered
            lastRenderedGlyph = NSMaxRange(layoutManager.glyphRangeForTextContainer(textContainer))
        }
        
        // add empty spaces to make sure we fill a full page for last page
        let modulo = numTextViews % numColumns
        if modulo != 0 {
            let textViewFrame = CGRectMake(currentXOffset, 0,
                CGRectGetWidth(self.view.bounds) / CGFloat(numColumns),
                CGRectGetHeight(self.view.bounds))
            currentXOffset += CGRectGetWidth(textViewFrame) * CGFloat(numColumns - modulo)
        }
        
        // update scrollview size
        let contentSize = CGSizeMake(currentXOffset, CGRectGetHeight(self.scrollView.bounds))
        self.scrollView.contentSize = contentSize
        self.pageControl.numberOfPages = Int((scrollView.contentSize.width+1) / scrollView.bounds.width)
    }
    
    // MARK - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let xPos = scrollView.contentOffset.x+1
        
        //Calculate the page we are on based on x coordinate position and width of scroll view
        let value = Int(xPos/width)
        pageControl.currentPage = value
    }
    
}

