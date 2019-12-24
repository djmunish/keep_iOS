//
//  PhotoModel.swift
//  keep
//
//  Created by Ankur Sehdev on 22/12/19.
//  Copyright © 2019 Munish. All rights reserved.
//

import UIKit

class PhotoModel: NSObject {

    let image:UIImage?
    let imageName:String?
    let path:String?
    
    init(_ image:UIImage, _ imageName:String, _ path:String) {
        self.image = image
        self.imageName = imageName
        self.path = path
    }
}
