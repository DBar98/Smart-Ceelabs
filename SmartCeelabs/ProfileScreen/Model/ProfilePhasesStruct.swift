//
//  ProfilePhasesStruct.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 01/11/2021.
//
import Foundation

struct ProfilePhaseStruct{
    
    var phaseName: String

    init(phaseName: String){
        self.phaseName = phaseName
    }

    private static var _phasesArray: [String] = ["L1", "L2", "L3"]

    public static var phasesArray: [String] {
        get {
            return _phasesArray
        }
    }
}

let profilePhasesCells: [ProfilePhaseStruct] = [
    ProfilePhaseStruct(phaseName: "Phase L1"),
    ProfilePhaseStruct(phaseName: "Phase L2"),
    ProfilePhaseStruct(phaseName: "Phase L3"),
    ProfilePhaseStruct(phaseName: "Average")
]
