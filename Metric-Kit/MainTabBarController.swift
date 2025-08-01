import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
     //   customizeAppearance()
    }
    
    private func setupTabs() {
        // Advanced Dashboard
        let advancedDashboard = AdvancedDashboardViewController()
        let advancedNav = UINavigationController(rootViewController: advancedDashboard)
        advancedNav.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")
        )
        
        // Detailed Analytics
        let analyticsVC = DetailedAnalyticsViewController()
        let analyticsNav = UINavigationController(rootViewController: analyticsVC)
        analyticsNav.tabBarItem = UITabBarItem(
            title: "Analytics",
            image: UIImage(systemName: "chart.bar.xaxis"),
            selectedImage: UIImage(systemName: "chart.bar.xaxis.fill")
        )
        
        // Call Stack Analyzer
        let callStackVC = CallStackAnalyzerViewController()
        let callStackNav = UINavigationController(rootViewController: callStackVC)
        callStackNav.tabBarItem = UITabBarItem(
            title: "Call Stacks",
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )
        
        // Settings & Export
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear.fill")
        )
        
        viewControllers = [advancedNav, analyticsNav, callStackNav, settingsNav]
    }
    
    private func customizeAppearance() {
        // Tab bar appearance
        tabBar.backgroundColor = UIColor.systemBackground
        tabBar.tintColor = UIColor.systemBlue
        tabBar.unselectedItemTintColor = UIColor.systemGray
        
        // Navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
