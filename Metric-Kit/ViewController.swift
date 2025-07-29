////
////  ViewController.swift
////  Metric-Kit
////
////  Created by Aditya Gaba on 11/07/25.
////
//
//import UIKit
//import MetricKit
//
//class ViewController: UIViewController, MXMetricManagerSubscriber {
//    
//    // UI Components
//    private let scrollView = UIScrollView()
//    private let contentView = UIView()
//    
//    // Header
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "MetricKit Demo App"
//        label.font = UIFont.boldSystemFont(ofSize: 24)
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let statusLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Status: Initializing..."
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .systemBlue
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    // Controls
//    private let controlsStackView: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .horizontal
//        stack.distribution = .fillEqually
//        stack.spacing = 10
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        return stack
//    }()
//    
//    private let clearLogsButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Clear Logs", for: .normal)
//        button.backgroundColor = .systemRed
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let simulateWorkButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Simulate Work", for: .normal)
//        button.backgroundColor = .systemGreen
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let exportButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Export Logs", for: .normal)
//        button.backgroundColor = .systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    // Stats Section
//    private let statsLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Metrics Received: 0"
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    // Text view to display logs
//    private let logTextView: UITextView = {
//        let textView = UITextView()
//        textView.isEditable = false
//        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.backgroundColor = UIColor(white: 0.05, alpha: 1)
//        textView.textColor = .systemGreen
//        textView.layer.cornerRadius = 8
//        textView.layer.borderWidth = 1
//        textView.layer.borderColor = UIColor.systemGray4.cgColor
//        return textView
//    }()
//    
//    // Properties
////    private var metricsCount = 0
////    private var startTime = Date()
////    private var workTimer: Timer?
//    
//    private var metricsCount = 0
//    private var startTime: Date = Date()
//    private var workTimer: Timer?
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupMetricKit()
//        setupButtonActions()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        startTime = Date()
//        
//        // Setup scroll view
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//        
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Add all UI elements to content view
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(statusLabel)
//        contentView.addSubview(controlsStackView)
//        contentView.addSubview(statsLabel)
//        contentView.addSubview(logTextView)
//        
//        // Add buttons to stack view
//        controlsStackView.addArrangedSubview(clearLogsButton)
//        controlsStackView.addArrangedSubview(simulateWorkButton)
//        controlsStackView.addArrangedSubview(exportButton)
//        
//        // Setup constraints
//        NSLayoutConstraint.activate([
//            // Scroll view
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            // Content view
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            
//            // Title
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            
//            // Status
//            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
//            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            
//            // Controls
//            controlsStackView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
//            controlsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            controlsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            controlsStackView.heightAnchor.constraint(equalToConstant: 44),
//            
//            // Stats
//            statsLabel.topAnchor.constraint(equalTo: controlsStackView.bottomAnchor, constant: 20),
//            statsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            statsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            
//            // Log text view
//            logTextView.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 20),
//            logTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            logTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            logTextView.heightAnchor.constraint(equalToConstant: 400),
//            logTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
//        ])
//    }
//    
//    private func setupMetricKit() {
//        // Register as a MetricKit subscriber
//        MXMetricManager.shared.add(self)
//        updateStatus("MetricKit subscriber registered")
//        appendLog("🚀 MetricKit Demo App Started\n")
//        appendLog("📊 Waiting for metric payloads...\n")
//        appendLog("ℹ️  Metrics are delivered daily by iOS\n")
//        appendLog("💡 Use 'Simulate Work' to generate activity\n\n")
//    }
//    
//    private func setupButtonActions() {
//        clearLogsButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
//        simulateWorkButton.addTarget(self, action: #selector(simulateWork), for: .touchUpInside)
//        exportButton.addTarget(self, action: #selector(exportLogs), for: .touchUpInside)
//    }
//
//    // MARK: - MXMetricManagerSubscriber
//
//        func didReceive(_ payloads: [MXMetricPayload]) {
//            metricsCount += payloads.count
//            updateStats()
//            
//            for (index, payload) in payloads.enumerated() {
//                var log = "📦 === METRIC PAYLOAD #\(metricsCount - payloads.count + index + 1) ===\n"
//                log += "🕐 Timestamp: \(formatDate(Date()))\n"
//                log += "📋 Payload Info:\n"
//                log += "   • Time Range: \(formatTimeInterval(payload.timeStampEnd.timeIntervalSince(payload.timeStampBegin)))\n"
//                
//                // CPU Metrics
//                if let cpuMetrics = payload.cpuMetrics {
//                    log += "\n🖥️  CPU METRICS:\n"
//                    log += "   • Cumulative CPU Time: \(formatDuration(cpuMetrics.cumulativeCPUTime))\n"
//                    log += "   • CPU Instructions: \(cpuMetrics.cumulativeCPUInstructions.value) \(cpuMetrics.cumulativeCPUInstructions.unit)\n"
//                }
//                
//                // Memory Metrics
//                if let memoryMetrics = payload.memoryMetrics {
//                    log += "\n💾 MEMORY METRICS:\n"
//                    log += "   • Peak Memory Usage: \(formatMemory(memoryMetrics.peakMemoryUsage))\n"
//                    log += "   • Average Suspended Memory: \(formatMemory(memoryMetrics.averageSuspendedMemory.averageMeasurement))\n"
//                }
//                
//                // Storage Metrics (iOS 14+)
//                if let storageMetrics = payload.metaData {
//                    log += "\n💿 STORAGE INFO:\n"
//                    log += "   • Application Version: \(storageMetrics.applicationBuildVersion)\n"
//                    log += "   • OS Version: \(storageMetrics.osVersion)\n"
//                    log += "   • Device Type: \(storageMetrics.deviceType)\n"
//                }
//                
//                // Display Metrics
//                if let displayMetrics = payload.displayMetrics {
//                    log += "\n📱 DISPLAY METRICS:\n"
//                    if let pixelLuminance = displayMetrics.averagePixelLuminance {
//                        log += "   • Average Pixel Luminance: \(pixelLuminance.averageMeasurement.value) \(pixelLuminance.averageMeasurement.unit)\n"
//                    }
//                }
//                
//                // Application Time Metrics
//                if let appTimeMetrics = payload.applicationTimeMetrics {
//                    log += "\n⏱️  APP TIME METRICS:\n"
//                    log += "   • Foreground Time: \(formatDuration(appTimeMetrics.cumulativeForegroundTime))\n"
//                    log += "   • Background Time: \(formatDuration(appTimeMetrics.cumulativeBackgroundTime))\n"
//                    log += "   • Background Audio Time: \(formatDuration(appTimeMetrics.cumulativeBackgroundAudioTime))\n"
//                    log += "   • Background Location Time: \(formatDuration(appTimeMetrics.cumulativeBackgroundLocationTime))\n"
//                }
//                
//                // Application Launch Metrics
//                if let launchMetrics = payload.applicationLaunchMetrics {
//                    log += "\n🚀 LAUNCH METRICS:\n"
//                    log += "   • Time to First Draw Histogram: \(launchMetrics.histogrammedTimeToFirstDraw.totalBucketCount) total buckets\n"
//                    
//                    // Enumerate histogram buckets
//                    let enumerator = launchMetrics.histogrammedTimeToFirstDraw.bucketEnumerator
//                    while let bucket = enumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
//                        log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) launches\n"
//                    }
//                    
//                    // App resume time histogram (iOS 14+)
////                    if let resumeHistogram = launchMetrics.histogrammedApplicationResumeTime {
////                        log += "   • App Resume Time Histogram: \(resumeHistogram.totalBucketCount) total buckets\n"
////                        let resumeEnumerator = resumeHistogram.bucketEnumerator
////                        while let bucket = resumeEnumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
////                            log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) resumes\n"
////                        }
////                    }
//                    
//                    // ...existing code...
//
//                                    // Application Launch Metrics
//                                    if let launchMetrics = payload.applicationLaunchMetrics {
//                                        log += "\n🚀 LAUNCH METRICS:\n"
//                                        log += "   • Time to First Draw Histogram: \(launchMetrics.histogrammedTimeToFirstDraw.totalBucketCount) total buckets\n"
//                                        
//                                        // Enumerate histogram buckets
//                                        let enumerator = launchMetrics.histogrammedTimeToFirstDraw.bucketEnumerator
//                                        while let bucket = enumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
//                                            log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) launches\n"
//                                        }
//                                        
//                                        // App resume time histogram (iOS 14+)
//                                        let resumeHistogram = launchMetrics.histogrammedApplicationResumeTime
//                                        log += "   • App Resume Time Histogram: \(resumeHistogram.totalBucketCount) total buckets\n"
//                                        let resumeEnumerator = resumeHistogram.bucketEnumerator
//                                        while let bucket = resumeEnumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
//                                            log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) resumes\n"
//                                        }
//                                    }
//
//                    // ...existing code...
//                }
//                
//                // Application Responsiveness Metrics
//                if let responsivenessMetrics = payload.applicationResponsivenessMetrics {
//                    log += "\n⚡ RESPONSIVENESS METRICS:\n"
//                    log += "   • App Hang Time Histogram: \(responsivenessMetrics.histogrammedApplicationHangTime.totalBucketCount) total buckets\n"
//                    
//                    // Enumerate hang time buckets
//                    let hangEnumerator = responsivenessMetrics.histogrammedApplicationHangTime.bucketEnumerator
//                    while let bucket = hangEnumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
//                        log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) hangs\n"
//                    }
//                }
//                
//                // Network Transfer Metrics
//                if let networkMetrics = payload.networkTransferMetrics {
//                    log += "\n🌐 NETWORK METRICS:\n"
//                    log += "   • Cumulative WiFi Upload: \(formatMemory(networkMetrics.cumulativeWifiUpload))\n"
//                    log += "   • Cumulative WiFi Download: \(formatMemory(networkMetrics.cumulativeWifiDownload))\n"
//                    log += "   • Cumulative Cellular Upload: \(formatMemory(networkMetrics.cumulativeCellularUpload))\n"
//                    log += "   • Cumulative Cellular Download: \(formatMemory(networkMetrics.cumulativeCellularDownload))\n"
//                }
//                
//                // GPU Metrics (iOS 14+)
//                if let gpuMetrics = payload.gpuMetrics {
//                    log += "\n🎮 GPU METRICS:\n"
//                    log += "   • Cumulative GPU Time: \(formatDuration(gpuMetrics.cumulativeGPUTime))\n"
//                }
//                
//                // Disk I/O Metrics (iOS 14+)
//                if let diskMetrics = payload.diskIOMetrics {
//                    log += "\n💽 DISK I/O METRICS:\n"
//                    log += "   • Cumulative Logical Writes: \(formatMemory(diskMetrics.cumulativeLogicalWrites))\n"
//                }
//                
//                // Location Activity Metrics (iOS 14+)
//                if let locationMetrics = payload.locationActivityMetrics {
//                    log += "\n📍 LOCATION METRICS:\n"
//                    log += "   • Cumulative Best Accuracy Time: \(formatDuration(locationMetrics.cumulativeBestAccuracyTime))\n"
//                    log += "   • Cumulative Nearest Ten Meters Accuracy Time: \(formatDuration(locationMetrics.cumulativeNearestTenMetersAccuracyTime))\n"
//                }
//                
//                // Cellular Condition Metrics (iOS 14+)
//                if let cellularMetrics = payload.cellularConditionMetrics {
//                    log += "\n📶 CELLULAR METRICS:\n"
//                    log += "   • Cell Condition Time Histogram: \(cellularMetrics.histogrammedCellularConditionTime.totalBucketCount) total buckets\n"
//                    
//                    // Enumerate cellular condition buckets
//                    let cellularEnumerator = cellularMetrics.histogrammedCellularConditionTime.bucketEnumerator
//                    while let bucket = cellularEnumerator.nextObject() as? MXHistogramBucket<MXUnitSignalBars> {
//                        log += "     - \(bucket.bucketStart.value) to \(bucket.bucketEnd.value) bars: \(bucket.bucketCount) events\n"
//                    }
//                }
//                
//                // App Exit Metrics (iOS 14+)
//                if let exitMetrics = payload.applicationExitMetrics {
//                    log += "\n🚪 APP EXIT METRICS:\n"
//                    log += "   • Foreground Exit Data:\n"
//                    log += "     - Normal: \(exitMetrics.foregroundExitData.cumulativeNormalAppExitCount)\n"
//                    log += "     - Memory Resource Limit: \(exitMetrics.foregroundExitData.cumulativeMemoryResourceLimitExitCount)\n"
//                    log += "     - Bad Access: \(exitMetrics.foregroundExitData.cumulativeBadAccessExitCount)\n"
//                    log += "     - Abnormal: \(exitMetrics.foregroundExitData.cumulativeAbnormalExitCount)\n"
//                    log += "     - Illegal Instruction: \(exitMetrics.foregroundExitData.cumulativeIllegalInstructionExitCount)\n"
//                    log += "     - App Watchdog: \(exitMetrics.foregroundExitData.cumulativeAppWatchdogExitCount)\n"
//                    
//                    log += "   • Background Exit Data:\n"
//                    log += "     - Normal: \(exitMetrics.backgroundExitData.cumulativeNormalAppExitCount)\n"
//                    log += "     - Memory Resource Limit: \(exitMetrics.backgroundExitData.cumulativeMemoryResourceLimitExitCount)\n"
//                    log += "     - Memory Pressure: \(exitMetrics.backgroundExitData.cumulativeMemoryPressureExitCount)\n"
//                    log += "     - Suspended With Locked File: \(exitMetrics.backgroundExitData.cumulativeSuspendedWithLockedFileExitCount)\n"
//                    log += "     - Background Task Assertion Timeout: \(exitMetrics.backgroundExitData.cumulativeBackgroundTaskAssertionTimeoutExitCount)\n"
//                }
//                
//                // Animation Metrics (iOS 14+)
//                if let animationMetrics = payload.animationMetrics {
//                    log += "\n🎬 ANIMATION METRICS:\n"
//                    log += "   • Scrolling Hitch Time Ratio: \(animationMetrics.scrollHitchTimeRatio.value)\n"
//                }
//                
//                log += "\n" + String(repeating: "=", count: 50) + "\n\n"
//                appendLog(log)
//            }
//            
//            updateStatus("Active - Last payload: \(formatDate(Date()))")
//        }
//
//    // MARK: - Button Actions
//    @objc private func clearLogs() {
//        logTextView.text = ""
//        metricsCount = 0
//        updateStats()
//        appendLog("🧹 Logs cleared\n\n")
//    }
//    
//    @objc private func simulateWork() {
//        appendLog("⚙️  Simulating CPU-intensive work...\n")
//        
//        // Simulate CPU work
//        DispatchQueue.global(qos: .userInitiated).async {
//            let startTime = CFAbsoluteTimeGetCurrent()
//            var result = 0.0
//            
//            // Heavy computation
//            for i in 0..<1000000 {
//                result += sin(Double(i)) * cos(Double(i))
//            }
//            
//            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
//            
//            DispatchQueue.main.async {
//                self.appendLog("✅ Work simulation completed in \(String(format: "%.2f", timeElapsed))s\n")
//                self.appendLog("💡 This activity may appear in future metric payloads\n\n")
//            }
//        }
//        
//        // Simulate memory allocation
//        DispatchQueue.global(qos: .background).async {
//            var arrays: [[Int]] = []
//            for _ in 0..<100 {
//                let array = Array(0..<10000)
//                arrays.append(array)
//                Thread.sleep(forTimeInterval: 0.01)
//            }
//            
//            DispatchQueue.main.async {
//                self.appendLog("💾 Memory simulation completed\n\n")
//            }
//        }
//    }
//    
//    @objc private func exportLogs() {
//        let activityViewController = UIActivityViewController(
//            activityItems: [logTextView.text ?? ""],
//            applicationActivities: nil
//        )
//        
//        if let popover = activityViewController.popoverPresentationController {
//            popover.sourceView = exportButton
//            popover.sourceRect = exportButton.bounds
//        }
//        
//        present(activityViewController, animated: true)
//    }
//    
//    // MARK: - Helper Methods
//    private func updateStatus(_ status: String) {
//        DispatchQueue.main.async {
//            self.statusLabel.text = "Status: \(status)"
//        }
//    }
//    
//    private func updateStats() {
//        DispatchQueue.main.async {
//            let uptime = Date().timeIntervalSince(self.startTime)
//            self.statsLabel.text = "Metrics: \(self.metricsCount) | Uptime: \(self.formatDuration(Measurement(value: uptime, unit: UnitDuration.seconds)))"
//        }
//    }
//    
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .medium
//        return formatter.string(from: date)
//    }
//    
//    private func formatDuration(_ measurement: Measurement<UnitDuration>) -> String {
//        let seconds = measurement.converted(to: .seconds).value
//        if seconds < 60 {
//            return String(format: "%.2fs", seconds)
//        } else if seconds < 3600 {
//            return String(format: "%.1fm", seconds / 60)
//        } else {
//            return String(format: "%.1fh", seconds / 3600)
//        }
//    }
//    
//    private func formatMemory(_ measurement: Measurement<UnitInformationStorage>) -> String {
//        let bytes = measurement.converted(to: .bytes).value
//        let formatter = ByteCountFormatter()
//        formatter.countStyle = .memory
//        return formatter.string(fromByteCount: Int64(bytes))
//    }
//    
//    private func formatTimeInterval(_ interval: TimeInterval) -> String {
//        return "Duration: \(formatDuration(Measurement(value: interval, unit: UnitDuration.seconds)))"
//    }
//
//    // Append log to the text view on the main thread
//    private func appendLog(_ text: String) {
//        DispatchQueue.main.async {
//            self.logTextView.text += text
//            let range = NSRange(location: self.logTextView.text.count - 1, length: 1)
//            self.logTextView.scrollRangeToVisible(range)
//        }
//    }
//
//    deinit {
//        Task { @MainActor in
//            MXMetricManager.shared.remove(self)
//        }
//    }
//
//
//}
//
//
//import UIKit
//import AVKit
//import MetricKit
//
//class ViewController: UIViewController, MXMetricManagerSubscriber {
//    
//    // MARK: - UI Components
//    private let playButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Play Video", for: .normal)
//        button.backgroundColor = .systemGreen
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    private let logTextView: UITextView = {
//        let tv = UITextView()
//        tv.isEditable = false
//        tv.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
//        tv.translatesAutoresizingMaskIntoConstraints = false
//        return tv
//    }()
//    private let statusLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Status: Initializing..."
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .systemBlue
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    // MARK: - Properties
//    private var metricsCount = 0
//    private var startTime = Date()
//    private var player: AVPlayer?
//    private var playerVC: AVPlayerViewController?
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupMetricKit()
//       playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
//    }
//    
//    // MARK: - UI Setup
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        view.addSubview(playButton)
//        view.addSubview(statusLabel)
//        view.addSubview(logTextView)
//        
//        NSLayoutConstraint.activate([
//            playButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
//            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            playButton.widthAnchor.constraint(equalToConstant: 160),
//            playButton.heightAnchor.constraint(equalToConstant: 44),
//            
//            statusLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
//            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            logTextView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
//            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            logTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
//        ])
//    }
//    
//    // MARK: - MetricKit Setup
//    private func setupMetricKit() {
//        MXMetricManager.shared.add(self)
//        appendLog("🚀 MetricKit Video Player Demo Started\n:bar_chart: Waiting for metric payloads...\n:information_source: Metrics are delivered daily by iOS\n")
//        updateStatus("MetricKit subscriber registered")
//    }
//    
//    // MARK: - Video Playback
//    @objc private func playVideo() {
//        // Use a sample video URL (replace with your own if needed)
//        guard let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {
//            appendLog("❌ Invalid video URL\n")
//            return
//        }
//        player = AVPlayer(url: url)
//        playerVC = AVPlayerViewController()
//        playerVC?.player = player
//        present(playerVC!, animated: true) {
//            self.player?.play()
//            self.appendLog("🎬 Video playback started at \(self.formatDate(Date()))\n")
//        }
//    }
//    
//    // MARK: - MXMetricManagerSubscriber
//    func didReceive(_ payloads: [MXMetricPayload]) {
//        metricsCount += payloads.count
//        for (index, payload) in payloads.enumerated() {
//            var log = "📦 === METRIC PAYLOAD #\(metricsCount - payloads.count + index + 1) ===\n"
//            log += "🕐 Timestamp: \(formatDate(Date()))\n"
//            log += "📋 Payload Info:\n"
//            log += "   • Time Range: Duration: 24.0h\n"
//            // CPU Metrics
//            if let cpuMetrics = payload.cpuMetrics {
//                log += "\n🖥️  CPU METRICS:\n"
//                log += "   • Cumulative CPU Time: \(formatDuration(cpuMetrics.cumulativeCPUTime))\n"
//                log += "   • CPU Instructions: \(cpuMetrics.cumulativeCPUInstructions.value) \(cpuMetrics.cumulativeCPUInstructions.unit)\n"
//            }
//            // Memory Metrics
//            if let memoryMetrics = payload.memoryMetrics {
//                log += "\n💾 MEMORY METRICS:\n"
//                log += "   • Peak Memory Usage: \(formatMemory(memoryMetrics.peakMemoryUsage))\n"
//                log += "   • Average Suspended Memory: \(formatMemory(memoryMetrics.averageSuspendedMemory.averageMeasurement))\n"
//            }
//            // Disk I/O Metrics
//            if let diskMetrics = payload.diskIOMetrics {
//                log += "\n💽 DISK I/O METRICS:\n"
//                log += "   • Cumulative Logical Writes: \(formatMemory(diskMetrics.cumulativeLogicalWrites))\n"
//            }
//            // Network Transfer Metrics
//            if let networkMetrics = payload.networkTransferMetrics {
//                log += "\n🌐 NETWORK METRICS:\n"
//                log += "   • Cumulative WiFi Upload: \(formatMemory(networkMetrics.cumulativeWifiUpload))\n"
//                log += "   • Cumulative WiFi Download: \(formatMemory(networkMetrics.cumulativeWifiDownload))\n"
//                log += "   • Cumulative Cellular Upload: \(formatMemory(networkMetrics.cumulativeCellularUpload))\n"
//                log += "   • Cumulative Cellular Download: \(formatMemory(networkMetrics.cumulativeCellularDownload))\n"
//            }
//            // Application Launch Metrics (histogram example)
//            if let launchMetrics = payload.applicationLaunchMetrics {
//                log += "\n🚀 LAUNCH METRICS:\n"
//                let enumerator = launchMetrics.histogrammedTimeToFirstDraw.bucketEnumerator
//                var bucketCount = 0
//                while let bucket = enumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
//                    log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) launches\n"
//                    bucketCount += 1
//                }
//                if bucketCount == 0 {
//                    log += "   • No launch histogram data yet (need more launches).\n"
//                }
//            }
//            log += "\n" + String(repeating: "=", count: 50) + "\n\n"
//            appendLog(log)
//        }
//        updateStatus("Active - Last payload: \(formatDate(Date()))")
//    }
//    
//    // MARK: - Helpers
//    private func updateStatus(_ status: String) {
//        DispatchQueue.main.async { self.statusLabel.text = "Status: \(status)" }
//    }
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .medium
//        return formatter.string(from: date)
//    }
//    private func formatDuration(_ measurement: Measurement<UnitDuration>) -> String {
//        let seconds = measurement.converted(to: .seconds).value
//        if seconds < 60 {
//            return String(format: "%.2fs", seconds)
//        } else if seconds < 3600 {
//            return String(format: "%.1fm", seconds / 60)
//        } else {
//            return String(format: "%.1fh", seconds / 3600)
//        }
//    }
//    private func formatMemory(_ measurement: Measurement<UnitInformationStorage>) -> String {
//        let bytes = measurement.converted(to: .bytes).value
//        let formatter = ByteCountFormatter()
//        formatter.countStyle = .memory
//        return formatter.string(fromByteCount: Int64(bytes))
//    }
//    private func appendLog(_ text: String) {
//        DispatchQueue.main.async {
//            self.logTextView.text += text
//            let range = NSRange(location: self.logTextView.text.count - 1, length: 1)
//            self.logTextView.scrollRangeToVisible(range)
//        }
//    }
//    deinit {
//        MXMetricManager.shared.remove(self)
//    }
//}
