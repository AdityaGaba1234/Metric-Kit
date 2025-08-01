//
//  DetailedAnalyticsViewController.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 30/07/25.
//

import Foundation
import UIKit
import SwiftUI

class DetailedAnalyticsViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

     private var isLoading = false
     private var lastLoadTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        loadAnalyticsData()
    }
    
    private func setupUI() {
        title = "Detailed Analytics"
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        
        // Add comprehensive analytics sections
        addMetricsSummarySection()
        addHistogramAnalysisSection()
        addMetadataSection()
        addSignpostSection()
        
        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
    }
    
    private func addMetricsSummarySection() {
        let sectionView = createSectionView(
            title: "📈 Metrics Summary",
            content: MetricKitManager.shared.getMetricsSummary()
        )
        stackView.addArrangedSubview(sectionView)
    }
    
    private func addHistogramAnalysisSection() {
        let sectionView = createSectionView(
            title: "📊 Histogram Analysis",
            content: MetricKitManager.shared.getHistogramAnalysis()
        )
        stackView.addArrangedSubview(sectionView)
    }
    
    private func addMetadataSection() {
        let sectionView = createSectionView(
            title: "📱 Device Metadata",
            content: MetricKitManager.shared.getDetailedMetadataReport()
        )
        stackView.addArrangedSubview(sectionView)
    }
    
    private func addSignpostSection() {
        let sectionView = createSectionView(
            title: "📊 Signpost Analysis",
            content: MetricKitManager.shared.getSignpostAnalysis()
        )
        stackView.addArrangedSubview(sectionView)
    }
    
    private func createSectionView(title: String, content: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor.label
        
        let contentTextView = UITextView()
        contentTextView.text = content
        contentTextView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        contentTextView.textColor = UIColor.secondaryLabel
        contentTextView.backgroundColor = UIColor.secondarySystemGroupedBackground
        contentTextView.layer.cornerRadius = 8
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
        contentTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        [titleLabel, contentTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            contentTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            contentTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        return containerView
    }
    

    
    private func loadAnalyticsData() {
        // Prevent multiple rapid refreshes
        let now = Date()
        if let lastLoad = lastLoadTime, now.timeIntervalSince(lastLoad) < 2.0 {
            return // Prevent refresh if called within 2 seconds
        }
        
        guard !isLoading else { return } // Prevent concurrent loading
        
        isLoading = true
        lastLoadTime = now
        
        DispatchQueue.main.async {
            // Clear existing sections first
            self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            // Add fresh data
            self.addMetricsSummarySection()
            self.addHistogramAnalysisSection()
            self.addMetadataSection()
            self.addSignpostSection()
            
            self.isLoading = false
        }
    }
    
    private func setupNavigationBar() {
        let refreshItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshAnalytics)
        )
        navigationItem.rightBarButtonItem = refreshItem
    }
    
    @objc private func refreshAnalytics() {
        loadAnalyticsData()
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
