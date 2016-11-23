//
//  ViewController.swift
//  stainedGlass
//
//  Created by Rachel Yen on 11/20/16.
//  Copyright © 2016 Rachel Yen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //CGRect(x: 50, y: 50, width: 250   , height: 300)
        
    }

    /** Properties **/
    // optional city
    private var origin : originPoint?
    private var frame: CGRect?
    private var container : UIView?
    private var img : UIImage?
    private var stainedGlass : StainedGlass? // so the OOP
    private var masterLayer = CAShapeLayer()
    
    /** end Properties **/
    
    struct originPoint {
        var x :Int
        var y: Int
        init?(coord_x: Int, coord_y: Int) {
            x = coord_x
            y = coord_y
        }
    }
    
    // pass information from StainedGlass
    func draw(coords_x: [Int], coords_y: [Int], color_data: [(Int, Int, Int)], x_idxs: [Int], y_idxs: [Int]) {
        
        let nc = x_idxs.count
        var color_idx = 0
        
        
        container!.layer.addSublayer(masterLayer)
        
        // #imScared lol! 
        
        for r in 0..<y_idxs.count - 1 {
            for c in 0..<x_idxs.count - 1 {
                let col = coords_x[r * nc + c]
                let row = coords_y[r * nc + c]
                let (red, green, blue) = color_data[color_idx]
                // end setup
                
                //NOTE: each tile is a CShape sublayer
                let shape = CAShapeLayer()
                masterLayer.addSublayer(shape)
                shape.opacity = 1.0
                shape.lineWidth = 1
                shape.lineJoin = kCALineJoinMiter
                shape.strokeColor = UIColor(hue: 0.786, saturation: 0.79, brightness: 0.53, alpha: 1.0).cgColor
                
                let adj_red = Double(red) / 255.0
                let adj_green = Double(green) / 255.0
                let adj_blue = Double(blue) / 255.0
                shape.fillColor = UIColor(red: CGFloat(adj_red), green: CGFloat(adj_green), blue: CGFloat(adj_blue),  alpha: 1.0).cgColor
                
                let path = UIBezierPath()
               // path.move(to: CGPoint(x: col, y: row))
                //path.addLine(to: CGPoint(x: col, y: row_plus))
              //  path.addLine(to: CGPoint(x: col_plus, y: coords_y[(r + 1) * nc + c + 1] + origin!.y))
             //   path.addLine(to: CGPoint(x: col_plus, y: coords_y[r * nc + c + 1] + origin!.y))
                
                path.move(to: CGPoint(x: col, y: row))
                path.addLine(to: CGPoint(x: coords_x[(r+1) * nc + c], y: coords_y[(r+1) * nc + c]))
                path.addLine(to: CGPoint(x: coords_x[(r + 1) * nc + c + 1], y: coords_y[(r + 1) * nc + c + 1]))
                path.addLine(to: CGPoint(x: coords_x[r * nc + c + 1], y: coords_y[r * nc + c + 1]))
                

                path.close()
                shape.path = path.cgPath
                color_idx += 1

            }
        }
        
    }
    
    func prepareStainedGlass() {
        
        // check if an image is set 
        if let our_img = img {
            print("test")
            
            // ship it off to StainedGlass
                // Initialize our StainedGlass class
            stainedGlass = StainedGlass(image: our_img)
            stainedGlass!.real_tile()
            // get info back
            
                    //send info to draw
            draw(coords_x: (stainedGlass?.getCoordX)!, coords_y: (stainedGlass?.getCoordY)!, color_data: (stainedGlass?.getColorData)!, x_idxs: (stainedGlass?.getXIntervals)!, y_idxs: (stainedGlass?.getYIntervals)! )
            
        }
    } // end prepareStainedGlass
    
    func setUp() {
    
        // set our origin
        origin = originPoint(coord_x: 50, coord_y: 50) //subject to change :(
        frame = CGRect(x: Double(origin!.x), y: Double(origin!.y), width: 200, height: 350)
        container = UIView(frame: frame!)
        
        if let container_view = container {
            img = UIImage(named: "babyme.jpg")
            let imageView = UIImageView(image: img!)
            imageView.frame = container_view.bounds
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            container_view.addSubview(imageView)
            view.addSubview(container_view)
            
            prepareStainedGlass()
        }

    }

} // end ViewController class

