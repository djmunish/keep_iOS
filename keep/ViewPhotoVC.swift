//
//  OnniFullImageViewController.swift
//  Onni
//
//  Created by Sakshi Bala on 25/03/19.
//  Copyright © 2019 MM Techies. All rights reserved.
//

import UIKit

class ViewPhotoVC: UIViewController {
    var documentInteractionController: UIDocumentInteractionController!

    @IBOutlet weak var fullImageView: UIImageView!
    
    var image:PhotoModel!
    var updateList:(() -> Void)?

    var overlay: UIView = {
        let view = UIView(frame: UIScreen.main.bounds);
        
        view.alpha = 0
        view.backgroundColor = .black
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = image.imageName
        fullImageView.isUserInteractionEnabled = true
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        
        // Use 2 thingers to move the view
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        
        // We delegate gestures so we can
        // perform both at the same time
        pan.delegate = self
        pinch.delegate = self
        
        fullImageView.addGestureRecognizer(pinch)
        fullImageView.addGestureRecognizer(pan)
        
        self.view.addSubview(overlay)
        self.view.bringSubviewToFront(fullImageView)
        
        self.setupImageView()
    }
    
    /// Setup imageView
    private func setupImageView() {
        
        fullImageView.image = image.image

        fullImageView.contentMode = .scaleAspectFit
        fullImageView.layer.masksToBounds = true
        fullImageView.layer.borderWidth = 0
        
        setupImageViewConstraints()
    }
    
    /// Setup ImageView constraints
    private func setupImageViewConstraints() {
        
        // Disable Autoresizing Masks into Constraints
        fullImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints
        NSLayoutConstraint.activate([
            fullImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fullImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fullImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            fullImageView.heightAnchor.constraint(equalToConstant: 250)
            ])
        
        view.layoutIfNeeded()
    }
    
    @IBAction func deleteFileMethod(_ sender: Any) {
        let alert = UIAlertController(title: "Delete?", message: "Do you want to delete this file?",         preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Delete",
                                      style: UIAlertAction.Style.destructive,
                                      handler: {(_: UIAlertAction!) in
                                        let fileManager = FileManager.default
                                        do {
                                            try fileManager.removeItem(atPath: self.image.path ?? "")
                                            self.updateList!()
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                        catch let error as NSError {
                                            print("Ooops! Something went wrong: \(error)")
                                        }
                                        
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func actionMethod(_ sender: UIBarButtonItem) {
        
        documentInteractionController = UIDocumentInteractionController()
        documentInteractionController.url = URL(fileURLWithPath: image.path ?? "")
        documentInteractionController.uti = "com.instagram.exclusivegram"
        documentInteractionController.presentOptionsMenu(from: sender, animated: true)
    }
    

}



extension ViewPhotoVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            
            // Only zoom in, not out
            if gesture.scale >= 1 {
                
                // Get the scale from the gesture passed in the function
                let scale = gesture.scale
                
                // use CGAffineTransform to transform the imageView
                gesture.view!.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            
            
            // Show the overlay
            UIView.animate(withDuration: 0.2) {
                self.overlay.alpha = 0.8
            }
            break;
        default:
            // If the gesture has cancelled/terminated/failed or everything else that's not performing
            // Smoothly restore the transform to the "original"
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                gesture.view!.transform = .identity
            }) { _ in
                // Hide the overlay
                UIView.animate(withDuration: 0.2) {
                    self.overlay.alpha = 0
                }
            }
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            // Get the touch position
            let translation = gesture.translation(in: fullImageView)
            
            // Edit the center of the target by adding the gesture position
            gesture.view!.center = CGPoint(x: fullImageView.center.x + translation.x, y: fullImageView.center.y + translation.y)
            gesture.setTranslation(.zero, in: fullImageView)
            
            // Show the overlay
            UIView.animate(withDuration: 0.2) {
                self.overlay.alpha = 0.8
            }
            break;
        default:
            // If the gesture has cancelled/terminated/failed or everything else that's not performing
            // Smoothly restore the transform to the "original"
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                gesture.view!.center = self.view.center
//                gesture.setTranslation(.zero, in: self.background)
            }) { _ in
                // Hide the overaly
                UIView.animate(withDuration: 0.2) {
                    self.overlay.alpha = 0
                }
            }
            break
        }
    }
}
