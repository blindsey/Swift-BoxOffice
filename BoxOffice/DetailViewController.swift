//
//  DetailViewController.swift
//  BoxOffice
//
//  Created by Ben Lindsey on 7/14/14.
//  Copyright (c) 2014 Ben Lindsey. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var posterImageView: UIImageView
    @IBOutlet var scrollView: UIScrollView
    @IBOutlet var synopsisLabel: UILabel
    @IBOutlet var titleLabel: UILabel

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let dict = detailItem as? NSDictionary {
            self.title = dict["title"] as? String
            if let label = titleLabel {
                label.text = dict["title"] as? String
            }
            if let label = synopsisLabel {
                label.text = dict["synopsis"] as? String
                label.sizeToFit();
                scrollView.contentSize = CGSize(width: 320, height: CGRectGetMaxY(label.frame))
            }
            if let view = posterImageView {
                if let posters = dict["posters"] as? NSDictionary {
                    if let thumb = posters["thumbnail"] as? String {
                        view.image = UIImage(data: NSData(contentsOfURL: NSURL(string: thumb)))
                        let original = thumb.stringByReplacingOccurrencesOfString("tmb", withString: "ori", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        let request = NSURLRequest(URL: NSURL(string: original))
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
                            UIView.transitionWithView(view, duration: 1.0, options: .TransitionCrossDissolve, animations: {
                                view.image = UIImage(data: data)
                            }, completion: nil)
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}