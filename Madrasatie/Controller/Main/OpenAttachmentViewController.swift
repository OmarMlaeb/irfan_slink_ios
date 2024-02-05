//
//  OpenAttachmentViewController.swift
//  Madrasatie
//
//  Created by Maher Jaber on 11/10/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import UIKit
import PWSwitch
import ActionSheetPicker_3_0
import SDWebImage
import SwipeCellKit
import ALCameraViewController
import BSImagePicker
import Photos
import Alamofire
import MobileCoreServices
import WebKit


class OpenAttachmentViewController: UIViewController, UINavigationControllerDelegate{
    @IBOutlet weak var webViewer: WKWebView!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var attachmentName = "SLink.pdf"
    var attachmentType = ".pdf"
    var linkText: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        link.text = linkText
        print(linkText)
        print("attachment type: \(attachmentType)")
        let myURL = URL(string:link.text!)
        let myRequest = URLRequest(url: myURL!)

        webViewer.load(myRequest)
        //add observer to get estimated progress value
           self.webViewer.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        

       }
        
    @IBAction func dismissViewController(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func downloadAttachment(_ sender: Any) {
                
        savePdf(urlString: self.linkText, fileName: attachmentName)
        
        
//        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileUrl = dir.appendingPathComponent(attachmentName)
        
        
        
//        guard let linkUrl = URL(string: self.linkText) else { return  }
//
//        let doc = UIDocumentInteractionController(url: linkUrl)
//        doc.presentOptionsMenu(from: view.bounds, in: view, animated: true)
        
        
//        let imageToShare = [linkUrl]
//        let activityViewController = UIActivityViewController(activityItems: imageToShare as [URL?], applicationActivities: nil)
//        activityViewController.excludedActivityTypes = [.airDrop]
//
//        if let popoverController = activityViewController.popoverPresentationController {
//            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
//            popoverController.sourceView = self.view
//            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
//        }
//
//        self.present(activityViewController, animated: true, completion: nil)
//
    }
    // Observe value
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(self.webViewer.estimatedProgress);
            self.progressView.progress = Float(self.webViewer.estimatedProgress);
        }
    }
    
        func savePdf(urlString:String, fileName:String) {
            DispatchQueue.main.async {
                            let url = URL(string: urlString)
                            let pdfData = try? Data.init(contentsOf: url!)
                            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
                            let type = self.attachmentType.split(separator: "/")
                            let pdfNameFromUrl = self.attachmentName + "." + type[1]
                            print(pdfNameFromUrl)
                            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
                            do {
                                try pdfData?.write(to: actualPath, options: .atomic)
                                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                App.showAlert(self, title: "SLink", message: "File saved successfully!", actions: [ok])
                                
                            } catch {
                                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                App.showAlert(self, title: "SLink", message: "File not saved!", actions: [ok])
                            }
                        }
            }

    
}

extension URL {
    func download(to directory: FileManager.SearchPathDirectory, using fileName: String? = nil, overwrite: Bool = false, completion: @escaping (URL?, Error?) -> Void) throws {
        let directory = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destination: URL
        if let fileName = fileName {
            destination = directory
                .appendingPathComponent(fileName)
                .appendingPathExtension(self.pathExtension)
        } else {
            destination = directory
            .appendingPathComponent(lastPathComponent)
        }
        if !overwrite, FileManager.default.fileExists(atPath: destination.path) {
            completion(destination, nil)
            return
        }
        URLSession.shared.downloadTask(with: self) { location, _, error in
            guard let location = location else {
                completion(nil, error)
                return
            }
            do {
                if overwrite, FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.moveItem(at: location, to: destination)
                completion(destination, nil)
            } catch {
                print(error)
            }
        }.resume()
    }
}
