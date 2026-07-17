//
//  generateBarcode.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import CoreImage.CIFilterBuiltins
import SwiftUI

private let context = CIContext()
private let filter = CIFilter.code128BarcodeGenerator()

func generateBarcode(from string: String) -> Image? {

    filter.message = Data(string.utf8)

    guard let outputImage = filter.outputImage,
          let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
    else {
        return nil
    }

    return Image(decorative: cgImage, scale: 1)
}
