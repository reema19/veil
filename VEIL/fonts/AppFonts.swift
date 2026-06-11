//
//  AppFonts.swift
//  VEIL
//
//  Created by reema aljohani on 6/6/26.
//


import SwiftUI

extension Font {

    static let veilHero = Font.custom(
        "DMSans-Bold",
        size: 36,
        relativeTo: .largeTitle
    )

    static let veilTitle = Font.custom(
        "DMSans-Bold",
        size: 24,
        relativeTo: .title2
    )

    static let veilSectionTitle = Font.custom(
        "DMSans-Bold",
        size: 20,
        relativeTo: .title3
    )

    static let veilHeadline = Font.custom(
        "DMSans-SemiBold",
        size: 20,
        relativeTo: .headline
    )

    static let veilBody = Font.custom(
        "DMSans-Regular",
        size: 16,
        relativeTo: .body
    )

    static let veilSubheadline = Font.custom(
        "DMSans-Regular",
        size: 14,
        relativeTo: .subheadline
    )

    static let veilCaption = Font.custom(
        "DMSans-Bold",
        size: 14,
        relativeTo: .caption
    )

    static let veilSmallCaption = Font.custom(
        "DMSans-Medium",
        size: 11,
        relativeTo: .caption2
    )
}
