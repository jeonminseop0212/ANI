//
//  RecruitContributionViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/11.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import Gallery

class RecruitContributionViewController: UIViewController {
  
  var gallery: GalleryController!
  var myImages = [UIImage]()
  
  private weak var pickupButton: UIButton?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.isStatusBarHidden = false
  }
  
  private func setup() {
    //basic
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    self.navigationController?.navigationBar.isTranslucent = true
    self.view.backgroundColor = .white
    
    //puckupButton
    let pickupButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    pickupButton.setTitle("pick up!", for: .normal)
    pickupButton.backgroundColor = .lightGray
    pickupButton.addTarget(self, action: #selector(pickupImage), for: .touchUpInside)
    pickupButton.center = self.view.center
    self.view.addSubview(pickupButton)
    self.pickupButton = pickupButton
    
    galleryControllerOn(animation: false)
  }
  
  private func galleryControllerOn(animation: Bool) {
    gallery = GalleryController()
    gallery.delegate = self
    Gallery.Config.initialTab = .imageTab
    Gallery.Config.PageIndicator.backgroundColor = .white
    Gallery.Config.Camera.imageLimit = 10
    Gallery.Config.Camera.oneImageMode = true
    if Gallery.Config.Camera.oneImageMode {
      Gallery.Config.Grid.previewRatio = 0.5
      Config.tabsToShow = [.imageTab]
    }
    let galleryNV = UINavigationController(rootViewController: gallery)
    present(galleryNV, animated: animation, completion: nil)
  }
  
  @objc private func pickupImage() {
    galleryControllerOn(animation: true)
  }
  
  func getCropImages(images: [UIImage?], items: [Image]) -> [UIImage] {
    var croppedImages = [UIImage]()
    
    for (index, image) in images.enumerated() {
      let imageSize = image?.size
      let scrollViewWidth = self.view.frame.width
      let widthScale =  scrollViewWidth / (imageSize?.width)! * items[index].scale
      let heightScale = scrollViewWidth / (imageSize?.height)! * items[index].scale
      
      let scale = 1 / min(widthScale, heightScale)
      let visibleRect = CGRect(x: items[index].offset.x * scale, y: items[index].offset.y * scale, width: scrollViewWidth * scale, height: scrollViewWidth * scale * Config.Grid.previewRatio)
      let ref: CGImage = (image?.cgImage?.cropping(to: visibleRect))!
      let croppedImage:UIImage = UIImage(cgImage: ref)
      
      croppedImages.append(croppedImage)
    }
    return croppedImages
  }
}

extension RecruitContributionViewController: GalleryControllerDelegate {
  func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
    
    Image.resolve(images: images) { (myImages) in
//      let filterViewController = FilterViewController()
//      filterViewController.images = self.getCropImages(images: myImages, items: images)
//      controller.navigationController?.pushViewController(filterViewController, animated: true)
    }
    
    gallery = nil
  }
  
  func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
    controller.dismiss(animated: true, completion: nil)
    
    gallery = nil
  }
  
  func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
  }
  
  func galleryControllerDidCancel(_ controller: GalleryController) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
  }
}
