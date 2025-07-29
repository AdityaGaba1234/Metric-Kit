import UIKit

class SettingsViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "⚙️ Settings"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateInfo()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    private func updateInfo() {
        infoLabel.text = """
        📊 MetricKit Complex Test App
        
        📱 This app tests ALL MetricKit features:
        
        🏠 Dashboard: View all metrics & histograms
        🧠 Quiz: CPU-intensive tasks
        🎬 Video: Network & memory usage
        ⚙️ Tasks: CPU, memory, disk, network tests
        
        ⏰ Expected Timeline:
        • Day 1: Basic metrics
        • Day 2-3: Launch histograms appear
        • Day 4+: Rich histogram data
        
        📋 Use the app daily and check Dashboard for payload deliveries!
        
        🔥 After 24-48 hours, you'll see detailed histograms showing:
        • Launch time distributions
        • Hang time patterns
        • Memory usage patterns
        • Network usage patterns
        """
    }
}
