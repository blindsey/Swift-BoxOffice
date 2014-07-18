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
                    if !error {
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
        hud = MBProgressHUD.showHUDAddedTo(view, animated: true)

        let url = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=\(API_KEY)";
        let request = NSURLRequest(URL: NSURL(string: url))
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            if error {
                println("HTTP error: \(error.description)")
                return;
            }
            var error: NSError?
            let object = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error:&error) as? NSDictionary
            if let e = error {
                println("JSON error: \(e.description)")
            } else if let dict = object {
                if let e = dict["error"] as? String {
                    self.hud.mode = MBProgressHUDModeText
                    self.hud.labelText = e
                    self.hud.hide(true, afterDelay: 5.0)
                } else if let movies = dict["movies"] as? [NSDictionary] {
                    self.movies = movies
                    self.tableView.reloadData()
                    self.hud.hide(true)
                }
            }
        }
    }
}

