//
//  DraftCell.swift
//  Notes
//
//  Created by Akshay on 2/6/18.
//  Copyright © 2018 Ganesh Potnuru. All rights reserved.
//

import UIKit

class DraftCell: UICollectionViewCell {
    
    @IBOutlet var lblTitle : UILabel?
    
    internal static func dequeue(fromCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> DraftCell {
        guard let cell: DraftCell = collectionView.dequeueReusableCell(indexPath: indexPath) else {
            fatalError("*** Failed to dequeue TweetCell ***")
        }
        return cell
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
