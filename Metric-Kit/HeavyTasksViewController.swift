import UIKit

class HeavyTasksViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "⚙️ Heavy Tasks"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createTaskButtons()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func createTaskButtons() {
        let tasks = [
            ("🔥 CPU Burn Test", #selector(cpuBurnTest)),
            ("💾 Memory Allocation", #selector(memoryAllocationTest)),
            ("💽 Disk Write Test", #selector(diskWriteTest)),
            ("🌐 Network Download", #selector(networkDownloadTest)),
            ("🔄 Combined Stress Test", #selector(combinedStressTest))
        ]
        
        for (title, action) in tasks {
            let button = createTaskButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func createTaskButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func cpuBurnTest() {
        MetricKitManager.shared.logEvent("🔥 Starting CPU burn test...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let startTime = CFAbsoluteTimeGetCurrent()
            var result = 0.0
            
            for i in 0..<5_000_000 {
                result += sin(Double(i)) * cos(Double(i)) * tan(Double(i)) * log(Double(i + 1))
            }
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            
            DispatchQueue.main.async {
                MetricKitManager.shared.logEvent("✅ CPU burn test completed in \(String(format: "%.2f", timeElapsed))s")
            }
        }
    }
    
    @objc private func memoryAllocationTest() {
        MetricKitManager.shared.logEvent("💾 Starting memory allocation test...")
        
        DispatchQueue.global(qos: .background).async {
            var arrays: [[Int]] = []
            
            for i in 0..<500 {
                let array = Array(0..<20000)
                arrays.append(array)
                
                if i % 100 == 0 {
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
            
            DispatchQueue.main.async {
                MetricKitManager.shared.logEvent("✅ Memory allocation test completed (allocated \(arrays.count) arrays)")
            }
        }
    }
    
    @objc private func diskWriteTest() {
        MetricKitManager.shared.logEvent("💽 Starting disk write test...")
        
        DispatchQueue.global(qos: .utility).async {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            for i in 0..<100 {
                let fileName = "test_file_\(i).txt"
                let fileURL = documentsPath.appendingPathComponent(fileName)
                let data = String(repeating: "MetricKit Test Data ", count: 1000).data(using: .utf8)!
                
                try? data.write(to: fileURL)
            }
            
            DispatchQueue.main.async {
                MetricKitManager.shared.logEvent("✅ Disk write test completed (wrote 100 files)")
            }
        }
    }
    
    @objc private func networkDownloadTest() {
        MetricKitManager.shared.logEvent("🌐 Starting network download test...")
        
        let urls = [
            "https://httpbin.org/bytes/1024",
            "https://httpbin.org/bytes/2048",
            "https://httpbin.org/bytes/4096"
        ]
        
        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let data = data {
                        MetricKitManager.shared.logEvent("📥 Downloaded \(data.count) bytes from network")
                    }
                }
            }.resume()
        }
    }
    
    @objc private func combinedStressTest() {
        MetricKitManager.shared.logEvent("🔄 Starting combined stress test (CPU + Memory + Disk + Network)...")
        
        // CPU
        cpuBurnTest()
        
        // Memory (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.memoryAllocationTest()
        }
        
        // Disk (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.diskWriteTest()
        }
        
        // Network (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.networkDownloadTest()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            MetricKitManager.shared.logEvent("✅ Combined stress test completed!")
        }
    }
}
