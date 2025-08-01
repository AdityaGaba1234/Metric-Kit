//
//  DeviceInfoView.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 30/07/25.
//

import Foundation
import UIKit
import MetricKit

class DeviceInfoView: UIView {
    private let titleLabel = UILabel()
    private let deviceTypeLabel = UILabel()
    private let osVersionLabel = UILabel()
    private let appVersionLabel = UILabel()
    private let testFlightLabel = UILabel()
    private let batteryModeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.secondarySystemGroupedBackground
        layer.cornerRadius = 12
        
        titleLabel.text = "📱 Device Information"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor.label
        
        let labels = [deviceTypeLabel, osVersionLabel, appVersionLabel, testFlightLabel, batteryModeLabel]
        
        labels.forEach { label in
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor.secondaryLabel
            label.numberOfLines = 0
        }
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel] + labels)
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func updateData(with metaData: MXMetaData) {
        deviceTypeLabel.text = "🔧 Device: \(metaData.deviceType)"
        osVersionLabel.text = "💿 OS Version: \(metaData.osVersion)"
        appVersionLabel.text = "📦 App Version: \(metaData.applicationBuildVersion)"
        testFlightLabel.text = "✈️ TestFlight: \(metaData.isTestFlightApp ? "Yes" : "No")"
        batteryModeLabel.text = "🔋 Low Power Mode: \(metaData.lowPowerModeEnabled ? "Enabled" : "Disabled")"
    }
}
