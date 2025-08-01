//
//  SwiftUIChartView.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 30/07/25.
//

import Foundation
import SwiftUI
import Charts

struct SwiftUIChartView: View {
    let histogramData: [HistogramData]
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if histogramData.isEmpty {
                EmptyChartView()
            } else {
                Chart(histogramData) { data in
                    BarMark(
                        x: .value("Range", data.range),
                        y: .value("Count", data.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color.opacity(0.8), color.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
                    
                    if data.count > 0 {
                        PointMark(
                            x: .value("Range", data.range),
                            y: .value("Count", data.count)
                        )
                        .foregroundStyle(.clear)
                        .annotation(position: .top) {
                            Text("\(data.count)")
                                .font(.caption2)
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .chartBackground { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                }
                .frame(height: 250)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct EmptyChartView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Data Available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Launch the app multiple times or trigger events to see histogram data")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 1)
                )
        )
    }
}

struct MemoryLineChartView: View {
    let memoryData: [MemoryDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Memory Usage Timeline")
                .font(.headline)
                .foregroundColor(.primary)
            
            if memoryData.isEmpty {
                EmptyChartView()
            } else {
                Chart(memoryData) { dataPoint in
                    LineMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value("Memory (MB)", dataPoint.memoryUsage)
                    )
                    .foregroundStyle(.purple.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value("Memory (MB)", dataPoint.memoryUsage)
                    )
                    .foregroundStyle(.purple.opacity(0.2))
                    
                    PointMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value("Memory (MB)", dataPoint.memoryUsage)
                    )
                    .foregroundStyle(.purple)
                    .symbolSize(40)
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
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                }
                .frame(height: 250)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct NetworkBarChartView: View {
    let networkData: [NetworkDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Network Transfer Summary")
                .font(.headline)
                .foregroundColor(.primary)
            
            if networkData.isEmpty {
                EmptyChartView()
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
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                }
                .frame(height: 250)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
