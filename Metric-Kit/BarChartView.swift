//
//  BarChartView.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 30/07/25.
//


import Foundation
import UIKit
import SwiftUI
import Charts
import MetricKit

struct NetworkDataPoint: Identifiable {
    let id = UUID()
    let type: String
    let upload: Double
    let download: Double
    let total: Double
}

class BarChartView: UIView {
    private var networkData: [NetworkDataPoint] = []
    private var hostingController: UIHostingController<AnyView>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        generateSampleData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        generateSampleData()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
    }
    
    private func generateSampleData() {
        networkData = [
            NetworkDataPoint(type: "WiFi", upload: 50, download: 200, total: 250),
            NetworkDataPoint(type: "Cellular", upload: 20, download: 80, total: 100)
        ]
        updateChart()
    }
    
    func updateNetworkData(networkMetrics: MXNetworkTransferMetric) {
        let wifiUpload = networkMetrics.cumulativeWifiUpload.converted(to: .megabytes).value
        let wifiDownload = networkMetrics.cumulativeWifiDownload.converted(to: .megabytes).value
        let cellularUpload = networkMetrics.cumulativeCellularUpload.converted(to: .megabytes).value
        let cellularDownload = networkMetrics.cumulativeCellularDownload.converted(to: .megabytes).value
        
        networkData = [
            NetworkDataPoint(
                type: "WiFi",
                upload: wifiUpload,
                download: wifiDownload,
                total: wifiUpload + wifiDownload
            ),
            NetworkDataPoint(
                type: "Cellular",
                upload: cellularUpload,
                download: cellularDownload,
                total: cellularUpload + cellularDownload
            )
        ]
        
        updateChart()
    }
    
    private func updateChart() {
        // Create SwiftUI Chart View
        let chartView = NetworkBarChartSwiftUIView(networkData: networkData)
        
        // Remove existing hosting controller
        hostingController?.view.removeFromSuperview()
        hostingController = nil
        
        // Create new hosting controller
        hostingController = UIHostingController(rootView: AnyView(chartView))
        guard let hostingController = hostingController else { return }
        
        hostingController.view.backgroundColor = UIColor.clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - SwiftUI Chart Component
struct NetworkBarChartSwiftUIView: View {
    let networkData: [NetworkDataPoint]
    
    var body: some View {
        VStack {
            if networkData.isEmpty {
                EmptyNetworkChartView()
            } else {
                Chart {
                    ForEach(networkData) { dataPoint in
                        BarMark(
                            x: .value("Type", dataPoint.type),
                            y: .value("Upload (MB)", dataPoint.upload)
                        )
                        .foregroundStyle(.blue.gradient)
                        .position(by: .value("Direction", "Upload"))
                        
                        BarMark(
                            x: .value("Type", dataPoint.type),
                            y: .value("Download (MB)", dataPoint.download)
                        )
                        .foregroundStyle(.green.gradient)
                        .position(by: .value("Direction", "Download"))
                    }
                }
                .chartLegend(.visible)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                        AxisTick()
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .chartBackground { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                }
                .frame(height: 200)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct EmptyNetworkChartView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Network Data")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Use your app to generate network transfer data")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator), lineWidth: 1)
                )
        )
    }
}



#Preview {
    NetworkBarChartSwiftUIView(networkData: [
        NetworkDataPoint(type: "WiFi", upload: 50, download: 200, total: 250),
        NetworkDataPoint(type: "Cellular", upload: 20, download: 80, total: 100)
    ])
}
