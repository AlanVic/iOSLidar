//
//  FeaturesView.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 14/06/23.
//

import SwiftUI

enum FeaturesFlow {
    case saveFrames
    case experienceLidar
}

struct FeaturesView: View {
    var tapAction: ((FeaturesFlow) -> Void)?

    var body: some View {
        VStack {
            Text("O que você deseja fazer?")
                .font(.title2)
                .padding([.bottom], 24)
            
            styleButton(iconImage: "plus.rectangle.on.folder", label: "Capturar frames") {
                tapAction?(.saveFrames)
            }
            styleButton(iconImage: "sensor", label: "Experiência LIDAR") {
                tapAction?(.experienceLidar)
            }
        }
    }

    private func styleButton(iconImage: String ,label: String, action: @escaping () -> Void) -> some View {
        return Button(action: action) {
            HStack {
                Image(systemName: iconImage)
                Text(label)
                    .accentColor(.white)
                    .font(.title3)
            }
            .padding([.bottom, .top], 4)
            .frame(maxWidth: .infinity)
        }
        .frame(width: UIScreen.main.bounds.width - 64)
        .buttonStyle(.borderedProminent)
        .padding([.bottom], 12)
    }
}

struct FeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesView(tapAction: { feature in
            print(feature)
        })
    }
}
