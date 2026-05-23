//
//  SensePrompt.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

//
//  SensePrompt.swift
//  VEIL
//
import Foundation

struct SensePrompt: Identifiable {
    let id = UUID()
    let question: String
    let sense: SenseType
}
