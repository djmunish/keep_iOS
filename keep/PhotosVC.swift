//
//  PhotosVC.swift
//  keep
//
//  Created by Ankur Sehdev on 21/12/19.
//  Copyright © 2019 Munish. All rights reserved.
//

import UIKit

class photocell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    
}

class PhotosVC: UIViewController ,UICollectionViewDelegate , UICollectionViewDataSource{

    var updateList:(() -> Void)?
    var imageArray = [PhotoModel]()
    @IBOutlet weak var clcView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateData()
        
    }
    
    
    
    func updateData(){
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Photos")
        let url = NSURL(string: path)
        let fileManager = FileManager.default
        let dirContents = try? fileManager.contentsOfDirectory(atPath: path)
        if(dirContents != nil){
        let nphoto = dirContents!.count
            for i in 0..<nphoto {
                let imagePath = url!.appendingPathComponent(dirContents![i])
                let urlString: String = imagePath!.absoluteString
                if fileManager.fileExists(atPath: urlString) {
                    let image = UIImage(contentsOfFile: urlString)
                    imageArray.append(PhotoModel.init(image!, dirContents![i], urlString))
                } else {
                    // print("No Image")
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }

    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath as IndexPath) as! photocell

        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let Photo = self.imageArray[indexPath.row]
        cell.imageView.image = Photo.image
        cell.title.text = Photo.imageName
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPhotoVC") as! ViewPhotoVC
        let Photo = self.imageArray[indexPath.row]
        vc.image = Photo
        vc.updateList = {
            self.imageArray.removeAll()
            self.updateData()
            self.clcView.reloadData()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
