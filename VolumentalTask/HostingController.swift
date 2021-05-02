//
//  HostingController.swift
//  VolumentalTask
//
//  Created by Samuel Norling on 2021-04-30.
//

import Foundation
import SwiftUI

class HostingController<ContentView>: UIHostingController<ContentView> where ContentView : View {
    // The purpose of this class is to set the status bar text to black which was requested in design
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
}
