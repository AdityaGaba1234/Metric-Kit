//import UIKit
//
//class SettingsViewController: UIViewController {
//    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "⚙️ Settings"
//        label.font = UIFont.boldSystemFont(ofSize: 24)
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let infoLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        updateInfo()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(titleLabel)
//        view.addSubview(infoLabel)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
//            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
//        ])
//    }
//    
//    private func updateInfo() {
//        infoLabel.text = """
//        📊 MetricKit Complex Test App
//        
//        📱 This app tests ALL MetricKit features:
//        
//        🏠 Dashboard: View all metrics & histograms
//        🧠 Quiz: CPU-intensive tasks
//        🎬 Video: Network & memory usage
//        ⚙️ Tasks: CPU, memory, disk, network tests
//        
//        ⏰ Expected Timeline:
//        • Day 1: Basic metrics
//        • Day 2-3: Launch histograms appear
//        • Day 4+: Rich histogram data
//        
//        📋 Use the app daily and check Dashboard for payload deliveries!
//        
//        🔥 After 24-48 hours, you'll see detailed histograms showing:
//        • Launch time distributions
//        • Hang time patterns
//        • Memory usage patterns
//        • Network usage patterns
//        """
//    }
//}

import UIKit

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private enum SettingsSection: Int, CaseIterable {
        case actions
        case data
        case about
        
        var title: String {
            switch self {
            case .actions: return "Actions"
            case .data: return "Data Management"
            case .about: return "About"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = UIColor.systemGroupedBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let settingsSection = SettingsSection(rawValue: section) else { return 0 }
        
        switch settingsSection {
        case .actions: return 4
        case .data: return 3
        case .about: return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingsSection(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard let settingsSection = SettingsSection(rawValue: indexPath.section) else {
            return cell
        }
        
        switch settingsSection {
        case .actions:
            configureActionCell(cell, for: indexPath.row)
        case .data:
            configureDataCell(cell, for: indexPath.row)
        case .about:
            configureAboutCell(cell, for: indexPath.row)
        }
        
        return cell
    }
    
    private func configureActionCell(_ cell: UITableViewCell, for row: Int) {
        switch row {
        case 0:
            cell.textLabel?.text = "💥 Simulate Crash"
            cell.textLabel?.textColor = UIColor.systemRed
        case 1:
            cell.textLabel?.text = "🔒 Simulate Hang"
            cell.textLabel?.textColor = UIColor.systemOrange
        case 2:
            cell.textLabel?.text = "🔥 Simulate CPU Exception"
            cell.textLabel?.textColor = UIColor.systemPurple
        case 3:
            cell.textLabel?.text = "💽 Simulate Disk Exception"
            cell.textLabel?.textColor = UIColor.systemBlue
        default:
            break
        }
        cell.accessoryType = .disclosureIndicator
    }
    
    private func configureDataCell(_ cell: UITableViewCell, for row: Int) {
        switch row {
        case 0:
            cell.textLabel?.text = "📤 Export All Data"
            cell.textLabel?.textColor = UIColor.systemBlue
        case 1:
            cell.textLabel?.text = "💾 Save Data to Storage"
            cell.textLabel?.textColor = UIColor.systemGreen
        case 2:
            cell.textLabel?.text = "🧹 Clear All Data"
            cell.textLabel?.textColor = UIColor.systemRed
        default:
            break
        }
        cell.accessoryType = .disclosureIndicator
    }
    
    private func configureAboutCell(_ cell: UITableViewCell, for row: Int) {
        switch row {
        case 0:
            cell.textLabel?.text = "📱 App Version"
            cell.detailTextLabel?.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            cell.selectionStyle = .none
        case 1:
            cell.textLabel?.text = "🔧 MetricKit Version"
            cell.detailTextLabel?.text = "iOS 13.0+"
            cell.selectionStyle = .none
        default:
            break
        }
        cell.accessoryType = .none
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let settingsSection = SettingsSection(rawValue: indexPath.section) else { return }
        
        switch settingsSection {
        case .actions:
            handleActionSelection(row: indexPath.row)
        case .data:
            handleDataSelection(row: indexPath.row)
        case .about:
            break // No actions for about section
        }
    }
    
    private func handleActionSelection(row: Int) {
        let manager = MetricKitManager.shared
        
        switch row {
        case 0:
            showConfirmationAlert(
                title: "💥 Simulate Crash",
                message: "This will intentionally crash the app for testing. Continue?",
                destructiveAction: "Crash App"
            ) {
                manager.simulateCrash()
            }
        case 1:
            showConfirmationAlert(
                title: "🔒 Simulate Hang",
                message: "This will freeze the app for 5 seconds. Continue?",
                destructiveAction: "Freeze App"
            ) {
                manager.simulateHang()
            }
        case 2:
            manager.simulateCPUException()
            showSuccessAlert(title: "🔥 CPU Exception Started", message: "High CPU usage simulation is running in background.")
        case 3:
            manager.simulateDiskWriteException()
            showSuccessAlert(title: "💽 Disk Exception Started", message: "Heavy disk writing simulation is running.")
        default:
            break
        }
    }
    
    private func handleDataSelection(row: Int) {
        let manager = MetricKitManager.shared
        
        switch row {
        case 0:
            exportAllData()
        case 1:
            manager.saveMetricsToStorage()
            showSuccessAlert(title: "💾 Data Saved", message: "Metrics data has been saved to device storage.")
        case 2:
            showConfirmationAlert(
                title: "🧹 Clear All Data",
                message: "This will permanently delete all stored metrics and diagnostics. This action cannot be undone.",
                destructiveAction: "Clear Data"
            ) {
                manager.clearAllStoredData()
                self.showSuccessAlert(title: "🧹 Data Cleared", message: "All stored data has been cleared.")
            }
        default:
            break
        }
    }
    
    private func exportAllData() {
        let manager = MetricKitManager.shared
        
        let exportData = """
        📊 COMPLETE METRICKIT EXPORT
        ===========================
        
        \(manager.getMetricsSummary())
        
        \(manager.getCrashReport())
        
        \(manager.getDetailedCallStackAnalysis())
        
        \(manager.getHistogramAnalysis())
        
        \(manager.getDetailedMetadataReport())
        
        Generated: \(DateFormatter.detailed.string(from: Date()))
        """
        
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
    
    private func showConfirmationAlert(title: String, message: String, destructiveAction: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: destructiveAction, style: .destructive) { _ in
            completion()
        })
        
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
