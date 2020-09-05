//
//  UserManager.swift
//  MotMystere
//
//  Created by Lionel Maquet on 19/07/2020.
//  Copyright © 2020 Lionel Maquet. All rights reserved.
//

import Foundation
import Firebase

struct UserManager {
    
    var delegate: UserManagerDelegate?
    let db = Firestore.firestore()
    
    func fetchUsernameFromMailAndNotifyDelegate(mail:String){
        db.collection("users").whereField("mail",isEqualTo: mail).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("error getting documents \(err)")
            } else {
                let username = querySnapshot?.documents[0].data()["username"] as? String
                if let username = username {
                    self.delegate?.currentUserUsernameWasLoaded(username: username)
                }
            }
        }
    }
    
    
    func loadCurrentUserUsernameAndNotifyDelegate() {
        if let mail = currentUserMail {
            fetchUsernameFromMailAndNotifyDelegate(mail: mail)
        }
    }
    
    var currentUserMail : String? {
        if let mail = Auth.auth().currentUser?.email {
            return mail
        } else {
            print("ERROR : couldn't get user mail")
            return "nomail"
        }
        
    }
    
    
    func getCurrentUserRank() {
        
        if let mail = currentUserMail {
            db.collection("users").whereField("mail",isEqualTo: mail).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("error getting documents \(err)")
                } else {
                    let rank = querySnapshot?.documents[0].data()["rank"] as? Int
                    self.delegate?.userRankWasLoaded(rank: rank!)
                }
            }
            
        }
        
        
        
    }
    
    
    
    func createUserCustomDbEntry(username: String) {
        
        //SAVE DATA to google firestore
        if let newUserMail = Auth.auth().currentUser?.email {
            self.db.collection("users").addDocument(data: [ // Ajoute un document à la collection
                
                "mail":newUserMail,
                "username":username,
                "rank":0
                
                
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data.")
                    DispatchQueue.main.async {
                        //self.delegate?.newUserWasCreated()
                    }
                    
                }
            }
        }
        
    }
    
    func updateGlobalRank(by score: Int) {
        if let mail = currentUserMail {
            db.collection("users").whereField("mail",isEqualTo: mail).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("error getting documents \(err)")
                } else {
                    querySnapshot?.documents.first!.reference.updateData(["rank" : FieldValue.increment(Int64(score))])
                    
                    
                    
                }
            }
            
        }
    }
    
}

protocol UserManagerDelegate {
    func userRankWasLoaded(rank : Int)
    func currentUserUsernameWasLoaded(username: String)
}
