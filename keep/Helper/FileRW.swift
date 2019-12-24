//
//  FileRW.swift
//  keep
//
//  Created by Ankur Sehdev on 24/12/19.
//  Copyright © 2019 Munish. All rights reserved.
//

import UIKit

class FileRW: NSObject {
    static let shared = FileRW()

    //write
    func saveFile(_ image:UIImage)  {
           let fileManager = FileManager.default
           let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            
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
       }
       
       func uniqueFilename(withPrefix prefix: String? = nil) -> String {
           let uniqueString = ProcessInfo.processInfo.globallyUniqueString
           if prefix != nil {
               return "\(prefix!)-\(uniqueString)" + ".jpg"
           }
           return uniqueString
       }
    
    //read
    func readFiles(folderName:String) ->[PhotoModel]{
        var imageArr = [PhotoModel]()
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
                    imageArr.append(PhotoModel.init(image!, dirContents![i], urlString))
                } else {
                    // print("No Image")
                }
            }
        }
        return imageArr
    }
}
