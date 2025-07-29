import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        
        // Initialize MetricKit Manager
        _ = MetricKitManager.shared
        MetricKitManager.shared.logEvent("🏁 Complex MetricKit Test App Started")
    }
    
    private func setupTabs() {
        // 1. MetricKit Dashboard
        let dashboardVC = MetricKitDashboardViewController()
        dashboardVC.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "chart.bar"), tag: 0)
        
        // 2. Quiz/MCQ Screen
        let quizVC = QuizViewController()
        quizVC.tabBarItem = UITabBarItem(title: "Quiz", image: UIImage(systemName: "questionmark.circle"), tag: 1)
        
        // 3. Video Player
        let videoVC = VideoPlayerViewController()
        videoVC.tabBarItem = UITabBarItem(title: "Video", image: UIImage(systemName: "play.circle"), tag: 2)
        
        // 4. Heavy Tasks
        let heavyTasksVC = HeavyTasksViewController()
        heavyTasksVC.tabBarItem = UITabBarItem(title: "Tasks", image: UIImage(systemName: "gear"), tag: 3)
        
        // 5. Settings
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 4)
        
        viewControllers = [dashboardVC, quizVC, videoVC, heavyTasksVC, settingsVC]
    }
}
