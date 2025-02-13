//
//  Date.swift
//  MessageIO
//
//  Copyright (c) 2025 z-wook. All right reserved.
//

import Foundation

extension Date {
    var dateFormattedString: String {
        return self.formatted(.dateTime
            .year(.defaultDigits)
            .month(.defaultDigits)
            .day(.defaultDigits)
            .hour(.twoDigits(amPM: .omitted))
            .minute(.twoDigits)
            .locale(Locale(identifier: "ko_KR"))
        )
    }
    
    var timeOnlyString: String {
        return self.formatted(.dateTime
            .hour(.twoDigits(amPM: .omitted))
            .minute(.twoDigits)
            .locale(Locale(identifier: "ko_KR"))
        )
    }
}
