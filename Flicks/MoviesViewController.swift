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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var movies : [NSDictionary]?
    var AllMovies : [NSDictionary]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refreshData(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        searchView.showsCancelButton = true

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
                       
                        self.movies = (responseDictionary["results"] as! [NSDictionary])
                        self.AllMovies = (responseDictionary["results"] as! [NSDictionary])
                        
                        self.tableView.reloadData()
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        refreshControl.endRefreshing()
                        
                        self.errorView.isHidden = true
                        self.tableView.isHidden = false
                        self.searchView.isHidden = false
                        
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
        var votes = movie["vote_average"] as! Double
        votes = votes * 10.0
        let userScore = Int(votes)
        cell.userScore?.text = String(userScore) + "%"
        cell.posterView.setImageWith(posterFullURL!)
        //cell.selectionStyle = .none
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        
        return cell;
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailsViewController = segue.destination as! DetailsViewController
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        
        let movie = self.movies![indexPath.row];
        let backdropPath = movie["backdrop_path"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        let backdropFullURL =  URL(string: baseURL + backdropPath)
        
        detailsViewController.imageURL = backdropFullURL
        
        detailsViewController.titleLabelText = movie["title"] as! String
        detailsViewController.overviewLabelText = movie["overview"] as! String
        
        var votes = movie["vote_average"] as! Double
        votes = votes * 10.0
        let userScore = Int(votes)
        
        detailsViewController.scoreLabelText = String(userScore) + "%"
        
        let dateFormatterFromAPI = DateFormatter()
        dateFormatterFromAPI.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterDisplay = DateFormatter()
        dateFormatterDisplay.dateFormat = "MMM dd,yyyy"
        
        let releaseDate = movie["release_date"] as! String
        let date: Date? = dateFormatterFromAPI.date(from: releaseDate)
        
        detailsViewController.releaseDateLabelText = dateFormatterDisplay.string(from: date!)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchView.resignFirstResponder()
        
        self.movies = self.AllMovies?.filter() {
            let title = $0["title"] as? String
            if title?.lowercased().range(of:(searchBar.text?.lowercased())!) != nil{
                return true
            }
            return false
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.searchView.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.movies = self.AllMovies?.filter() {
            let title = $0["title"] as? String
            if title?.lowercased().range(of:(searchText.lowercased())) != nil{
                return true
            }
            return false
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            //self.searchView.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchView.resignFirstResponder()
        searchView.text = ""
        self.movies = self.AllMovies;
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.searchView.resignFirstResponder()
        }
    }
}
