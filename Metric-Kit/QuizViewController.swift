import UIKit

class QuizViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🧠 Quiz Challenge"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Score: 0"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let generateQuizButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate CPU-Heavy Quiz", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var currentQuestion = 0
    private var score = 0
    private let quiz = [
        ("What is 2 + 2?", ["3", "4", "5", "6"], 1),
        ("What is the capital of France?", ["London", "Berlin", "Paris", "Madrid"], 2),
        ("What is 10 * 5?", ["45", "50", "55", "60"], 1),
        ("What year was Swift released?", ["2013", "2014", "2015", "2016"], 1)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadQuestion()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(questionLabel)
        view.addSubview(optionsStackView)
        view.addSubview(scoreLabel)
        view.addSubview(generateQuizButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            questionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 30),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            scoreLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 40),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            generateQuizButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 30),
            generateQuizButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateQuizButton.widthAnchor.constraint(equalToConstant: 250),
            generateQuizButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        generateQuizButton.addTarget(self, action: #selector(generateCPUHeavyQuiz), for: .touchUpInside)
    }
    
    private func loadQuestion() {
        guard currentQuestion < quiz.count else {
            questionLabel.text = "Quiz Complete! 🎉"
            optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            return
        }
        
        let (question, options, _) = quiz[currentQuestion]
        questionLabel.text = question
        
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func optionSelected(_ sender: UIButton) {
        let (_, _, correctAnswer) = quiz[currentQuestion]
        
        if sender.tag == correctAnswer {
            score += 1
            sender.backgroundColor = .systemGreen
            MetricKitManager.shared.logEvent("✅ Quiz: Correct answer selected")
        } else {
            sender.backgroundColor = .systemRed
            MetricKitManager.shared.logEvent("❌ Quiz: Wrong answer selected")
        }
        
        scoreLabel.text = "Score: \(score)/\(quiz.count)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentQuestion += 1
            self.loadQuestion()
        }
    }
    
    @objc private func generateCPUHeavyQuiz() {
        MetricKitManager.shared.logEvent("🔥 Generating CPU-heavy quiz calculations...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            // CPU-intensive calculations
            var result = 0.0
            for i in 0..<1_000_000 {
                result += sin(Double(i)) * cos(Double(i)) * tan(Double(i))
            }
            
            // Memory allocation
            var arrays: [[Int]] = []
            for _ in 0..<200 {
                let array = Array(0..<5000)
                arrays.append(array)
            }
            
            DispatchQueue.main.async {
                MetricKitManager.shared.logEvent("✅ CPU-heavy quiz generation completed")
                self.currentQuestion = 0
                self.score = 0
                self.loadQuestion()
            }
        }
    }
}
