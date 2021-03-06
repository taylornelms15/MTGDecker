//
//  MCardImage+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/2/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit


public class MCardImage: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MCardImage> {
        return NSFetchRequest<MCardImage>(entityName: "MCardImage")
    }
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    @NSManaged public var imageData: NSData?
    @NSManaged public var inv_mcard: MCard?
    
    public var image: UIImage? {
        get{
            if imageData == nil{
                return nil
            }
            
            return UIImage(data: imageData! as Data)!
        }
        set{
            if newValue == nil{
                imageData = nil
            }
            
            imageData = NSData(data: UIImagePNGRepresentation(newValue!)!)
        }
    }//image
    
}//MCardImage
