//
//  OptionalExtensions.swift
//  GraphKit
//
//  Created by Håkan Andersson on 20/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import Foundation

extension Optional {
    func or(_ defaultValue: Wrapped) -> Wrapped {
        switch(self) {
        case .none:
            return defaultValue
        case .some(let value):
            return value
        }
    }
}
