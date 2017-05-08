//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Shin Park on 5/5/17.
//  Copyright © 2017 shinDev. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    // outlets to the UI components in our Custom UITableViewCell
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    // public API of this UITableViewCell subclass
    // each row in the table has its own instance of this class
    // and each instance will have its own tweet to show
    // as set by this var
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    // whenever our public API tweet is set
    // we just update our outlets using this method
    private func updateUI() {
        tweetTextLabel?.text = tweet?.text
        tweetUserLabel?.text = tweet?.user.description
        
        if let profileImageURL = tweet?.user.profileImageURL {
            
            // FIXME: blocks main thread
//            if let imageData = try? Data(contentsOf: profileImageURL) {
//                tweetProfileImageView?.image = UIImage(data: imageData)
//            }
            
            // try? Data(contentsOf:) blocks the thread it is on
            // we are currently on the main thread
            // so we must dispatch that call off to a background queue
            // we'll use one of the shared, global, concurrent background queues
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: profileImageURL)
                // now that we're back from blocking
                // are we still even interested in this url (i.e. does it == self.imageURL)?
                if let imageData = urlContents, profileImageURL == self?.tweet?.user.profileImageURL {
                    // now we want to set the image in the UI
                    // but we are not on the main thread right now
                    // so we are not allowed to do UI
                    // no problem: just dispatch the UI stuff back to the main queue
                    DispatchQueue.main.async {
                    self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
}
