//
//  ViewController.swift
//  ReadMoreTextView
//
//  Created by Ilya Puchka on 06.04.15.
//  Copyright (c) 2015 Ilya Puchka. All rights reserved.
//

import UIKit
import ReadMoreTextView

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topReadMoreTextView: ReadMoreTextView!
    @IBOutlet weak var readMoreTextView: ReadMoreTextView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 100
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        readMoreTextView.text = "Lorem http://ipsum.com dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        #if swift(>=3.0)
            let readMoreTextAttributes: [String: Any] = [
                NSForegroundColorAttributeName: view.tintColor,
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)
            ]
            let readLessTextAttributes = [
                NSForegroundColorAttributeName: UIColor.red,
                NSFontAttributeName: UIFont.italicSystemFont(ofSize: 16)
            ]
        #else
            let readMoreTextAttributes = [
                NSForegroundColorAttributeName: view.tintColor,
                NSFontAttributeName: UIFont.boldSystemFontOfSize(16)
            ]
            let readLessTextAttributes = [
                NSForegroundColorAttributeName: UIColor.redColor(),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(16)
            ]
        #endif
        readMoreTextView.attributedReadMoreText = NSAttributedString(string: "... Read more", attributes: readMoreTextAttributes)
        readMoreTextView.attributedReadLessText = NSAttributedString(string: " Read less", attributes: readLessTextAttributes)
        readMoreTextView.maximumNumberOfLines = 6
        readMoreTextView.shouldTrim = true
    }

    override func viewDidLayoutSubviews() {
        tableView.reloadData()
    }

    var expandedCells = Set<Int>()

    #if swift(>=3.0)
    @IBAction func toggleTrim(_ sender: UIButton) {
        readMoreTextView.shouldTrim = !readMoreTextView.shouldTrim
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadMoreCell", for: indexPath)
        let readMoreTextView = cell.contentView.viewWithTag(1) as! ReadMoreTextView
        readMoreTextView.shouldTrim = !expandedCells.contains(indexPath.row)
        readMoreTextView.setNeedsUpdateTrim()
        readMoreTextView.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let readMoreTextView = cell.contentView.viewWithTag(1) as! ReadMoreTextView
        readMoreTextView.onSizeChange = { [unowned tableView, unowned self] r in
            let point = tableView.convert(r.bounds.origin, from: r)
            guard let indexPath = tableView.indexPathForRow(at: point) else { return }
            if r.shouldTrim {
                self.expandedCells.remove(indexPath.row)
            } else {
                self.expandedCells.insert(indexPath.row)
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        let readMoreTextView = cell.contentView.viewWithTag(1) as! ReadMoreTextView
        readMoreTextView.shouldTrim = !readMoreTextView.shouldTrim
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: {_ in
            self.readMoreTextView.setNeedsUpdateTrim()
            self.topReadMoreTextView.setNeedsUpdateTrim()
        }, completion: nil)
    }
    
    #else
    @IBAction func toggleTrim(sender: UIButton) {
        readMoreTextView.shouldTrim = !readMoreTextView.shouldTrim
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReadMoreCell", forIndexPath: indexPath)
        let readMoreTextView = cell.contentView.viewWithTag(1) as! ReadMoreTextView
        readMoreTextView.shouldTrim = !expandedCells.contains(indexPath.row)
        readMoreTextView.setNeedsUpdateTrim()
        readMoreTextView.layoutIfNeeded()
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let readMoreTextView = cell.contentView.viewWithTag(1) as! ReadMoreTextView
        readMoreTextView.onSizeChange = { [unowned tableView, unowned self] r in
            let point = tableView.convertPoint(r.bounds.origin, fromView: r)
            guard let indexPath = tableView.indexPathForRowAtPoint(point) else { return }
            if r.shouldTrim {
                self.expandedCells.remove(indexPath.row)
            } else {
                self.expandedCells.insert(indexPath.row)
            }
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let readMoreTextView = cell?.contentView.viewWithTag(1) as! ReadMoreTextView
        readMoreTextView.shouldTrim = !readMoreTextView.shouldTrim
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({_ in
            self.readMoreTextView.setNeedsUpdateTrim()
            self.topReadMoreTextView.setNeedsUpdateTrim()
            }, completion: nil)
    }
    
    #endif
    
}

class ReadMoreCell : UITableViewCell {
    
    @IBOutlet weak var readMoreTextView: ReadMoreTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        readMoreTextView.onSizeChange = { _ in }
        readMoreTextView.shouldTrim = true
    }
    
}
