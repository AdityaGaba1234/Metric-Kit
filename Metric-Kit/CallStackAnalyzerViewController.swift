//
//  CallStackAnalyzerViewController.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 30/07/25.
//

import Foundation
import UIKit

class CallStackAnalyzerViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private var isLoading = false
    private var lastDataHash: Int = 0
    
    private let refreshButton = UIButton(type: .system)
    private let exportButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        loadCallStackData()
    }
    
    private func setupUI() {
        title = "Call Stack Analyzer"
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        
        // Add call stack analysis sections
        addCallStackAnalysisSection()
        addCrashFinderSection()
        addDetailedAnalysisSection()
        
        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
    }
    
    private func addCallStackAnalysisSection() {
        let sectionView = createAnalysisSection(
            title: "🔍 Call Stack Analysis",
            content: MetricKitManager.shared.getDetailedCallStackAnalysis(),
            color: UIColor.systemBlue
        )
        stackView.addArrangedSubview(sectionView)
    }
    
    private func addCrashFinderSection() {
        let sectionView = createAnalysisSection(
            title: "🎯 Crash Location Finder",
            content: MetricKitManager.shared.findCrashLocationInDevelopment(),
            color: UIColor.systemRed
        )
        stackView.addArrangedSubview(sectionView)
    }
    
    private func addDetailedAnalysisSection() {
        let manager = MetricKitManager.shared
        var detailedContent = "📊 DETAILED DIAGNOSTIC SUMMARY:\n\n"
        
        detailedContent += "💥 Crashes: \(manager.crashes.count)\n"
        detailedContent += "🔒 Hangs: \(manager.hangs.count)\n"
        detailedContent += "🔥 CPU Exceptions: \(manager.cpuExceptions.count)\n"
        detailedContent += "💽 Disk Exceptions: \(manager.diskExceptions.count)\n"
        detailedContent += "🚀 Launch Diagnostics: \(manager.launchDiagnostics.count)\n\n"
        
        if manager.crashes.isEmpty && manager.hangs.isEmpty {
            detailedContent += "✅ No issues detected! Your app is running smoothly.\n"
        } else {
            detailedContent += "⚠️ Issues detected. Check individual sections for details.\n"
        }
        
        let sectionView = createAnalysisSection(
            title: "📈 Summary Overview",
            content: detailedContent,
            color: UIColor.systemGreen
        )
        stackView.addArrangedSubview(sectionView)
    }
    
    private func createAnalysisSection(title: String, content: String, color: UIColor) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = color.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = color
        
        let contentTextView = UITextView()
        contentTextView.text = content
        contentTextView.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        contentTextView.textColor = UIColor.label
        contentTextView.backgroundColor = UIColor.secondarySystemGroupedBackground
        contentTextView.layer.cornerRadius = 12
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
        contentTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        // Add copy button
        let copyButton = UIButton(type: .system)
        copyButton.setTitle("📋 Copy", for: .normal)
        copyButton.backgroundColor = color.withAlphaComponent(0.1)
        copyButton.setTitleColor(color, for: .normal)
        copyButton.layer.cornerRadius = 8
        copyButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        copyButton.addAction(UIAction { _ in
            UIPasteboard.general.string = content
            
            // Show brief confirmation
            let alert = UIAlertController(title: "✅ Copied!", message: "Content copied to clipboard", preferredStyle: .alert)
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alert.dismiss(animated: true)
            }
        }, for: .touchUpInside)
        
        [titleLabel, contentTextView, copyButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            copyButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            copyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            contentTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            contentTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            contentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
        
        return containerView
    }

    private func loadCallStackData() {
        guard !isLoading else { return }
        
        let manager = MetricKitManager.shared
        
        // Create a hash of current data to check if it changed
        let currentDataHash = manager.crashes.count * 1000 +
                             manager.hangs.count * 100 +
                             manager.cpuExceptions.count * 10 +
                             manager.diskExceptions.count
        
        // Only refresh if data actually changed
        if currentDataHash == lastDataHash {
            return
        }
        
        isLoading = true
        lastDataHash = currentDataHash
        
        DispatchQueue.main.async {
            // Clear and reload sections
            self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self.addCallStackAnalysisSection()
            self.addCrashFinderSection()
            self.addDetailedAnalysisSection()
            
            self.isLoading = false
        }
    }
    
    private func setupNavigationBar() {
        let refreshItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshData)
        )
        
        let exportItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(exportAnalysis)
        )
        
        navigationItem.rightBarButtonItems = [exportItem, refreshItem]
    }
    
    @objc private func refreshData() {
        loadCallStackData()
    }
    
    @objc private func exportAnalysis() {
        let fullAnalysis = """
        📊 COMPLETE CALL STACK ANALYSIS REPORT
        =====================================
        
        \(MetricKitManager.shared.getDetailedCallStackAnalysis())
        
        \(MetricKitManager.shared.findCrashLocationInDevelopment())
        
        Generated: \(DateFormatter.detailed.string(from: Date()))
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [fullAnalysis],
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.first
        }
        
        present(activityVC, animated: true)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}
