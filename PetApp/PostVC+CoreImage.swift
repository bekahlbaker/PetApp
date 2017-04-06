//
//  PostVC+CoreImage.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/1/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//  https:code.tutsplus.com/tutorials/ios-sdk-apply-photo-filters-with-core-image-in-swift--cms-27142
//
// swiftlint:disable force_cast

import UIKit

extension PostVC {
    func filterButtonTapped(_ sender: UIButton) {
        let button = sender as UIButton
        imageToFilter.image = button.image(for: UIControlState.normal)
        PostVC.imageSelected = true
        filterChosen = true
    }
    
    func addFiltersToButtons(_ imageUnfiltered: UIImage) {
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 5
        let buttonWidth: CGFloat = 80
        let buttonHeight: CGFloat = 80
        let gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        for i in 0..<CIFilterNames.count {
            itemCount = i
            
            // Button properties
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            filterButton.tag = itemCount
            filterButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
            filterButton.clipsToBounds = true
            
            // Create filters for each button
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(image: imageUnfiltered)
            let filter = CIFilter(name: "\(CIFilterNames[i])" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!)
            
            // Assign filtered image to the button
            if itemCount == 0 {
                if let img = PostVC.unFilteredImageCache.object(forKey: "unfilteredImage") {
                    filterButton.setImage(img, for: .normal)
                    filterButton.imageView?.contentMode = UIViewContentMode.scaleAspectFill
                }
            } else {
                filterButton.setImage(imageForButton, for: .normal)
                filterButton.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            }
            // Add Buttons in the Scroll View
            xCoord +=  buttonWidth + gapBetweenButtons
            filterScrollView.addSubview(filterButton)
        }
        // Resize Scroll View
        filterScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount+2), height: yCoord)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImageBtn.setTitle("", for: .normal)
            originalImage.image = image
            PostVC.imageSelected = true
            PostVC.unFilteredImageCache.setObject(image, forKey: "unfilteredImage")
            self.addFiltersToButtons(self.originalImage.image!)
        } else {
            print("Valid image not selected.")
        }
        picker.dismiss(animated: true, completion: nil)
        self.addImageBtn.setTitle("", for: .normal)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        PostVC.imageSelected = false
        dismiss(animated: true, completion: nil)
    }
    
    func loadImage() {
        if let img = PostVC.imageToPassBackCache.object(forKey: "imageToPassBack") {
            originalImage.image = img
            PostVC.imageSelected = true
            if let unfilteredImg = PostVC.unFilteredImageCache.object(forKey: "unfilteredImage") {
                self.addFiltersToButtons(unfilteredImg)
            }
        } else {
            addImageBtn.setTitle("Add Image", for: .normal)
        }
        PostVC.imageToPassBackCache.removeObject(forKey: "imageToPassBack")
    }
}
