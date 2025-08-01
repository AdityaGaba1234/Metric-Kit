//
//  HistogramChartView.swift
//  Metric-Kit
//
//  Created by Aditya Gaba on 30/07/25.
//

import Foundation
import UIKit
import Charts
import MetricKit
import SwiftUI


struct HistogramData: Identifiable {
    let id = UUID()
    let range: String
    let count: Int
    let startValue: Double
    let endValue: Double
}

class HistogramChartView: UIView {
    private var chartData: [HistogramData] = []
    private var hostingController: UIHostingController<AnyView>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateChart()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        updateChart()
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
    }

    func updateHistogram<T: Unit>(histogram: MXHistogram<T>, title: String) {
        var newData: [HistogramData] = []

        let enumerator = histogram.bucketEnumerator

        while let bucket = enumerator.nextObject() as? MXHistogramBucket<T> {
            let range: String

            if T.self == UnitDuration.self {
                let startDuration = bucket.bucketStart as! Measurement<UnitDuration>
                let endDuration = bucket.bucketEnd as! Measurement<UnitDuration>
                range = "\(formatDuration(startDuration))-\(formatDuration(endDuration))"
            } else {
                range = "\(bucket.bucketStart)-\(bucket.bucketEnd)"
            }

            let histogramPoint = HistogramData(
                range: range,
                count: bucket.bucketCount,
                startValue: 0,
                endValue: 0
            )

            newData.append(histogramPoint)
        }

        if newData.isEmpty {
            newData = [
                HistogramData(range: "No Data", count: 0, startValue: 0, endValue: 0)
            ]
        }

        chartData = newData
        updateChart()
    }

    private func updateChart() {
        // Remove old hosting controller if present
        hostingController?.view.removeFromSuperview()
        hostingController = nil

        let chartView = HistogramChartSwiftUIView(chartData: chartData)
        let controller = UIHostingController(rootView: AnyView(chartView))
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        hostingController = controller
    }

    private func formatDuration(_ measurement: Measurement<UnitDuration>) -> String {
        let seconds = measurement.converted(to: .seconds).value
        if seconds < 1 {
            return String(format: "%.0fms", seconds * 1000)
        } else if seconds < 60 {
            return String(format: "%.1fs", seconds)
        } else {
            return String(format: "%.1fm", seconds / 60)
        }
    }
}



// MARK: - SwiftUI Chart View
struct HistogramChartSwiftUIView: View {
    let chartData: [HistogramData]

    var body: some View {
        Chart(chartData) { data in
            BarMark(
                x: .value("Range", data.range),
                y: .value("Count", data.count)
            )
            .foregroundStyle(
                data.count > 0 ?
                    .linearGradient(
                        colors: [.blue.opacity(0.8), .blue.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    ) :
                    .linearGradient(
                        colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
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
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        }
        .frame(height: 200)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    HistogramChartSwiftUIView(chartData: [
        HistogramData(range: "0-1s", count: 5, startValue: 0, endValue: 1),
        HistogramData(range: "1-2s", count: 10, startValue: 1, endValue: 2)
    ])
}

