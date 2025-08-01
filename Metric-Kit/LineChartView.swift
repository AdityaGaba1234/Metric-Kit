//
//  LineChartView.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 30/07/25.
//

import Foundation
import UIKit
import Charts
import MetricKit
import SwiftUI

struct MemoryDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let memoryUsage: Double
    let type: String
}

class LineChartView: UIView {
    private var memoryData: [MemoryDataPoint] = []
    
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
        let now = Date()
        let calendar = Calendar.current
        
        // Generate sample memory usage data
        for i in 0..<24 {
            let timestamp = calendar.date(byAdding: .hour, value: -i, to: now) ?? now
            let baseMemory = 100.0 + Double.random(in: -20...50)
            
            memoryData.append(MemoryDataPoint(
                timestamp: timestamp,
                memoryUsage: baseMemory,
                type: "Peak Memory"
            ))
        }
        
        memoryData.sort { $0.timestamp < $1.timestamp }
        updateChart()
    }
    
    func updateMemoryData(memoryMetrics: MXMemoryMetric) {
        let now = Date()
        let memoryMB = memoryMetrics.peakMemoryUsage.converted(to: .megabytes).value
        
        // Add new data point
        let newPoint = MemoryDataPoint(
            timestamp: now,
            memoryUsage: memoryMB,
            type: "Peak Memory"
        )
        
        memoryData.append(newPoint)
        
        // Keep only last 24 hours of data
        let dayAgo = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
        memoryData = memoryData.filter { $0.timestamp >= dayAgo }
        
        updateChart()
    }
    
    private func updateChart() {
        let chart = Chart(memoryData) { dataPoint in
            LineMark(
                x: .value("Time", dataPoint.timestamp),
                y: .value("Memory (MB)", dataPoint.memoryUsage)
            )
            .foregroundStyle(.blue.gradient)
            .lineStyle(StrokeStyle(lineWidth: 3))
            
            AreaMark(
                x: .value("Time", dataPoint.timestamp),
                y: .value("Memory (MB)", dataPoint.memoryUsage)
            )
            .foregroundStyle(.blue.opacity(0.2))
            
            PointMark(
                x: .value("Time", dataPoint.timestamp),
                y: .value("Memory (MB)", dataPoint.memoryUsage)
            )
            .foregroundStyle(.blue)
            .symbolSize(30)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 4)) { _ in
                AxisValueLabel(format: .dateTime.hour())
                AxisGridLine()
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
        
        let hostingController = UIHostingController(rootView: chart)
        hostingController.view.backgroundColor = UIColor.clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove existing chart
        subviews.forEach { $0.removeFromSuperview() }
        
        addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
