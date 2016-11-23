//
//  StainedGlass.swift
//  stainedGlass
//
//  Created by Rachel Yen on 11/20/16.
//  Copyright © 2016 Rachel Yen. All rights reserved.
//

import Foundation
import UIKit

class StainedGlass {
    //  meow  
    private var coordinates_x : [Int]?
    private var coordinates_y: [Int]?
    private var color_data: [(Int, Int, Int)]?
    private var img : UIImage
    private var x_intervals : [Int]?
    private var y_intervals : [Int]?
    
    init(image : UIImage) {
        img = image
        //TODO: other setup as necessary
    }
    
    // have you some getter methods
    // am I doing this correctly? lol, whatever
    var getCoordX: [Int]? {
        get {
            return coordinates_x
        }
    }
    
    var getCoordY: [Int]? {
        get {
            return coordinates_y
        }
    }
    
    var getXIntervals : [Int]? {
        get {
            return x_intervals
        }
    }
    
    var getYIntervals : [Int]? {
        get {
            return y_intervals
        }
    }
    
    var getColorData: [(Int, Int, Int)]? {
        get {
            return color_data
        }
    }
    
    struct Pixel {
        var value: UInt32
        var red: UInt8 {
            get { return UInt8(value & 0xFF) }
            set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
        }
        var green: UInt8 {
            get { return UInt8((value >> 8) & 0xFF) }
            set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
        }
        var blue: UInt8 {
            get { return UInt8((value >> 16) & 0xFF) }
            set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
        }
        var alpha: UInt8 {
            get { return UInt8((value >> 24) & 0xFF) }
            set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
        }
    } /// end Pixel Struct
    
    struct RGBA {
        var pixels: UnsafeMutableBufferPointer<Pixel> //really an array of pixels, also 1-D :(
        var width: Int
        var height: Int
        
        init?(image: UIImage) {
            guard let cgImage = image.cgImage else { return nil } // 1
            
            width = Int(image.size.width)
            height = Int(image.size.height)
            let bitsPerComponent = 8 // 2
            
            let bytesPerPixel = 4
            let bytesPerRow = width * bytesPerPixel
            let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
            let colorSpace = CGColorSpaceCreateDeviceRGB() // 3
            
            var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
            bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
            guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
            
            imageContext.draw(cgImage, in: CGRect(origin: CGPoint(x:0, y:0), size: image.size))
            // CGContextDrawImage(imageContext, CGRect(origin: CGPointZero, size: image.size), cgImage) // 4
            
            pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        } // end init
        
        func toUIImage() -> UIImage? {
            let bitsPerComponent = 8
            let bytesPerPixel = 4
            let bytesPerRow = width * bytesPerPixel
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
            bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
            let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
            guard let cgImage = imageContext!.makeImage() else {return nil}
            let image = UIImage(cgImage: cgImage)
            return image
        }
    } //end RGBA struct
    
    /**** end structs ****/
    
    
    // basically linspace
    private func coordHelper(n:Int, increment : Int) -> [Int] {
        var idxs = [Int]()
        
        for i in stride(from: 0, to: n, by: increment) {
            idxs.append(i)
        }
        
        // last end point
        idxs.append(n)
        return idxs
    }
    
    private func colorInfo(rgba : RGBA, x_idxs :[Int], y_idxs : [Int], offset : Int) -> [(Int, Int, Int)] {
        var colors = [(Int, Int, Int)]()
        //let nc = x_idxs.count
        
        for r in 0..<(y_idxs.count  - 1){
            for c in 0..<(x_idxs.count - 1) {
                var totalRed = 0
                var totalGreen = 0
                var totalBlue = 0
                var num = 0
                for x in x_idxs[c]..<x_idxs[c + 1] {
                    for y in y_idxs[r]..<y_idxs[r + 1] {
                        let tempIdx = y * rgba.width + x
                        var pixel = rgba.pixels[tempIdx]
                        totalRed += Int(pixel.red)
                        totalGreen += Int(pixel.green)
                        totalBlue += Int(pixel.blue)
                        num += 1
                        
                    }
                    
                }
                
                totalRed /= (num)
                totalGreen /= (num)
                totalBlue /= (num)
                
                //create a new pixel
                colors.append((totalRed, totalGreen, totalBlue))
                
            }
        }
        
        return colors
        
    }
    
    private func coords(x_idxs:[Int], y_idxs:[Int]) -> (rows: [Int], cols: [Int]) {
        var coords_x = [Int]()
        var coords_y = [Int]()
        for r in 0..<y_idxs.count {
            for c in 0..<x_idxs.count {
                coords_x.append(x_idxs[c])
                coords_y.append(y_idxs[r])
                
            }
        }
        
        return (coords_y, coords_x)
    }
    
    private func distort(coords_x:[Int], coords_y:[Int],x_idxs:[Int], y_idxs:[Int]) -> (rows: [Int], cols: [Int]) {
        let nc = x_idxs.count
        let horiz_space = x_idxs[1] - x_idxs[0]
        let xMaxNoise = 0.35 * Double(horiz_space)
        
        let vert_space = y_idxs[1] - y_idxs[0]
        let yMaxNoise = 0.35 * Double(vert_space)
        
        var coords_x = coords_x
        var coords_y = coords_y
        for r in 0..<y_idxs.count - 1{
            for c in 1..<x_idxs.count - 1{
                coords_x[r*nc + c] += Int(2.0 * xMaxNoise * Double(arc4random_uniform(2)) - xMaxNoise)
                //coords_y[r*nc + c] += Int(2.0 * yMaxNoise * Double(arc4random_uniform(2)) - yMaxNoise)
            }
            
        }
        
        // y-coords 
        for r in 1..<y_idxs.count - 1 {
            for c in 0..<x_idxs.count{
                coords_y[r*nc + c] += Int(2.0 * yMaxNoise * Double(arc4random_uniform(2)) - yMaxNoise)
            }
        }
        
        return (coords_y, coords_x)
    }
    
    func real_tile() {
        let rgba = RGBA(image: img)!
        let offset = 10
        x_intervals = coordHelper(n: rgba.width, increment: offset)
        
        y_intervals = coordHelper(n: rgba.height, increment: offset)
        
        //print(x_idxs, y_idxs)
        //print(x_idxs.count, y_idxs.count)
        // make coordinates, at the same time make color data structure
        let coords_ = coords(x_idxs: x_intervals!, y_idxs: y_intervals!)
        coordinates_x = coords_.cols
        coordinates_y = coords_.rows
        //print (x_coords, y_coords)
        
        //distort the coordinates
        let dist_coords = distort(coords_x: coordinates_x!, coords_y: coordinates_y!, x_idxs: x_intervals!, y_idxs: y_intervals!)
        coordinates_x = dist_coords.cols
        coordinates_y = dist_coords.rows
        
        //print(coordinates_y)
        // get colors
        color_data = colorInfo(rgba: rgba, x_idxs: x_intervals!, y_idxs: y_intervals!, offset: offset)
        
    }
    
    

}
