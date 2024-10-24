//
//  UserModel.swift
//  SwipableCards
//
//  Created by Alireza Toghiani on 10/22/24.
//

import Foundation

struct User: Hashable, CustomStringConvertible {
    var id: Int
    
    let firstName: String
    let lastName: String
    
    var description: String {
        return "\(firstName), id: \(id)"
    }
}
