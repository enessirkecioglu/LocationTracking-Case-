//
//  CustomCalloutView.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 1.06.2024.
//

import UIKit

final class CustomCalloutView: UIView {
    static let reuseIdentifier = "customAnnotation"
    private let addressLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addressLabel.numberOfLines = 0
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(addressLabel)
        
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            addressLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            addressLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    
    func setAddress(_ address: String) {
        addressLabel.text = address
    }
}
