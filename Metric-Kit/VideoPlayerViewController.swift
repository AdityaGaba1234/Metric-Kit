import UIKit
import AVKit

class VideoPlayerViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎬 Video Player"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play HD Video", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Ready to play video"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var player: AVPlayer?
    private var playerVC: AVPlayerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        MetricKitManager.shared.logEvent("📱 Video Player tab loaded")
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(playButton)
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 200),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            
            statusLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
    }
    
    @objc private func playVideo() {
        statusLabel.text = "Loading HD video... (Network intensive)"
        MetricKitManager.shared.logEvent("🎬 Starting HD video playback (network/memory intensive)")
        
        guard let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {
            statusLabel.text = "❌ Invalid video URL"
            return
        }
        
        player = AVPlayer(url: url)
        playerVC = AVPlayerViewController()
        playerVC?.player = player
        
        present(playerVC!, animated: true) {
            self.player?.play()
            self.statusLabel.text = "🎬 Video playing (check network metrics)"
            MetricKitManager.shared.logEvent("📹 HD video playback started - monitoring network/CPU/memory usage")
        }
    }
}
