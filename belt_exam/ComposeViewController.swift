//
//  ViewController.swift
//  belt_exam
//
//  Created by William Tsai on 1/26/18.
//  Copyright © 2018 William Tsai. All rights reserved.
//

import UIKit

protocol AddNoteDelegate {
    func save(_ content: String, date: Date, indexPath: NSIndexPath?)
}

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    var currentDate: String?
    var data: (Note, NSIndexPath)?
    
    let date = Date()
    
    var delegate: AddNoteDelegate?
    
    @IBOutlet var noteContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteContent.text = data?.0.content
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Compose Your Note"
        
        noteContent.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("saving")
        delegate?.save(noteContent.text, date: date, indexPath: data?.1)
    }
}

