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

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate
 {
    let imagePickerController = UIImagePickerController()
    var context = LAContext()
    enum AuthenticationState {
           case loggedin, loggedout
       }
    
    var state = AuthenticationState.loggedout

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)

        // Set the initial app state. This impacts the initial state of the UI as well.
        state = .loggedout

    }

    
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

    
    @IBAction func importPhotos(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset{
            if let fileName = asset.value(forKey: "filename") as? String{
            print(fileName)
            }
        }
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        print(image)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
         
         let fileManager = FileManager.default

         
         let folderURL = documentsDirectory.appendingPathComponent("Photos")
         if !fileManager.fileExists(atPath: folderURL.path) {
             do {
                 // Attempt to create folder
                 try fileManager.createDirectory(atPath: folderURL.path,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
             } catch {
                 // Creation failed. Print error & return nil
                 print(error.localizedDescription)
             }
         }
         
         
         // choose a name for your image
         // create the destination file url to save your image
        let fileURL = folderURL.appendingPathComponent(uniqueFilename(withPrefix: "Photo"))
         // get your UIImage jpeg data representation and check if the destination file url already exists
         if let data = image.jpegData(compressionQuality:  1.0),
             !FileManager.default.fileExists(atPath: fileURL.path) {
             do {
                 // writes the image data to disk
                 try data.write(to: fileURL)
                 print("file saved")
             } catch {
                 print("error saving file:", error)
             }
         }
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uniqueFilename(withPrefix prefix: String? = nil) -> String {
        let uniqueString = ProcessInfo.processInfo.globallyUniqueString
        
        if prefix != nil {
            return "\(prefix!)-\(uniqueString)" + ".jpg"
        }
        
        return uniqueString
    }
    
}

extension NSLayoutConstraint {

    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
