//
//  CardNameList+CoreDataClass.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 3/25/18.
//  Copyright © 2018 Taylor. All rights reserved.
//
//

import Foundation
import CoreData
import MTGSDKSwift


///Sets the acceptable total of sets, divided by 100. Affects how many threads look for the current block of set names
var SET_TOTAL_PAGES: Int = 4
///Sets the acceptable total of cards per set, divided by 100. Gambling that no set will ever be released with more than 500 cards.
var CARD_TOTAL_PAGES: Int = 5
///List of set types not supported in searching for names
let UNSUPPORTED_SETS: [String] = ["promo", "premium deck", "reprint", "duel deck", "from the vault", "conspiracy", "starter", "box", "un", "planechase", "archenemy", "vanguard"]

/**
 A singleton class with the list of all valid MTG card names. The app updates and stores these in a persistent manner; actual card data is only pulled and stored for cards put into decks.
 */
public class CardNameList: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardNameList> {
        return NSFetchRequest<CardNameList>(entityName: "CardNameList")
    }
    public static func entityDescription(context: NSManagedObjectContext)->NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: String(describing: self), in: context)!
    }//entityDescription
    
    @NSManaged public var cardNames: [String]?
    @NSManaged public var sourceSetCodes: Set<String>
    @NSManaged public var lastUpdated: NSDate?
    private var checkedSetCodes: Set<String> = Set<String>()
    private var cardAddQueue: DispatchQueue = DispatchQueue(label: "cardAddQueue");
    private var setAddQueue: DispatchQueue = DispatchQueue(label: "setAddQueue");
    private var setSourceQueue: DispatchQueue = DispatchQueue(label: "setSourceQueue");

    
    /**
     Updates set of legal card names, by checking to see which sets are represented
     */
    func updateCardNames(context: NSManagedObjectContext){
        
        let magic: Magic = Magic();
        //Magic.enableLogging = true;
        magic.fetchPageSize = "100"
        magic.fetchPageTotal = "1";
        
        let setDownloadGroup: DispatchGroup = DispatchGroup()
        updateSetNames(magic, setDownloadGroup: setDownloadGroup)//calls to the internet, with multiple threads, to get set codes
        
        
        //TODO: make timeout variables sensible
        var didTimeout: DispatchTimeoutResult
        didTimeout = setDownloadGroup.wait(timeout: (DispatchTime.now() + 10))
        if (didTimeout == .timedOut){
            NSLog("Error: set requesting timed out")
        }//if timeout
        
        let needsUpdateCodeSet: Set<String> = self.checkedSetCodes.subtracting(self.sourceSetCodes)
        
        
        let cardDownloadGroup: DispatchGroup = DispatchGroup();
        
        for setCode: String in needsUpdateCodeSet{
            
            cardDownloadGroup.enter()
            let cardDownloadQueue: DispatchQueue = DispatchQueue(label: "\(setCode)_Queue")
            cardDownloadQueue.async {
                self.getCardNames(setCode: setCode, cardDownloadGroup: cardDownloadGroup)
            }

            let delayGroup: DispatchGroup = DispatchGroup();
            let delayQueue: DispatchQueue = DispatchQueue(label: "Delay Queue")
            
            delayGroup.enter()
            delayQueue.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {//slows the process slightly
                delayGroup.leave()
            })
            
            delayGroup.wait()

        }//needsUpdateCodeSet
        
        cardDownloadGroup.wait()
        
        if let x = self.cardNames!.index(of: ""){
            self.cardNames!.remove(at: x)
        }//in case the empty string snuck in there, remove it
        
        self.cardNames!.sort()
        
        self.lastUpdated = NSDate(timeIntervalSinceNow: 0)
        
        do{
            try context.save()
        }catch{
            NSLog("Core Data Error: \(error)")
        }
        
    }//updateCardNames
    
    
    
    /**
     Helper function to get the card names for a particular set code
     */
    private func getCardNames(setCode: String, cardDownloadGroup: DispatchGroup){
        let magic: Magic = Magic();
        magic.fetchPageSize = "100"
        magic.fetchPageTotal = "1"
        let setCodeParam: CardSearchParameter = CardSearchParameter(parameterType: .set, value: setCode)
        var pagenum: Int = 1;
        
        var wasKosherSetPull = true;
        
        var setCardNames: Set<String> = Set<String>()
        
        let setCardGroup: DispatchGroup = DispatchGroup();///keeps track of the page# threads' completion
        let setCardNameDispatch: DispatchQueue = DispatchQueue(label: "\(setCode)_queue")
        
        while (pagenum < CARD_TOTAL_PAGES){
            
            if (pagenum == 5 && setCode != "TSP" && setCode != "TSB" && setCode != "5ED"){
                break;
            }

            setCardGroup.enter()
            
            setCardNameDispatch.async{
                magic.fetchCards([setCodeParam], completion: { (cards, error) in
                    
                    print("\(setCode)-\(pagenum) starting")
                    
                    if (error != nil){
                        NSLog("\n***Error with \(setCode) page \(pagenum)***")
                        NSLog("\(error.debugDescription)")
                        wasKosherSetPull = false;
                    }//if error
                    
                    if ((cards != nil)&&(cards!.isEmpty == false)){
                        for card in cards!{
                            
                            let syncResult = setCardNameDispatch.sync{
                                setCardNames.insert(card.name!)
                            }//sync call to queue; essentially, puts the set accessor and mutator inside a thread-safe queue
                            if !(syncResult.inserted) {/*NSLog("\(syncResult)")*/}
                        }//for each card name
                    }//if there are cards
                    
                    
                    setCardGroup.leave()
                })//completion block: fetch cards
            }//async
            
            //wait for the cards to come back
            setCardGroup.wait()
            
            pagenum += 1;
            magic.fetchPageTotal = "\(pagenum)"
        }//loop through the pages to make requests'
   
        for name in setCardNames{
            
            self.addCardName(name: name)
            
        }//for each card name within the set
        
        if wasKosherSetPull{
            self.setSourceQueue.async{
                self.sourceSetCodes.insert(setCode)
            }//async
        }
        
        
        
        cardDownloadGroup.leave()
    }//getCardNames
    
    /**
     Adds a card name to the list of card names
     */
    private func addCardName(name: String){
        
        cardAddQueue.sync {
            if self.cardNames!.contains(name) == false{
                self.cardNames!.append(name)
            }//if the name isn't already in there
        }//put in a queue
        
    }//addCardName
    
    
    fileprivate func updateSetNames(_ magic: Magic, setDownloadGroup: DispatchGroup) {
        var currentPage: Int = 1;
        var lastSetFound: Bool = false;
        
        let blockparam: SetSearchParameter = SetSearchParameter(parameterType: .name, value: "")
        
        while (lastSetFound == false){
            
            setDownloadGroup.enter()
            magic.fetchSets([blockparam], completion: { (sets, error) in
                //code
                if (error != nil){
                    NSLog("Set fetch error: \(error!)\n")
                }//if
                
                if sets == nil || sets!.count == 0{
                    NSLog("Error picking up set things: \(error). Not sure why.")
                }
                
                
                for set in sets!{
                    
                    if (set.code != nil){
                        if (UNSUPPORTED_SETS.contains(set.type!) == false){
                            self.addSetName(name: set.code!)
                        }//if the set is of a type we want to deal with
                    }//if the set has a code
                    
                }
                setDownloadGroup.leave()
            })//completion block: fetchsets
            
            currentPage += 1;
            
            magic.fetchPageTotal = "\(currentPage)"
            
            
            if (currentPage > SET_TOTAL_PAGES){
                lastSetFound = true
            }
            
        }//while
        
    }//updateSetNames
    
    private func addSetName(name: String){
        setAddQueue.sync {
            if self.checkedSetCodes.contains(name) == false{
                self.checkedSetCodes.insert(name)
            }//if the name isn't already in there
        }//put in a queue
    }//addSetName
    
    func initiateFromFiles(){
        
        //Put default card names in
        let cardsPath = Bundle.main.url(forResource: "CardNameStarter", withExtension: "rtf")
        var cardString: String = ""
        if cardsPath != nil{
            do {
                cardString = try NSAttributedString(url: cardsPath!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil).string
            } catch let error {
                print("Got an error \(error)")
            }
        }
        let cardArray = cardString.components(separatedBy: "\n")
        
        
        cardNames! += cardArray
        
        //Put default set names in
        let setsPath = Bundle.main.url(forResource: "SetCodeStarter", withExtension: "rtf")
        var setString: String = ""
        if setsPath != nil{
            do {
                setString = try NSAttributedString(url: setsPath!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil).string
            } catch let error {
                print("Got an error \(error)")
            }
        }
        let setArray = setString.components(separatedBy: "\n")
        sourceSetCodes = sourceSetCodes.union(setArray)
        
        self.lastUpdated = NSDate()
        
        NSLog("Card name import from file complete")
        
    }//initiateFromFiles
    
}//CardNameList
