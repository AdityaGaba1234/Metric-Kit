//
//  CallStackAnalysisView.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 30/07/25.
//

import Foundation
import UIKit
import MetricKit

class CallStackAnalysisView: UIView {
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
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
        
        titleLabel.text = "🔍 Call Stack Analysis"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor.label
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        
        [titleLabel, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            scrollView.heightAnchor.constraint(equalToConstant: 150),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func updateData(crashes: [MXCrashDiagnostic], hangs: [MXHangDiagnostic]) {
        // Clear existing views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if crashes.isEmpty && hangs.isEmpty {
            let noDataLabel = createInfoLabel("✅ No crashes or hangs detected", color: UIColor.systemGreen)
            stackView.addArrangedSubview(noDataLabel)
            return
        }
        
        // Add crash info
        for (index, crash) in crashes.enumerated() {
            let crashView = createCrashInfoView(crash: crash, index: index + 1)
            stackView.addArrangedSubview(crashView)
        }
        
        // Add hang info
        for (index, hang) in hangs.enumerated() {
            let hangView = createHangInfoView(hang: hang, index: index + 1)
            stackView.addArrangedSubview(hangView)
        }
    }
    
    private func createCrashInfoView(crash: MXCrashDiagnostic, index: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemRed.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "💥 Crash #\(index)"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.systemRed
        
        let exceptionLabel = UILabel()
        exceptionLabel.text = "Exception: \(crash.exceptionType?.description ?? "Unknown")"
        exceptionLabel.font = UIFont.systemFont(ofSize: 14)
        exceptionLabel.textColor = UIColor.label
        
        let signalLabel = UILabel()
        signalLabel.text = "Signal: \(crash.signal?.description ?? "Unknown")"
        signalLabel.font = UIFont.systemFont(ofSize: 14)
        signalLabel.textColor = UIColor.label
        
        [titleLabel, exceptionLabel, signalLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            exceptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            exceptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            exceptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            signalLabel.topAnchor.constraint(equalTo: exceptionLabel.bottomAnchor, constant: 4),
            signalLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            signalLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            signalLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    private func createHangInfoView(hang: MXHangDiagnostic, index: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemOrange.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "🔒 Hang #\(index)"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.systemOrange
        
        let durationLabel = UILabel()
        let seconds = hang.hangDuration.converted(to: .seconds).value
        durationLabel.text = "Duration: \(String(format: "%.2f", seconds))s"
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.textColor = UIColor.label
        
        let versionLabel = UILabel()
        versionLabel.text = "App Version: \(hang.applicationVersion)"
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.textColor = UIColor.label
        
        [titleLabel, durationLabel, versionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            durationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            versionLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 4),
            versionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            versionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            versionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    private func createInfoLabel(_ text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = color
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
}
