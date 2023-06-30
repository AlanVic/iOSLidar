//
//  TargetView.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 30/06/23.
//

import UIKit

class TargetView: UIView {
    private let dotView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: 2))
        view.layer.cornerRadius = view.frame.width / 2
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()

    private let borderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        view.layer.borderWidth = 2
        view.layer.cornerRadius = view.frame.width / 2
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.red.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addViews()
        configConstraints()
    }

    private func addViews() {
        self.addSubview(borderView)
        self.borderView.addSubview(dotView)
    }

    private func configConstraints() {
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 4),
            self.widthAnchor.constraint(equalTo: self.heightAnchor),

            borderView.widthAnchor.constraint(equalTo: self.widthAnchor),
            borderView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: borderView.centerYAnchor),

            dotView.widthAnchor.constraint(equalToConstant: 2),
            dotView.heightAnchor.constraint(equalToConstant: 2),
            dotView.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
            dotView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor)
        ])
    }

}
