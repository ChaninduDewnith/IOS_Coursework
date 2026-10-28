//
//  ServiceCatagery.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-28.
//

import Foundation


struct ServiceCategory: Identifiable, Hashable {
    let name: String
    let icon: String
    var id: String { name }
}
