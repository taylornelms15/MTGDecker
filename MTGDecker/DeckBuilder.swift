//
//  DeckBuilder.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/6/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import CoreData
import MTGSDKSwift

class DeckBuilder{
    ///Allow a 10-second interval before internet request times out
    public static var TIMEOUT_INTERVAL : DispatchTimeInterval = DispatchTimeInterval.milliseconds(10000)
    
    var context: NSManagedObjectContext
    var deck: Deck
    
    init(inContext: NSManagedObjectContext, deck: Deck){
        self.context = inContext
        self.deck = deck
    }//init
    
    //MARK: Card Manipulation

    
    func addCardsByNames(cardNames: Set<String>){
        
        for cardName in cardNames{
            DispatchQueue.global().async(group: nil, qos: .userInteractive, flags: [], execute: {
                self.addCardByName(cardName)
            })
            
        }//for each card in the set
        
    }//addCardsByNames
    
    
    func addCardByName(_ cardName: String){
        
        let cardFR: NSFetchRequest<MCard> = MCard.fetchRequest()
        cardFR.predicate = NSPredicate(format: "name = %@", cardName)
        var results: [MCard] = []
        do{
            results = try context.fetch(cardFR)
        }
        catch{
            NSLog("Error fetching card from card list in core data: \(error)")
        }
        
        if (results.count > 0){
            let referencedCard: MCard = results[0]
            self.deck.addCard(referencedCard, context: context)
            
            self.pullCardImageByNameAndURL(name: results[0].name, url: results[0].imageURL!, intoMCard: results[0])
            
        }//if we already have the card in the app somewhere
            
        else{
            pullCardFromInternet(cardName)
        }//if we don't have the card in the app somewhere

        NotificationCenter.default.post(name: .cardAddNotification, object: cardName)
        
    }//addCardByName
    
    private func pullCardFromInternet(_ cardName: String) {
        let magic: Magic = Magic()
        let nameParam: CardSearchParameter = CardSearchParameter(parameterType: .name, value: cardName)
        var cardResults: [Card] = []
        
        let fetchCardDispatchGroup: DispatchGroup = DispatchGroup()
        
        fetchCardDispatchGroup.enter()
        DispatchQueue.global().async(group: fetchCardDispatchGroup, qos: .userInitiated, flags: []) {
            magic.fetchCards([nameParam]) {
                cards, error in
                
                if error != nil {
                    NSLog("\(String(describing: error))")
                }
                
                if cards == nil || cards!.count == 0{
                    //TODO: handle error better
                    NSLog("Got an error fetching card data from the internet: \(String(describing: error)). Was looking for \(cardName)")
                    fetchCardDispatchGroup.leave()
                    return
                }//An error finding the card
                
                let filteredCards: [Card] = cards!.filter({ (card) -> Bool in
                    if (card.name == nil || card.name! != cardName){
                        return false
                    }
                    return true
                })//filters card results so that searching for "Flight" doesn't allow back "Vow of Flight"
                
                //finds the most recent card printing; makes that the one to look up.
                var setCode: String = ""
                if filteredCards.count != 0{
                    let printedSets: [String] = filteredCards[0].printings!
                    setCode = printedSets.last!
                }
                
                //Pulls card info from the internet again, this time with the specification that it is from the most recent printing of the card.
                let setParam: CardSearchParameter = CardSearchParameter(parameterType: .set, value: setCode)
                magic.fetchCards([nameParam, setParam], completion: { (recentCards, error) in
                    if error != nil{
                        NSLog("\(String(describing: error))")
                    }
                    
                    if recentCards == nil || recentCards!.count == 0{
                        //TODO: handle error better
                        NSLog("Got an error fetching card data from the internet: \(String(describing: error))")
                        fetchCardDispatchGroup.leave()
                        return
                    }//An error finding the card
                    
                    let cards: [Card] = recentCards!.filter({ (card) -> Bool in
                        if (card.name == nil || card.name! != cardName){
                            return false
                        }
                        return true
                    })//filters card results so that searching for "Flight" doesn't allow back "Vow of Flight"
                    
                    for card in cards{
                        cardResults.append(card)
                    }
                    
                    fetchCardDispatchGroup.leave()
                    
                })
                
            }//fetch the card for that name
        }
        
        //fetchCardDispatchGroup.wait()
        
        if fetchCardDispatchGroup.wait(timeout: .now() + 20 /*DeckBuilder.TIMEOUT_INTERVAL*/ ) == DispatchTimeoutResult.timedOut{
            print("Timed out on internet pull for card \(cardName). Please try again.")
            fetchCardDispatchGroup.leave()
            return
        }
        
        if (cardResults.count == 0){
            print("Error retrieving card \(cardName); please try again another time")
            fetchCardDispatchGroup.leave()
        }
        else{
            self.addCardByCard(cardResults[0])
        }
        
    }//pullCardFromInternet
    
    func addCardByCard(_ card: Card){
        
        self.context.performAndWait {
            
            var myCard: MCard = MCard(context: context)
            
            if card.types!.contains("Land"){
                context.delete(myCard)
                
                myCard = MCardLand(context: context)
            }

            myCard.copyFromCard(card: card)
            
            self.deck.addCard(myCard, context: context)
            
            DispatchQueue.global(qos: .utility).async {
                self.pullCardImageFromInternet(card: card, intoMCard: myCard)
            }
            
            do{
                try self.context.save()
            }catch{
                NSLog("Error: could not save card into deck. \(error)")
            }
        }//performandwait
        
        
    }//addCardByCard
    
    //MARK: Deal with card images
    
    func pullCardImageByNameAndURL(name: String, url: String, intoMCard: MCard){
        
        var fakeCard: Card = Card.init()
        fakeCard.name = name
        fakeCard.imageUrl = url
        
        pullCardImageFromInternet(card: fakeCard, intoMCard: intoMCard)
        
    }//pullCardImageByName
    
    func pullCardImageFromInternet(card: Card, intoMCard: MCard){
        
        if intoMCard.image != nil && intoMCard.image!.imageData != nil{
            
            NotificationCenter.default.post(name: .cardImageAddNotification, object: intoMCard)
            
            return
            
        }//if we already have an image for the card, no need to go any further
        
        
        
        let magic: Magic = Magic()
        magic.fetchImageForCard(card) { (image, error) in
            
            if (error != nil){
                NSLog("Error fetching card image for \(card.name!):\n\(error!)")
            }//if there was an error
            
            if (image == nil){
                NSLog("Error: no image found for \(card.name!).")
                return;//no need to do another thing
            }//if no image came back
            
            self.context.performAndWait {
                let cardImage: MCardImage = MCardImage(context: self.context)
                cardImage.image = image!
                intoMCard.image = cardImage
                do{
                    try self.context.save()
                }catch{
                    NSLog("Error: could not saving card image. \(error)")
                }
            }
            
            
            
            NotificationCenter.default.post(name: .cardImageAddNotification, object: intoMCard)
            
        }//fetchImageForCard
    }//pullCardImageFromInternet
    
    
}//DeckBuilder

extension Notification.Name{
    static let cardAddNotification = Notification.Name(rawValue: "cardAdd")
    static let cardCellRemoveNotification = Notification.Name(rawValue: "cardCellRemove")
    static let cardNumberChangeNotification = Notification.Name(rawValue: "cardNumberChange")
    static let cardImageAddNotification = Notification.Name(rawValue: "cardImageAdd")
}
