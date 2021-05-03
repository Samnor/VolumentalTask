//
//  UserState.swift
//  VolumentalTask
//
//  Created by Samuel Norling on 2021-05-03.
//

import Foundation

class UserState: ObservableObject {
    @Published var showARView: Bool
    
    init(showARView: Bool) {
        self.showARView = showARView
    }
    
}
