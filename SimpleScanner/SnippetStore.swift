//
//  SnippetStore.swift
//  SimpleScanner
//
//  Created by Ronen Lahat on 10/10/2016.
//  Copyright © 2016 Ronen Lahat. All rights reserved.
//

import UIKit
import CoreData

class SnippetStore: NSObject {
    
    static let shared = SnippetStore()
    let managedContext = DBManager.shared.context
    
    private override init() {
        super.init()
        print("SnippetStore Created")
    }
    
    func getFetchedResultsController(withDelegate delegate : NSFetchedResultsControllerDelegate?) ->
        NSFetchedResultsController<Snippet>{
    
        let controller = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil) // cacheName: "master"
        
        controller.delegate = delegate
            
        do{
            try controller.performFetch()
        } catch let err as NSError{
            print(err)
        }
        
        return controller
    }
    
    func taskFetchRequest() -> NSFetchRequest<Snippet> {
        let request: NSFetchRequest<Snippet> = NSFetchRequest<Snippet>(entityName:"Snippet")
        //request.entity = NSEntityDescription.entity(forEntityName: "Snippet", in: managedContext)
        
        //request.fetchBatchSize = 10
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    /*
    var allSnippets : [Snippet] {
        get {
            let request: NSFetchRequest<Snippet> = NSFetchRequest<Snippet>()
            request.entity = NSEntityDescription.entity(forEntityName: "Snippet", in: managedContext)
            
            request.fetchBatchSize = 10
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sortDescriptor]
            
            guard let arr = try? managedContext.fetch(request) else {
                return []
            }
            
            return arr
        }
    }*/
    
    func saveSnippet(title: String, text: String) {
        
        let entity =  NSEntityDescription.entity(forEntityName: "Snippet",
                                                 in:managedContext)
        
        let snippet = NSManagedObject(entity: entity!,
                                      insertInto: managedContext)
        
        snippet.setValue(title, forKey: "title")
        snippet.setValue(text, forKey: "text")
        snippet.setValue(Date(), forKey: "date")
        snippet.setValue(UUID().uuidString, forKey: "uuid")
        
        DBManager.shared.saveContext()
    }
    
    func removeSnippet(_ snippet: Snippet) {
        managedContext.delete(snippet)
        DBManager.shared.saveContext()
    }
    
    func updateSnippet(snippet: Snippet, text: String) {
        snippet.setValue(text, forKey: "text")
        DBManager.shared.saveContext()
    }
    
}
