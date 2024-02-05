//
//  GalleryViewController.swift
//  Madrasatie
//
//  Created by Maher Jaber on 4/17/20.
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
import CropViewController
import TOCropViewController

protocol GalleryViewControllerDelegate {
    func galleryPressed(calendarType: CalendarStyle?)
}

class GalleryViewController: CollapsableTableViewController, CropViewControllerDelegate {
    @IBOutlet weak var addAlbumTableView: UITableView!
    @IBOutlet weak var galleryAlbums: UICollectionView!
    @IBOutlet weak var albumPhotos: UICollectionView!
    @IBOutlet weak var addPhotosTableView: UITableView!
    @IBOutlet weak var addButtonTableView: UITableView!
    @IBOutlet weak var switchAlbumsTableView: UITableView!
    var galleryDelegate: GalleryViewControllerDelegate?
    var user: User!
    var departments = [CalendarEventItem(id: "1", title: "dep1", active: true, studentId: ""), CalendarEventItem(id: "2", title: "dep2", active: true, studentId: ""), CalendarEventItem(id: "3", title: "dep3", active: true, studentId: ""), CalendarEventItem(id: "4", title: "dep4", active: true, studentId: "")]
    var classes = [CalendarEventItem(id: "1", title: "class1", active: true, studentId: ""), CalendarEventItem(id: "2", title: "class2", active: true, studentId: ""), CalendarEventItem(id: "3", title: "class3", active: true, studentId: ""), CalendarEventItem(id: "4", title: "class4", active: true, studentId: "")]
    //var imagePicker = UIImagePickerController()
    var selectedImage : UIImage = UIImage()
    var isSelectedImage = false
    var selectedAssets = [PHAsset]()
    var selectedImages = [UIImage]()
    var photosPreview = [String]()
    var check = false
    var createRemark = CreateRemark.init(students: [], subject: "", remarkText: "", id: 0)
    var allSchoolSwitch = true
    var extraStudents = [String]()
    var extraEmployees = [String]()
    var selectedStudents = [Student]()
    var selectedEmployees = [Student]()
    var galleryAlb = [AlbumModel]()
    var albumId = ""
    var photoAlbum = [PhotoAlbumModel]()
    var classesId = [String]()
    var departmentsId = [String]()
    var albumTitle = ""
    var count = 0
    var source = ""
    var albumsNames = [String]()
    var albumIndex = 0
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")

    var croppingStyle = CropViewCroppingStyle.default
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    var indexPathToImages = 0
    var saveButtonIsHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAlbumTableView.dataSource = self
        addAlbumTableView.delegate = self
        addAlbumTableView.isHidden = true
        
        galleryAlbums.delegate = self
        galleryAlbums.dataSource = self
        
        albumPhotos.delegate = self
        albumPhotos.dataSource = self
        albumPhotos.isHidden = true
        
        
        addPhotosTableView.delegate = self
        addPhotosTableView.dataSource = self
        addPhotosTableView.isHidden = true
        
        addButtonTableView.delegate = self
        addButtonTableView.dataSource = self
        
        switchAlbumsTableView.dataSource = self
        switchAlbumsTableView.delegate = self
        switchAlbumsTableView.isHidden = true
        
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.addTarget(self, action: #selector(backSegue) )
        swipeLeft.direction = .right
        albumPhotos!.addGestureRecognizer(swipeLeft)
        
        getSectionsDepartments(user: user)
        getAlbums(user: user)
        
        

       

        // Do any additional setup after loading the view.
    }
    
    
      @objc func donedatePicker(){
        let title = self.addAlbumTableView.viewWithTag(888) as! UITextField
        self.albumTitle = title.text!
        print("albumtitle: \(albumTitle)")
          self.view.endEditing(true)
        }

        @objc func cancelDatePicker(){
           self.view.endEditing(true)
         }

      override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
      }
    
    
    @IBAction func backSegue() {
        self.albumPhotos.rightToLeftAnimation()
        self.albumPhotos.isHidden = true
        self.galleryAlbums.isHidden = false
        self.switchAlbumsTableView.isHidden = true
        self.addButtonTableView.isHidden = false
        
        

           }
    @IBAction func unwindBack(segue:UIStoryboardSegue) {
        print("Welcome back!!!")
    }
    /// Description:
    /// - Configure Collapse/Expanse table view cells:
    override func sectionHeaderNibName() -> String? {
        return "ProductHeader"
    }
    
    override func singleOpenSelectionOnly() -> Bool {
        return false
    }
    
    override func collapsableTableView() -> UITableView? {
        return addAlbumTableView
    }
    
    @objc func deleteImage(sender: CustomTapGestureRecognizer){

        print("index: \(sender.passedValue ?? 0)")
        print("size: \(self.selectedImages.count)")
        
        let imageView = self.addPhotosTableView.viewWithTag(996) as! UIImageView
        if(self.selectedImages.count == 0 || self.selectedImages.count == 1){
             imageView.image = UIImage(named: "kjdjd")
         }
        else if(sender.passedValue == 0 && self.selectedImages.count >= 2) {
             let image = selectedImages[sender.passedValue! + 1 ]
             imageView.image = image
         }
        else{
            let image = selectedImages[sender.passedValue! - 1 ]
            imageView.image = image
        }
                   
        selectedImages.remove(at: sender.passedValue!)

        if(self.addPhotosTableView.isHidden == false){
            let collection = self.addPhotosTableView.viewWithTag(723) as! UICollectionView
            collection.reloadData()
           
            
        }
        else if(self.addAlbumTableView.isHidden == false){
            let collection = self.addAlbumTableView.viewWithTag(723) as! UICollectionView
            collection.reloadData()
        }
         
        
    }
    @objc func prevAlbum(sender: UIButton){
        if(albumIndex > 0){
            albumIndex -= 1
            let albumTitle = self.switchAlbumsTableView.viewWithTag(892) as! UILabel
            albumTitle.text = self.galleryAlb[albumIndex].albumName
            getAlbumPhotos(user: user, albumId: self.galleryAlb[albumIndex].id)
            
        }
        
    }
    @objc func nextAlbum(sender: UIButton){
        if(albumIndex < (self.galleryAlb.count - 1)){
                albumIndex += 1
                let albumTitle = self.switchAlbumsTableView.viewWithTag(892) as! UILabel
                albumTitle.text = self.galleryAlb[albumIndex].albumName
                getAlbumPhotos(user: user, albumId: self.galleryAlb[albumIndex].id)
                
            }
    }
   
    @objc func showClasses(sender: UIButton){
        print("hellomaher")
        
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.addAlbumTableView.indexPath(for: cell)
        
        let department = model![indexPath!.section - 7].items[indexPath!.item]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "StudentsViewController") as! StudentsViewController
        studentVC.delegate = self
        studentVC.user = self.user
        studentVC.sectionId = department.id ?? ""
        studentVC.departmentId = ""
        studentVC.modalPresentationStyle = .fullScreen
        self.present(studentVC, animated: true, completion: nil)
    }
    
    @objc func showDepartments(sender: UIButton){
        print("hellomaher")
      
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "StudentsViewController") as! StudentsViewController
        studentVC.delegate = self
        studentVC.user = self.user
        studentVC.departmentId = sender.accessibilityHint!
        studentVC.sectionId = ""
        studentVC.modalPresentationStyle = .fullScreen
        self.present(studentVC, animated: true, completion: nil)
       }
    
    @objc func disableDepArrow(sender: PWSwitch){
        
        
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = self.addAlbumTableView.indexPath(for: cell)
        if indexpath?.section == 7{
            let id = model![indexpath!.section - 7].items[indexpath!.row].id
            let active = model![indexpath!.section - 7].items[indexpath!.row].active
            model![indexpath!.section - 7].items[indexpath!.row].active = !active
            if let row = self.departments.firstIndex(where: {$0.id == id}) {
                self.departments[row].active = !active
            }
        }
    }
    @objc func cancelAddPhotos(sender: UIButton){
        self.addPhotosTableView.isHidden = true
        self.albumPhotos.isHidden = false
        self.switchAlbumsTableView.isHidden = false
    }
    
    @objc func secondCancelAddPhotos(sender: UIButton){
        
        let imageView = self.addPhotosTableView.viewWithTag(996) as! UIImageView
        imageView.isHidden = true
        self.addPhotosTableView.isHidden = true
        self.albumPhotos.isHidden = true
        self.switchAlbumsTableView.isHidden = false
        
        let addImageView = self.addButtonTableView.viewWithTag(600) as! UIImageView
        let xImageView = self.addButtonTableView.viewWithTag(6001) as! UIImageView
        let addLabel = self.addButtonTableView.viewWithTag(601) as! UILabel
        
//        if(self.galleryAlbums.isHidden == false && self.albumPhotos.isHidden == true && self.addAlbumTableView.isHidden == true && self.addPhotosTableView.isHidden == true){
            self.addAlbumTableView.isHidden = false
            self.galleryAlbums.isHidden = true
            //addButton.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            //addImageView.isHidden = true
            xImageView.isHidden = false
            addLabel.text = "Cancel"
            addImageView.image = UIImage(named: "cancel")
        
        let collection = self.addAlbumTableView.viewWithTag(723) as! UICollectionView
        collection.reloadData()
        
//
//        }
//
//        else if(self.galleryAlbums.isHidden == true && self.albumPhotos.isHidden == true && self.addAlbumTableView.isHidden == false && self.addPhotosTableView.isHidden == true){
//            self.addAlbumTableView.isHidden = true
//            self.galleryAlbums.isHidden = false
//            xImageView.isHidden = true
//            addLabel.text = "Add"
//            addImageView.image = UIImage(named: "add-school")
//        }
    }
    
    @objc func editAddPhotos(sender: UIButton){
        let imageView = self.addPhotosTableView.viewWithTag(996) as! UIImageView
        guard let selectedImage = imageView.image else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: selectedImage)
        
        cropController.delegate = self
        
                self.present(cropController, animated: true, completion: nil)
                //self.navigationController!.pushViewController(cropController, animated: true)
    
    }
    
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
           self.croppedRect = cropRect
           self.croppedAngle = angle
           updateImageViewWithImage(image, fromCropViewController: cropViewController)
       }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            self.croppedRect = cropRect
            self.croppedAngle = angle
            updateImageViewWithImage(image, fromCropViewController: cropViewController)
        }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        //            self.isFileSelected = false
        
        let cell = self.addPhotosTableView.viewWithTag(1452) as! UITableViewCell
        
        let collectionView = cell.viewWithTag(723) as! UICollectionView
        
//        let tapGestureRecognizer = UITapGestureRecognizer()
//
//        let pointInCollectionView = tapGestureRecognizer.location(in: collectionView)
//        let indexPath = collectionView.indexPathForItem(at: pointInCollectionView)
//
//        let collectionViewCell = collectionView.viewWithTag(6996) as! UICollectionViewCell
//
//
//        let selectedCell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0))
//
        var collectionViewCellImages = collectionView.viewWithTag(6543) as! UIImageView
        
        
        self.selectedImage = image
        self.isSelectedImage = true
        let imageView = addPhotosTableView.viewWithTag(996) as! UIImageView
            imageView.image = image
        
        selectedImages[indexPathToImages] = image
//        collectionViewCellImages.image = selectedImages[indexPathToImages]
        
        //        self.isSelectedImage = true
        //        let imageView = calendarTableView.viewWithTag(721) as! UIImageView
        //        imageView.image = selectedImage
            layoutImageView()
            
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            
            if cropViewController.croppingStyle != .circular {
                imageView.isHidden = true
                
                cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                       toView: imageView,
                                                       toFrame: CGRect.zero,
                                                       setup: { self.layoutImageView() },
                                                       completion: {
                                                        imageView.isHidden = false })
            }
            else {
                imageView.isHidden = false
                cropViewController.dismiss(animated: true, completion: nil)
                
            }
        }
    
    public func layoutImageView() {
        let imageView = addPhotosTableView.viewWithTag(996) as! UIImageView
            guard imageView.image != nil else { return }
            
            let padding: CGFloat = 20.0
            
            var viewFrame = self.view.bounds
            viewFrame.size.width -= (padding * 2.0)
            viewFrame.size.height -= ((padding * 2.0))
            
            var imageFrame = CGRect.zero
            imageFrame.size = imageView.image!.size;
            
            if imageView.image!.size.width > viewFrame.size.width || imageView.image!.size.height > viewFrame.size.height {
                let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
                imageFrame.size.width *= scale
                imageFrame.size.height *= scale
                imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
                imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
                imageView.frame = imageFrame
            }
            else {
                imageView.frame = imageFrame;
                imageView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            }
        }
    
    @objc func disableClassesArrow(sender: PWSwitch){
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = self.addAlbumTableView.indexPath(for: cell)
        if indexpath?.section == 8{
            let id = model![indexpath!.section - 7].items[indexpath!.item].id
            let active = model![indexpath!.section - 7].items[indexpath!.item].active
            model![indexpath!.section - 7].items[indexpath!.item].active = !active
            if let row = self.classes.firstIndex(where: {$0.id == id}) {
                self.classes[row].active = !active
            }
        }
    }
    @objc func previewImage(sender: CustomTapGestureRecognizer){
        print("indexindex: \(sender.passedValue ?? 0)")
        print("sizesize: \(selectedImages.count)")
        let image = selectedImages[sender.passedValue!]
        indexPathToImages = sender.passedValue!
        let imageView = self.addPhotosTableView.viewWithTag(996) as! UIImageView
        imageView.image = image
        
    }
    
    @objc func addButtonPressed(sender: UIButton){
        let addImageView = self.addButtonTableView.viewWithTag(600) as! UIImageView
        let xImageView = self.addButtonTableView.viewWithTag(6001) as! UIImageView
        let addLabel = self.addButtonTableView.viewWithTag(601) as! UILabel
        
        if(self.galleryAlbums.isHidden == false && self.albumPhotos.isHidden == true && self.addAlbumTableView.isHidden == true && self.addPhotosTableView.isHidden == true){
            self.addAlbumTableView.isHidden = false
            self.galleryAlbums.isHidden = true
            //addButton.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            //addImageView.isHidden = true
            xImageView.isHidden = false
            addLabel.text = "Cancel"
            addImageView.image = UIImage(named: "cancel")
            
        }
        
        else if(self.galleryAlbums.isHidden == true && self.albumPhotos.isHidden == true && self.addAlbumTableView.isHidden == false && self.addPhotosTableView.isHidden == true){
            self.addAlbumTableView.isHidden = true
            self.galleryAlbums.isHidden = false
            xImageView.isHidden = true
            addLabel.text = "Add"
            addImageView.image = UIImage(named: "add-school")
        }
       
    }
    
    @objc
    func handleLongPressImage(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .ended {
            return
        }

        let point = longPressGR.location(in: self.albumPhotos)
        let indexPath = self.albumPhotos.indexPathForItem(at: point)

        if let indexPath = indexPath {
            if(indexPath.item > 0){
                if(user.userType == 2){
                    deletePhoto(user: user, photoId: self.photoAlbum[indexPath.item].id, index: indexPath.item)
                    print(indexPath.item)
                }
               
               
            }
            
        } else {
            print("Could not find index path")
        }
    }
    @objc
       func handleLongPressAlbum(longPressGR: UILongPressGestureRecognizer) {
           if longPressGR.state != .ended {
               return
           }

           let point = longPressGR.location(in: self.albumPhotos)
        let indexPath = self.galleryAlbums.indexPathForItem(at: point)

           if let indexPath = indexPath {
                var cell = self.galleryAlbums.cellForItem(at: indexPath)
            if(user.userType == 2){
                deleteAlbum(user: user, albumId: self.galleryAlb[indexPath.item].id, index: indexPath.item)
            }
           
           
            print("indexpath: \(indexPath.item)")
            print("id\(self.galleryAlb[indexPath.item].id)")
           } else {
               print("Could not find index path")
           }
       }
    
    /// Description:
      /// - Show alert with option to take picture or upload one from phone gallery.
      @objc func uploadImageButtonPressed(sender: UIButton){
          let alert = UIAlertController(title: "Upload picture".localiz(), message: nil, preferredStyle: .actionSheet)
          
          alert.addAction(UIAlertAction(title: "Choose from library".localiz(), style: .default, handler: { _ in
              self.openGallery()
          }))
          
          alert.addAction(UIAlertAction.init(title: "Cancel".localiz(), style: .cancel, handler: nil))
          switch UIDevice.current.userInterfaceIdiom {
          case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
          default:
              break
          }
          self.present(alert, animated: true, completion: nil)
      }
       
       func openGallery() {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cancelCell = self.addPhotosTableView.cellForRow(at: indexPath)
        let cancelLabel = cancelCell?.viewWithTag(998) as! UIButton
        let secondCancelLabel = cancelCell?.viewWithTag(1120) as! UIButton
        secondCancelLabel.isHidden = false
        secondCancelLabel.isUserInteractionEnabled = true
        cancelLabel.isHidden = true
        cancelLabel.isUserInteractionEnabled = false
        
         selectedImages.removeAll()
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
        imagePicker.settings.selection.unselectOnReachingMax = true

        let start = Date()
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            print("Finished with selections: \(assets)")
            
            print("finished picking images")
            
            for asset in assets{
                            
            //                    let retinaScale = UIScreen.main.scale
            //                    let retinaSquare = CGSize(width: 100 * retinaScale, height: 100 * retinaScale)
                            //let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
                           
                            
                            let manager = PHImageManager.default()
                            let options = PHImageRequestOptions()
                            options.version = .current
                            options.resizeMode = .exact
                            options.deliveryMode = .highQualityFormat
                            options.isNetworkAccessAllowed = true
                            options.isSynchronous = true
                            
            //                    manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
            //                        thumbnail = result!
            //                    })
                            
                            manager.requestImage(for: asset,targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (thumbnail, info) in
                                     if let img = thumbnail {
                                        self.selectedImages.append(img);
                                      }
                                }
                            
                        }
            let collection = self.addPhotosTableView.viewWithTag(723) as! UICollectionView
            collection.reloadData()
            
//
            let imageView = self.addPhotosTableView.viewWithTag(996) as! UIImageView
            imageView.image = self.selectedImages[0]
            self.addPhotosTableView.isHidden = false
            self.albumPhotos.isHidden = true
            self.switchAlbumsTableView.isHidden = true
            
            self.saveButtonIsHidden = true
//
//
//
        }, completion: {
            let finish = Date()
            print(finish.timeIntervalSince(start))
        })
        
//           imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//
//           imagePicker.allowsEditing = true
//           self.present(imagePicker, animated: true, completion: nil)
       }
    
//    func openCamera() {
//
//           var minimumSize: CGSize = CGSize(width: 60, height: 60)
//            selectedImages.removeAll()
//
//           var croppingParameters: CroppingParameters {
//               return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: minimumSize)
//           }
//
//           let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
//
//               // Do something with your image here.
//               if image != nil{
//                    self?.selectedImages.append(image!)
//                   //self?.selectedImage = image!
//                   self?.isSelectedImage = true
//                let collection = self?.addPhotosTableView.viewWithTag(723) as! UICollectionView
//                collection.reloadData()
//
//
//                let imageView = self?.addPhotosTableView.viewWithTag(996) as! UIImageView
//                imageView.image = self?.selectedImages[0]
//
//               }
//               self?.dismiss(animated: true, completion: nil)
//            self?.addPhotosTableView.isHidden = false
//            self?.albumPhotos.isHidden = true
//            self?.switchAlbumsTableView.isHidden = true
//           }
//           present(cameraViewController, animated: true, completion: nil)
//       }
    
           func openGallery1() {
             selectedImages.removeAll()
            let imagePicker = ImagePickerController()
            imagePicker.settings.selection.max = 5
            imagePicker.settings.theme.selectionStyle = .numbered
            imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
            imagePicker.settings.selection.unselectOnReachingMax = true

            let start = Date()
            self.presentImagePicker(imagePicker, select: { (asset) in
                print("Selected: \(asset)")
            }, deselect: { (asset) in
                print("Deselected: \(asset)")
            }, cancel: { (assets) in
                print("Canceled with selections: \(assets)")
            }, finish: { (assets) in
                print("Finished with selections: \(assets)")
                
                
                
                for asset in assets{
                                
                //                    let retinaScale = UIScreen.main.scale
                //                    let retinaSquare = CGSize(width: 100 * retinaScale, height: 100 * retinaScale)
                                //let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
                               
                                
                                let manager = PHImageManager.default()
                                let options = PHImageRequestOptions()
                                options.version = .current
                                options.resizeMode = .exact
                                options.deliveryMode = .highQualityFormat
                                options.isNetworkAccessAllowed = true
                                options.isSynchronous = true
                                
                //                    manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
                //                        thumbnail = result!
                //                    })
                                
                                manager.requestImage(for: asset,targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (thumbnail, info) in
                                         if let img = thumbnail {
                                            self.selectedImages.append(img);
                                          }
                                    }
                                
                            }
                let collection = self.addPhotosTableView.viewWithTag(723) as! UICollectionView
                collection.reloadData()
                
               
                let imageView = self.addPhotosTableView.viewWithTag(996) as! UIImageView
                imageView.image = self.selectedImages[0]
                self.addPhotosTableView.isHidden = false
                self.albumPhotos.isHidden = true
                self.switchAlbumsTableView.isHidden = true
                
            }, completion: {
                let finish = Date()
                print(finish.timeIntervalSince(start))
            })
            
    //           imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
    //
    //           imagePicker.allowsEditing = true
    //           self.present(imagePicker, animated: true, completion: nil)
           }
    
    @objc func saveButtonPressed(sender: UIButton){
        
        let albumT = self.addAlbumTableView.viewWithTag(888) as! UITextField
        print(albumT.text)
        createAlbum(user: user, image: selectedImages, title: albumT.text!, allSchoolSwitch: allSchoolSwitch, std: self.extraStudents, emp: self.extraEmployees)
    }
    @objc func savePhotosPressed(sender: UIButton){
        self.count = 0
        self.source = "photo"
        for image in selectedImages{
            self.addAlbumPhotos(user: user, image: image, albumId: self.albumId)
        }
    }
    
    @objc func switchChanged(mySwitch: PWSwitch) {
      
            print("allschoolswitch: \(allSchoolSwitch)")
            if(mySwitch.on){
               allSchoolSwitch = true
                self.addAlbumTableView.reloadData()
            }
            else{
               allSchoolSwitch = false
                self.addAlbumTableView.reloadData()
            }
            
           
           // Do something
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

extension GalleryViewController: SectionVCToGalleryDelegate{
    func switchGalleryChildren(user: User, batchId: Int?, children: Children?) {
        self.user = user
        self.getAlbums(user: self.user)
    }
    
    func galleryFilterSectionView(type: Int) {
        print("entered gallery")
    }
}
extension GalleryViewController: IndicatorInfoProvider, StudentsViewControllerDelegate{
    func selectedStudents(students: [Student], std: String, parents: [Student]) {
        self.createRemark.students = students
        if(std.elementsEqual("1")){
            self.selectedStudents = students
            for std in students{
                extraStudents.append(std.id)
                print("student: \(std.fullName)")
            }
        }else if(std.elementsEqual("0")){
            self.selectedEmployees = students
            for std in students{
                extraEmployees.append(std.id)
                print("student: \(std.fullName)")
               
            }
        }
        
        
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Gallery", counter: "", image: UIImage(named: "Gallery"), backgroundViewColor: App.hexStringToUIColorCst(hex: "#06c6b3", alpha: 1.0), id: App.galleryId)
    }
    
}

extension GalleryViewController:  UITextViewDelegate{
    override func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == addAlbumTableView){
            return 11
        }
        else if (tableView == addPhotosTableView){
            return 4
        }
        else if(tableView == addButtonTableView){
            return 1
        }
        else if(tableView == switchAlbumsTableView){
            return 1
        }
        else{
            return 0
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == addAlbumTableView){
            if(section == 7 || section == 8){
                       
                       let menuSection = self.model?[section-7]
                       
                       if(menuSection != nil){
                           print("countcount: \(menuSection!.items.count)")

                       }
                       return (menuSection?.isVisible ?? false) ? menuSection!.items.count : 0
                   }
        }
       
        else{
           return 1
        }
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == addAlbumTableView){
            switch(indexPath.section){
            case 0:
                print("case1")
                let cell = tableView.dequeueReusableCell(withIdentifier: "teacherHeaderReuse", for: indexPath)
                cell.textLabel?.text = "Album Title"
                return cell
                
            case 1:
                print("case2")
                let cell = tableView.dequeueReusableCell(withIdentifier: "albumTitleReuse", for: indexPath)as!AlbumTitleCell
                cell.albumTitleTextView.placeholder = "Enter album title here"
                
                //ToolBar
//                  let toolbar = UIToolbar();
//                  toolbar.sizeToFit()
//                  let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
//
//                let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
//                 let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
//
//                toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
                
//                cell.albumTitleTextView.inputAccessoryView = toolbar
                //cell.albumTitleTextView.inputView = datePicker
                
                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "schoolReuse", for: indexPath)as!SchoolSwitchCell
                cell.addAlbumText.text = "All Schools"
                if(allSchoolSwitch){
                    cell.allSchoolSwitch.setOn(true, animated: true)
                }
                else{
                    cell.allSchoolSwitch.setOn(false, animated: true)

                }
                cell.allSchoolSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
                
                let sectionVisible0 = self.model?[0].isVisible ?? false
                let sectionVisible1 = self.model?[1].isVisible ?? false
                self.model = [
                    ItemsHeader(isVisible: sectionVisible0, items: self.departments, title: "Departments".localiz()),
                    ItemsHeader(isVisible: sectionVisible1, items: self.classes, title: "Classes".localiz()),
                ]
                
               
                
                return cell
                
            case 7:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "depListReuse", for: indexPath)
                
//                cell.depName.text = "Departments name"
//                cell.depName.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
//                cell.plusImage.image = UIImage(named: "arrow")
//
                
                let depName = cell.viewWithTag(740) as! UILabel
                let plusImage = cell.viewWithTag(742) as! UIButton
                let entireDepSwitch = cell.viewWithTag(741) as! PWSwitch
                
                let department = model![indexPath.section - 7].items[indexPath.item]
                depName.text = department.title
               entireDepSwitch.addTarget(self, action: #selector(disableDepArrow), for: UIControl.Event.valueChanged)
                print("department: \(department.title)")
                cell.selectionStyle = .none
                
//                let depGesture = CustomTapGestureRecognizer(target: self, action: #selector(showDepartments))
//                depGesture.passedValue = Int(department.id)
//               plusImage.addGestureRecognizer(depGesture)
                plusImage.accessibilityHint = department.id
               plusImage.isUserInteractionEnabled = true
                plusImage.addTarget(self, action: #selector(self.showDepartments), for: .touchUpInside)
                
                if(allSchoolSwitch){
                    entireDepSwitch.setOn(true, animated: true)
                    plusImage.isUserInteractionEnabled = false
                    entireDepSwitch.isEnabled = false
                }
                else{
                    plusImage.isUserInteractionEnabled = true
                    entireDepSwitch.isEnabled = true
                }
                return cell
                
            case 8:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "classesListReuse", for: indexPath)
                let className = cell.viewWithTag(740) as! UILabel
                let classPlusImage = cell.viewWithTag(742) as! UIButton
                let entireClassSwitch = cell.viewWithTag(741) as! PWSwitch
                
                
                className.text = "classes name"
                className.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                
                
                
                let department = model![indexPath.section - 7].items[indexPath.item]
               className.text = department.title
               entireClassSwitch.addTarget(self, action: #selector(disableClassesArrow), for: UIControl.Event.valueChanged)
                print("department: \(department.title)")
                cell.selectionStyle = .none
                
//                let classesGesture = CustomTapGestureRecognizer(target: self, action: #selector(showClasses))
//                classesGesture.passedValue = Int(department.id)
//               classPlusImage.addGestureRecognizer(classesGesture)
               classPlusImage.isUserInteractionEnabled = true
                
                classPlusImage.addTarget(self, action: #selector(showClasses), for: .touchUpInside)
                
                if(allSchoolSwitch){
                   entireClassSwitch.setOn(true, animated: true)
                   classPlusImage.isUserInteractionEnabled = false
                   entireClassSwitch.isEnabled = false
                 }
                 else{
                    classPlusImage.isUserInteractionEnabled = true
                    entireClassSwitch.isEnabled = true
                }
                return cell
                
            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pictureReuse")
                let uploadLabel = cell?.viewWithTag(720) as! UILabel
                let imageView = cell?.viewWithTag(721) as! UIImageView
                let imageButton = cell?.viewWithTag(722) as! UIButton
                let photosCollectionView = cell?.viewWithTag(723) as! UICollectionView
                photosCollectionView.dataSource = self
                photosCollectionView.delegate = self
                uploadLabel.isHidden = true
                uploadLabel.text = "Upload a picture".localiz()
                imageButton.addTarget(self, action: #selector(uploadImageButtonPressed), for: .touchUpInside)
                cell?.selectionStyle = .none
                return cell!
                
            case 10:
                let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                let saveButton = cell?.viewWithTag(745) as! UIButton
                saveButton.layer.cornerRadius = saveButton.frame.height / 2
                saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
                cell?.selectionStyle = .none
                return cell!
                            
            default:
                print("hello")
            }
        }
        else if(tableView == addPhotosTableView){
            print("addphotos: \(indexPath.section)")
            switch(indexPath.section){
                
            case 0:
                let cancelCell = tableView.dequeueReusableCell(withIdentifier: "CancelReuse")
                let cancelLabel = cancelCell?.viewWithTag(998) as! UIButton
                let secondCancelLabel = cancelCell?.viewWithTag(1120) as! UIButton
                secondCancelLabel.isHidden = true
                secondCancelLabel.isUserInteractionEnabled = false
                saveButtonIsHidden = false
                if cancelLabel.isHidden == true {
                    secondCancelLabel.isHidden = false
                    secondCancelLabel.isUserInteractionEnabled = true
                    
                }
                
                if secondCancelLabel.isHidden == false {
                    saveButtonIsHidden = true
                }
                
                let editLabel = cancelCell?.viewWithTag(99898) as! UIButton
                
                cancelLabel.titleLabel?.text = "Cancel"
                editLabel.titleLabel?.text = "Edit"
                cancelLabel.addTarget(self, action: #selector(cancelAddPhotos), for: .touchUpInside)
                secondCancelLabel.addTarget(self, action: #selector(secondCancelAddPhotos), for: .touchUpInside)
                editLabel.addTarget(self, action: #selector(editAddPhotos), for: .touchUpInside)
                cancelCell!.selectionStyle = .none
                return cancelCell!
                
            case 1:
                let imagePreviewCell = tableView.dequeueReusableCell(withIdentifier: "photoPreviewReuse")
                let image = imagePreviewCell?.viewWithTag(996) as! UIImageView
                image.image = UIImage(named: "1")
                imagePreviewCell!.selectionStyle = .none
                return imagePreviewCell!
                
            case 2:
               let cell = tableView.dequeueReusableCell(withIdentifier: "pictureReuse")
//                let uploadLabel = cell?.viewWithTag(720) as! UILabel
//                let imageView = cell?.viewWithTag(721) as! UIImageView
//                let imageButton = cell?.viewWithTag(722) as! UIButton
                let photosCollectionView = cell?.viewWithTag(723) as! UICollectionView
                photosCollectionView.dataSource = self
                photosCollectionView.delegate = self
//                uploadLabel.isHidden = true
//                uploadLabel.text = "Upload a picture".localiz()
//                imageButton.addTarget(self, action: #selector(uploadImageButtonPressed), for: .touchUpInside)
               
                cell!.selectionStyle = .none
                return cell!
                
            case 3:
                
                let saveCell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                
                let saveButton = saveCell?.viewWithTag(745) as! UIButton
                saveButton.layer.cornerRadius = saveButton.frame.height / 2
                saveButton.addTarget(self, action: #selector(savePhotosPressed), for: .touchUpInside)
                if saveButtonIsHidden == true{
                    saveButton.isHidden = true
                }
                saveCell?.selectionStyle = .none
                return saveCell!
            default:
                print("hello")
            }
        }
        else if(tableView == addButtonTableView){
            switch(indexPath.section){
            case 0:
                let eventsCell = tableView.dequeueReusableCell(withIdentifier: "eventsReuse")
                let monthLabel = eventsCell?.viewWithTag(11) as! UILabel
                let addImageView = eventsCell?.viewWithTag(600) as! UIImageView
                let xImageView = eventsCell?.viewWithTag(6001) as! UIImageView
                let addLabel = eventsCell?.viewWithTag(601) as! UILabel
                let addButton = eventsCell?.viewWithTag(602) as! UIButton
                if(user.userType == 2){
                    addButton.isHidden = false
                    addLabel.isHidden = false
                    addImageView.isHidden = false
                }
                else{
                    addButton.isHidden = true
                    addLabel.isHidden = true
                    addImageView.isHidden = true
                }
                monthLabel.isHidden = true
                xImageView.isHidden = true
                addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
                addLabel.text = "Add".localiz()
                eventsCell!.selectionStyle = .none
                return eventsCell!
                
            default:
                print("hello")
            }
            
        }
        else if(tableView == switchAlbumsTableView){
            switch(indexPath.section){
            case 0:
                let switchCell = tableView.dequeueReusableCell(withIdentifier: "albumSwitchReuse")
                 
                let nextButton = switchCell?.viewWithTag(890) as! UIButton
                let nextImage = switchCell?.viewWithTag(891) as! UIImageView
                let albumTitle = switchCell?.viewWithTag(892) as! UILabel
                let prevButton = switchCell?.viewWithTag(893) as! UIButton
                let prevImage = switchCell?.viewWithTag(894) as! UIImageView
                
//                let prevGesture = CustomTapGestureRecognizer(target: self, action: #selector(prevAlbum))
//                prevGesture.passedValue = indexPath.item
//                prevButton.addGestureRecognizer(prevGesture)
//                prevButton.isUserInteractionEnabled = true
//
//                let nextGesture = CustomTapGestureRecognizer(target: self, action: #selector(nextAlbum))
//                nextGesture.passedValue = indexPath.item
//                nextButton.addGestureRecognizer(nextGesture)
//                nextButton.isUserInteractionEnabled = true
//
                
                prevButton.addTarget(self, action: #selector(prevAlbum), for: .touchUpInside)
                nextButton.addTarget(self, action: #selector(nextAlbum), for: .touchUpInside)

                
                prevButton.dropCircleShadow()
                nextButton.dropCircleShadow()
                
                
                return switchCell!
                
            default:
                print("hello")
            }
        }
        
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == addAlbumTableView){
            if(indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6){
                       return 0
                   }
        }
        else if(tableView == addPhotosTableView){
            if(indexPath.section == 1){
                return 300
            }
            else if(indexPath.section == 2 || indexPath.section == 3){
                return 100
            }
        }
        
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
        case 0:
            return 250
        default:
            return 100
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if( section == 0 || section == 1 || section == 2 || section == 5 || section == 6 || section == 3 || section == 4 || section == 10 || section == 9){
           return 0
       }
       else{
          return 50
       }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch(section){
        case 7:
            // Init Collapse/Expand sections:
            var view: CollapsableSectionHeaderProtocol?
            if let reuseID = self.sectionHeaderReuseIdentifier() {
                view = Bundle.main.loadNibNamed(reuseID, owner: nil, options: nil)!.first as? CollapsableSectionHeaderProtocol
            }
            view?.tag = section
            view?.interactionDelegate = self
            
            let menuSection = self.model?[section-7]
            view?.sectionTitleLabel.text = (menuSection?.title ?? "").capitalized
            view?.close(true)
            view?.containerView.backgroundColor = .white
            return view as? UIView
            
        case 8:
        // Init Collapse/Expand sections:
        var view: CollapsableSectionHeaderProtocol?
        if let reuseID = self.sectionHeaderReuseIdentifier() {
            view = Bundle.main.loadNibNamed(reuseID, owner: nil, options: nil)!.first as? CollapsableSectionHeaderProtocol
        }
        view?.tag = section
        view?.interactionDelegate = self
        
        let menuSection = self.model?[section-7]
        view?.sectionTitleLabel.text = (menuSection?.title ?? "").capitalized
        view?.close(true)
        view?.containerView.backgroundColor = .white
        return view as? UIView
        default:
            return UIView()
        }
        }

        }

extension GalleryViewController: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == galleryAlbums){
            return galleryAlb.count
        }
        else if(collectionView == albumPhotos){
            return photoAlbum.count
        }
        else{
           return selectedImages.count
        }

        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        switch(collectionView){
        case galleryAlbums:
            print("maherentered1")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumIdentifier", for: indexPath)as!GalleryView
           var image = galleryAlb[indexPath.item].image
                 
            if(baseURL?.prefix(8) == "https://"){
                if(image.prefix(8) != "https://"){
                    image = "https://" + image
                }
            }
            else if(baseURL?.prefix(7) == "http://"){
                if (image.prefix(7) != "http://" ){
                    image = "http://" + image
                }
            }
            let indicatorView = App.loading()
            indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            indicatorView.tag = 100
            cell.addSubview(indicatorView)
          
            cell.albumImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                cell.photoAlbum.image = image
          cell.albumImage.sd_setImage(with: URL(string: image),
                                         completed: { (image, error, cacheType, imageUrl) in
                                            if let viewWithTag = self.view.viewWithTag(100){
                                                viewWithTag.removeFromSuperview()
                                            }
                                            })
            
            
            cell.albumImage.layer.cornerRadius = 10
            cell.albumTitle.text = galleryAlb[indexPath.item].albumName
            cell.albumTitle.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            cell.photoCount.text = String(galleryAlb[indexPath.item].albumCount)+" Photos"
            cell.photoCount.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            let formatterInput = DateFormatter()
            formatterInput.dateFormat = "yy-MM-dd"
            let formatterOutput = DateFormatter()
            formatterOutput.dateFormat = "dd-MMMM-yyyy"
            let date = formatterInput.date(from: galleryAlb[indexPath.item].dateCreated)
            cell.date.text = formatterOutput.string(from: date!)
            cell.date.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            
            let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressAlbum(longPressGR:)))
            longPressGR.minimumPressDuration = 0.5
            longPressGR.delaysTouchesBegan = true
            collectionView.addGestureRecognizer(longPressGR)
            
            return cell
            
        case albumPhotos:
            print("maherentered2")
            print(user.userType)
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "photoIdentifier", for: indexPath)as!PhotoAlbumCell
            if(user.userType == 2){
                print("entered teacher")
                if(indexPath.item == 0 ){
                    
                        cell.photoAlbum.image = UIImage(named: "add-picture")
                }
                else{
                    var image = self.photoAlbum[indexPath.item].imageLink
                    
    //                let image = App.base64Convert(base64String: imageLink)

                   
                    if(baseURL?.prefix(8) == "https://"){
                        if(image.prefix(8) != "https://"){
                            image = "https://" + image
                        }
                    }
                    else if(baseURL?.prefix(7) == "http://"){
                        if (image.prefix(7) != "http://" ){
                            image = "http://" + image
                        }
                    }
                    let indicatorView = App.loading()
                    indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                    indicatorView.tag = 100
                    cell.addSubview(indicatorView)
                  
                    cell.photoAlbum.sd_imageIndicator = SDWebImageActivityIndicator.gray
    //                cell.photoAlbum.image = image
                  cell.photoAlbum.sd_setImage(with: URL(string: image),
                                                 completed: { (image, error, cacheType, imageUrl) in
                                                    if let viewWithTag = self.view.viewWithTag(100){
                                                        viewWithTag.removeFromSuperview()
                                                    }
                                                    })
                  cell.photoAlbum.layer.cornerRadius = 10
                    
                    let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressImage(longPressGR:)))
                    longPressGR.minimumPressDuration = 0.5
                    longPressGR.delaysTouchesBegan = true
                    collectionView.addGestureRecognizer(longPressGR)
                }
               
            }
            else{
                print("entered student")

                    var image = self.photoAlbum[indexPath.item].imageLink
                    
    //                let image = App.base64Convert(base64String: imageLink)

                   
                    if(baseURL?.prefix(8) == "https://"){
                        if(image.prefix(8) != "https://"){
                            image = "https://" + image
                        }
                    }
                    else if(baseURL?.prefix(7) == "http://"){
                        if (image.prefix(7) != "http://" ){
                            image = "http://" + image
                        }
                    }
                    let indicatorView = App.loading()
                    indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                    indicatorView.tag = 100
                    cell.addSubview(indicatorView)
                  
                    cell.photoAlbum.sd_imageIndicator = SDWebImageActivityIndicator.gray
    //                cell.photoAlbum.image = image
                  cell.photoAlbum.sd_setImage(with: URL(string: image),
                                                 completed: { (image, error, cacheType, imageUrl) in
                                                    if let viewWithTag = self.view.viewWithTag(100){
                                                        viewWithTag.removeFromSuperview()
                                                    }
                                                    })
                  cell.photoAlbum.layer.cornerRadius = 10
                    
                    let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressImage(longPressGR:)))
                    longPressGR.minimumPressDuration = 0.5
                    longPressGR.delaysTouchesBegan = true
                    collectionView.addGestureRecognizer(longPressGR)
                
            }
           
            
            
            return cell
            
            
        default:
            print("maherentered3")
            print("section entered:")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosReuse", for: indexPath)as!GalleryView
            cell.galleryImage.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
            cell.galleryImage.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
            cell.galleryImage.image = selectedImages[indexPath.item]
            cell.deleteImageButton.image = UIImage(named: "x")
            let deleteGesture = CustomTapGestureRecognizer(target: self, action: #selector(deleteImage))
            deleteGesture.passedValue = indexPath.item
            cell.deleteImageButton.addGestureRecognizer(deleteGesture)
            cell.deleteImageButton.isUserInteractionEnabled = true
            
            
            let previewGesture = CustomTapGestureRecognizer(target: self, action: #selector(previewImage))
            previewGesture.passedValue = indexPath.item
            cell.galleryImage.addGestureRecognizer(previewGesture)
            cell.galleryImage.isUserInteractionEnabled = true
            
            return cell
        }
            
        
//        switch collectionView{
//        case galleryAlbums:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumIdentifier", for: indexPath)
//            as!GalleryView
//            if(indexPath.row == 0){
//                cell.galleryImage.image = UIImage(named: "ic_add_event_picture")
//
//            }
//            else{
//                cell.galleryImage.image = UIImage(named: albums[indexPath.row].photoLink)
//                cell.galleryImage.layer.cornerRadius = 10
//
//
//            }
//
//            return cell
//
//        case albumPhotos:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoIdentifier", for: indexPath)as!PhotoAlbumCell
//            cell.photoAlbum.image = UIImage(named: photos[indexPath.row].photoLink)
//            cell.photoAlbum.layer.cornerRadius = 10
//            return cell
//
//
//
//        default:
//            print("no items attached")
//        }
    }

}

extension GalleryViewController: UICollectionViewDelegate{
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  print("item at \(indexPath.section)/\(indexPath.item) tapped")
    if(collectionView == galleryAlbums){
        galleryAlbums.isHidden = true
        albumPhotos.isHidden = false
        self.albumId = self.galleryAlb[indexPath.item].id
        addButtonTableView.isHidden = true
        switchAlbumsTableView.isHidden = false
        albumIndex = indexPath.item
        getAlbumPhotos(user: user, albumId: self.albumId)
        
        let albumTitle = self.switchAlbumsTableView.viewWithTag(892) as! UILabel
        albumTitle.text = self.galleryAlb[indexPath.item].albumName

    }
    else if(collectionView == albumPhotos){
        print(indexPath)
        if(user.userType == 2){
            if(indexPath.item == 0){
                let alert = UIAlertController(title: "Upload picture".localiz(), message: nil, preferredStyle: .actionSheet)
                
    //            alert.addAction(UIAlertAction(title: "Choose from Camera".localiz(), style: .default, handler: { _ in
    //                self.openCamera()
    //            }))
                
                alert.addAction(UIAlertAction(title: "Choose from library".localiz(), style: .default, handler: { _ in
                    self.openGallery1()
                }))
                
                alert.addAction(UIAlertAction.init(title: "Cancel".localiz(), style: .cancel, handler: nil))
    //            switch UIDevice.current.userInterfaceIdiom {
    //            case .pad:
    //              alert.popoverPresentationController?.sourceView = sender
    //              alert.popoverPresentationController?.sourceRect = sender.bounds
    //            default:
    //                break
    //            }
                self.present(alert, animated: true, completion: nil)
            }
            else{
                //let vc=ImagePreviewViewController()
                       let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController

                    
                       vc.imgArray = self.photosPreview
                       vc.passedContentOffset = indexPath
                       vc.modalPresentationStyle = .fullScreen


                
                          self.show(vc, sender: self)

                       //self.navigationController?.pushViewController(vc, animated: true)
                
                
            
            }
        }else{
            //let vc=ImagePreviewViewController()
                   let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController

                
                   vc.imgArray = self.photosPreview
                   vc.passedContentOffset = indexPath
                   vc.modalPresentationStyle = .fullScreen


            
                      self.show(vc, sender: self)

                   //self.navigationController?.pushViewController(vc, animated: true)
        }

       
    } else if collectionView == addPhotosTableView {
        print("item at \(indexPath.section)/\(indexPath.item) tapped")
    }
}
    
 
}

// extention for UICollectionViewDelegateFlowLayout
extension GalleryViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == galleryAlbums){
            print("entered1")

            let bounds = collectionView.bounds
            print("bounds: \(bounds)")
            let heightVal = self.view.frame.height
            print("height: \(heightVal)")
            let widthVal = self.view.frame.width
            print("width: \(widthVal)")
            let cellsize = (heightVal < widthVal) ?  bounds.height/2 : bounds.width/2
            print("cellSize: \(cellsize)")

            return CGSize(width: cellsize - 10   , height:  230  )
        }
        else if(collectionView == albumPhotos){
            let bounds = collectionView.bounds
            let heightVal = self.view.frame.height
            let widthVal = self.view.frame.width
            let cellsize = (heightVal < widthVal) ?  bounds.height/3 : bounds.width/3

            return CGSize(width: cellsize - 10   , height:  cellsize - 10  )
        }
        else{
            return CGSize(width: 100  , height:  100  )
        }
        
        
        
                    
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}//end of extension  ViewController


class CustomTapGestureRecognizer: UITapGestureRecognizer {
    var passedValue: Int?
}

extension UICollectionView {
    func rightToLeftAnimation(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition object
        let leftToRightTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided
        if let delegate: AnyObject = completionDelegate {
            leftToRightTransition.delegate = (delegate as! CAAnimationDelegate)
        }
        
        leftToRightTransition.type = CATransitionType.push
        leftToRightTransition.subtype = CATransitionSubtype.fromLeft
        leftToRightTransition.duration = duration
        leftToRightTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        leftToRightTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(leftToRightTransition, forKey: "leftToRightTransition")
    }
}

// APIS Calls
extension GalleryViewController{
    
// - This function call "get_sections_and_departments" API to get sections and departments data.
    func getSectionsDepartments(user: User){
        
        
        Request.shared.getSectionDepartment(user: user) { (message, sectionData, departmentData, status) in
            if status == 200{
                self.departments = departmentData!
                self.classes = sectionData!
                self.addAlbumTableView.reloadData()
            }
            else{
                print("error", "getSectionsDepartments")
            }
            
        }
    }
    
    func getAlbums(user: User){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)

        Request.shared.getAlbums(user: user){
            (message, albums, status) in
            if(status == 200){
                self.galleryAlb = albums!
                for alb in self.galleryAlb{
                    self.albumsNames.append(alb.albumName)
                }
                print("getAlbums")

                self.galleryAlbums.reloadData()

            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    func getAlbumPhotos(user: User, albumId: String){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)


        Request.shared.getAlbumPhotos(user: user, albumId: albumId){
            (message, albums, status) in
            if(status == 200){
                self.photoAlbum = albums!
                self.photosPreview = [];
                for photo in self.photoAlbum{
                    self.photosPreview.append(photo.imageLink)
                }
                let add = PhotoAlbumModel(id: "", imageLink: "", imageContentType: "", imageSize: "", createdAt: "", description: "", imageName: "")
                if(user.userType == 2){
                    self.photoAlbum.insert(add, at: 0)
                }
                //self.photosPreview.insert("", at: 0)
                self.albumPhotos.reloadData()

            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    func deleteAlbum(user: User, albumId: String, index: Int){
        let alert = UIAlertController(title: "Are you sure?".localiz(), message: "Are you sure you want to delete this album ?",preferredStyle: UIAlertController.Style.alert)
               
               alert.addAction(UIAlertAction(title: "Cancel".localiz(), style: UIAlertAction.Style.default, handler: { _ in
                   alert.dismiss(animated: true, completion: nil)
               }))
               alert.addAction(UIAlertAction(title: "OK".localiz(),style: UIAlertAction.Style.default,handler: {(_: UIAlertAction!) in
                   self.view.superview?.superview?.insertSubview(self.loading, at: 1)
                print("indexpath1: \(index)")
                print("id1: \(albumId)")
                Request.shared.deleteAlbum(user: user, albumId: albumId) { (message, result, status) in
                    if status == 200{
                        App.showMessageAlert(self, title: "", message: "Album deleted!", dismissAfter: 1.0)
                        self.galleryAlb.remove(at: index)
                        self.galleryAlbums.reloadData()
                        
                            
                       }
                       else{
                           let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                           App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                       }
                       self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
                   }
               }))
               self.present(alert, animated: true, completion: nil)
    }
    
    func deletePhoto(user: User, photoId: String, index: Int){
          let alert = UIAlertController(title: "Are you sure?".localiz(), message: "Are you sure you want to delete this image ?",preferredStyle: UIAlertController.Style.alert)
                 
                 alert.addAction(UIAlertAction(title: "Cancel".localiz(), style: UIAlertAction.Style.default, handler: { _ in
                     alert.dismiss(animated: true, completion: nil)
                 }))
                 alert.addAction(UIAlertAction(title: "OK".localiz(),style: UIAlertAction.Style.default,handler: {(_: UIAlertAction!) in
                     self.view.superview?.superview?.insertSubview(self.loading, at: 1)
                  print("indexpath1: \(index)")
                  print("id1: \(photoId)")
                  Request.shared.deletePhoto(user: user, photoId: photoId) { (message, result, status) in
                      if status == 200{
                          App.showMessageAlert(self, title: "", message: "Photo deleted!", dismissAfter: 1.0)
                        self.photoAlbum.remove(at: index)
                        self.albumPhotos.reloadData()
                          
                              
                         }
                         else{
                             let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                             App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                         }
                         self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
                     }
                 }))
                 self.present(alert, animated: true, completion: nil)
      }
    func createAlbum(user: User, image: [UIImage], title: String, allSchoolSwitch: Bool, std: [String], emp: [String]){
            let indicatorView = App.loading()
            indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            indicatorView.tag = 100
            self.view.addSubview(indicatorView)
           SectionVC.canChange = true
        var allSchool = "0"
        if(allSchoolSwitch){
            allSchool = "1"
        }
        else{
            allSchool = "0"
        }
        
        var sectionsArray: [String] = []
        var departmentsArray: [String] = []
        //TODO check if switching these is correct
        let filteredDepartment = model![0].items.filter({$0.active == true})
        let filteredSections = model![1].items.filter({$0.active == true})
        
        for section in filteredSections{
            sectionsArray.append(section.id)
        }
        for department in filteredDepartment{
            departmentsArray.append(department.id)
        }

        
        Request.shared.createAlbum(user: user, title: title, allSchool: allSchool, departments: departmentsArray, classes: sectionsArray, std: std, emp: emp){
            (message, albums, status) in
            if(status == 200){
               
                let addImageView = self.addButtonTableView.viewWithTag(600) as! UIImageView
                let xImageView = self.addButtonTableView.viewWithTag(6001) as! UIImageView
                let addLabel = self.addButtonTableView.viewWithTag(601) as! UILabel
                
                App.showMessageAlert(self, title: "", message: "Saved!".localiz(), dismissAfter: 1.0)
                xImageView.isHidden = true
                addLabel.text = "Add"
                addImageView.image = UIImage(named: "add-school")
                
                print("albumid: \(albums!)")
                if(self.selectedImages.count == 0){
                    
                    self.getAlbums(user: user)
                }
                else{
                    self.source = "album"
                    self.count = 0
                    for image in self.selectedImages{
                        print("entered1")
                        self.addAlbumPhotos(user: user, image: image, albumId: albums!)
                    }
                }
                
                

            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                }
            if let viewWithTag = self.view.viewWithTag(100){
                print("entered4")
                viewWithTag.removeFromSuperview()
            }
        }
         
       }
    
    func addAlbumPhotos(user: User, image: UIImage, albumId: String){
        if(self.source.elementsEqual("album")){
            let indicatorView = App.loading()
            indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            indicatorView.tag = 120
            self.view.addSubview(indicatorView)
        }
         
    
        Request.shared.addAlbumPhotos(user: user, photo: image, album_id: albumId){
         (message, albums, status) in
         if(status == 200){
            self.count+=1
            print("count0: \(self.count)")
            print("count1: \(self.selectedImages.count)")

            if(self.count == self.selectedImages.count){
                print("entered1")
                if(self.source.elementsEqual("album")){
                    self.getAlbums(user: user)
                    self.addAlbumTableView.isHidden = true
                    self.galleryAlbums.isHidden = false
                }
                else if(self.source.elementsEqual("photo")){
                    self.getAlbumPhotos(user: user, albumId: albumId)
                    self.addPhotosTableView.isHidden = true
                    self.albumPhotos.isHidden = false
                }
               
                
            }
         }
         else{
             let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
             App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
             }
            if let viewWithTag = self.view.viewWithTag(120){
                print("entered3")
                viewWithTag.removeFromSuperview()
            }
        
     }
      
    }
}

//// MARK: - Handle Sections page delegate functions:
//extension GalleryViewController: sectionToGalleryDelegate{
//
//
//}
