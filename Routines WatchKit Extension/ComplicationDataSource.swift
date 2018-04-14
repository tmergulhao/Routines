//
//  ComplicationDataSource.swift
//  Routines WatchKit Extension
//
//  Created by Tiago Mergulhão on 14/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import ClockKit
import WatchKit

class ComplicationDataSource : NSObject, CLKComplicationDataSource {

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {

        handler(nil)
    }

    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {

    }
}
