//
//  MasterViewController.swift
//  BoxOffice
//
//  Created by Ben Lindsey on 7/14/14.
//  Copyright (c) 2014 Ben Lindsey. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    let API_KEY = "esm6sfwy2f2x8brqh3gv6ukk"

    var hud = MBProgressHUD()
    var movies = [NSDictionary]()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()

        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "fetchBoxOffice", forControlEvents: UIControlEvents.ValueChanged)
        fetchBoxOffice()
    }

    // #pragma mark - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            (segue.destinationViewController as DetailViewController).detailItem = movies[indexPath.row]
        }
    }

    // #pragma mark - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let movie = movies[indexPath.row]
        cell.detailTextLabel.text = movie["synopsis"] as? String
        cell.textLabel.text = movie["title"] as? String

        if let posters = movie["posters"] as? NSDictionary {
            if let thumb = posters["thumbnail"] as? String {
                let request = NSURLRequest(URL: NSURL(string: thumb))
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
                    if data {
                        cell.imageView.image = UIImage(data: data)
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        return cell
    }

    // #pragma mark - Private

    func fetchBoxOffice() {
        self.refreshControl.endRefreshing()
        hud = MBProgressHUD.showHUDAddedTo(view, animated: true)

        var url : String
        if self.tabBarController.tabBar.selectedItem.title == "Box Office" {
            url = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=\(API_KEY)";
        } else {
            url = "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=\(API_KEY)";
        }
        let request = NSURLRequest(URL: NSURL(string: url))
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            self.hud.hide(true)
            if error {
                println(error.description)
                return self.displayError("Network Error")
            }
            var error: NSError?
            let object = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error:&error) as? NSDictionary
            if let e = error {
                println(e.description)
                return self.displayError("Error parsing JSON")
            } else if let dict = object {
                if let e = dict["error"] as? String {
                    self.displayError(e)
                } else if let movies = dict["movies"] as? [NSDictionary] {
                    self.movies = movies
                    self.tableView.reloadData()
                }
            }
        }
    }

    func displayError(error: String) {
        let label = UILabel(frame: CGRect(x: 0, y: -44, width:320, height: 44))
        label.text = "⚠️ \(error)"
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.blackColor()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.alpha = 0.8
        label.textAlignment = .Center
        self.view.addSubview(label)
        UIView.animateWithDuration(2.0, animations: {
            label.frame.origin.y = 0
        }, completion: { completed in
            UIView.animateWithDuration(2.0, animations: {
                label.alpha = 0
            }, completion: { completed in
                label.removeFromSuperview()
            })
        })
    }
}

