//
//  DetailsViewController.swift
//  Flicks
//
//  Created by Waghmare, Amol on 01/04/17.
//  Copyright © 2017 Waghmare, Amol. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var backdropImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    var imageURL : URL!
    var titleLabelText : String!
    var scoreLabelText : String!
    var overviewLabelText : String!
    var releaseDateLabelText : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backdropImage.setImageWith(imageURL)
        
        titleLabel?.text = titleLabelText
        scoreLabel?.text = scoreLabelText
        overviewLabel?.text = overviewLabelText
        releaseDateLabel?.text = releaseDateLabelText
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
