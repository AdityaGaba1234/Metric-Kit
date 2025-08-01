//
//  TerminalViewController.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 31/07/25.
//

import Foundation
import UIKit
import MetricKit

class TerminalViewController: UIViewController {
    
    private let textView = UITextView()
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTerminalContent()
    }
    
    private func setupUI() {
        title = "🖥️ MetricKit Terminal"
        view.backgroundColor = UIColor.black
        
        // Navigation bar
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissTerminal)
        )
        navigationItem.rightBarButtonItem = doneButton
        
        // Terminal text view
        textView.backgroundColor = UIColor.black
        textView.textColor = UIColor.green
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = false
        textView.text = ""
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadTerminalContent() {
        let manager = MetricKitManager.shared
        
        var terminalOutput = """
        🖥️ METRICKIT TERMINAL OUTPUT
        ============================
        
        📊 SYSTEM STATUS:
        • Total Payloads: \(manager.totalPayloadsReceived)
        • Stored Payloads: \(manager.allPayloads.count)
        • Crashes Detected: \(manager.crashes.count)
        • Hangs Detected: \(manager.hangs.count)
        • CPU Exceptions: \(manager.cpuExceptions.count)
        • Disk Exceptions: \(manager.diskExceptions.count)
        
        📱 DEVICE INFO:
        """
        
        
        // Replace the entire device info section in TerminalViewController:
        if let lastPayload = manager.allPayloads.last,
           let metaData = lastPayload.metaData {
            terminalOutput += """
            • App Build: \(metaData.applicationBuildVersion)
            • OS Version: \(metaData.osVersion)
            • Device Type: \(metaData.deviceType)
            • Platform: \(metaData.platformArchitecture)
            • Region: \(metaData.regionFormat)
            
            """
        }
        
        terminalOutput += """
        
        🔧 RECENT EVENTS:
        \(manager.getMetricsSummary())
        
        📋 DETAILED LOGS:
        \(manager.getCrashReport())
        
        Last Updated: \(DateFormatter.detailed.string(from: Date()))
        ============================
        """
        
        textView.text = terminalOutput
        
        // Auto-scroll to bottom
        DispatchQueue.main.async {
            let bottom = NSMakeRange(self.textView.text.count - 1, 1)
            self.textView.scrollRangeToVisible(bottom)
        }
    }
    
    @objc private func dismissTerminal() {
        dismiss(animated: true)
    }
}
