//
//  PhotoPicker.swift
//  keep
//
//  Created by Ankur Sehdev on 24/12/19.
//  Copyright © 2019 Munish. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
protocol ImagePickerDelegate: class {
    func imagePickerDelegate(canUseCamera accessIsAllowed: Bool, delegatedForm: PhotoPicker)
    func imagePickerDelegate(canUseGallery accessIsAllowed: Bool, delegatedForm: PhotoPicker)
    func imagePickerDelegate(didSelect image: UIImage, delegatedForm: PhotoPicker)
    func imagePickerDelegate(didCancel delegatedForm: PhotoPicker)
}
class PhotoPicker: NSObject {

    private weak var controller: UIImagePickerController?
    weak var delegate: ImagePickerDelegate? = nil

    func present(parent viewController: UIViewController, sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        self.controller = controller
        DispatchQueue.main.async {
            viewController.present(controller, animated: true, completion: nil)
        }
    }

    func dismiss() {
        controller?.dismiss(animated: true, completion: nil)
    }
}
extension PhotoPicker {

    private func showAlert(targetName: String, completion: @escaping (Bool)->()) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alertVC = UIAlertController(title: "Access to the \(targetName)",
                                            message: "Please provide access to your \(targetName)",
                                            preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                guard   let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingsUrl) else { completion(false); return }
                UIApplication.shared.open(settingsUrl, options: [:]) {
                    [weak self] _ in self?.showAlert(targetName: targetName, completion: completion)
                }
            }))
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completion(false) }))
            UIApplication.shared.delegate?.window??.rootViewController?.present(alertVC, animated: true, completion: nil)
        }
    }

    func cameraAsscessRequest() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            delegate?.imagePickerDelegate(canUseCamera: true, delegatedForm: self)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.delegate?.imagePickerDelegate(canUseCamera: granted, delegatedForm: self)
                } else {
                    self.showAlert(targetName: "camera") { self.delegate?.imagePickerDelegate(canUseCamera: $0, delegatedForm: self) }
                }
            }
        }
    }

    func photoGalleryAsscessRequest() {
        PHPhotoLibrary.requestAuthorization { [weak self] result in
            guard let self = self else { return }
            if result == .authorized {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.imagePickerDelegate(canUseGallery: result == .authorized, delegatedForm: self)
                }
            } else {
                self.showAlert(targetName: "photo gallery") { self.delegate?.imagePickerDelegate(canUseCamera: $0, delegatedForm: self) }
            }
        }
    }
}

extension PhotoPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            delegate?.imagePickerDelegate(didSelect: image, delegatedForm: self)
            return
        }

        if let image = info[.originalImage] as? UIImage {
            delegate?.imagePickerDelegate(didSelect: image, delegatedForm: self)
        } else {
            print("Other source")
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.imagePickerDelegate(didCancel: self)
    }
}
