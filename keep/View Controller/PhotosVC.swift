//
//  PhotosVC.swift
//  keep
//
//  Created by Ankur Sehdev on 21/12/19.
//  Copyright © 2019 Munish. All rights reserved.
//

import UIKit
import AXPhotoViewer

class photocell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    
}

class PhotosVC: UIViewController ,UICollectionViewDelegate , UICollectionViewDataSource{
    @IBOutlet weak var placeHolderView: UIView!
    private lazy var imagePicker = PhotoPicker()
    var photosViewController: AXPhotosViewController!
    var updateList:(() -> Void)?
    var imageArray = [PhotoModel]()
    var photoAXArray = [AXPhoto]()
    @IBOutlet weak var clcView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let alignedFlowLayout = clcView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        alignedFlowLayout?.verticalAlignment = .top
        // Do any additional setup after loading the view.
        updateData()
        imagePicker.delegate = self
    }
    
    func conversion(){
        for photo in imageArray{
            let axPhoto = AXPhoto(attributedTitle: NSAttributedString(
                string: photo.imageName!),
                image: photo.image
            )
            photoAXArray.append(axPhoto)
        }
        
    }
    
    
    func updateData(){
        imageArray = FileRW.shared.readFiles(folderName:"Photos")
        conversion()
        placeHolderView.isHidden = imageArray.count != 0
    }
    //MARK: - Button Action

    @IBAction func addAction(_ sender: Any) {
        imagePicker.photoGalleryAsscessRequest()
    }
    
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker.present(parent: self, sourceType: sourceType)
    }
    
    //MARK: - CollectionView DataSoure and Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoAXArray.count
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
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPhotoVC") as! ViewPhotoVC
//        let Photo = self.imageArray[indexPath.row]
//        vc.image = Photo
//        vc.updateList = {
//            self.imageArray.removeAll()
//            self.updateData()
//            self.clcView.reloadData()
//        }
//        self.navigationController?.pushViewController(vc, animated: true)
        
        
        let dataSource = AXPhotosDataSource(photos: self.photoAXArray, initialPhotoIndex: indexPath.row)
        let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: nil)
        photosViewController.modalPresentationStyle = .fullScreen
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let bottomView = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44)))
        let barBtn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteFileMethod))
        bottomView.items = [
            flex,
            flex,
            flex,
            barBtn,
        ]
        bottomView.backgroundColor = .clear
        bottomView.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        photosViewController.overlayView.bottomStackContainer.insertSubview(bottomView, at: 0) // insert custom

        self.present(photosViewController, animated: true)
    }
    
    @objc func deleteFileMethod() {
        let currVC = UIApplication.topViewController() as? AXPhotosViewController
        
        let alert = UIAlertController(title: "Delete?", message: "Do you want to delete this file?",
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Delete",
                                      style: UIAlertAction.Style.destructive,
                                      handler: {(_: UIAlertAction!) in
                                        let fileManager = FileManager.default
                                        do {
                                            
                                            
                                            let currPhoto = self.imageArray[currVC!.currentPhotoIndex]
                                            print(currPhoto)
                                            self.photoAXArray.remove(at: currVC!.currentPhotoIndex)
                                            self.imageArray.remove(at: currVC!.currentPhotoIndex)
                                            currVC?.dataSource = AXPhotosDataSource(photos: self.photoAXArray, initialPhotoIndex: currVC!.currentPhotoIndex == self.photoAXArray.count ? currVC!.currentPhotoIndex - 1 : currVC!.currentPhotoIndex)
                                            
                                            try fileManager.removeItem(atPath: currPhoto.path ?? "")
                                            self.updateListMethod()
                                            //                                            self.navigationController?.popViewController(animated: true)
                                        }
                                        catch let error as NSError {
                                            print("Ooops! Something went wrong: \(error)")
                                        }
                                        
        }))
        currVC!.present(alert, animated: false, completion: nil)
        
    }
    
    
    func updateListMethod(){
        self.imageArray.removeAll()
        self.photoAXArray.removeAll()
        self.updateData()
        self.clcView.reloadData()
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
extension PhotosVC: ImagePickerDelegate {

    func imagePickerDelegate(didSelect image: UIImage, delegatedForm: PhotoPicker) {
        FileRW.shared.saveFile(image)
        self.imageArray.removeAll()
        self.updateData()
        self.clcView.reloadData()
        imagePicker.dismiss()
    }

    func imagePickerDelegate(didCancel delegatedForm: PhotoPicker) { imagePicker.dismiss() }

    func imagePickerDelegate(canUseGallery accessIsAllowed: Bool, delegatedForm: PhotoPicker) {
        if accessIsAllowed { presentImagePicker(sourceType: .photoLibrary) }
    }

    func imagePickerDelegate(canUseCamera accessIsAllowed: Bool, delegatedForm: PhotoPicker) {
        // works only on real device (crash on simulator)
        if accessIsAllowed { presentImagePicker(sourceType: .camera) }
    }
}
extension UIApplication {
  class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let tabController = controller as? UITabBarController {
      return topViewController(controller: tabController.selectedViewController)
    }
    if let navController = controller as? UINavigationController {
      return topViewController(controller: navController.visibleViewController)
    }
    if let presented = controller?.presentedViewController {
      return topViewController(controller: presented)
    }
    return controller
  }
}
