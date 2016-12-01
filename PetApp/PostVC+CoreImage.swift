//
//  PostVC+CoreImage.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/1/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//  https:code.tutsplus.com/tutorials/ios-sdk-apply-photo-filters-with-core-image-in-swift--cms-27142
//

import UIKit

extension PostVC {
    
    func filterButtonTapped(sender: UIButton) {
        let button = sender as UIButton
        
        imageToFilter.image = button.backgroundImage(for: UIControlState.normal)
    }
    
    func addFiltersToButtons() {
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 5
        let buttonWidth:CGFloat = 70
        let buttonHeight: CGFloat = 70
        let gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        for i in 0..<CIFilterNames.count {
            itemCount = i
            
            // Button properties
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            filterButton.tag = itemCount
            filterButton.addTarget(self, action: #selector(PostVC.filterButtonTapped(sender:)), for: .touchUpInside)
//            filterButton.layer.cornerRadius = 6
            filterButton.clipsToBounds = true
            
            // CODE FOR FILTERS WILL BE ADDED HERE...
            
            // Create filters for each button
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(image: originalImage.image!)
            let filter = CIFilter(name: "\(CIFilterNames[i])" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!);
            
            // Assign filtered image to the button
            if itemCount == 0 {
                filterButton.setBackgroundImage(originalImage.image, for: .normal)
            } else {
             filterButton.setBackgroundImage(imageForButton, for: .normal)   
            }
            
            // Add Buttons in the Scroll View
            xCoord +=  buttonWidth + gapBetweenButtons
            filterScrollView.addSubview(filterButton)
        } // END FOR LOOP
        
        // Resize Scroll View
        filterScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount+2), height: yCoord)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            originalImage.image = image
            imageSelected = true
        } else {
            print("Valid image not selected.")
        }
        picker.dismiss(animated: true, completion: nil)
        self.addFiltersToButtons()
    }
    
}
