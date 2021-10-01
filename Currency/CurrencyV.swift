//
//  CurrencyV.swift
//  Currency
//
//  Created by Андрей Илалов on 01.10.2021.
//  Copyright © 2021 Максим Смирнов. All rights reserved.
//

import Foundation

class CurrencyVM {
    func getMinimumDifference(a: [String], b: [String]) -> [Int] {
        var diff: [Int] = []
        
        a.enumerated().forEach({ id, element in
            if element.count != b[id].count {
                diff.append(-1)
            } else {
                let arrayOfAs = Array(element)
                let arrayOfBs = Array(b[id])
                
                let dictA = createDictOfTypes(from: arrayOfAs)
                let dictB = createDictOfTypes(from: arrayOfBs)
                
                
                var res: Int = 0
                var usedSetOfB: Set<String> = []
                var usedSetOfA: Set<String> = []
                
                arrayOfAs.forEach { char in
                    let str = String(char)
                    
                    if dictB[str] != nil  {
                        if dictB[str]! != dictA[str], !usedSetOfB.contains(str) {
                            
                            res += abs(dictB[str]! - dictA[str]!) - 1
                        }
                        usedSetOfB.insert(str)
                    } else if !usedSetOfA.contains(str) {
                        res += dictA[str]!
                        usedSetOfA.insert(str)
                    }
                }
                diff.append(res)
            }
        })
        
        return diff
    }

    func createDictOfTypes(from array: [String.Element]) -> Dictionary<String, Int> {
        var resultedDict: Dictionary<String, Int> = [:]
        
        for elementAs in array {
            if resultedDict[String(elementAs)] != nil {
                resultedDict[String(elementAs)]! += 1
            } else {
                resultedDict[String(elementAs)] = 1
            }
        }
        
        return resultedDict
    }
}
