//
//  ViewController.swift
//  ChatSample
//
//  Created by 藤井陽介 on 2017/02/16.
//  Copyright © 2017年 touyou. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ViewController: JSQMessagesViewController {
    
    var messages: [JSQMessage]?
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFirebase()
        setupChatUi()
        
        messages = []
    }
    
    func setupFirebase() {
        let rootRef = FIRDatabase.database().reference()
        
        rootRef.queryLimited(toLast: 100).observe(.childAdded, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                return
            }
            let text = value["text"] as! String
            let sender = value["from"] as! String
            let name = value["name"] as! String
            let message = JSQMessage(senderId: sender, displayName: name, text: text)!
            self.messages?.append(message)
            self.finishReceivingMessage()
        })
    }
    
    func setupChatUi() {
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        senderId = "user2"
        senderDisplayName = "touyou2"
        incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "icon"), diameter: 64)
        outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "icon"), diameter: 64)
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        finishSendingMessage(animated: true)
        sendTextToDataBase(text)
    }
    
    func sendTextToDataBase(_ text: String) {
        let rootRef = FIRDatabase.database().reference()
        
        let post = ["from": senderId, "name": senderDisplayName, "text": text]
        let postRef = rootRef.childByAutoId()
        postRef.setValue(post)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages?[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        guard let message = messages?[indexPath.item], message.senderId == senderId else {
            return incomingBubble
        }
        return outgoingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        guard let message = messages?[indexPath.item], message.senderId == senderId else {
            return incomingAvatar
        }
        return outgoingAvatar
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }
}

