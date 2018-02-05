//
//  DraftViewController.swift
//  Notes
//
//  Created by Akshay on 2/6/18.
//  Copyright © 2018 Ganesh Potnuru. All rights reserved.
//

import UIKit

class DraftViewController: UIViewController {
    
    @IBOutlet var collectionView : UICollectionView?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.registerReusableCell(DraftCell.self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView?.reloadData()
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

extension DraftViewController:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:collectionView.frame.size.width/2,height:collectionView.frame.size.width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = DraftCell.dequeue(fromCollectionView: collectionView, atIndexPath: indexPath)
        cell.lblTitle?.text = "UserDefaults.standard.value(forKey: ) as? NSAttributedString UserDefaults.standard.value(forKey: ) as? NSAttributedString"
        return cell
    }
    
}

