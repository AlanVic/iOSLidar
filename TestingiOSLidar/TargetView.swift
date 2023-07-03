//
//  TargetView.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 30/06/23.
//

import UIKit

class TargetView: UIView {
    private let dotView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .red
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()

    private let borderView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.borderWidth = 2
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var sizeHeightAnchor: NSLayoutConstraint = self.heightAnchor.constraint(equalToConstant: 30)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupCornerRadius()
    }

    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        addViews()
        configConstraints()
    }

    private func setupCornerRadius() {
        self.borderView.layer.cornerRadius = borderView.frame.width / 2
        self.dotView.layer.cornerRadius = dotView.frame.width / 2
    }

    private func addViews() {
        self.addSubview(borderView)
        self.addSubview(dotView)
    }

    private func configConstraints() {
        NSLayoutConstraint.activate([
            sizeHeightAnchor,
            self.widthAnchor.constraint(equalTo: self.heightAnchor),

            borderView.widthAnchor.constraint(equalTo: self.widthAnchor),
            borderView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: borderView.centerYAnchor),

            dotView.widthAnchor.constraint(equalToConstant: 5),
            dotView.heightAnchor.constraint(equalToConstant: 5),
            dotView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dotView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    public func setSizeTarget(_ size: CGFloat) {
        sizeHeightAnchor.constant = size
        //layoutSubviews()
    }

}
