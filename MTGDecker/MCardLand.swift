//
//  MCardLand.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/9/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import CoreData
import MTGSDKSwift

public class MCardLand: MCard{
    
    @NSManaged public var isBasic: Bool
    @NSManaged public var comesInTapped: Bool
    @NSManaged private var landTypeRaw: Int16
    
    //Yields
    @NSManaged public var wYield: Int16
    @NSManaged public var uYield: Int16
    @NSManaged public var bYield: Int16
    @NSManaged public var rYield: Int16
    @NSManaged public var gYield: Int16
    @NSManaged public var wuYield: Int16
    @NSManaged public var ubYield: Int16
    @NSManaged public var brYield: Int16
    @NSManaged public var rgYield: Int16
    @NSManaged public var gwYield: Int16
    @NSManaged public var wbYield: Int16
    @NSManaged public var urYield: Int16
    @NSManaged public var bgYield: Int16
    @NSManaged public var rwYield: Int16
    @NSManaged public var guYield: Int16
    @NSManaged public var cYield: Int16
    @NSManaged public var anyYield: Int16
    //NOTE: cheating for tri-color yields (like Jungle Shrine): using negative value of the value slot that corresponds to "anything but these"
    
    
    
    public var landType: LandTypeVariant{
        get{
            return LandTypeVariant(rawValue: landTypeRaw)!
        }
        set{
            landTypeRaw = newValue.rawValue
        }
    }//landType
    
    public override func copyFromCard(card: Card){
        super.copyFromCard(card: card)//everything other cards get from their source card, lands get too
        
        if card.supertypes != nil && card.supertypes!.contains("Basic"){
            self.isBasic = true
        }//if
        
        //TODO: deal with land fuckery
        if card.text != nil && card.text!.contains("enters the battlefield tapped"){
            self.comesInTapped = true
        }
        else{
            self.comesInTapped = false
        }
        
        self.setYields()
        
    }//copyFromCard
    
    //MARK: Mana Yield Functions
    
    public func possibleYields() -> [ManaPool]{
        var result: [ManaPool] = [ManaPool()]//start with a single output pool, with 0 yield
        
        if (wYield > 0){
            for pool in result{
                pool.w += Int(wYield)
            }
        }//w
        if (uYield > 0){
            for pool in result{
                pool.u += Int(uYield)
            }
        }//u
        if (bYield > 0){
            for pool in result{
                pool.b += Int(bYield)
            }
        }//b
        if (rYield > 0){
            for pool in result{
                pool.r += Int(rYield)
            }
        }//r
        if (gYield > 0){
            for pool in result{
                pool.g += Int(gYield)
            }
        }//g
        if (cYield > 0){
            for pool in result{
                pool.c += Int(cYield)
            }
        }//c
        if wuYield != 0{
            if wuYield > 0{
                for _ in 0 ..< wuYield{
                    for pool in result{
                        let altPool = ManaPool(pool: pool)
                        pool.w += 1
                        altPool.u += 1
                        result.append(altPool)
                    }
                }//for each instance of mana-choice
            }//WU
            else{
                for _ in wuYield ..< 0{
                    for pool in result{
                        let altPool1 = ManaPool(pool: pool)
                        let altPool2 = ManaPool(pool: pool)
                        pool.b += 1
                        altPool1.r += 1
                        altPool2.g += 1
                        result.append(altPool1)
                        result.append(altPool2)
                    }
                }//for each instance of mana-choice
            }//BRG
        }//if nonzero WU
        
        if ubYield != 0{
            if ubYield > 0{
                for _ in 0 ..< ubYield{
                    for pool in result{
                        let altPool = ManaPool(pool: pool)
                        pool.u += 1
                        altPool.b += 1
                        result.append(altPool)
                    }
                }//for each instance of mana-choice
            }//UB
            else{
                for _ in ubYield ..< 0{
                    for pool in result{
                        let altPool1 = ManaPool(pool: pool)
                        let altPool2 = ManaPool(pool: pool)
                        pool.r += 1
                        altPool1.g += 1
                        altPool2.w += 1
                        result.append(altPool1)
                        result.append(altPool2)
                    }
                }//for each instance of mana-choice
            }//RGW
        }//if nonzero UB
        
        if brYield != 0{
            if brYield > 0{
                for _ in 0 ..< brYield{
                    for pool in result{
                        let altPool = ManaPool(pool: pool)
                        pool.b += 1
                        altPool.r += 1
                        result.append(altPool)
                    }
                }//for each instance of mana-choice
            }//BR
            else{
                for _ in brYield ..< 0{
                    for pool in result{
                        let altPool1 = ManaPool(pool: pool)
                        let altPool2 = ManaPool(pool: pool)
                        pool.g += 1
                        altPool1.w += 1
                        altPool2.u += 1
                        result.append(altPool1)
                        result.append(altPool2)
                    }
                }//for each instance of mana-choice
            }//GWU
        }//if nonzero BR
        
        if rgYield != 0{
            if rgYield > 0{
                for _ in 0 ..< rgYield{
                    for pool in result{
                        let altPool = ManaPool(pool: pool)
                        pool.r += 1
                        altPool.g += 1
                        result.append(altPool)
                    }
                }//for each instance of mana-choice
            }//RG
            else{
                for _ in rgYield ..< 0{
                    for pool in result{
                        let altPool1 = ManaPool(pool: pool)
                        let altPool2 = ManaPool(pool: pool)
                        pool.w += 1
                        altPool1.u += 1
                        altPool2.b += 1
                        result.append(altPool1)
                        result.append(altPool2)
                    }
                }//for each instance of mana-choice
            }//WUB
        }//if nonzero RG
        
        if gwYield != 0{
            if gwYield > 0{
                for _ in 0 ..< gwYield{
                    for pool in result{
                        let altPool = ManaPool(pool: pool)
                        pool.g += 1
                        altPool.w += 1
                        result.append(altPool)
                    }
                }//for each instance of mana-choice
            }//GW
            else{
                for _ in gwYield ..< 0{
                    for pool in result{
                        let altPool1 = ManaPool(pool: pool)
                        let altPool2 = ManaPool(pool: pool)
                        pool.u += 1
                        altPool1.b += 1
                        altPool2.r += 1
                        result.append(altPool1)
                        result.append(altPool2)
                    }
                }//for each instance of mana-choice
            }//UBR
        }//if nonzero GW
        
        if wbYield != 0{
            if wbYield > 0{
                for _ in 0 ..< wbYield{
                    for pool in result{
                        let altPool = ManaPool(pool: pool)
                        pool.w += 1
                        altPool.b += 1
                        result.append(altPool)
                    }
                }//for each instance of mana-choice
            }//WB
            else{
                for _ in wbYield ..< 0{
                    for pool in result{
                        let altPool1 = ManaPool(pool: pool)
                        let altPool2 = ManaPool(pool: pool)
                        pool.g += 1
                        altPool1.u += 1
                        altPool2.r += 1
                        result.append(altPool1)
                        result.append(altPool2)
                    }
                }//for each instance of mana-choice
            }//GUR
        }//if nonzero WB
        
        if urYield != 0{
            if urYield > 0{
                for _ in 0 ..< urYield{
                    for pool in result{
                        let altPool = ManaPool(pool: pool)
                        pool.u += 1
                        altPool.r += 1
                        result.append(altPool)
                    }
                }//for each instance of mana-choice
            }//UR
            else{
                for _ in urYield ..< 0{
                    for pool in result{
                        let altPool1 = ManaPool(pool: pool)
                        let altPool2 = ManaPool(pool: pool)
                        pool.w += 1
                        altPool1.b += 1
                        altPool2.g += 1
                        result.append(altPool1)
                        result.append(altPool2)
                    }
                }//for each instance of mana-choice
            }//WBG
        }//if nonzero UR
        
        if bgYield != 0{
            if bgYield > 0{
                for _ in 0 ..< bgYield{
                    for pool in result{
                        let altPool = ManaPool(pool: pool)
                        pool.b += 1
                        altPool.g += 1
                        result.append(altPool)
                    }
                }//for each instance of mana-choice
            }//BG
            else{
                for _ in bgYield ..< 0{
                    for pool in result{
                        let altPool1 = ManaPool(pool: pool)
                        let altPool2 = ManaPool(pool: pool)
                        pool.u += 1
                        altPool1.r += 1
                        altPool2.w += 1
                        result.append(altPool1)
                        result.append(altPool2)
                    }
                }//for each instance of mana-choice
            }//URW
        }//if nonzero BG
        
        if rwYield != 0{
            if rwYield > 0{
                for _ in 0 ..< rwYield{
                    for pool in result{
                        let altPool = ManaPool(pool: pool)
                        pool.r += 1
                        altPool.w += 1
                        result.append(altPool)
                    }
                }//for each instance of mana-choice
            }//RW
            else{
                for _ in rwYield ..< 0{
                    for pool in result{
                        let altPool1 = ManaPool(pool: pool)
                        let altPool2 = ManaPool(pool: pool)
                        pool.b += 1
                        altPool1.g += 1
                        altPool2.u += 1
                        result.append(altPool1)
                        result.append(altPool2)
                    }
                }//for each instance of mana-choice
            }//BGU
        }//if nonzero RW
        
        if guYield != 0{
            if guYield > 0{
                for _ in 0 ..< guYield{
                    for pool in result{
                        let altPool = ManaPool(pool: pool)
                        pool.g += 1
                        altPool.u += 1
                        result.append(altPool)
                    }
                }//for each instance of mana-choice
            }//GU
            else{
                for _ in guYield ..< 0{
                    for pool in result{
                        let altPool1 = ManaPool(pool: pool)
                        let altPool2 = ManaPool(pool: pool)
                        pool.r += 1
                        altPool1.w += 1
                        altPool2.b += 1
                        result.append(altPool1)
                        result.append(altPool2)
                    }
                }//for each instance of mana-choice
            }//RWB
        }//if nonzero GU
        
        if anyYield != 0{
            for _ in 0 ..< anyYield{
                for pool in result{
                    let altPool1 = ManaPool(pool: pool)
                    let altPool2 = ManaPool(pool: pool)
                    let altPool3 = ManaPool(pool: pool)
                    let altPool4 = ManaPool(pool: pool)
                    let altPool5 = ManaPool(pool: pool)
                    pool.c += 1
                    altPool1.w += 1
                    altPool2.u += 1
                    altPool3.b += 1
                    altPool4.r += 1
                    altPool5.g += 1
                    result.append(altPool1)
                    result.append(altPool2)
                    result.append(altPool3)
                    result.append(altPool4)
                    result.append(altPool5)
                }
            }//for each instance of mana-choice
        }//anyYield
        
        result = Array<ManaPool>(Set<ManaPool>(result))//remove duplicates
        return result
    }//possibleYields
    
    private func setYields(){
        if self.isBasic{
            setBasicYields()
            return
        }//Basics
        //DUALS (choice)
        if (text!.contains("{T}: Add {W} or {U}") && !text!.contains(", {T}: Add {W} or {U}")){
            wuYield = 1
            return
        }//WU
        if (text!.contains("{T}: Add {U} or {B}") && !text!.contains(", {T}: Add {U} or {B}")){
            ubYield = 1
            return
        }//UB
        if (text!.contains("{T}: Add {B} or {R}") && !text!.contains(", {T}: Add {B} or {R}")){
            brYield = 1
            return
        }//BR
        if (text!.contains("{T}: Add {R} or {G}") && !text!.contains(", {T}: Add {R} or {G}")){
            rgYield = 1
            return
        }//RG
        if (text!.contains("{T}: Add {G} or {W}") && !text!.contains(", {T}: Add {G} or {W}")){
            gwYield = 1
            return
        }//GW
        if (text!.contains("{T}: Add {W} or {B}") && !text!.contains(", {T}: Add {W} or {B}")){
            wbYield = 1
            return
        }//WB
        if (text!.contains("{T}: Add {U} or {R}") && !text!.contains(", {T}: Add {U} or {R}")){
            urYield = 1
            return
        }//UR
        if (text!.contains("{T}: Add {B} or {G}") && !text!.contains(", {T}: Add {B} or {G}")){
            bgYield = 1
            return
        }//BG
        if (text!.contains("{T}: Add {R} or {W}") && !text!.contains(", {T}: Add {R} or {W}")){
            rwYield = 1
            return
        }//RW
        if (text!.contains("{T}: Add {G} or {U}") && !text!.contains(", {T}: Add {G} or {U}")){
            guYield = 1
            return
        }//GU
        //COLORLESS
        if (text!.contains("{T}: Add {C}{C}")){
            cYield = 2
            return
        }
        if (text!.contains("{T}: Add {C}")){
            cYield = 1
            return
        }//Note: currently treats filter lands as colorless, rather than their pay-cost values. SO MANY issues to fix about land
        //TRIPLES (reminder: using negative values of the complementary for triple-color mana choice)
        //Shards
        if (text!.contains("{T}: Add {B}, {R}, or {G}")){
            wuYield = -1
            return
        }//BRG
        if (text!.contains("{T}: Add {R}, {G}, or {W}")){
            ubYield = -1
            return
        }//RGW
        if (text!.contains("{T}: Add {G}, {W}, or {U}")){
            brYield = -1
            return
        }//GWU
        if (text!.contains("{T}: Add {W}, {U}, or {B}")){
            rgYield = -1
            return
        }//WUB
        if (text!.contains("{T}: Add {U}, {B}, or {R}")){
            gwYield = -1
            return
        }//UBR
        //Wedges
        if (text!.contains("{T}: Add {G}, {U}, or {R}")){
            wbYield = -1
            return
        }//GUR
        if (text!.contains("{T}: Add {W}, {B}, or {G}")){
            urYield = -1
            return
        }//WBG
        if (text!.contains("{T}: Add {U}, {R}, or {W}")){
            bgYield = -1
            return
        }//URW
        if (text!.contains("{T}: Add {B}, {G}, or {U}")){
            rwYield = -1
            return
        }//BGU
        if (text!.contains("{T}: Add {R}, {W}, or {B}")){
            guYield = -1
            return
        }//RWB
        
        //SINGLE-YIELD (cycle lands, other utility, etc.)
        if (text!.contains("{T}: Add {W}")){
            wYield = 1
            return
        }
        if (text!.contains("{T}: Add {U}")){
            uYield = 1
            return
        }
        if (text!.contains("{T}: Add {B}")){
            bYield = 1
            return
        }
        if (text!.contains("{T}: Add {R}")){
            rYield = 1
            return
        }
        if (text!.contains("{T}: Add {G}")){
            gYield = 1
            return
        }
    }//setYields
    
    private func setBasicYields(){
        
        if name.contains("Plains"){
            wYield = 1
            return
        }
        if name.contains("Island"){
            uYield = 1
            return
        }
        if name.contains("Swamp"){
            bYield = 1
            return
        }
        if name.contains("Mountain"){
            rYield = 1
            return
        }
        if name.contains("Forest"){
            gYield = 1
            return
        }
        if name.contains("Wastes"){
            cYield = 1
            return
        }
    }//setBasicYields
    
    public enum LandTypeVariant: Int16{
        ///Basic land (example: Plains)
        case basic
        ///Dual land, choice (example: Meandering River, Tranquil Cove [lifegain], Temple of Enlightenment [scry])
        case dual
        ///Dual land, OP version (old school) (example: Tundra)
        case dualOP
        ///Pain land (example: Adakar Wastes)
        case pain
        ///Shock land (example: Hallowed Fountain)
        case shock
        ///Turn 3 land (example: Seachrome Coast)
        case turn3
        ///Bounce land (example: Azorious Chancery)
        case bounce
        ///Battle land (example: Prairie Stream)
        case battle
        ///Buddy land (example: Glacial Fortress)
        case buddy
        ///Reveal land (example: Port Town)
        case reveal
        ///Fetch land (example: Flooded Strand)
        case fetch
        ///Filter land (example: Skycloud Expanse)
        case filter
        ///Filter lands, with some restrictions (example: Mystic Gate)
        case filterHarder
    }//LandType
    
    
    
}//MCardLand
