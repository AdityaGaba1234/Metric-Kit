//
//  MetricCardView.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 30/07/25.
//

import UIKit

class MetricCardView: UIView {

    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let backgroundView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Background
        backgroundView.backgroundColor = UIColor.systemBackground
        backgroundView.layer.cornerRadius = 12
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundView.layer.shadowRadius = 4
        backgroundView.layer.shadowOpacity = 0.1
        
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        
        titleLabel.font = UIFont.systemFont(ofSize: 14 , weight: .medium)
        titleLabel.textColor = UIColor.secondaryLabel
        titleLabel.textAlignment = .center
        
        valueLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        valueLabel.textColor = UIColor.label
        valueLabel.textAlignment = .center
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = UIColor.tertiaryLabel
        subtitleLabel.textAlignment = .center
        
        [backgroundView , iconLabel , titleLabel , valueLabel , subtitleLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
            iconLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
            
            subtitleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(title: String , value: String , subtitle: String , color: UIColor , icon: String) {
        titleLabel.text = title
        valueLabel.text = value
        subtitleLabel.text = subtitle
        iconLabel.text = icon
        
        backgroundView.layer.borderWidth = 2
        backgroundView.layer.borderColor = color.cgColor
        valueLabel.textColor = color
    }
    
    func updateValue(_ newValue: String){
        valueLabel.text = newValue
        
        UIView.animate(withDuration: 0.3){
            self.valueLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.valueLabel.transform = .identity
            }
        }

        
    }
    
}

