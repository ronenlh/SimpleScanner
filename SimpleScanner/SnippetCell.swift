//
//  SnippetCellTableViewCell.swift
//  SimpleScanner
//
//  Created by Ronen Lahat on 10/10/2016.
//  Copyright © 2016 Ronen Lahat. All rights reserved.
//

import UIKit

class SnippetCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textContentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with snippet: Snippet) {
        guard let title = snippet.value(forKey: "title") as? String else { return }
        guard let text = snippet.value(forKey: "text") as? String else { return }
        guard let rawDate = snippet.value(forKey: "date") as? Date else { return }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: rawDate)

        titleLabel.text = title
        dateLabel.text = dateString
        textContentLabel.text = text
        
    }

}
