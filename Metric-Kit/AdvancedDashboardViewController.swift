//
//  AdvancedDashboardViewController.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 30/07/25.
//

import UIKit
import Charts
import MetricKit
import SwiftUI

class AdvancedDashboardViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    // Header Stats
    private let headerStatsView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let refreshButton = UIButton(type: .system)
    
    private var isLoading = false
    private var lastRefreshTime: Date?
    
    // Quick Stats Cards
    private let quickStatsStackView = UIStackView()
    private let crashesCard = MetricCardView()
    private let hangsCard = MetricCardView()
    private let memoryCard = MetricCardView()
    private let cpuCard = MetricCardView()
    
    // Charts Container
    private let chartsContainerView = UIView()
    private let launchTimeChartView = HistogramChartView()
    private let hangTimeChartView = HistogramChartView()
    private let memoryUsageChartView = LineChartView()
    private let networkUsageChartView = BarChartView()
    
    // Detailed Analysis
    private let analysisContainerView = UIView()
    private let callStackAnalysisView = CallStackAnalysisView()
    private let deviceInfoView = DeviceInfoView()
    
    // Action Buttons
    private let actionButtonsStackView = UIStackView()
    
    private let refreshIndicator = UIActivityIndicatorView(style: .medium)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        
        // Load saved data first
        MetricKitManager.shared.loadMetricsFromStorage()
        
        // Then load current metrics
        loadMetricsData()
        
        // Setup MetricKit callbacks
        MetricKitManager.shared.onPayloadReceived = { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadMetricsData()
            }
        }
        
        MetricKitManager.shared.onDiagnosticReceived = { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadMetricsData()
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        
        // Header
        setupHeaderView()
        
        // Quick Stats
        setupQuickStatsView()
        
        // Charts
        setupChartsView()
        
        // Analysis
        setupAnalysisView()
        
        // Action Buttons
        setupActionButtons()
        
        // Add to stack view
        stackView.addArrangedSubview(headerStatsView)
        stackView.addArrangedSubview(quickStatsStackView)
        stackView.addArrangedSubview(chartsContainerView)
        stackView.addArrangedSubview(analysisContainerView)
        stackView.addArrangedSubview(actionButtonsStackView)
        
        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
    }
    
    private func setupHeaderView() {
        headerStatsView.backgroundColor = UIColor.systemBackground
        headerStatsView.layer.cornerRadius = 12
        headerStatsView.layer.shadowColor = UIColor.black.cgColor
        headerStatsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerStatsView.layer.shadowRadius = 4
        headerStatsView.layer.shadowOpacity = 0.1
        
        titleLabel.text = "📊 MetricKit Analytics Dashboard"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor.label
        
        subtitleLabel.text = "Real-time app performance insights"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor.secondaryLabel
        

        
        [titleLabel, subtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerStatsView.addSubview($0)
        }
    }
    
    private func setupQuickStatsView() {
        quickStatsStackView.axis = .horizontal
        quickStatsStackView.distribution = .fillEqually
        quickStatsStackView.spacing = 12
        
        // Configure cards
        crashesCard.configure(
            title: "Crashes",
            value: "0",
            subtitle: "Total detected",
            color: UIColor.systemRed,
            icon: "💥"
        )
        
        hangsCard.configure(
            title: "Hangs",
            value: "0",
            subtitle: "App freezes",
            color: UIColor.systemOrange,
            icon: "🔒"
        )
        
        memoryCard.configure(
            title: "Memory",
            value: "0 MB",
            subtitle: "Peak usage",
            color: UIColor.systemPurple,
            icon: "💾"
        )
        
        cpuCard.configure(
            title: "CPU Time",
            value: "0s",
            subtitle: "Total usage",
            color: UIColor.systemGreen,
            icon: "🖥️"
        )
        
        [crashesCard, hangsCard, memoryCard, cpuCard].forEach {
            quickStatsStackView.addArrangedSubview($0)
        }
    }
    

    private func setupChartsView() {
        chartsContainerView.backgroundColor = UIColor.systemBackground
        chartsContainerView.layer.cornerRadius = 12
        chartsContainerView.layer.shadowColor = UIColor.black.cgColor
        chartsContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        chartsContainerView.layer.shadowRadius = 4
        chartsContainerView.layer.shadowOpacity = 0.1
        
        let chartsStackView = UIStackView()
        chartsStackView.axis = .vertical
        chartsStackView.spacing = 24 // Increased spacing for better separation
        chartsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Chart titles with better font size
        let launchTimeTitle = createChartTitleLabel("🚀 Launch Time Distribution")
        let hangTimeTitle = createChartTitleLabel("🔒 Hang Time Analysis")
        let memoryTitle = createChartTitleLabel("💾 Memory Usage Timeline")
        let networkTitle = createChartTitleLabel("🌐 Network Transfer Summary")
        
        chartsStackView.addArrangedSubview(launchTimeTitle)
        chartsStackView.addArrangedSubview(launchTimeChartView)
        chartsStackView.addArrangedSubview(hangTimeTitle)
        chartsStackView.addArrangedSubview(hangTimeChartView)
        chartsStackView.addArrangedSubview(memoryTitle)
        chartsStackView.addArrangedSubview(memoryUsageChartView)
        chartsStackView.addArrangedSubview(networkTitle)
        chartsStackView.addArrangedSubview(networkUsageChartView)
        
        chartsContainerView.addSubview(chartsStackView)
        
        // More padding for better presentation
        NSLayoutConstraint.activate([
            chartsStackView.topAnchor.constraint(equalTo: chartsContainerView.topAnchor, constant: 24), // Increased padding
            chartsStackView.leadingAnchor.constraint(equalTo: chartsContainerView.leadingAnchor, constant: 20),
            chartsStackView.trailingAnchor.constraint(equalTo: chartsContainerView.trailingAnchor, constant: -20),
            chartsStackView.bottomAnchor.constraint(equalTo: chartsContainerView.bottomAnchor, constant: -24) // Increased padding
        ])
    }
    
    private func setupAnalysisView() {
        analysisContainerView.backgroundColor = UIColor.systemBackground
        analysisContainerView.layer.cornerRadius = 12
        analysisContainerView.layer.shadowColor = UIColor.black.cgColor
        analysisContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        analysisContainerView.layer.shadowRadius = 4
        analysisContainerView.layer.shadowOpacity = 0.1
        
        let analysisStackView = UIStackView()
        analysisStackView.axis = .vertical
        analysisStackView.spacing = 16
        analysisStackView.translatesAutoresizingMaskIntoConstraints = false
        
        analysisStackView.addArrangedSubview(callStackAnalysisView)
        analysisStackView.addArrangedSubview(deviceInfoView)
        
        analysisContainerView.addSubview(analysisStackView)
        
        NSLayoutConstraint.activate([
            analysisStackView.topAnchor.constraint(equalTo: analysisContainerView.topAnchor, constant: 20),
            analysisStackView.leadingAnchor.constraint(equalTo: analysisContainerView.leadingAnchor, constant: 20),
            analysisStackView.trailingAnchor.constraint(equalTo: analysisContainerView.trailingAnchor, constant: -20),
            analysisStackView.bottomAnchor.constraint(equalTo: analysisContainerView.bottomAnchor, constant: -20)
        ])
    }
    

//    }
    private func setupActionButtons() {
        actionButtonsStackView.axis = .vertical
        actionButtonsStackView.distribution = .fill
        actionButtonsStackView.spacing = 20 // More space between sections
        
        // SECTION 1: Simulation Tests (2x3 grid)
        let simulationSection = createButtonSection(
            title: "🧪 SIMULATION TESTS",
            buttons: [
                createLargeActionButton(title: "💀 Crash Test", backgroundColor: .systemRed) { [weak self] in self?.simulateCrash() },
                createLargeActionButton(title: "🔒 Hang Test", backgroundColor: .systemOrange) { [weak self] in self?.simulateHang() },
                createLargeActionButton(title: "🔥 CPU Test", backgroundColor: .systemPurple) { [weak self] in self?.simulateCPU() },
                createLargeActionButton(title: "💾 Memory Test", backgroundColor: .systemYellow) { [weak self] in self?.simulateMemory() },
                createLargeActionButton(title: "💽 Disk Test", backgroundColor: .systemTeal) { [weak self] in self?.simulateDisk() },
                createLargeActionButton(title: "📥 Request Data", backgroundColor: .systemGreen) { [weak self] in self?.requestMetrics() }
            ],
            columns: 2
        )
        
        // SECTION 2: Analysis Tools (2x2 grid)
        let analysisSection = createButtonSection(
            title: "🔍 ANALYSIS TOOLS",
            buttons: [
                createLargeActionButton(title: "🔍 Call Stacks", backgroundColor: .systemIndigo) { [weak self] in self?.showCallStackAnalysis() },
                createLargeActionButton(title: "📱 Metadata", backgroundColor: .systemBrown) { [weak self] in self?.showMetadataReport() },
                createLargeActionButton(title: "📊 Histograms", backgroundColor: .systemMint) { [weak self] in self?.showHistogramAnalysis() },
                createLargeActionButton(title: "🎯 Find Crash", backgroundColor: .systemRed) { [weak self] in self?.showCrashFinder() }
            ],
            columns: 2
        )
        
        // SECTION 3: Data Controls (3 buttons in a row)
        let controlSection = createButtonSection(
            title: "📋 DATA CONTROLS",
            buttons: [
                createLargeActionButton(title: "📤 Export Data", backgroundColor: .systemBlue) { [weak self] in self?.exportMetricsData() },
                createLargeActionButton(title: "🧹 Clear Data", backgroundColor: .systemGray) { [weak self] in self?.clearAllData() },
                createLargeActionButton(title: "🔄 Refresh All", backgroundColor: .systemCyan) { [weak self] in self?.refreshData() }
            ],
            columns: 3
        )
        
        // Add sections to main stack
        actionButtonsStackView.addArrangedSubview(simulationSection)
        actionButtonsStackView.addArrangedSubview(analysisSection)
        actionButtonsStackView.addArrangedSubview(controlSection)
    }

    // Helper method to create button sections
    private func createButtonSection(title: String, buttons: [UIButton], columns: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        // Section title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Button grid container
        let gridStackView = UIStackView()
        gridStackView.axis = .vertical
        gridStackView.distribution = .fillEqually
        gridStackView.spacing = 12
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create rows
        var currentRow: UIStackView?
        for (index, button) in buttons.enumerated() {
            if index % columns == 0 {
                // Start new row
                currentRow = UIStackView()
                currentRow?.axis = .horizontal
                currentRow?.distribution = .fillEqually
                currentRow?.spacing = 12
                gridStackView.addArrangedSubview(currentRow!)
            }
            currentRow?.addArrangedSubview(button)
        }
        
        // Add empty views to fill last row if needed
        if let lastRow = currentRow, lastRow.arrangedSubviews.count < columns {
            let missing = columns - lastRow.arrangedSubviews.count
            for _ in 0..<missing {
                let emptyView = UIView()
                lastRow.addArrangedSubview(emptyView)
            }
        }
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(gridStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            gridStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            gridStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            gridStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            gridStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        return containerView
    }

    // Create larger, more readable buttons
    private func createLargeActionButton(
        title: String,
        backgroundColor: UIColor,
        action: @escaping () -> Void
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold) // Bigger font
        button.titleLabel?.numberOfLines = 2 // Allow text wrapping
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8) // More padding
        
        // Add shadow for better visibility
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        
        // Add touch feedback
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        let buttonAction = UIAction { _ in action() }
        button.addAction(buttonAction, for: .touchUpInside)
        
        return button
    }

    // Button animation methods
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity
            sender.alpha = 1.0
        }
    }
    
    // MARK: - Helper Methods
    
    private func createChartTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor.label
        return label
    }
    

    
    private func createActionButton(
        title: String,
        backgroundColor: UIColor,
        action: @escaping () -> Void
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium) // Smaller font for more buttons
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4) // Reduced padding
        
        let buttonAction = UIAction { _ in action() }
        button.addAction(buttonAction, for: .touchUpInside)
        
        return button
    }
    
    // Add these action methods:
    private func simulateCPU() {
        MetricKitManager.shared.simulateCPUException()
    }

    private func simulateMemory() {
        MetricKitManager.shared.simulateMemoryPressure()
    }

    private func simulateDisk() {
        MetricKitManager.shared.simulateDiskWriteException()
    }

    private func showCallStackAnalysis() {
        let analysis = MetricKitManager.shared.getDetailedCallStackAnalysis()
        showAnalysisReport(title: "🔍 Call Stack Analysis", content: analysis)
    }

    private func showMetadataReport() {
        let report = MetricKitManager.shared.getDetailedMetadataReport()
        showAnalysisReport(title: "📱 Metadata Report", content: report)
    }

    private func showHistogramAnalysis() {
        let analysis = MetricKitManager.shared.getHistogramAnalysis()
        showAnalysisReport(title: "📊 Histogram Analysis", content: analysis)
    }

    private func showCrashFinder() {
        let analysis = MetricKitManager.shared.findCrashLocationInDevelopment()
        showAnalysisReport(title: "🎯 Crash Location Finder", content: analysis)
    }

    private func requestMetrics() {
        MetricKitManager.shared.requestMetricKitUpdate()
        subtitleLabel.text = "📥 Requested MetricKit update..."
        refreshData()
        
    }

    private func showAnalysisReport(title: String, content: String) {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        
        let textView = UITextView()
        textView.text = content
        textView.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -20)
        ])
        
        vc.title = title
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissModal)
        )
        
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc private func dismissModal() {
        dismiss(animated: true)
    }
    

//
    // MARK: - Data Loading
    
    private func loadMetricsData() {
        let manager = MetricKitManager.shared
        
        // Update quick stats
        crashesCard.updateValue("\(manager.crashes.count)")
        hangsCard.updateValue("\(manager.hangs.count)")
        
        if let lastPayload = manager.allPayloads.last {
            if let memoryMetrics = lastPayload.memoryMetrics {
                let memoryMB = Int(memoryMetrics.peakMemoryUsage.converted(to: .megabytes).value)
                memoryCard.updateValue("\(memoryMB) MB")
            }
            
            if let cpuMetrics = lastPayload.cpuMetrics {
                let cpuSeconds = Int(cpuMetrics.cumulativeCPUTime.converted(to: .seconds).value)
                cpuCard.updateValue("\(cpuSeconds)s")
            }
            
            // Update charts
            updateCharts(with: lastPayload)
        }
        
        // Update analysis views
        callStackAnalysisView.updateData(crashes: manager.crashes, hangs: manager.hangs)
        
        if let lastPayload = manager.allPayloads.last, let metaData = lastPayload.metaData {
            deviceInfoView.updateData(with: metaData)
        }
        
        // Update timestamp
        subtitleLabel.text = "Last updated: \(DateFormatter.shortTime.string(from: Date()))"
    }



    private func updateCharts(with payload: MXMetricPayload) {
        // Update launch time histogram
        if let launchMetrics = payload.applicationLaunchMetrics {
            let histogramData = MetricKitManager.shared.getHistogramDataFor(launchMetrics.histogrammedTimeToFirstDraw)
            
            let swiftUIChart = SwiftUIChartView(
                histogramData: histogramData,
                title: "Launch Time Distribution",
                color: .blue
            )
            
            let hostingController = UIHostingController(rootView: swiftUIChart)
            hostingController.view.backgroundColor = UIColor.clear
            
            // Update the chart container
            updateChartContainer(launchTimeChartView, with: hostingController)
        }
        
        // Update hang time histogram
        if let responsivenessMetrics = payload.applicationResponsivenessMetrics {
            let histogramData = MetricKitManager.shared.getHistogramDataFor(responsivenessMetrics.histogrammedApplicationHangTime)
            
            let swiftUIChart = SwiftUIChartView(
                histogramData: histogramData,
                title: "Hang Time Analysis",
                color: .orange
            )
            
            let hostingController = UIHostingController(rootView: swiftUIChart)
            hostingController.view.backgroundColor = UIColor.clear
            
            updateChartContainer(hangTimeChartView, with: hostingController)
        }
        
        // Update memory usage chart
        let memoryData = MetricKitManager.shared.getMemoryUsageHistory()
        let memoryChart = MemoryLineChartView(memoryData: memoryData)
        let memoryHostingController = UIHostingController(rootView: memoryChart)
        memoryHostingController.view.backgroundColor = UIColor.clear
        
        updateChartContainer(memoryUsageChartView, with: memoryHostingController)
        
        // Update network usage chart
        let networkData = MetricKitManager.shared.getNetworkUsageData()
        let networkChart = NetworkBarChartView(networkData: networkData)
        let networkHostingController = UIHostingController(rootView: networkChart)
        networkHostingController.view.backgroundColor = UIColor.clear
        
        updateChartContainer(networkUsageChartView, with: networkHostingController)
    }
    
    private func updateChartContainer(_ containerView: UIView, with hostingController: UIHostingController<some View>) {
        // Remove existing chart and its hosting controller
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Configure hosting controller
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = UIColor.clear
        
        // Add with proper clipping
        containerView.addSubview(hostingController.view)
        containerView.clipsToBounds = true // Prevent overflow
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor) // Changed to lessThanOrEqual
        ])
    }

    
    @objc private func refreshData() {
        // Prevent multiple rapid refreshes
        let now = Date()
        if let lastRefresh = lastRefreshTime, now.timeIntervalSince(lastRefresh) < 2.0 {
            return
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        lastRefreshTime = now
        
        // Start loading animation
        refreshIndicator.startAnimating()
        
        // Disable navigation buttons
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        // Show loading in subtitle with animation
        UIView.transition(with: subtitleLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.subtitleLabel.text = "🔄 Refreshing data..."
        }
        
        // Animate quick stats cards
        [crashesCard, hangsCard, memoryCard, cpuCard].forEach { card in
            UIView.animate(withDuration: 0.3) {
                card.alpha = 0.6
            }
        }
        
        MetricKitManager.shared.requestMetricKitUpdate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.loadMetricsData()
            self.isLoading = false
            
            // Stop loading animation
            self.refreshIndicator.stopAnimating()
            
            // Re-enable navigation buttons
            self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            
            // Animate cards back
            [self.crashesCard, self.hangsCard, self.memoryCard, self.cpuCard].forEach { card in
                UIView.animate(withDuration: 0.3) {
                    card.alpha = 1.0
                }
            }
            
            // Show success message
            UIView.transition(with: self.subtitleLabel, duration: 0.3, options: .transitionCrossDissolve) {
                self.subtitleLabel.text = "✅ Data refreshed: \(DateFormatter.shortTime.string(from: Date()))"
            }
        }
    }

    private func simulateCrash() {
        let alert = UIAlertController(
            title: "⚠️ Simulate Crash",
            message: "This will intentionally crash the app for testing MetricKit crash detection. Continue?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Crash App", style: .destructive) { _ in
            MetricKitManager.shared.simulateCrash()
        })
        
        present(alert, animated: true)
    }
    
    private func simulateHang() {
        let alert = UIAlertController(
            title: "⚠️ Simulate Hang",
            message: "This will freeze the app for 5 seconds to test hang detection. Continue?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Freeze App", style: .destructive) { _ in
            MetricKitManager.shared.simulateHang()
        })
        
        present(alert, animated: true)
    }
    
    private func exportMetricsData() {
        let manager = MetricKitManager.shared
        let exportData = manager.getDetailedMetadataReport()
        
        let activityVC = UIActivityViewController(
            activityItems: [exportData],
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(activityVC, animated: true)
    }
    
    private func clearAllData() {
        let alert = UIAlertController(
            title: "🧹 Clear All Data",
            message: "This will clear all stored metrics and diagnostics. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear Data", style: .destructive) { _ in
            // Clear data logic here
            self.loadMetricsData()
        })
        
        present(alert, animated: true)
    }

    private func setupNavigationBar() {
        title = "MetricKit Analytics"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Configure refresh indicator
//        refreshIndicator.hidesWhenStopped = true
//        refreshIndicator.color = UIColor.systemBlue
        
        // Add terminal/console button
        let terminalItem = UIBarButtonItem(
            image: UIImage(systemName: "terminal"),
            style: .plain,
            target: self,
            action: #selector(showTerminal)
        )
        
        let exportItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(exportData)
        )
        
        // Add refresh indicator as custom view
      //  let refreshItem = UIBarButtonItem(customView: refreshIndicator)
        let refreshItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshData)
        )
        
        navigationItem.rightBarButtonItems = [terminalItem, exportItem, refreshItem]
        
        // Add settings gear on left side
        let settingsItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )
        
        navigationItem.leftBarButtonItem = settingsItem
    }
    
    
    
    @objc private func exportData() {
        exportMetricsData()
    }
    
    @objc private func showTerminal() {
        let terminalVC = TerminalViewController()
        let navController = UINavigationController(rootViewController: terminalVC)
        present(navController, animated: true)
    }

    @objc private func showSettings() {
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
    
    // MARK: - Constraints

    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Header constraints
            titleLabel.topAnchor.constraint(equalTo: headerStatsView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: headerStatsView.leadingAnchor, constant: 20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerStatsView.leadingAnchor, constant: 20),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerStatsView.bottomAnchor, constant: -20),
            
            // INCREASED Chart heights for better visibility
            launchTimeChartView.heightAnchor.constraint(equalToConstant: 280), // Increased from 180
            hangTimeChartView.heightAnchor.constraint(equalToConstant: 280),   // Increased from 180
            memoryUsageChartView.heightAnchor.constraint(equalToConstant: 280), // Increased from 180
            networkUsageChartView.heightAnchor.constraint(equalToConstant: 280), // Increased from 180
            
            // Cards height
            quickStatsStackView.heightAnchor.constraint(equalToConstant: 120),
            
            // Action buttons height
           // actionButtonsStackView.heightAnchor.constraint(equalToConstant: 180) // Increased for 3 rows
            actionButtonsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 400)
        ])
    }
}
