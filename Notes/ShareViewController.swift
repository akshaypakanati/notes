//
//  ShareViewController.swift
//  JanaSenaPost
//
//  Created by Akshay on 12/26/17.
//  Copyright © 2017 iOS. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {

    @IBOutlet private var previewImageView : UIImageView?
    var previewImage : UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewImageView?.image = previewImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
 
    @IBAction func tweetTapped(_ sender:UIButton) {
        if let image = previewImage {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)

        }
        
    }

}
