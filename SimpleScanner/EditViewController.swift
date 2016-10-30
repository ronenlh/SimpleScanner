//
//  EditViewController.swift
//  SimpleScanner
//
//  Created by Ronen Lahat on 10/10/2016.
//  Copyright © 2016 Ronen Lahat. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    
    var snippet: Snippet!

    @IBOutlet weak var textContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textContent.text = snippet.value(forKey: "text") as? String
    }

    @IBAction func done(_ sender: AnyObject) {
        SnippetStore.shared.updateSnippet(snippet: snippet, text: textContent.text!)
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func export(_ sender: AnyObject) {
        if textContent.text.isEmpty {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [textContent.text], applicationActivities: nil)
        let excludeActivities : [UIActivityType] = [
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo]
        activityViewController.excludedActivityTypes = excludeActivities
        
        present(activityViewController, animated: true, completion: nil)
    }

}
