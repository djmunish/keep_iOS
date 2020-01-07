//
//  ViewController.swift
//  keep
//
//  Created by Ankur Sehdev on 21/12/19.
//  Copyright © 2019 Munish. All rights reserved.
//

import UIKit
import LocalAuthentication
import Photos
import OpalImagePicker

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
 {
    let imagePickerController = UIImagePickerController()
    var context = LAContext()
    enum AuthenticationState {
           case loggedin, loggedout
       }
    private lazy var imagePicker = PhotoPicker()
    var state = AuthenticationState.loggedout

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)

        // Set the initial app state. This impacts the initial state of the UI as well.
        state = .loggedout
        imagePicker.delegate = self

    }

    //MARK: - Button Actions
    @IBAction func open(_ sender: Any) {
        Authenticate()
    }
    func Authenticate(){

        if state == .loggedin {

            // Log out immediately.
            state = .loggedout

        } else {

            // Get a fresh context for each login. If you use the same context on multiple attempts
            //  (by commenting out the next line), then a previously successful authentication
            //  causes the next policy evaluation to succeed without testing biometry again.
            //  That's usually not what you want.
            context = LAContext()

            context.localizedCancelTitle = "Cancel"

            // First check if we have the needed hardware support.
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {

                let reason = "Log in to your account"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                    if success {

                        // Move to the main thread because a state update triggers UI changes.
                        DispatchQueue.main.async { [unowned self] in
                            self.state = .loggedin
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilesVC") as! FilesVC
                            self.navigationController?.pushViewController(vc, animated: true)

                        }

                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate")

                        // Fall back to a asking for username and password.
                        // ...
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Can't evaluate policy")
                showAlertWithTitle(title: "Error", message: error?.localizedDescription ?? "Can't evaluate policy")
                // Fall back to a asking for username and password.
                // ...
            }
        }
    }
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker.present(parent: self, sourceType: sourceType)
    }
    @IBAction func importPhotos(_ sender: Any) {
//        imagePicker.photoGalleryAsscessRequest()
        let imagePicker = OpalImagePickerController()
        imagePicker.imagePickerDelegate = self
        imagePicker.maximumSelectionsAllowed = 10
        present(imagePicker, animated: true, completion: nil)
    }
        
    
    //MARK: TouchID error
    func errorMessage(errorCode:Int) -> String{

        var strMessage = ""

        switch errorCode {

        case LAError.Code.authenticationFailed.rawValue:
            strMessage = "Authentication Failed"

        case LAError.Code.userCancel.rawValue:
            strMessage = "User Cancel"

        case LAError.Code.systemCancel.rawValue:
            strMessage = "System Cancel"

        case LAError.Code.passcodeNotSet.rawValue:
            strMessage = "Please goto the Settings & Turn On Passcode"

        case LAError.Code.appCancel.rawValue:
            strMessage = "App Cancel"

        case LAError.Code.invalidContext.rawValue:
            strMessage = "Invalid Context"

        default:
            strMessage = ""

        }
        return strMessage
    }
    
    //MARK: Show Alert
    func showAlertWithTitle( title:String, message:String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let actionOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(actionOk)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension NSLayoutConstraint {

    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
extension ViewController: ImagePickerDelegate {

    func imagePickerDelegate(didSelect image: UIImage, delegatedForm: PhotoPicker) {
        FileRW.shared.saveFile(image)
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

extension ViewController: OpalImagePickerControllerDelegate{
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingAssets assets: [PHAsset]){
        picker.dismiss(animated: true, completion: {
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            // this one is key
            requestOptions.isSynchronous = true
            
            for asset in assets{
                if (asset.mediaType == PHAssetMediaType.image)
                {
                    
                    PHImageManager.default().requestImage(for: asset , targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOptions, resultHandler: { (pickedImage, info) in
                            FileRW.shared.saveFile(pickedImage!)
                    })
                }
            }
            
        })
        
    }
    func imagePickerDidCancel(_ picker: OpalImagePickerController){
        
    }

}
