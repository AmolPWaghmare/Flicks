//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Waghmare, Amol on 01/04/17.
//  Copyright © 2017 Waghmare, Amol. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var movies : [NSDictionary]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refreshData(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)

        getData(refreshControl);
    }
    
    func refreshData(_ refreshControl: UIRefreshControl) {
        self.errorView.isHidden = true
        getData(refreshControl)
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func getData(_ refreshControl: UIRefreshControl) {
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        //print("responseDictionary: \(responseDictionary)")
                        
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        self.movies = (responseDictionary["results"] as! [NSDictionary])
                        
                        self.tableView.reloadData()
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        refreshControl.endRefreshing()
                        
                        self.errorView.isHidden = true
                        self.tableView.isHidden = false
                        
                        // This is where you will store the returned array of posts in your posts property
                        // self.feeds = responseFieldDictionary["posts"] as! [NSDictionary]
                    }
                }
                else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.errorView.isHidden = false
                }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = self.movies![indexPath.row];
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        let posterFullURL = URL(string: baseURL + posterPath)
        
        cell.titleLabel?.text = title
        cell.overviewLabel?.text = overview
        cell.posterView.setImageWith(posterFullURL!)
        return cell;
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailsViewController = segue.destination as! DetailsViewController
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        
        let movie = self.movies![indexPath.row];
        let backdropPath = movie["backdrop_path"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        let backdropFullURL =  URL(string: baseURL + backdropPath)
        
        detailsViewController.imageURL = backdropFullURL
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
