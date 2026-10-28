//
//  TimeLine.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-28.
//


struct TimelineStep: Identifiable {
    enum Kind { case done, upcoming, failed }

    let id: Int
    let title: String
    let date: Date?
    let kind: Kind
}
