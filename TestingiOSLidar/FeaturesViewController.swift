//
//  FeaturesViewController.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 14/06/23.
//

import SwiftUI

class FeaturesViewController: UIHostingController<FeaturesView> {

    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: FeaturesView())
        rootView.tapAction = featureFlowManagement
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func featureFlowManagement(_ featureFlow: FeaturesFlow) {
        switch(featureFlow) {
        case .saveFrames:
            if let sicoobAuthController = self.storyboard?.instantiateViewController(withIdentifier: "SaveFrameViewController") {
                self.navigationController?.pushViewController(sicoobAuthController, animated: true)
            }
        case .experienceLidar:
            if let managementCallController = self.storyboard?.instantiateViewController(withIdentifier: "ExperienceViewController") {
                self.navigationController?.pushViewController(managementCallController, animated: true)
            }
        }
    }

}
