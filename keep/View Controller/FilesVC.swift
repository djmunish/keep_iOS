//
//  FilesVC.swift
//  keep
//
//  Created by Ankur Sehdev on 22/12/19.
//  Copyright © 2019 Munish. All rights reserved.
//

import UIKit

class FilesVC: UIViewController{

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let alignedFlowLayout = collectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        alignedFlowLayout?.verticalAlignment = .top
        // Do any additional setup after loading the view.
        
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

extension FilesVC : UICollectionViewDelegate, UICollectionViewDataSource  {
    
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 1
       }
    
        

       // make a cell for each cell index path
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

           // get a reference to our storyboard cell
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath as IndexPath) as! photocell

           // Use the outlet in our custom class to get a reference to the UILabel in the cell
//           let Photo = self.imageArray[indexPath.row]
//           cell.imageView.image = Photo.image
           cell.title.text = "Photos"
           return cell
       }

       
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotosVC") as! PhotosVC
           self.navigationController?.pushViewController(vc, animated: true)
       }
}
