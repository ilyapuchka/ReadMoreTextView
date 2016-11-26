//
//  ViewController.swift
//  ReadMoreTextView
//
//  Created by Ilya Puchka on 06.04.15.
//  Copyright (c) 2015 Ilya Puchka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var readMoreTextView: ReadMoreTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        readMoreTextView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        readMoreTextView.attributedReadMoreText = NSAttributedString(string: "Read more", attributes: [
            NSForegroundColorAttributeName: view.tintColor,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)
            ])
        readMoreTextView.attributedReadLessText = NSAttributedString(string: "Read less", attributes: [
            NSForegroundColorAttributeName: UIColor.red,
            NSFontAttributeName: UIFont.italicSystemFont(ofSize: 16)
            ])
        readMoreTextView.maximumNumberOfLines = 6
        readMoreTextView.shouldTrim = true
    }

    @IBAction func toggleTrim(_ sender: UIButton) {
        readMoreTextView.shouldTrim = !readMoreTextView.shouldTrim
    }
    
}

