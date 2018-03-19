//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Mrunal Bhatt on 3/14/18.
//  Copyright © 2018 Sonal. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController
{

    var memeImage : Meme!
    
    
    @IBOutlet weak var imageViewMeme: UIImageView!
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.imageViewMeme.image = memeImage.imageMemed
        
    }

}
