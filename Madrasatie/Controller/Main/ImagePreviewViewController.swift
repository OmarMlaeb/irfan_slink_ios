//
//  ImagePreviewViewController.swift
//  Madrasatie
//
//  Created by Maher Jaber on 4/22/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//


import UIKit
import SDWebImage


class ImagePreviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIDocumentInteractionControllerDelegate  {
   
    //@IBOutlet weak var facebook: UIButton!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var shareToolbar: UIToolbar!
    //@IBOutlet weak var instagram: UIButton!
    var imgArray = [String]()
    var passedContentOffset = IndexPath()
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")
    var shareImage = UIImage()
    var contentOffset: Int = 0;
    var moveDirection: Int = 0;
    var itemIndex: Int = 0;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
    

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor=UIColor.black
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
           
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        layout.scrollDirection = .horizontal
        
        myCollectionView.frame = self.view.frame
        myCollectionView.collectionViewLayout = layout
        //myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(ImagePreviewFullViewCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.isPagingEnabled = false
        print("passedContentOffset: \(passedContentOffset)")
        itemIndex = passedContentOffset.item - 1;
        myCollectionView.reloadData()
        myCollectionView.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            self.myCollectionView.scrollToItem(at: IndexPath(item: self.passedContentOffset.item - 1, section: 0), at: .left, animated: false)
            
            self.myCollectionView.isPagingEnabled = true
        }
        
        
        self.view.addSubview(myCollectionView)
        
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
    }
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           
       }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
    func initNavigation(){
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let backButton = UIBarButtonItem(title: nil, style: .done, target: self, action: #selector(backButtonPressed))
        let languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
        if languageId == "ar"{
            backButton.image = UIImage(named: "white-nav-back-ar")
        }else{
            
            backButton.image = UIImage(named: "white-nav-back")
        }
        backButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barTintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        self.navigationController?.navigationBar.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 18)!]
        
        self.navigationController?.setToolbarHidden(false, animated: true)

       var items = [UIBarButtonItem]()

       items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
       items.append( UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButton)) ) // replace add with your function
       items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
       self.toolbarItems = items
        self.navigationController?.toolbar.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    }
    
    @objc func backButtonPressed(){
        self.navigationController?.toolbarItems?.removeAll()
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func shareButton(_ sender: Any) {
        // set up activity view controller
    
        print("hello: \(self.itemIndex)")
        

        var imageUrl = self.imgArray[self.itemIndex]
              
         if(baseURL?.prefix(8) == "https://"){
             if(imageUrl.prefix(8) != "https://"){
                imageUrl = "https://" + imageUrl
             }
         }
         else if(baseURL?.prefix(7) == "http://"){
             if (imageUrl.prefix(7) != "http://" ){
                imageUrl = "http://" + imageUrl
             }
         }
        
        
        
        let imageURL = URL(string: imageUrl)!

        let imageData = try! Data(contentsOf: imageURL)

        let image = UIImage(data: imageData)
        
        
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.airDrop]

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func closeForm(_ sender: UIButton) {
        self.dismiss(animated: true)

    }
    
    @IBAction func cancelbtn(_ sender: Any) {
           
        self.navigationController?.popViewController(animated: true)
            
         
    }
    @IBAction func shareFacebook(_ sender: UIButton) {
        
    

        // set up activity view controller
        let imageToShare = [shareImage]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.airDrop]

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }

        self.present(activityViewController, animated: true, completion: nil)
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1

        
       
       
    }
 
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("imgArray1: \(imgArray.count)")
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImagePreviewFullViewCell
        
//
//        let editButton = UIButton(frame: CGRect(x:0, y:0, width:100,height:100))
//        editButton.addTarget(self, action: #selector(editButtonTapped), for: UIControl.Event.touchUpInside)
//
//        editButton.setImage(UIImage(named: "1.jpg"), for: UIControl.State.normal)
//        cell.addSubview(editButton)

//        print("imgArray2: \(indexPath.item)")
//        let imageString64 = self.imgArray[indexPath.row]
//         if(baseURL?.prefix(8) == "https://"){
//            if(image.prefix(8) != "https://"){
//                image = "https://" + image
//            }
//        }
//        else if(baseURL?.prefix(7) == "http://"){
//            if (image.prefix(7) != "http://" ){
//                image = "http://" + image
//            }
//        }
        
//        let indicatorView = App.loading()
//        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
//        indicatorView.tag = 100
//        cell.addSubview(indicatorView)
        
//        cell.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        print("hello world: \(indexPath.item)")
        print("hello world: \(indexPath.item)")
        print("hello world: \(indexPath.row)")
        print("hello world: \(indexPath.section)")

//        let image = App.base64Convert(base64String: imageString64)
        
        var image = self.imgArray[indexPath.row]
              
//         let indicatorView = App.loading()
//         indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
//         indicatorView.tag = 100
//         cell.addSubview(indicatorView)
        
        print("image image: \(image)")
       
                cell.imgView.sd_setImage(with: URL(string: image),
                                             completed: { (image, error, cacheType, imageUrl) in
                                                if let viewWithTag = self.view.viewWithTag(100){
                                                    viewWithTag.removeFromSuperview()
                                                }
                                                })
        
//        self.shareImage = cell.imgView.image!

//        print("hello world1: \(self.shareImage.description)")
        print("hello world2: \(cell.imgView.image?.description)")



//        cell.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "1"))
        

        return cell
    }
 
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.itemSize = myCollectionView.frame.size
        
        flowLayout.invalidateLayout()
        
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("viewWillTransition")
        let offset = myCollectionView.contentOffset
        let width  = myCollectionView.bounds.size.width
        
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        myCollectionView.setContentOffset(newOffset, animated: false)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.myCollectionView.reloadData()
            self.myCollectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
           return self
       }
}


extension ImagePreviewViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        print("hello hello hello1")
        print(scrollView.contentOffset.x)
        self.contentOffset = Int(scrollView.contentOffset.x)
        
        if(self.contentOffset < Int(view.frame.width)){
            self.itemIndex = 0
        }
        else{
            let ind = self.contentOffset / Int(view.frame.width)
            print("item index: \(ind)")
            self.itemIndex = ind
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("Called1: \(scrollView.contentOffset.x)")
       }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView){
        print("Called2: \(scrollView.contentOffset.x)")
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
       
        
//        if(self.contentOffset > self.moveDirection){
//            self.itemIndex = self.itemIndex + 1
//            self.moveDirection = self.contentOffset
//        }
//        else if(self.contentOffset < self.moveDirection){
//            self.itemIndex = self.itemIndex - 1
//            self.moveDirection = self.contentOffset
//        }
//
//        print("Called: \(self.contentOffset)")
//        print("Called: \(self.moveDirection)")
//        print("Called: \(self.itemIndex)")
//        print("Called: \(view.frame.width)")


        print("---------------------------------------")


    }
}

class ImagePreviewFullViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var scrollImg: UIScrollView!
    var imgView: UIImageView!
//    var facebook: UIButton!
//    var instagram: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        
        
        scrollImg = UIScrollView()
        
        scrollImg.contentMode = .scaleAspectFit
        scrollImg.delegate = self
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = false
        scrollImg.showsHorizontalScrollIndicator = false
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 4.0
        
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollImg.addGestureRecognizer(doubleTapGest)
        
//        let tapGest = UITapGestureRecognizer(target: self, action: #selector(handleTapScrollView(recognizer:)))
//        tapGest.numberOfTapsRequired = 1
//        scrollImg.addGestureRecognizer(tapGest)
        
        
        imgView = UIImageView()
        scrollImg.addSubview(imgView!)
        imgView.contentMode = .scaleAspectFit
        self.addSubview(scrollImg)

    }
    
//    @objc func handleTapScrollView(recognizer: UITapGestureRecognizer){
//        let a = ImagePreviewViewController()
//        let shareToolbar = a.shareToolbar
//
//        if(shareToolbar!.isHidden){
//            shareToolbar!.isHidden = false
//
//            }
//            else{
//            shareToolbar!.isHidden = true
//            }
//
//
//    }
    
   
    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollImg.zoomScale == 1 {
            scrollImg.zoom(to: zoomRectForScale(scale: scrollImg.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollImg.setZoomScale(1, animated: true)
        }
    }
    
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imgView.frame.size.height / scale
        zoomRect.size.width  = imgView.frame.size.width  / scale
        let newCenter = imgView.convert(center, from: scrollImg)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollImg.frame = self.bounds
        imgView.frame = self.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollImg.setZoomScale(1, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   

}

