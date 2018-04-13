//
//  ManaPool.swift
//  MTGDecker
//
//  Created by Taylor Nelms on 4/11/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import Foundation
import CoreData

public class ManaPool: Equatable, Hashable, CustomStringConvertible, Comparable{
    
    ///White mana in the pool
    var w: Int = 0
    ///Blue mana in the pool
    var u: Int = 0
    ///Black mana in the pool
    var b: Int = 0
    ///Red mana in the pool
    var r: Int = 0
    ///Green mana in the pool
    var g: Int = 0
    ///Colorless mana in the pool
    var c: Int = 0
    
    public init(){
        
    }
    
    public init(pool: ManaPool){
        self.w = pool.w
        self.u = pool.u
        self.b = pool.b
        self.r = pool.r
        self.g = pool.g
        self.c = pool.c
    }
    
    static public func + (lhs: ManaPool, rhs: ManaPool)-> ManaPool{
        let resultPool: ManaPool = ManaPool()
        
        resultPool.w = lhs.w + rhs.w
        resultPool.u = lhs.u + rhs.u
        resultPool.b = lhs.b + rhs.b
        resultPool.r = lhs.r + rhs.r
        resultPool.g = lhs.g + rhs.g
        resultPool.c = lhs.c + rhs.c
        
        return resultPool
    }//Operator +
    
    ///Compares CMC totals
    public static func < (lhs: ManaPool, rhs: ManaPool) -> Bool{
        return lhs.totalCMC < rhs.totalCMC
    }//Operator <
    
    static public func == (lhs: ManaPool, rhs: ManaPool) -> Bool{
        return (lhs.w == rhs.w) && (lhs.u == rhs.u) && (lhs.b == rhs.b) && (lhs.r == rhs.r) && (lhs.g == rhs.g) && (lhs.c == rhs.c)
    }//Operator ==
    
    public var hashValue: Int{
        return(w.hashValue ^ u.hashValue ^ b.hashValue ^ r.hashValue ^ g.hashValue ^ c.hashValue)
    }
    
    public var description: String{
        return "{*MP* w:\(w) u:\(u) b:\(b) r:\(r) g:\(g) c:\(c)}"
    }
    
    public var totalCMC: Int{
        return w + u + b + r + g + c
    }
    
    ///Important: DO NOT call this if the cost cannot be paid (todo: make this not be the case)
    public func payCost(ofCard: MCard) -> Set<ManaPool>{
        var cardCostBlock: CostBlock = CostBlock()
        //TODO: handle Phyrexian mana better
        
        let trivialResult: ManaPool = ManaPool(pool: self)
        
        //Get the fixed costs out of the way early
        trivialResult.w -= Int(ofCard.whiteCost + ofCard.whitephyCost)
        trivialResult.u -= Int(ofCard.blueCost + ofCard.bluephyCost)
        trivialResult.b -= Int(ofCard.blackCost + ofCard.blackphyCost)
        trivialResult.r -= Int(ofCard.redCost + ofCard.redphyCost)
        trivialResult.g -= Int(ofCard.greenCost + ofCard.greenphyCost)
        trivialResult.c -= Int(ofCard.colorlessCost)
        cardCostBlock.any = Int(ofCard.anymanaCost + ofCard.xmanaCost)
        cardCostBlock.wu = Int(ofCard.whiteblueCost)
        cardCostBlock.ub = Int(ofCard.blueblackCost)
        cardCostBlock.br = Int(ofCard.blackredCost)
        cardCostBlock.rg = Int(ofCard.redgreenCost)
        cardCostBlock.gw = Int(ofCard.greenwhiteCost)
        cardCostBlock.wb = Int(ofCard.whiteblackCost)
        cardCostBlock.ur = Int(ofCard.blueredCost)
        cardCostBlock.bg = Int(ofCard.blackgreenCost)
        cardCostBlock.rw = Int(ofCard.redwhiteCost)
        cardCostBlock.gu = Int(ofCard.greenblueCost)
        
        var results: Set<ManaPool> = Set<ManaPool>()
        
        results = trivialResult.payCost(block: cardCostBlock)
        
        return results
    }//payCost
    
    //Note: BE IMMUTABLE
    private func payCost(block: CostBlock) -> Set<ManaPool>{
        if block.isEmpty() == true{
            return Set<ManaPool>([self])
        }//if this current pool
        
        var resultSet: Set<ManaPool> = Set<ManaPool>()
        
        if block.any > 0{
            if self.w > 0{
                let wPool: ManaPool = ManaPool(pool: self)
                var wBlock: CostBlock = block
                wPool.w -= 1
                wBlock.any -= 1
                if wPool.canCoverCost(block: wBlock){
                    resultSet = resultSet.union(wPool.payCost(block: wBlock))
                }
            }//W
            if self.u > 0{
                let uPool: ManaPool = ManaPool(pool: self)
                var uBlock: CostBlock = block
                uPool.u -= 1
                uBlock.any -= 1
                if uPool.canCoverCost(block: uBlock){
                    resultSet = resultSet.union(uPool.payCost(block: uBlock))
                }
            }//U
            if self.b > 0{
                let bPool: ManaPool = ManaPool(pool: self)
                var bBlock: CostBlock = block
                bPool.b -= 1
                bBlock.any -= 1
                if bPool.canCoverCost(block: bBlock){
                    resultSet = resultSet.union(bPool.payCost(block: bBlock))
                }
            }//B
            if self.r > 0{
                let rPool: ManaPool = ManaPool(pool: self)
                var rBlock: CostBlock = block
                rPool.r -= 1
                rBlock.any -= 1
                if rPool.canCoverCost(block: rBlock){
                    resultSet = resultSet.union(rPool.payCost(block: rBlock))
                }
            }//R
            if self.g > 0{
                let gPool: ManaPool = ManaPool(pool: self)
                var gBlock: CostBlock = block
                gPool.g -= 1
                gBlock.any -= 1
                if gPool.canCoverCost(block: gBlock){
                    resultSet = resultSet.union(gPool.payCost(block: gBlock))
                }
            }//G
            if self.c > 0{
                let cPool: ManaPool = ManaPool(pool: self)
                var cBlock: CostBlock = block
                cPool.c -= 1
                cBlock.any -= 1
                if cPool.canCoverCost(block: cBlock){
                    resultSet = resultSet.union(cPool.payCost(block: cBlock))
                }
            }//C
        }//if any cost left
        
        if block.wu > 0{
            if self.w > 0{
                let wPool: ManaPool = ManaPool(pool: self)
                var wBlock: CostBlock = block
                wPool.w -= 1
                wBlock.wu -= 1
                if wPool.canCoverCost(block: wBlock){
                    resultSet = resultSet.union(wPool.payCost(block: wBlock))
                }
            }//W
            if self.u > 0{
                let uPool: ManaPool = ManaPool(pool: self)
                var uBlock: CostBlock = block
                uPool.u -= 1
                uBlock.wu -= 1
                if uPool.canCoverCost(block: uBlock){
                    resultSet = resultSet.union(uPool.payCost(block: uBlock))
                }
            }//U
        }//WU
        
        if block.ub > 0{
            if self.u > 0{
                let uPool: ManaPool = ManaPool(pool: self)
                var uBlock: CostBlock = block
                uPool.u -= 1
                uBlock.ub -= 1
                if uPool.canCoverCost(block: uBlock){
                    resultSet = resultSet.union(uPool.payCost(block: uBlock))
                }
            }//U
            if self.b > 0{
                let bPool: ManaPool = ManaPool(pool: self)
                var bBlock: CostBlock = block
                bPool.b -= 1
                bBlock.ub -= 1
                if bPool.canCoverCost(block: bBlock){
                    resultSet = resultSet.union(bPool.payCost(block: bBlock))
                }
            }//B
        }//UB
        
        if block.br > 0{
            if self.b > 0{
                let bPool: ManaPool = ManaPool(pool: self)
                var bBlock: CostBlock = block
                bPool.b -= 1
                bBlock.br -= 1
                if bPool.canCoverCost(block: bBlock){
                    resultSet = resultSet.union(bPool.payCost(block: bBlock))
                }
            }//B
            if self.r > 0{
                let rPool: ManaPool = ManaPool(pool: self)
                var rBlock: CostBlock = block
                rPool.r -= 1
                rBlock.br -= 1
                if rPool.canCoverCost(block: rBlock){
                    resultSet = resultSet.union(rPool.payCost(block: rBlock))
                }
            }//R
        }//BR
        
        if block.rg > 0{
            if self.r > 0{
                let rPool: ManaPool = ManaPool(pool: self)
                var rBlock: CostBlock = block
                rPool.r -= 1
                rBlock.rg -= 1
                if rPool.canCoverCost(block: rBlock){
                    resultSet = resultSet.union(rPool.payCost(block: rBlock))
                }
            }//R
            if self.g > 0{
                let gPool: ManaPool = ManaPool(pool: self)
                var gBlock: CostBlock = block
                gPool.g -= 1
                gBlock.rg -= 1
                if gPool.canCoverCost(block: gBlock){
                    resultSet = resultSet.union(gPool.payCost(block: gBlock))
                }
            }//G
        }//RG
        
        if block.gw > 0{
            if self.g > 0{
                let gPool: ManaPool = ManaPool(pool: self)
                var gBlock: CostBlock = block
                gPool.g -= 1
                gBlock.gw -= 1
                if gPool.canCoverCost(block: gBlock){
                    resultSet = resultSet.union(gPool.payCost(block: gBlock))
                }
            }//G
            if self.w > 0{
                let wPool: ManaPool = ManaPool(pool: self)
                var wBlock: CostBlock = block
                wPool.w -= 1
                wBlock.gw -= 1
                if wPool.canCoverCost(block: wBlock){
                    resultSet = resultSet.union(wPool.payCost(block: wBlock))
                }
            }//W
        }//GW
        
        if block.wb > 0{
            if self.w > 0{
                let wPool: ManaPool = ManaPool(pool: self)
                var wBlock: CostBlock = block
                wPool.w -= 1
                wBlock.wb -= 1
                if wPool.canCoverCost(block: wBlock){
                    resultSet = resultSet.union(wPool.payCost(block: wBlock))
                }
            }//W
            if self.b > 0{
                let bPool: ManaPool = ManaPool(pool: self)
                var bBlock: CostBlock = block
                bPool.b -= 1
                bBlock.wb -= 1
                if bPool.canCoverCost(block: bBlock){
                    resultSet = resultSet.union(bPool.payCost(block: bBlock))
                }
            }//B
        }//WB
        
        if block.ur > 0{
            if self.u > 0{
                let uPool: ManaPool = ManaPool(pool: self)
                var uBlock: CostBlock = block
                uPool.u -= 1
                uBlock.ur -= 1
                if uPool.canCoverCost(block: uBlock){
                    resultSet = resultSet.union(uPool.payCost(block: uBlock))
                }
            }//U
            if self.r > 0{
                let rPool: ManaPool = ManaPool(pool: self)
                var rBlock: CostBlock = block
                rPool.r -= 1
                rBlock.ur -= 1
                if rPool.canCoverCost(block: rBlock){
                    resultSet = resultSet.union(rPool.payCost(block: rBlock))
                }
            }//R
        }//UR
        
        if block.bg > 0{
            if self.b > 0{
                let bPool: ManaPool = ManaPool(pool: self)
                var bBlock: CostBlock = block
                bPool.b -= 1
                bBlock.bg -= 1
                if bPool.canCoverCost(block: bBlock){
                    resultSet = resultSet.union(bPool.payCost(block: bBlock))
                }
            }//B
            if self.g > 0{
                let gPool: ManaPool = ManaPool(pool: self)
                var gBlock: CostBlock = block
                gPool.g -= 1
                gBlock.bg -= 1
                if gPool.canCoverCost(block: gBlock){
                    resultSet = resultSet.union(gPool.payCost(block: gBlock))
                }
            }//G
        }//BG
        
        if block.rw > 0{
            if self.r > 0{
                let rPool: ManaPool = ManaPool(pool: self)
                var rBlock: CostBlock = block
                rPool.r -= 1
                rBlock.rw -= 1
                if rPool.canCoverCost(block: rBlock){
                    resultSet = resultSet.union(rPool.payCost(block: rBlock))
                }
            }//R
            if self.w > 0{
                let wPool: ManaPool = ManaPool(pool: self)
                var wBlock: CostBlock = block
                wPool.w -= 1
                wBlock.rw -= 1
                if wPool.canCoverCost(block: wBlock){
                    resultSet = resultSet.union(wPool.payCost(block: wBlock))
                }
            }//W
        }//RW
        
        if block.gu > 0{
            if self.g > 0{
                let gPool: ManaPool = ManaPool(pool: self)
                var gBlock: CostBlock = block
                gPool.g -= 1
                gBlock.gu -= 1
                if gPool.canCoverCost(block: gBlock){
                    resultSet = resultSet.union(gPool.payCost(block: gBlock))
                }
            }//G
            if self.u > 0{
                let uPool: ManaPool = ManaPool(pool: self)
                var uBlock: CostBlock = block
                uPool.u -= 1
                uBlock.gu -= 1
                if uPool.canCoverCost(block: uBlock){
                    resultSet = resultSet.union(uPool.payCost(block: uBlock))
                }
            }//U
        }//GU
        
        return resultSet
    }//payCost
    
    public func canCoverCost(ofCard: MCard) -> Bool{
        var cardCostBlock: CostBlock = CostBlock()
        //TODO: handle Phyrexian mana better
        cardCostBlock.w = Int(ofCard.whiteCost + ofCard.whitephyCost)
        cardCostBlock.u = Int(ofCard.blueCost + ofCard.bluephyCost)
        cardCostBlock.b = Int(ofCard.blackCost + ofCard.blackphyCost)
        cardCostBlock.r = Int(ofCard.redCost + ofCard.redphyCost)
        cardCostBlock.g = Int(ofCard.greenCost + ofCard.greenphyCost)
        cardCostBlock.c = Int(ofCard.colorlessCost)
        cardCostBlock.any = Int(ofCard.anymanaCost + ofCard.xmanaCost)
        cardCostBlock.wu = Int(ofCard.whiteblueCost)
        cardCostBlock.ub = Int(ofCard.blueblackCost)
        cardCostBlock.br = Int(ofCard.blackredCost)
        cardCostBlock.rg = Int(ofCard.redgreenCost)
        cardCostBlock.gw = Int(ofCard.greenwhiteCost)
        cardCostBlock.wb = Int(ofCard.whiteblackCost)
        cardCostBlock.ur = Int(ofCard.blueredCost)
        cardCostBlock.bg = Int(ofCard.blackgreenCost)
        cardCostBlock.rw = Int(ofCard.redwhiteCost)
        cardCostBlock.gu = Int(ofCard.greenblueCost)
        
        return self.canCoverCost(block: cardCostBlock)
        
    }//canCoverCost
    
    ///Recursively tries replacing "choice" costs with various hard-mana to test the cost covering capabilities
    private func canCoverCost(block: CostBlock) -> Bool{
        if block.isEmpty(){
            return true
        }
        
        
        //Choice-mana handlers
        //Any
        if block.any > 0{
            var tryBlock: CostBlock = block
            tryBlock.any -= 1
            
            if (self.w > block.w){
                var tryWhite: CostBlock = tryBlock
                tryWhite.w += 1
                if (canCoverCost(block: tryWhite)){ return true }
            }
            
            if (self.u > block.u){
                var tryBlue: CostBlock = tryBlock
                tryBlue.u += 1
                if (canCoverCost(block: tryBlue)){ return true }
            }
            
            if (self.b > block.b){
                var tryBlack: CostBlock = tryBlock
                tryBlack.b += 1
                if (canCoverCost(block: tryBlack)){ return true }
            }
            
            if (self.r > block.r){
                var tryRed: CostBlock = tryBlock
                tryRed.r += 1
                if (canCoverCost(block: tryRed)){ return true }
            }
            
            if (self.g > block.g){
                var tryGreen: CostBlock = tryBlock
                tryGreen.g += 1
                if (canCoverCost(block: tryGreen)){ return true }
            }
            
            var tryColorless: CostBlock = tryBlock
            tryColorless.c += 1
            if (canCoverCost(block: tryColorless)){ return true }
            
            return false //cannot meet this requirement
        }//if an any-mana cost still exists
        
        //Dual
        if block.wu > 0{
            var tryBlock: CostBlock = block
            tryBlock.wu -= 1
            
            if (self.w > block.w){
                var tryWhite: CostBlock = tryBlock
                tryWhite.w += 1
                if (canCoverCost(block: tryWhite)){ return true }
            }
            
            if (self.u > block.u){
                var tryBlue: CostBlock = tryBlock
                tryBlue.u += 1
                if (canCoverCost(block: tryBlue)){ return true }
            }
            
            return false //cannot meet this requirement
        }//WU
        
        if block.ub > 0{
            var tryBlock: CostBlock = block
            tryBlock.ub -= 1
            
            if (self.u > block.u){
                var tryBlue: CostBlock = tryBlock
                tryBlue.u += 1
                if (canCoverCost(block: tryBlue)){ return true }
            }
            
            if (self.b > block.b){
                var tryBlack: CostBlock = tryBlock
                tryBlack.b += 1
                if (canCoverCost(block: tryBlack)){ return true }
            }
            
            return false //cannot meet this requirement
        }//UB
        
        if block.br > 0{
            var tryBlock: CostBlock = block
            tryBlock.br -= 1

            if (self.b > block.b){
                var tryBlack: CostBlock = tryBlock
                tryBlack.b += 1
                if (canCoverCost(block: tryBlack)){ return true }
            }
            
            if (self.r > block.r){
                var tryRed: CostBlock = tryBlock
                tryRed.r += 1
                if (canCoverCost(block: tryRed)){ return true }
            }
            
            return false //cannot meet this requirement
        }//BR
        
        if block.rg > 0{
            var tryBlock: CostBlock = block
            tryBlock.rg -= 1
            
            if (self.r > block.r){
                var tryRed: CostBlock = tryBlock
                tryRed.r += 1
                if (canCoverCost(block: tryRed)){ return true }
            }
            
            if (self.g > block.g){
                var tryGreen: CostBlock = tryBlock
                tryGreen.g += 1
                if (canCoverCost(block: tryGreen)){ return true }
            }
            
            return false //cannot meet this requirement
        }//RG
        
        if block.gw > 0{
            var tryBlock: CostBlock = block
            tryBlock.gw -= 1
            
            if (self.g > block.g){
                var tryGreen: CostBlock = tryBlock
                tryGreen.g += 1
                if (canCoverCost(block: tryGreen)){ return true }
            }
            
            if (self.w > block.w){
                var tryWhite: CostBlock = tryBlock
                tryWhite.w += 1
                if (canCoverCost(block: tryWhite)){ return true }
            }
            
            return false //cannot meet this requirement
        }//GW
        
        if block.wb > 0{
            var tryBlock: CostBlock = block
            tryBlock.wb -= 1
            
            if (self.w > block.w){
                var tryWhite: CostBlock = tryBlock
                tryWhite.w += 1
                if (canCoverCost(block: tryWhite)){ return true }
            }
            
            if (self.b > block.b){
                var tryBlack: CostBlock = tryBlock
                tryBlack.b += 1
                if (canCoverCost(block: tryBlack)){ return true }
            }
            
            return false //cannot meet this requirement
        }//WB
        
        if block.ur > 0{
            var tryBlock: CostBlock = block
            tryBlock.ur -= 1
       
            if (self.u > block.u){
                var tryBlue: CostBlock = tryBlock
                tryBlue.u += 1
                if (canCoverCost(block: tryBlue)){ return true }
            }
            
            if (self.r > block.r){
                var tryRed: CostBlock = tryBlock
                tryRed.r += 1
                if (canCoverCost(block: tryRed)){ return true }
            }
            
            return false //cannot meet this requirement
        }//UR
        
        if block.bg > 0{
            var tryBlock: CostBlock = block
            tryBlock.bg -= 1
            
            if (self.b > block.b){
                var tryBlack: CostBlock = tryBlock
                tryBlack.b += 1
                if (canCoverCost(block: tryBlack)){ return true }
            }
            
            if (self.g > block.g){
                var tryGreen: CostBlock = tryBlock
                tryGreen.g += 1
                if (canCoverCost(block: tryGreen)){ return true }
            }
            
            return false //cannot meet this requirement
        }//BG
        
        if block.rw > 0{
            var tryBlock: CostBlock = block
            tryBlock.rw -= 1
            
            if (self.r > block.r){
                var tryRed: CostBlock = tryBlock
                tryRed.r += 1
                if (canCoverCost(block: tryRed)){ return true }
            }
            
            if (self.w > block.w){
                var tryWhite: CostBlock = tryBlock
                tryWhite.w += 1
                if (canCoverCost(block: tryWhite)){ return true }
            }
            
            return false //cannot meet this requirement
        }//RW
        
        if block.gu > 0{
            var tryBlock: CostBlock = block
            tryBlock.gu -= 1
            
            if (self.g > block.g){
                var tryGreen: CostBlock = tryBlock
                tryGreen.g += 1
                if (canCoverCost(block: tryGreen)){ return true }
            }
            
            if (self.u > block.u){
                var tryBlue: CostBlock = tryBlock
                tryBlue.u += 1
                if (canCoverCost(block: tryBlue)){ return true }
            }
            
            return false //cannot meet this requirement
        }//GU
        
        if block.w > self.w{
            return false//cannot meet this requirement
        }
        if block.u > self.u{
            return false//cannot meet this requirement
        }
        if block.b > self.b{
            return false//cannot meet this requirement
        }
        if block.r > self.r{
            return false//cannot meet this requirement
        }
        if block.g > self.g{
            return false//cannot meet this requirement
        }
        if block.c > self.c{
            return false//cannot meet this requirement
        }

        return true
    }//canCoverCost
    
    private struct CostBlock{
        var w: Int = 0
        var u: Int = 0
        var b: Int = 0
        var r: Int = 0
        var g: Int = 0
        var c: Int = 0
        var any: Int = 0
        var wu: Int = 0
        var ub: Int = 0
        var br: Int = 0
        var rg: Int = 0
        var gw: Int = 0
        var wb: Int = 0
        var ur: Int = 0
        var bg: Int = 0
        var rw: Int = 0
        var gu: Int = 0
        
        internal func isEmpty()->Bool{
            return (self.any == 0) && (w == 0) && (u == 0) && (b == 0) && (r == 0) && (g == 0) && (c == 0) && (wu == 0) && (ub == 0) && (br == 0) && (rg == 0) && (gw == 0) && (wb == 0) && (ur == 0) && (bg == 0) && (rw == 0) && (gu == 0)
        }
        
    }//CostBlock
    
    
    
}//ManaPool

