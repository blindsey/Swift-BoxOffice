//
//  MasterViewController.swift
//  BoxOffice
//
//  Created by Ben Lindsey on 7/14/14.
//  Copyright (c) 2014 Ben Lindsey. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var hud: MBProgressHUD = MBProgressHUD()
    var movies : [Dictionary<String, AnyObject>] = []

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        fetchMovies()
    }

    // #pragma mark - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let movie = movies[indexPath.row]
            (segue.destinationViewController as DetailViewController).detailItem = movie["synopsis"].description
        }
    }

    // #pragma mark - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let movie = movies[indexPath.row]
        cell.textLabel.text = movie["title"].description
        return cell
    }

    // #pragma mark - Private

    func fetchMovies() {
        let url = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=g9au4hv6khv6wzvzgt55gpqs";
        let request = NSURLRequest(URL: NSURL(string: url))
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            if error {
                NSLog("%@", error)
            } else {
                var error: NSError?
                var object : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error:&error)
                if object is NSDictionary {
                    if object["error"] {
                        self.hud.mode = MBProgressHUDModeText
                        self.hud.labelText = object["error"].description
                        self.hud.hide(true, afterDelay: 5)
                    } else {
                        self.movies = object["movies"] as [Dictionary<String, AnyObject>]
                        self.tableView.reloadData()
                        self.hud.hide(true)
                    }
                } else {
                    NSLog("Unexpected object %@ %@", error.description, object.description);
                }
            }
        }
    }
}

