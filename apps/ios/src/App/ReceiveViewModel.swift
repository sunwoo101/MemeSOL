//
//  ReceiveViewModel.swift
//  
//
//  Created by Gurpreet on 3/5/2026.
//

//give wallet address to view
//handle copy
//prepare  qr
//communicate w service

import Foundation
import Combine

import CoreImage.CIFilterBuiltins
import UIKit

class ReceiveViewModel: ObservableObject {
    @Published var address: String
    @Published var qrImage: UIImage?
    
    let context = CIContext() //convert to image
    let filter = CIFilter.qrCodeGenerator() //generate QR code
    
    init() {
        self.address = WalletService().getWalletAddress().address
        self.qrImage = generateQRCode(from: address)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        filter.setValue(Data(string.utf8), forKey: "inputMessage") //create qr with data from address string
        if let outputImage = filter.outputImage { //filter create CI Image
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) { //convert from CI Image to CG Image 
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
