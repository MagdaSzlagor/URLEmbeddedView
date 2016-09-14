//
//  OGData.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

import Foundation
import CoreData

public final class OGData: NSManagedObject {
    fileprivate enum PropertyName: String {
        case Description = "og:description"
        case Image       = "og:image"
        case SiteName    = "og:site_name"
        case Title       = "og:title"
        case Type        = "og:type"
        case Url         = "og:url"
    }
    
    fileprivate lazy var URL: Foundation.URL? = {
        return Foundation.URL(string: self.sourceUrl)
    }()

    class func fetchOrInsertOGData(url: String) -> OGData {
        guard let ogData = fetchOGData(url: url) else {
            let managedObjectContext = OGDataCacheManager.sharedInstance.updateManagedObjectContext
            let newOGData = NSEntityDescription.insertNewObject(forEntityName: "OGData", into: managedObjectContext) as! OGData
            let date = Date()
            newOGData.createDate = date
            newOGData.updateDate = date
            return newOGData
        }
        return ogData
    }
    
    class func fetchOGData(url: String) -> OGData? {
        let managedObjectContext = OGDataCacheManager.sharedInstance.updateManagedObjectContext
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "OGData", in: managedObjectContext)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "sourceUrl = %@", url)
        let fetchedList = (try? managedObjectContext.fetch(fetchRequest)) as? [OGData]
        return fetchedList?.first
    }
    
    func setValue(property: String, content: String) {
        guard let propertyName = PropertyName(rawValue: property) else { return }
        switch propertyName  {
        case .SiteName    : siteName        = content
        case .Type        : pageType        = content
        case .Title       : pageTitle       = content
        case .Image       : imageUrl        = content
        case .Url         : url             = content
        case .Description : pageDescription = content.replacingOccurrences(of: "\n", with: " ")
        }
    }
    
    func save() {
        updateDate = Date()
        OGDataCacheManager.sharedInstance.saveContext(nil)
    }
}
