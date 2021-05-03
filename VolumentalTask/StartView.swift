//
//  StartView.swift
//  VolumentalTask
//
//  Created by Samuel Norling on 2021-04-28.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var userState = UserState(showARView: false)
    var body: some View {
        ZStack {
            ARContentView(showARView: $userState.showARView)
            if userState.showARView == false {
                Rectangle()
                .fill(Color.primary)
                .edgesIgnoringSafeArea(.all)
                StartBackgroundView()
                StartTextView()
                StartButtonView(showARView: $userState.showARView)
            }
        }
    }
}

struct StartTextView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                Text("LET'S FIND A PERFECT")
                Text("PAIR FOR YOU")
            }
            .font(Font.custom(VolumentalFonts.bold, size: 24))
            .foregroundColor(.black)
            .fixedSize(horizontal: true, vertical: false)
            Text("A 3D foot scan tech let's you see your feet beyond shoe size - and helps us find you the perfect fit.")
            .font(Font.custom(VolumentalFonts.regular, size: 14))
            .foregroundColor(.black)
        }
        .padding(.horizontal, 30)
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}

struct StartButtonView: View {
    @Binding var showARView: Bool
    var body: some View {
        VStack {
            Spacer()
            Button("GET STARTED WITH INVITE LINK", action: {
                showARView.toggle()
            })
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
            .background(Color.black)
            .foregroundColor(Color.white)
            .font(Font.custom(VolumentalFonts.semibold, size: 12))
            .cornerRadius(24.0)
        }
    }
}

struct StartBackgroundView: View {
    var body: some View {
        VStack(alignment: .trailing) {
            RectangleClear()
            HStack {
                RectangleClear()
                Image("StartIntroImage")
                .resizable()
                .scaledToFill()
            }
            RectangleClear()
            RectangleClear()
        }
    }
}
