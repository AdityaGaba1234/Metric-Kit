
import Foundation
import MetricKit
import os.signpost

final class MetricKitManager: NSObject, MXMetricManagerSubscriber {
    static let shared = MetricKitManager()
    
    // MARK: - Storage Properties
    private(set) var allPayloads: [MXMetricPayload] = []
    private(set) var allDiagnostics: [MXDiagnosticPayload] = []
    private(set) var totalPayloadsReceived = 0
    private(set) var totalDiagnosticsReceived = 0
    
    // Crash and diagnostic storage
    private(set) var crashes: [MXCrashDiagnostic] = []
    private(set) var hangs: [MXHangDiagnostic] = []
    private(set) var cpuExceptions: [MXCPUExceptionDiagnostic] = []
    private(set) var diskExceptions: [MXDiskWriteExceptionDiagnostic] = []
    private(set) var launchDiagnostics: [MXAppLaunchDiagnostic] = []
    
    // Custom Signpost Logging
    private let customLog = MXMetricManager.makeLogHandle(category: "CustomMetrics")
    private let signpostLog = OSLog(subsystem: "com.metrickit.demo", category: "Performance")
    
    // Observers for UI updates
    var onPayloadReceived: ((MXMetricPayload) -> Void)?
    var onDiagnosticReceived: ((MXDiagnosticPayload) -> Void)?
    var onLogUpdate: ((String) -> Void)?
    var onCrashDetected: ((MXCrashDiagnostic) -> Void)?
    var onHangDetected: ((MXHangDiagnostic) -> Void)?
    
    private override init() {
        super.init()
        MXMetricManager.shared.add(self)
        logEvent("🚀 MetricKit Manager initialized with FULL comprehensive analytics")
        
        // Process any past payloads that exist
        processPastPayloads()
    }
    
    // MARK: - MXMetricManagerSubscriber
    
    /// Regular metrics delivery (performance data)
    func didReceive(_ payloads: [MXMetricPayload]) {
        totalPayloadsReceived += payloads.count
        allPayloads.append(contentsOf: payloads)
        
        for payload in payloads {
            onPayloadReceived?(payload)
            logComprehensivePayload(payload)
        }
        saveMetricsToStorage()
    }
    
    /// Diagnostic delivery (crash reports, hangs, exceptions)
    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        totalDiagnosticsReceived += payloads.count
        allDiagnostics.append(contentsOf: payloads)
        
        for payload in payloads {
            onDiagnosticReceived?(payload)
            processComprehensiveDiagnosticPayload(payload)
        }
        saveMetricsToStorage()
    }
    
    // MARK: - Public Methods
    
    func logEvent(_ message: String) {
        let timestamp = DateFormatter.shortTime.string(from: Date())
        let logMessage = "[\(timestamp)] \(message)\n"
        onLogUpdate?(logMessage)
        print(logMessage)
        
        // Log to custom MetricKit log
        os_log(.info, log: customLog, "%{public}@", message)
    }
    
    func clearLogs() {
        onLogUpdate?("🧹 Logs cleared\n\n")
    }
    
    func getMetricsSummary() -> String {
        var summary = "📊 COMPREHENSIVE METRICS SUMMARY:\n"
        summary += String(repeating: "=", count: 50) + "\n"
        
        // Basic counts
        summary += "📈 PAYLOAD STATISTICS:\n"
        summary += "• Total Payloads: \(totalPayloadsReceived)\n"
        summary += "• Total Diagnostics: \(totalDiagnosticsReceived)\n"
        summary += "• Stored Payloads: \(allPayloads.count)\n"
        summary += "• Past Payloads Available: \(MXMetricManager.shared.pastPayloads.count)\n"
        summary += "• Past Diagnostics Available: \(MXMetricManager.shared.pastDiagnosticPayloads.count)\n"
        
        // Diagnostic counts
        summary += "\n🚨 DIAGNOSTIC STATISTICS:\n"
        summary += "• Crashes Detected: \(crashes.count)\n"
        summary += "• Hangs Detected: \(hangs.count)\n"
        summary += "• CPU Exceptions: \(cpuExceptions.count)\n"
        summary += "• Disk Exceptions: \(diskExceptions.count)\n"
        summary += "• Launch Diagnostics: \(launchDiagnostics.count)\n"
        
        // Latest metrics if available
        if let lastPayload = allPayloads.last {
            summary += "\n📱 LATEST DEVICE METRICS:\n"
            if let metaData = lastPayload.metaData {
                summary += "• Device Type: \(metaData.deviceType)\n"
                summary += "• App Build Version: \(metaData.applicationBuildVersion)\n"
                summary += "• TestFlight App: \(metaData.isTestFlightApp ? "Yes" : "No")\n"
            }
            summary += "• Last Received: \(DateFormatter.shortTime.string(from: Date()))\n"
            summary += "• Time Range: \(DateFormatter.shortTime.string(from: lastPayload.timeStampBegin)) - \(DateFormatter.shortTime.string(from: lastPayload.timeStampEnd))\n"
            summary += "• Multiple App Versions: \(lastPayload.includesMultipleApplicationVersions ? "Yes" : "No")\n"
            summary += "• Latest App Version: \(lastPayload.latestApplicationVersion)\n"
            
            // Performance summary
            if let cpuMetrics = lastPayload.cpuMetrics {
                summary += "• CPU Time: \(formatDuration(cpuMetrics.cumulativeCPUTime))\n"
            }
            if let memoryMetrics = lastPayload.memoryMetrics {
                summary += "• Peak Memory: \(formatMemory(memoryMetrics.peakMemoryUsage))\n"
            }
            if let networkMetrics = lastPayload.networkTransferMetrics {
                let totalWifi = networkMetrics.cumulativeWifiDownload.value + networkMetrics.cumulativeWifiUpload.value
                let totalCellular = networkMetrics.cumulativeCellularDownload.value + networkMetrics.cumulativeCellularUpload.value
                summary += "• Total WiFi: \(formatMemory(Measurement(value: totalWifi, unit: UnitInformationStorage.bytes)))\n"
                summary += "• Total Cellular: \(formatMemory(Measurement(value: totalCellular, unit: UnitInformationStorage.bytes)))\n"
            }
        }
        
        return summary + "\n"
    }
    
    func getCrashReport() -> String {
        var report = "💥 COMPREHENSIVE DIAGNOSTIC REPORT:\n"
        report += String(repeating: "=", count: 60) + "\n"
        
        if crashes.isEmpty && hangs.isEmpty && cpuExceptions.isEmpty && diskExceptions.isEmpty && launchDiagnostics.isEmpty {
            report += "✅ No crashes, hangs, or exceptions detected\n"
            report += "🎉 Your app is running smoothly!\n"
            return report
        }
        
        report += "\n" + findCrashLocationInDevelopment() + "\n";
        
        // Detailed Crash Reports
        if !crashes.isEmpty {
            report += "\n💥 CRASH DIAGNOSTICS (\(crashes.count) total):\n"
            for (index, crash) in crashes.enumerated() {
                report += "\n📍 Crash #\(index + 1):\n"
                report += "• Exception Type: \(crash.exceptionType?.description ?? "Unknown")\n"
                report += "• Exception Code: \(crash.exceptionCode?.description ?? "Unknown")\n"
                report += "• Signal: \(crash.signal?.description ?? "Unknown")\n"
                report += "• Termination Reason: \(crash.terminationReason ?? "Unknown")\n"
                report += "• Virtual Memory: \(crash.virtualMemoryRegionInfo ?? "Unknown")\n"
                report += "• App Version: \(crash.applicationVersion)\n"
                
                if let objcException = crash.exceptionReason {
                    report += "• ObjC Exception Name: \(objcException.exceptionName)\n"
                    report += "• ObjC Exception Type: \(objcException.exceptionType)\n"
                    report += "• Composed Message: \(objcException.composedMessage)\n"
                    report += "• Arguments: \(objcException.arguments.joined(separator: ", "))\n"
                }
                
                let callStack = crash.callStackTree
                report += "• Call Stack JSON: \(callStack.jsonRepresentation().count) bytes\n"
            }
        }
        
        // Detailed Hang Reports
        if !hangs.isEmpty {
            report += "\n🔒 HANG DIAGNOSTICS (\(hangs.count) total):\n"
            for (index, hang) in hangs.enumerated() {
                report += "\n📍 Hang #\(index + 1):\n"
                report += "• Duration: \(formatDuration(hang.hangDuration))\n"
                report += "• App Version: \(hang.applicationVersion)\n"
                
                let callStack = hang.callStackTree
                report += "• Call Stack JSON: \(callStack.jsonRepresentation().count) bytes\n"
            }
        }
        
        // CPU Exception Reports
        if !cpuExceptions.isEmpty {
            report += "\n🔥 CPU EXCEPTION DIAGNOSTICS (\(cpuExceptions.count) total):\n"
            for (index, exception) in cpuExceptions.enumerated() {
                report += "\n📍 CPU Exception #\(index + 1):\n"
                report += "• Total CPU Time: \(formatDuration(exception.totalCPUTime))\n"
                report += "• Total Sampled Time: \(formatDuration(exception.totalSampledTime))\n"
                report += "• App Version: \(exception.applicationVersion)\n"
                
                let callStack = exception.callStackTree
                report += "• Call Stack JSON: \(callStack.jsonRepresentation().count) bytes\n"
            }
        }
        
        // Disk Exception Reports
        if !diskExceptions.isEmpty {
            report += "\n💽 DISK EXCEPTION DIAGNOSTICS (\(diskExceptions.count) total):\n"
            for (index, exception) in diskExceptions.enumerated() {
                report += "\n📍 Disk Exception #\(index + 1):\n"
                report += "• Total Writes: \(formatMemory(exception.totalWritesCaused))\n"
                report += "• App Version: \(exception.applicationVersion)\n"
                
                let callStack = exception.callStackTree
                report += "• Call Stack JSON: \(callStack.jsonRepresentation().count) bytes\n"
            }
        }
        
        // Launch Diagnostic Reports
        if !launchDiagnostics.isEmpty {
            report += "\n🚀 LAUNCH DIAGNOSTICS (\(launchDiagnostics.count) total):\n"
            for (index, launch) in launchDiagnostics.enumerated() {
                report += "\n📍 Launch Diagnostic #\(index + 1):\n"
                report += "• Launch Duration: \(formatDuration(launch.launchDuration))\n"
                report += "• App Version: \(launch.applicationVersion)\n"
                
                let callStack = launch.callStackTree
                report += "• Call Stack JSON: \(callStack.jsonRepresentation().count) bytes\n"
            }
        }
        
        return report
    }
    
    // MARK: - Custom Signpost Methods


    func startSignpostInterval(name: String) -> OSSignpostID {
        let signpostID = OSSignpostID(log: signpostLog)
        os_signpost(.begin, log: signpostLog, name: "Custom Interval", signpostID: signpostID, "%{public}@", name)
        logEvent("📊 Started signpost interval: \(name)")
        return signpostID
    }

    func endSignpostInterval(name: String, signpostID: OSSignpostID) {
        os_signpost(.end, log: signpostLog, name: "Custom Interval", signpostID: signpostID, "%{public}@", name)
        logEvent("📊 Ended signpost interval: \(name)")
    }

    func signpostEvent(name: String, message: String = "") {
        os_signpost(.event, log: signpostLog, name: "Custom Event", "%{public}@ - %{public}@", name, message)
        logEvent("📊 Signpost event: \(name) - \(message)")
     }
    
    
    // MARK: - Extended Launch Measurement
    func extendLaunchMeasurement(taskID: String) {
        do {
            let launchTaskID = MXLaunchTaskID(taskID)
            try MXMetricManager.extendLaunchMeasurement(forTaskID: launchTaskID)
            logEvent("🚀 Extended launch measurement for task: \(taskID)")
        } catch {
            logEvent("❌ Failed to extend launch measurement: \(error)")
        }
    }
    
    func finishExtendedLaunchMeasurement(taskID: String) {
        do {
            let launchTaskID = MXLaunchTaskID(taskID)
            try MXMetricManager.finishExtendedLaunchMeasurement(forTaskID: launchTaskID)
            logEvent("✅ Finished extended launch measurement for task: \(taskID)")
        } catch {
            logEvent("❌ Failed to finish launch measurement: \(error)")
        }
    }
    
    // MARK: - Simulation Methods
    
    func simulateCrash() {
        logEvent("💀 Simulating crash for testing...")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
            let array: [Int] = []
            let _ = array[10] // Index out of bounds crash
        }
    }
    
    func simulateHang() {
        logEvent("🔒 Simulating hang for testing...")
        DispatchQueue.main.async {
            Thread.sleep(forTimeInterval: 5)
        }
    }
    
    func simulateCPUException() {
        logEvent("🔥 Simulating CPU exception...")
        DispatchQueue.global(qos: .userInitiated).async {
            var result = 0.0
            for i in 0..<50_000_000 {
                result += sin(Double(i)) * cos(Double(i)) * tan(Double(i))
            }
            print("CPU intensive task result: \(result)")
        }
    }
    
    func simulateMemoryPressure() {
        logEvent("💾 Simulating memory pressure...")
        DispatchQueue.global(qos: .background).async {
            var arrays: [[Int]] = []
            for i in 0..<1000 {
                let array = Array(0..<50000)
                arrays.append(array)
                if i % 100 == 0 {
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
            Thread.sleep(forTimeInterval: 5)
            // Arrays will be deallocated when they go out of scope
        }
    }
    
    func simulateDiskWriteException() {
        logEvent("💽 Simulating disk write exception...")
        DispatchQueue.global(qos: .utility).async {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            for i in 0..<500 {
                let fileName = "heavy_write_test_\(i).dat"
                let fileURL = documentsPath.appendingPathComponent(fileName)
                let data = Data(repeating: 0xFF, count: 1024 * 1024) // 1MB files
                
                try? data.write(to: fileURL)
                
                if i % 50 == 0 {
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func processPastPayloads() {
        let pastPayloads = MXMetricManager.shared.pastPayloads
        let pastDiagnostics = MXMetricManager.shared.pastDiagnosticPayloads
        
        if !pastPayloads.isEmpty {
            logEvent("📋 Found \(pastPayloads.count) past payload(s)")
            allPayloads.append(contentsOf: pastPayloads)
            totalPayloadsReceived += pastPayloads.count
        }
        
        if !pastDiagnostics.isEmpty {
            logEvent("🚨 Found \(pastDiagnostics.count) past diagnostic(s)")
            allDiagnostics.append(contentsOf: pastDiagnostics)
            totalDiagnosticsReceived += pastDiagnostics.count
            
            for diagnostic in pastDiagnostics {
                processComprehensiveDiagnosticPayload(diagnostic)
            }
        }
    }
    
    private func processComprehensiveDiagnosticPayload(_ payload: MXDiagnosticPayload) {
        var log = "🚨 === COMPREHENSIVE DIAGNOSTIC PAYLOAD ===\n"
        log += "🕐 Timestamp: \(DateFormatter.detailed.string(from: Date()))\n"
        
        // Process Crashes
        if let crashDiagnostics = payload.crashDiagnostics {
            crashes.append(contentsOf: crashDiagnostics)
            log += "\n💥 CRASHES DETECTED: \(crashDiagnostics.count)\n"
            
            for (index, crash) in crashDiagnostics.enumerated() {
                log += "\n🔍 Crash #\(index + 1) Comprehensive Details:\n"
                log += "   • Exception Type: \(crash.exceptionType?.description ?? "Unknown")\n"
                log += "   • Exception Code: \(crash.exceptionCode?.description ?? "Unknown")\n"
                log += "   • Signal: \(crash.signal?.description ?? "Unknown")\n"
                log += "   • Termination Reason: \(crash.terminationReason ?? "Unknown")\n"
                log += "   • Virtual Memory: \(crash.virtualMemoryRegionInfo ?? "Unknown")\n"
                log += "   • App Version: \(crash.applicationVersion)\n"
                
                // ObjC Exception details
                if let objcException = crash.exceptionReason {
                    log += "   • ObjC Exception Name: \(objcException.exceptionName)\n"
                    log += "   • ObjC Exception Type: \(objcException.exceptionType)\n"
                    log += "   • Composed Message: \(objcException.composedMessage)\n"
                    log += "   • Arguments Count: \(objcException.arguments.count)\n"
                }
                
                let callStack = crash.callStackTree
                log += "   • Call Stack Available: ✅\n"
                log += "   • Call Stack Size: \(callStack.jsonRepresentation().count) bytes\n"
                
                onCrashDetected?(crash)
            }
        }
        
        // Process Hangs
        if let hangDiagnostics = payload.hangDiagnostics {
            hangs.append(contentsOf: hangDiagnostics)
            log += "\n🔒 HANGS DETECTED: \(hangDiagnostics.count)\n"
            
            for (index, hang) in hangDiagnostics.enumerated() {
                log += "\n🔍 Hang #\(index + 1) Comprehensive Details:\n"
                log += "   • Duration: \(formatDuration(hang.hangDuration))\n"
                log += "   • App Version: \(hang.applicationVersion)\n"
                
                let callStack = hang.callStackTree
                log += "   • Call Stack Available: ✅\n"
                log += "   • Call Stack Size: \(callStack.jsonRepresentation().count) bytes\n"
                
                onHangDetected?(hang)
            }
        }
        
        // Process CPU Exceptions
        if let cpuExceptionDiagnostics = payload.cpuExceptionDiagnostics {
            cpuExceptions.append(contentsOf: cpuExceptionDiagnostics)
            log += "\n🔥 CPU EXCEPTIONS: \(cpuExceptionDiagnostics.count)\n"
            
            for (index, exception) in cpuExceptionDiagnostics.enumerated() {
                log += "\n🔍 CPU Exception #\(index + 1) Comprehensive Details:\n"
                log += "   • Total CPU Time: \(formatDuration(exception.totalCPUTime))\n"
                log += "   • Total Sampled Time: \(formatDuration(exception.totalSampledTime))\n"
                log += "   • App Version: \(exception.applicationVersion)\n"
                
                let callStack = exception.callStackTree
                log += "   • Call Stack Available: ✅\n"
                log += "   • Call Stack Size: \(callStack.jsonRepresentation().count) bytes\n"
            }
        }
        
        // Process Disk Write Exceptions
        if let diskExceptionDiagnostics = payload.diskWriteExceptionDiagnostics {
            diskExceptions.append(contentsOf: diskExceptionDiagnostics)
            log += "\n💽 DISK EXCEPTIONS: \(diskExceptionDiagnostics.count)\n"
            
            for (index, exception) in diskExceptionDiagnostics.enumerated() {
                log += "\n🔍 Disk Exception #\(index + 1) Comprehensive Details:\n"
                log += "   • Total Writes: \(formatMemory(exception.totalWritesCaused))\n"
                log += "   • App Version: \(exception.applicationVersion)\n"
                
                let callStack = exception.callStackTree
                log += "   • Call Stack Available: ✅\n"
                log += "   • Call Stack Size: \(callStack.jsonRepresentation().count) bytes\n"
            }
        }
        
        // Process App Launch Diagnostics
        if let appLaunchDiagnostics = payload.appLaunchDiagnostics {
            launchDiagnostics.append(contentsOf: appLaunchDiagnostics)
            log += "\n🚀 LAUNCH DIAGNOSTICS: \(appLaunchDiagnostics.count)\n"
            
            for (index, launch) in appLaunchDiagnostics.enumerated() {
                log += "\n🔍 Launch Diagnostic #\(index + 1) Details:\n"
                log += "   • Launch Duration: \(formatDuration(launch.launchDuration))\n"
                log += "   • App Version: \(launch.applicationVersion)\n"
                
                let callStack = launch.callStackTree
                log += "   • Call Stack Available: ✅\n"
                log += "   • Call Stack Size: \(callStack.jsonRepresentation().count) bytes\n"
            }
        }
        
        log += "\n" + String(repeating: "=", count: 60) + "\n\n"
        onLogUpdate?(log)
        
        // Send critical alert if crashes detected
        if let crashes = payload.crashDiagnostics, !crashes.isEmpty {
            logEvent("🚨 CRITICAL: \(crashes.count) crash(es) detected! Check diagnostic report.")
        }
    }
    
    private func logComprehensivePayload(_ payload: MXMetricPayload) {
        var log = "📦 === COMPREHENSIVE METRIC PAYLOAD ===\n"
        log += "🕐 Timestamp: \(DateFormatter.detailed.string(from: Date()))\n"
        log += "⏰ Time Range: \(DateFormatter.shortTime.string(from: payload.timeStampBegin)) - \(DateFormatter.shortTime.string(from: payload.timeStampEnd))\n"
        log += "📦 Multiple App Versions: \(payload.includesMultipleApplicationVersions ? "Yes" : "No")\n"
        log += "🏷️ Latest App Version: \(payload.latestApplicationVersion)\n"
        
        // MetaData
        if let metaData = payload.metaData {
            log += "\n📊 METADATA:\n"
            log += "   • OS Version: \(metaData.osVersion)\n"
            log += "   • Device Type: \(metaData.deviceType)\n"
            log += "   • App Build Version: \(metaData.applicationBuildVersion)\n"
            log += "   • Platform Architecture: \(metaData.platformArchitecture)\n"
            log += "   • Region Format: \(metaData.regionFormat)\n"
            log += "   • TestFlight App: \(metaData.isTestFlightApp ? "Yes" : "No")\n"
            log += "   • Low Power Mode: \(metaData.lowPowerModeEnabled ? "Yes" : "No")\n"
            log += "   • Bundle Identifier: \(metaData.bundleIdentifier)\n"
            log += "   • Process ID: \(metaData.pid)\n"
        }
        
        // Battery Metrics
        
        // Cellular Condition Metrics
        if let cellularMetrics = payload.cellularConditionMetrics {
            log += "\n📶 CELLULAR CONDITION METRICS:\n"
            log += "   • Cell Condition Time:\n"
            
            let histogram = cellularMetrics.histogrammedCellularConditionTime
            let enumerator = histogram.bucketEnumerator
            while let bucket = enumerator.nextObject() as? MXHistogramBucket<MXUnitSignalBars> {
                log += "     - \(bucket.bucketStart.value) to \(bucket.bucketEnd.value) bars: \(bucket.bucketCount) samples\n"
            }
        }
        
        // CPU Metrics
        if let cpuMetrics = payload.cpuMetrics {
            log += "\n🖥️ CPU METRICS:\n"
            log += "   • Cumulative CPU Time: \(formatDuration(cpuMetrics.cumulativeCPUTime))\n"
            log += "   • CPU Instructions: \(cpuMetrics.cumulativeCPUInstructions.value) \(cpuMetrics.cumulativeCPUInstructions.unit)\n"
        }
        
        // Display Metrics
//        if let displayMetrics = payload.displayMetrics {
//            log += "\n📺 DISPLAY METRICS:\n"
//            if let avgLuminance = displayMetrics.averagePixelLuminance {
//                log += "   • Average Pixel Luminance: \(avgLuminance.averageMeasurement.value) \(avgLuminance.averageMeasurement.unit)\n"
//            }
//        }
        if let displayMetrics = payload.displayMetrics {
            log += "\n📺 DISPLAY METRICS:\n"
            if let avgLuminance = displayMetrics.averagePixelLuminance {
                log += "   • Average Pixel Luminance: \(avgLuminance.averageMeasurement.value) \(avgLuminance.averageMeasurement.unit)\n"
                log += "   • Sample Count: \(avgLuminance.sampleCount)\n"
                log += "   • Standard Deviation: \(avgLuminance.standardDeviation)\n"
            }
        }
//
        // GPU Metrics
        if let gpuMetrics = payload.gpuMetrics {
            log += "\n🎮 GPU METRICS:\n"
            log += "   • Cumulative GPU Time: \(formatDuration(gpuMetrics.cumulativeGPUTime))\n"
        }
        
        // Location Activity Metrics
        if let locationMetrics = payload.locationActivityMetrics {
            log += "\n📍 LOCATION ACTIVITY METRICS:\n"
            log += "   • Cumulative Best Accuracy Time: \(formatDuration(locationMetrics.cumulativeBestAccuracyTime))\n"
            log += "   • Cumulative Best Accuracy for Navigation Time: \(formatDuration(locationMetrics.cumulativeBestAccuracyForNavigationTime))\n"
            log += "   • Cumulative Nearest Ten Meters Accuracy Time: \(formatDuration(locationMetrics.cumulativeNearestTenMetersAccuracyTime))\n"
            log += "   • Cumulative Hundred Meters Accuracy Time: \(formatDuration(locationMetrics.cumulativeHundredMetersAccuracyTime))\n"
            log += "   • Cumulative Kilometer Accuracy Time: \(formatDuration(locationMetrics.cumulativeKilometerAccuracyTime))\n"
            log += "   • Cumulative Three Kilometers Accuracy Time: \(formatDuration(locationMetrics.cumulativeThreeKilometersAccuracyTime))\n"
        }
        
        
        // Network Transfer Metrics
        if let networkMetrics = payload.networkTransferMetrics {
            log += "\n🌐 NETWORK TRANSFER METRICS:\n"
            log += "   • WiFi Upload: \(formatMemory(networkMetrics.cumulativeWifiUpload))\n"
            log += "   • WiFi Download: \(formatMemory(networkMetrics.cumulativeWifiDownload))\n"
            log += "   • Cellular Upload: \(formatMemory(networkMetrics.cumulativeCellularUpload))\n"
            log += "   • Cellular Download: \(formatMemory(networkMetrics.cumulativeCellularDownload))\n"
        }
        
        // Performance Metrics
        
        // App Exit Metrics
        if let exitMetrics = payload.applicationExitMetrics {
            log += "\n🚪 APPLICATION EXIT METRICS:\n"
            log += "   FOREGROUND EXITS:\n"
            log += "     • Normal Exits: \(exitMetrics.foregroundExitData.cumulativeNormalAppExitCount)\n"
            log += "     • Memory Resource Limit Exits: \(exitMetrics.foregroundExitData.cumulativeMemoryResourceLimitExitCount)\n"
            log += "     • Bad Access Exits: \(exitMetrics.foregroundExitData.cumulativeBadAccessExitCount)\n"
            log += "     • Abnormal Exits: \(exitMetrics.foregroundExitData.cumulativeAbnormalExitCount)\n"
            log += "     • Illegal Instruction Exits: \(exitMetrics.foregroundExitData.cumulativeIllegalInstructionExitCount)\n"
            log += "     • App Watchdog Exits: \(exitMetrics.foregroundExitData.cumulativeAppWatchdogExitCount)\n"
            
            log += "   BACKGROUND EXITS:\n"
            log += "     • Normal Exits: \(exitMetrics.backgroundExitData.cumulativeNormalAppExitCount)\n"
            log += "     • Memory Resource Limit Exits: \(exitMetrics.backgroundExitData.cumulativeMemoryResourceLimitExitCount)\n"
            log += "     • CPU Resource Limit Exits: \(exitMetrics.backgroundExitData.cumulativeCPUResourceLimitExitCount)\n"
            log += "     • Bad Access Exits: \(exitMetrics.backgroundExitData.cumulativeBadAccessExitCount)\n"
            log += "     • Abnormal Exits: \(exitMetrics.backgroundExitData.cumulativeAbnormalExitCount)\n"
            log += "     • Illegal Instruction Exits: \(exitMetrics.backgroundExitData.cumulativeIllegalInstructionExitCount)\n"
            log += "     • App Watchdog Exits: \(exitMetrics.backgroundExitData.cumulativeAppWatchdogExitCount)\n"
            log += "     • Memory Pressure Exits: \(exitMetrics.backgroundExitData.cumulativeMemoryPressureExitCount)\n"
            log += "     • Suspended With Locked File Exits: \(exitMetrics.backgroundExitData.cumulativeSuspendedWithLockedFileExitCount)\n"
            log += "     • Background Task Assertion Timeout Exits: \(exitMetrics.backgroundExitData.cumulativeBackgroundTaskAssertionTimeoutExitCount)\n"
        }
        
        // App Runtime Metrics
        if let runtimeMetrics = payload.applicationTimeMetrics {
            log += "\n⏱️ APPLICATION TIME METRICS:\n"
            log += "   • Cumulative Foreground Time: \(formatDuration(runtimeMetrics.cumulativeForegroundTime))\n"
            log += "   • Cumulative Background Time: \(formatDuration(runtimeMetrics.cumulativeBackgroundTime))\n"
            log += "   • Cumulative Background Audio Time: \(formatDuration(runtimeMetrics.cumulativeBackgroundAudioTime))\n"
            log += "   • Cumulative Background Location Time: \(formatDuration(runtimeMetrics.cumulativeBackgroundLocationTime))\n"
        }
        
        // Memory Metrics
        if let memoryMetrics = payload.memoryMetrics {
            log += "\n💾 MEMORY METRICS:\n"
            log += "   • Peak Memory Usage: \(formatMemory(memoryMetrics.peakMemoryUsage))\n"
            log += "   • Average Suspended Memory: \(formatMemory(memoryMetrics.averageSuspendedMemory.averageMeasurement))\n"
            log += "   • Suspended Memory Sample Count: \(memoryMetrics.averageSuspendedMemory.sampleCount)\n"
        }
        
        // Responsiveness Metrics
        
        // Animation Metrics
        if let animationMetrics = payload.animationMetrics {
            log += "\n🎬 ANIMATION METRICS:\n"
            log += "   • Scroll Hitch Time Ratio: \(animationMetrics.scrollHitchTimeRatio.value) \(animationMetrics.scrollHitchTimeRatio.unit)\n"
            log += "   • Hitch Time Ratio: \(animationMetrics.hitchTimeRatio.value) \(animationMetrics.hitchTimeRatio.unit)\n"
        }
        
        // App Launch Metrics
//        if let launchMetrics = payload.applicationLaunchMetrics {
//            log += "\n🚀 APPLICATION LAUNCH METRICS:\n"
//            
//            // Time to First Draw Histogram
//            let firstDrawHistogram = launchMetrics.histogrammedTimeToFirstDraw
//            log += "   • Time to First Draw Histogram (\(firstDrawHistogram.totalBucketCount) buckets):\n"
//            
//            let firstDrawEnumerator = firstDrawHistogram.bucketEnumerator
//            var bucketFound = false
//            while let bucket = firstDrawEnumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
//                log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) launches\n"
//                bucketFound = true
//            }
//            if !bucketFound {
//                log += "     - No histogram data yet (need more app launches)\n"
//            }
//            
//            // Application Resume Time Histogram
//            let resumeHistogram = launchMetrics.histogrammedApplicationResumeTime
//            log += "   • Application Resume Time Histogram (\(resumeHistogram.totalBucketCount) buckets):\n"
//            
//            let resumeEnumerator = resumeHistogram.bucketEnumerator
//            bucketFound = false
//            while let bucket = resumeEnumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
//                log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) resumes\n"
//                bucketFound = true
//            }
//            if !bucketFound {
//                log += "     - No resume histogram data yet\n"
//            }
//        }
        
        // Replace your existing launch metrics section with this complete version:

        if let launchMetrics = payload.applicationLaunchMetrics {
            log += "\n🚀 APPLICATION LAUNCH METRICS:\n"
            
            // Time to First Draw Histogram
            let firstDrawHistogram = launchMetrics.histogrammedTimeToFirstDraw
            log += "   • Time to First Draw Histogram (\(firstDrawHistogram.totalBucketCount) buckets):\n"
            
            let firstDrawEnumerator = firstDrawHistogram.bucketEnumerator
            var bucketFound = false
            while let bucket = firstDrawEnumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
                log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) launches\n"
                bucketFound = true
            }
            if !bucketFound {
                log += "     - No histogram data yet (need more app launches)\n"
            }
            
            // Application Resume Time Histogram
            let resumeHistogram = launchMetrics.histogrammedApplicationResumeTime
            log += "   • Application Resume Time Histogram (\(resumeHistogram.totalBucketCount) buckets):\n"
            
            let resumeEnumerator = resumeHistogram.bucketEnumerator
            bucketFound = false
            while let bucket = resumeEnumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
                log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) resumes\n"
                bucketFound = true
            }
            if !bucketFound {
                log += "     - No resume histogram data yet\n"
            }
            
            // Extended Launch Histogram (MISSING from your code)
            let extendedHistogram = launchMetrics.histogrammedExtendedLaunch
            log += "   • Extended Launch Histogram (\(extendedHistogram.totalBucketCount) buckets):\n"
            
            let extendedEnumerator = extendedHistogram.bucketEnumerator
            bucketFound = false
            while let bucket = extendedEnumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
                log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) extended launches\n"
                bucketFound = true
            }
            if !bucketFound {
                log += "     - No extended launch data yet\n"
            }
        }
        
        // App Responsiveness Metrics
        if let responsivenessMetrics = payload.applicationResponsivenessMetrics {
            log += "\n⚡ APPLICATION RESPONSIVENESS METRICS:\n"
            
            // Hang Time Histogram
            let hangHistogram = responsivenessMetrics.histogrammedApplicationHangTime
            log += "   • Application Hang Time Histogram (\(hangHistogram.totalBucketCount) buckets):\n"
            
            let hangEnumerator = hangHistogram.bucketEnumerator
            var hangBucketFound = false
            while let bucket = hangEnumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
                log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) hangs\n"
                hangBucketFound = true
            }
            if !hangBucketFound {
                log += "     - No hang histogram data yet\n"
            }
        }
        
        // Disk Usage Metrics
        
        // Disk I/O Metrics
        if let diskMetrics = payload.diskIOMetrics {
            log += "\n💽 DISK I/O METRICS:\n"
            log += "   • Cumulative Logical Writes: \(formatMemory(diskMetrics.cumulativeLogicalWrites))\n"
        }
        
        // Disk Space Usage Metrics (Beta)
        if let diskSpaceMetrics = payload.diskSpaceUsageMetrics {
            log += "\n📦 DISK SPACE USAGE METRICS (Beta):\n"
            log += "   • Total Binary File Count: \(diskSpaceMetrics.totalBinaryFileCount)\n"
            log += "   • Total Data File Count: \(diskSpaceMetrics.totalDataFileCount)\n"
            log += "   • Total Binary File Size: \(formatMemory(diskSpaceMetrics.totalBinaryFileSize))\n"
            log += "   • Total Data File Size: \(formatMemory(diskSpaceMetrics.totalDataFileSize))\n"
            log += "   • Total Cache Folder Size: \(formatMemory(diskSpaceMetrics.totalCacheFolderSize))\n"
            log += "   • Total Clone Size: \(formatMemory(diskSpaceMetrics.totalCloneSize))\n"
            log += "   • Total Disk Space Capacity: \(formatMemory(diskSpaceMetrics.totalDiskSpaceCapacity))\n"
            log += "   • Total Disk Space Used: \(formatMemory(diskSpaceMetrics.totalDiskSpaceUsedSize))\n"
        }
        
        // Custom Metrics
        
        // Signpost Metrics
        if let signpostMetrics = payload.signpostMetrics {
            log += "\n📊 SIGNPOST METRICS (\(signpostMetrics.count) categories):\n"
            for signpostMetric in signpostMetrics {
                log += "   • Category: \(signpostMetric.signpostCategory)\n"
                log += "   • Name: \(signpostMetric.signpostName)\n"
                log += "   • Total Count: \(signpostMetric.totalCount)\n"
                
                if let signpostIntervalData = signpostMetric.signpostIntervalData {
                    log += "   • Histogram Buckets: \(signpostIntervalData.histogrammedSignpostDuration.totalBucketCount)\n"
                    if let avgMemory = signpostIntervalData.averageMemory {
                        log += "   • Average Memory: \(formatMemory(avgMemory.averageMeasurement))\n"
                    }
                    
                    let durationEnumerator = signpostIntervalData.histogrammedSignpostDuration.bucketEnumerator
                    while let bucket = durationEnumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
                        log += "     - \(formatDuration(bucket.bucketStart)) to \(formatDuration(bucket.bucketEnd)): \(bucket.bucketCount) intervals\n"
                    }
                }
            }
        }
        
        log += "\n" + String(repeating: "=", count: 60) + "\n\n"
        onLogUpdate?(log)
    }
    
    private func formatDuration(_ measurement: Measurement<UnitDuration>) -> String {
        let seconds = measurement.converted(to: .seconds).value
        if seconds < 60 {
            return String(format: "%.2fs", seconds)
        } else if seconds < 3600 {
            return String(format: "%.1fm", seconds / 60)
        } else {
            return String(format: "%.1fh", seconds / 3600)
        }
    }
    
    private func formatMemory(_ measurement: Measurement<UnitInformationStorage>) -> String {
        let bytes = measurement.converted(to: .bytes).value
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    
    // MARK: - JSON and Dictionary Export Methods
    func exportPayloadAsJSON(_ payload: MXMetricPayload) -> String {
        let jsonData = payload.jsonRepresentation()
        return String(data: jsonData, encoding: .utf8) ?? "Failed to convert JSON"
    }

    func exportPayloadAsDictionary(_ payload: MXMetricPayload) -> String {
        let dict = payload.dictionaryRepresentation()
        return formatDictionary(dict)
    }

    func exportDiagnosticAsJSON(_ diagnostic: MXDiagnosticPayload) -> String {
        let jsonData = diagnostic.jsonRepresentation()
        return String(data: jsonData, encoding: .utf8) ?? "Failed to convert JSON"
    }

    func exportDiagnosticAsDictionary(_ diagnostic: MXDiagnosticPayload) -> String {
        let dict = diagnostic.dictionaryRepresentation()
        return formatDictionary(dict)
    }

    // MARK: - Call Stack Analysis
    func getDetailedCallStackAnalysis() -> String {
        var analysis = "🔍 CALL STACK ANALYSIS:\n"
        analysis += String(repeating: "=", count: 50) + "\n"
        
        if crashes.isEmpty && hangs.isEmpty && cpuExceptions.isEmpty {
            analysis += "✅ No call stacks available (no crashes/hangs detected)\n"
            return analysis
        }
        
        // Analyze crash call stacks
        for (index, crash) in crashes.enumerated() {
            analysis += "\n💥 CRASH #\(index + 1) CALL STACK:\n"
            analysis += "• App Version: \(crash.applicationVersion)\n"
            
            let callStackJSON = crash.callStackTree.jsonRepresentation()
            print("Call Stack JSON Size: \(callStackJSON.count) bytes")
            if let jsonString = String(data: callStackJSON, encoding: .utf8) {
                analysis += "• Call Stack JSON:\n\(jsonString)\n"
            }
            
            // Parse and analyze the call stack
            analysis += analyzeCallStackData(callStackJSON)
        }
        
        // Analyze hang call stacks
        for (index, hang) in hangs.enumerated() {
            analysis += "\n🔒 HANG #\(index + 1) CALL STACK:\n"
            analysis += "• Duration: \(formatDuration(hang.hangDuration))\n"
            analysis += "• App Version: \(hang.applicationVersion)\n"
            
            let callStackJSON = hang.callStackTree.jsonRepresentation()
            if let jsonString = String(data: callStackJSON, encoding: .utf8) {
                analysis += "• Call Stack JSON:\n\(jsonString)\n"
            }
            
            analysis += analyzeCallStackData(callStackJSON)
        }
        
        return analysis
    }

    private func analyzeCallStackData(_ jsonData: Data) -> String {
        var analysis = "📊 CALL STACK BREAKDOWN:\n"
        
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let callStacks = json["callStacks"] as? [[String: Any]] {
                
                for (stackIndex, callStack) in callStacks.enumerated() {
                    analysis += "  📋 Stack #\(stackIndex + 1):\n"
                    
                    if let threadAttributed = callStack["threadAttributed"] as? Bool {
                        analysis += "    • Thread Attributed: \(threadAttributed)\n"
                    }
                    
                    if let rootFrames = callStack["callStackRootFrames"] as? [[String: Any]] {
                        analysis += "    • Root Frames Count: \(rootFrames.count)\n"
                        
                        for (frameIndex, frame) in rootFrames.enumerated() {
                            analysis += "      Frame #\(frameIndex + 1):\n"
                            
                            if let binaryName = frame["binaryName"] as? String {
                                analysis += "        - Binary: \(binaryName)\n"
                            }
                            
                            if let binaryUUID = frame["binaryUUID"] as? String {
                                analysis += "        - UUID: \(binaryUUID)\n"
                            }
                            
                            if let address = frame["address"] as? Int64 {
                                analysis += "        - Address: 0x\(String(address, radix: 16))\n"
                            }
                            
                            if let offset = frame["offsetIntoBinaryTextSegment"] as? Int64 {
                                analysis += "        - Offset: \(offset)\n"
                            }
                            
                            if let sampleCount = frame["sampleCount"] as? Int {
                                analysis += "        - Sample Count: \(sampleCount)\n"
                            }
                        }
                    }
                }
            }
        } catch {
            analysis += "❌ Failed to parse call stack JSON: \(error)\n"
        }
        
        return analysis + "\n"
    }

    // MARK: - Enhanced Metadata Analysis
    func getDetailedMetadataReport() -> String {
        var report = "📱 DEVICE METADATA ANALYSIS:\n"
        report += String(repeating: "=", count: 50) + "\n"
        
        guard let lastPayload = allPayloads.last,
              let metaData = lastPayload.metaData else {
            report += "❌ No metadata available\n"
            return report
        }
        
        // Export metadata as JSON
        let metadataJSON = metaData.jsonRepresentation()
        if let jsonString = String(data: metadataJSON, encoding: .utf8) {
            report += "\n📄 METADATA JSON:\n\(jsonString)\n\n"
        }
        
        // Export metadata as Dictionary
        let metadataDict = metaData.dictionaryRepresentation()
        report += "📖 METADATA DICTIONARY:\n\(formatDictionary(metadataDict))\n"
        
        // Detailed analysis
        report += "\n🔍 DETAILED ANALYSIS:\n"
        report += "• Device Type: \(metaData.deviceType)\n"
        report += "• OS Version: \(metaData.osVersion)\n"
        report += "• Platform Architecture: \(metaData.platformArchitecture)\n"
        report += "• App Build Version: \(metaData.applicationBuildVersion)\n"
        report += "• Bundle Identifier: \(metaData.bundleIdentifier)\n"
        report += "• Region Format: \(metaData.regionFormat)\n"
        report += "• TestFlight App: \(metaData.isTestFlightApp ? "Yes" : "No")\n"
        report += "• Low Power Mode: \(metaData.lowPowerModeEnabled ? "Yes" : "No")\n"
        report += "• Process ID: \(metaData.pid)\n"
        
        return report
    }

    // MARK: - Histogram Data Export
    func getHistogramAnalysis() -> String {
        var analysis = "📊 HISTOGRAM DATA ANALYSIS:\n"
        analysis += String(repeating: "=", count: 50) + "\n"
        
        guard let lastPayload = allPayloads.last else {
            analysis += "❌ No payload data available\n"
            return analysis
        }
        
        // Launch time histograms
        if let launchMetrics = lastPayload.applicationLaunchMetrics {
            analysis += "\n🚀 LAUNCH TIME HISTOGRAMS:\n"
            
            // Time to first draw
            let firstDrawHistogram = launchMetrics.histogrammedTimeToFirstDraw
            analysis += exportHistogramData(firstDrawHistogram, title: "Time to First Draw")
            
            // Resume time
            let resumeHistogram = launchMetrics.histogrammedApplicationResumeTime
            analysis += exportHistogramData(resumeHistogram, title: "Application Resume Time")
            
            // Extended launch (if available)
            let extendedHistogram = launchMetrics.histogrammedExtendedLaunch
            analysis += exportHistogramData(extendedHistogram, title: "Extended Launch Time")
        }
        
        // Hang time histograms
        if let responsivenessMetrics = lastPayload.applicationResponsivenessMetrics {
            analysis += "\n🔒 RESPONSIVENESS HISTOGRAMS:\n"
            let hangHistogram = responsivenessMetrics.histogrammedApplicationHangTime
            analysis += exportHistogramData(hangHistogram, title: "Application Hang Time")
        }
        
        // Cellular condition histograms
        if let cellularMetrics = lastPayload.cellularConditionMetrics {
            analysis += "\n📶 CELLULAR CONDITION HISTOGRAMS:\n"
            let cellularHistogram = cellularMetrics.histogrammedCellularConditionTime
            analysis += exportCellularHistogramData(cellularHistogram, title: "Cellular Condition Time")
        }
        
        return analysis
    }

    private func exportHistogramData<T: Unit>(_ histogram: MXHistogram<T>, title: String) -> String {
        var data = "\n📈 \(title.uppercased()):\n"
        data += "• Total Buckets: \(histogram.totalBucketCount)\n"
        
        let enumerator = histogram.bucketEnumerator
        var bucketCount = 0
        
        while let bucket = enumerator.nextObject() as? MXHistogramBucket<T> {
            bucketCount += 1
            if T.self == UnitDuration.self {
                let startDuration = bucket.bucketStart as! Measurement<UnitDuration>
                let endDuration = bucket.bucketEnd as! Measurement<UnitDuration>
                data += "  Bucket \(bucketCount): \(formatDuration(startDuration)) - \(formatDuration(endDuration)) (\(bucket.bucketCount) samples)\n"
            } else {
                data += "  Bucket \(bucketCount): \(bucket.bucketStart) - \(bucket.bucketEnd) (\(bucket.bucketCount) samples)\n"
            }
        }
        
        if bucketCount == 0 {
            data += "  ⚠️ No histogram data available yet\n"
        }
        
        return data
    }

    private func exportCellularHistogramData(_ histogram: MXHistogram<MXUnitSignalBars>, title: String) -> String {
        var data = "\n📶 \(title.uppercased()):\n"
        data += "• Total Buckets: \(histogram.totalBucketCount)\n"
        
        let enumerator = histogram.bucketEnumerator
        var bucketCount = 0
        
        while let bucket = enumerator.nextObject() as? MXHistogramBucket<MXUnitSignalBars> {
            bucketCount += 1
            data += "  Bucket \(bucketCount): \(bucket.bucketStart.value) - \(bucket.bucketEnd.value) signal bars (\(bucket.bucketCount) samples)\n"
        }
        
        if bucketCount == 0 {
            data += "  ⚠️ No cellular histogram data available yet\n"
        }
        
        return data
    }

    private func formatDictionary(_ dict: [AnyHashable: Any], indent: String = "") -> String {
        var result = ""
        for (key, value) in dict {
            result += "\(indent)• \(key): "
            if let nestedDict = value as? [AnyHashable: Any] {
                result += "\n\(formatDictionary(nestedDict, indent: indent + "  "))"
            } else if let array = value as? [Any] {
                result += "[\(array.count) items]\n"
            } else {
                result += "\(value)\n"
            }
        }
        return result
    }

    func requestMetricKitUpdate() {
        logEvent("📋 Requesting MetricKit update...")
        
        // Check if past payloads are available
        let pastPayloads = MXMetricManager.shared.pastPayloads
        let pastDiagnostics = MXMetricManager.shared.pastDiagnosticPayloads
        
        logEvent("📊 Available past payloads: \(pastPayloads.count)")
        logEvent("🚨 Available past diagnostics: \(pastDiagnostics.count)")
        
        if pastPayloads.isEmpty && pastDiagnostics.isEmpty {
            logEvent("⚠️ No payloads available yet. Reasons:")
            logEvent("   • App needs 24+ hours of usage")
            logEvent("   • Device needs to be plugged in OR >50% battery")
            logEvent("   • Device should be on WiFi")
            logEvent("   • Apple decides delivery timing")
        }
        
        // Process any newly available past payloads
        processPastPayloads()
    }
    
    // Add these methods after your existing methods (around line 1200):

    // MARK: - Data Persistence and Storage
//    func saveMetricsToStorage() {
//        let encoder = JSONEncoder()
//        
//        do {
//            // Save payloads
//            let payloadData = try encoder.encode(allPayloads.map { $0.dictionaryRepresentation() })
//            UserDefaults.standard.set(payloadData, forKey: "SavedMetricPayloads")
//            
//            // Save diagnostic summary (can't encode MXDiagnosticPayload directly)
//            let diagnosticSummary = [
//                "crashCount": crashes.count,
//                "hangCount": hangs.count,
//                "cpuExceptionCount": cpuExceptions.count,
//                "diskExceptionCount": diskExceptions.count,
//                "lastUpdateTime": Date().timeIntervalSince1970
//            ]
//            let diagnosticData = try encoder.encode(diagnosticSummary)
//            UserDefaults.standard.set(diagnosticData, forKey: "SavedDiagnosticSummary")
//            
//            logEvent("💾 Metrics data saved to storage")
//        } catch {
//            logEvent("❌ Failed to save metrics: \(error)")
//        }
//    }
//
//    func loadMetricsFromStorage() {
//        let decoder = JSONDecoder()
//        
//        // Load diagnostic summary
//        if let diagnosticData = UserDefaults.standard.data(forKey: "SavedDiagnosticSummary") {
//            do {
//                let diagnosticSummary = try decoder.decode([String: Any].self, from: diagnosticData)
//                logEvent("📱 Loaded diagnostic summary from storage")
//            } catch {
//                logEvent("❌ Failed to load diagnostic summary: \(error)")
//            }
//        }
//    }
    
    // ...existing code...

    // Diagnostic summary struct
    private struct DiagnosticSummary: Codable {
        let crashCount: Int
        let hangCount: Int
        let cpuExceptionCount: Int
        let diskExceptionCount: Int
        let lastUpdateTime: Double
    }

    // Save metrics to storage
//    func saveMetricsToStorage() {
//        // Save payloads as JSON Data array
//        let payloadsDataArray = allPayloads.map { $0.jsonRepresentation() }
//        UserDefaults.standard.set(payloadsDataArray, forKey: "SavedMetricPayloads")
//        
//        // Save diagnostic summary
//        let summary = DiagnosticSummary(
//            crashCount: crashes.count,
//            hangCount: hangs.count,
//            cpuExceptionCount: cpuExceptions.count,
//            diskExceptionCount: diskExceptions.count,
//            lastUpdateTime: Date().timeIntervalSince1970
//        )
//        if let summaryData = try? JSONEncoder().encode(summary) {
//            UserDefaults.standard.set(summaryData, forKey: "SavedDiagnosticSummary")
//        }
//        
//        logEvent("💾 Metrics data saved to storage")
//    }
    
    func saveMetricsToStorage() {
        // Save diagnostic summary only (not the complex objects)
        let summary = DiagnosticSummary(
            crashCount: crashes.count,
            hangCount: hangs.count,
            cpuExceptionCount: cpuExceptions.count,
            diskExceptionCount: diskExceptions.count,
            lastUpdateTime: Date().timeIntervalSince1970
        )
        
        if let summaryData = try? JSONEncoder().encode(summary) {
            UserDefaults.standard.set(summaryData, forKey: "SavedDiagnosticSummary")
            logEvent("💾 Metrics data saved to storage")
        }
    }
    

    // Load metrics from storage
//    func loadMetricsFromStorage() {
//        // Load diagnostic summary
//        if let summaryData = UserDefaults.standard.data(forKey: "SavedDiagnosticSummary"),
//           let summary = try? JSONDecoder().decode(DiagnosticSummary.self, from: summaryData) {
//            logEvent("📱 Loaded diagnostic summary from storage: Crashes \(summary.crashCount), Hangs \(summary.hangCount)")
//        }
//        
//        // Load payloads (optional: implement if you want to restore them)
//        if let payloadsDataArray = UserDefaults.standard.array(forKey: "SavedMetricPayloads") as? [Data] {
//            logEvent("📦 Loaded \(payloadsDataArray.count) payloads from storage")
//            // You can parse these back into MXMetricPayload if needed (not shown here)
//        }
//    }
    func loadMetricsFromStorage() {
        if let summaryData = UserDefaults.standard.data(forKey: "SavedDiagnosticSummary"),
           let summary = try? JSONDecoder().decode(DiagnosticSummary.self, from: summaryData) {
            logEvent("📱 Loaded diagnostic summary: Crashes \(summary.crashCount), Hangs \(summary.hangCount)")
        }
    }

    // ...existing code...

    func clearAllStoredData() {
        UserDefaults.standard.removeObject(forKey: "SavedMetricPayloads")
        UserDefaults.standard.removeObject(forKey: "SavedDiagnosticSummary")
        
        // Clear in-memory data
        allPayloads.removeAll()
        allDiagnostics.removeAll()
        crashes.removeAll()
        hangs.removeAll()
        cpuExceptions.removeAll()
        diskExceptions.removeAll()
        launchDiagnostics.removeAll()
        
        totalPayloadsReceived = 0
        totalDiagnosticsReceived = 0
        
        logEvent("🧹 All stored metrics data cleared")
    }

    // MARK: - Chart Data Providers
    func getMemoryUsageHistory() -> [MemoryDataPoint] {
        var memoryHistory: [MemoryDataPoint] = []
        
        for (index, payload) in allPayloads.enumerated() {
            if let memoryMetrics = payload.memoryMetrics {
                let timestamp = Calendar.current.date(byAdding: .hour, value: -index, to: Date()) ?? Date()
                let memoryMB = memoryMetrics.peakMemoryUsage.converted(to: .megabytes).value
                
                memoryHistory.append(MemoryDataPoint(
                    timestamp: timestamp,
                    memoryUsage: memoryMB,
                    type: "Peak Memory"
                ))
            }
        }
        
        return memoryHistory.sorted { $0.timestamp < $1.timestamp }
    }

    func getNetworkUsageData() -> [NetworkDataPoint] {
        guard let lastPayload = allPayloads.last,
              let networkMetrics = lastPayload.networkTransferMetrics else {
            return []
        }
        
        let wifiUpload = networkMetrics.cumulativeWifiUpload.converted(to: .megabytes).value
        let wifiDownload = networkMetrics.cumulativeWifiDownload.converted(to: .megabytes).value
        let cellularUpload = networkMetrics.cumulativeCellularUpload.converted(to: .megabytes).value
        let cellularDownload = networkMetrics.cumulativeCellularDownload.converted(to: .megabytes).value
        
        return [
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
    }

    func getHistogramDataFor<T: Unit>(_ histogram: MXHistogram<T>) -> [HistogramData] {
        var histogramData: [HistogramData] = []
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
            
            histogramData.append(HistogramData(
                range: range,
                count: bucket.bucketCount,
                startValue: 0,
                endValue: 0
            ))
        }
        
        return histogramData
    }
    
    

    // MARK: - Enhanced Signpost Analysis
    func getSignpostAnalysis() -> String {
        var analysis = "📊 SIGNPOST METRICS ANALYSIS:\n"
        analysis += String(repeating: "=", count: 50) + "\n"
        
        guard let lastPayload = allPayloads.last,
              let signpostMetrics = lastPayload.signpostMetrics,
              !signpostMetrics.isEmpty else {
            analysis += "❌ No signpost metrics available\n"
            analysis += "💡 Use custom signpost methods to generate metrics\n"
            return analysis
        }
        
        for (index, signpost) in signpostMetrics.enumerated() {
            analysis += "\n🏷️ SIGNPOST #\(index + 1):\n"
            analysis += "• Category: \(signpost.signpostCategory)\n"
            analysis += "• Name: \(signpost.signpostName)\n"
            analysis += "• Total Count: \(signpost.totalCount)\n"
            
            if let intervalData = signpost.signpostIntervalData {
                analysis += "\n📈 INTERVAL DATA:\n"
                
                // Duration histogram
                let durationHistogram = intervalData.histogrammedSignpostDuration
                analysis += exportHistogramData(durationHistogram, title: "Signpost Duration")
                
                // Performance metrics
                if let avgMemory = intervalData.averageMemory {
                    analysis += "• Average Memory: \(formatMemory(avgMemory.averageMeasurement))\n"
                    analysis += "• Memory Sample Count: \(avgMemory.sampleCount)\n"
                    analysis += "• Memory Std Deviation: \(avgMemory.standardDeviation)\n"
                }
                
                if let cpuTime = intervalData.cumulativeCPUTime {
                    analysis += "• Cumulative CPU Time: \(formatDuration(cpuTime))\n"
                }
                
                if let logicalWrites = intervalData.cumulativeLogicalWrites {
                    analysis += "• Cumulative Disk Writes: \(formatMemory(logicalWrites))\n"
                }
                
                if let hitchRatio = intervalData.cumulativeHitchTimeRatio {
                    analysis += "• Hitch Time Ratio: \(hitchRatio.value) \(hitchRatio.unit)\n"
                }
            }
        }
        
        return analysis
    }

    
    
    // Add this simple crash finder to your MetricManager:
    
    // Add this simple helper to find crashes:
    func findCrashLocationInDevelopment() -> String {
        var result = "🔍 WHERE IS MY BUG?\n"
        
        for crash in crashes {
            let callStackJSON = crash.callStackTree.jsonRepresentation()
            
            do {
                if let json = try JSONSerialization.jsonObject(with: callStackJSON) as? [String: Any],
                   let callStacks = json["callStacks"] as? [[String: Any]] {
                    
                    for callStack in callStacks {
                        if let threadAttributed = callStack["threadAttributed"] as? Bool,
                           threadAttributed == true {
                            
                            if let rootFrames = callStack["callStackRootFrames"] as? [[String: Any]] {
                                for frame in rootFrames {
                                    if let binaryName = frame["binaryName"] as? String,
                                       let offset = frame["offsetIntoBinaryTextSegment"] as? Int64 {
                                        
                                        result += "🎯 CRASH FOUND:\n"
                                        result += "• Binary: \(binaryName)\n"
                                        result += "• Offset: \(offset)\n"
                                        
                                        // Tell you what type of crash
                                        if binaryName.contains("swift") {
                                            result += "• BUG TYPE: Array/nil/bounds error\n"
                                            result += "• CHECK: Your simulateCrash() function\n"
                                            result += "• LINE: let _ = array[10] ← HERE!\n"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                result += "❌ Error parsing: \(error)\n"
            }
        }
        
        return result
    }
    
    
    
    deinit {
        MXMetricManager.shared.remove(self)
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
    
    static let detailed: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
}

