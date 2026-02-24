import Foundation
import Combine

// Protocole définissant les fonctionnalités d'un solveur mathématique
protocol MathSolverProtocol {
    func solve(_ equation: String) -> String
    func solveAsync(_ equation: String) -> AnyPublisher<String, Error>
}

// Erreurs possibles lors de la résolution
enum MathSolverError: Error {
    case invalidEquation
    case unsolvableEquation
    case networkError(String)
    case parsingError(String)
}

// Classe principale pour résoudre des équations mathématiques
class MathSolver: MathSolverProtocol {
    // Singleton pour accéder facilement au solveur
    static let shared = MathSolver()
    
    // Stratégie de résolution actuelle
    private var strategy: MathSolverStrategy
    
    // Initialisation avec la stratégie par défaut
    init(strategy: MathSolverStrategy = SwiftMathSolverStrategy()) {
        self.strategy = strategy
    }
    
    // Changer la stratégie de résolution
    func setStrategy(_ strategy: MathSolverStrategy) {
        self.strategy = strategy
    }
    
    // Résoudre une équation de manière synchrone
    func solve(_ equation: String) -> String {
        // Prétraitement de l'équation
        let processedEquation = preprocessEquation(equation)
        
        // Utiliser la stratégie actuelle pour résoudre
        return strategy.solve(processedEquation)
    }
    
    // Résoudre une équation de manière asynchrone
    func solveAsync(_ equation: String) -> AnyPublisher<String, Error> {
        // Prétraitement de l'équation
        let processedEquation = preprocessEquation(equation)
        
        // Utiliser la stratégie actuelle pour résoudre de manière asynchrone
        return strategy.solveAsync(processedEquation)
    }
    
    // Prétraitement commun des équations
    private func preprocessEquation(_ equation: String) -> String {
        return equation
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "−", with: "-")
            .replacingOccurrences(of: "π", with: "\(Double.pi)")
    }
}

// Protocole pour les différentes stratégies de résolution
protocol MathSolverStrategy {
    func solve(_ equation: String) -> String
    func solveAsync(_ equation: String) -> AnyPublisher<String, Error>
}

// Stratégie utilisant Swift natif pour résoudre les équations
class SwiftMathSolverStrategy: MathSolverStrategy {
    func solve(_ equation: String) -> String {
        // Vérifier si c'est une équation (contient =)
        if equation.contains("=") {
            return solveEquation(equation)
        } else {
            return evaluateExpression(equation)
        }
    }
    
    func solveAsync(_ equation: String) -> AnyPublisher<String, Error> {
        // Version asynchrone qui utilise la méthode synchrone
        return Future<String, Error> { promise in
            let result = self.solve(equation)
            promise(.success(result))
        }.eraseToAnyPublisher()
    }
    
    // Évaluer une expression mathématique
    private func evaluateExpression(_ expression: String) -> String {
        do {
            let expr = NSExpression(format: expression)
            if let result = expr.expressionValue(with: nil, context: nil) as? NSNumber {
                // Formater le résultat
                if result.doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                    return "\(Int(result.doubleValue))"
                } else {
                    // Vérifier si c'est proche d'une fraction simple
                    let (num, denom) = approximateFraction(result.doubleValue)
                    if denom <= 10 { // Afficher uniquement les "belles" fractions
                        return "\(num)/\(denom)"
                    }
                    return "\(result.doubleValue)"
                }
            }
        } catch {
            return "Erreur d'évaluation de l'expression"
        }
        
        return "Impossible d'évaluer l'expression"
    }
    
    // Résoudre une équation
    private func solveEquation(_ equation: String) -> String {
        // Diviser l'équation en côtés gauche et droit
        let sides = equation.split(separator: "=")
        if sides.count != 2 {
            return "Format d'équation invalide"
        }
        
        let leftSide = String(sides[0])
        let rightSide = String(sides[1])
        
        // Vérifier si l'équation contient x
        if equation.contains("x") {
            // Solveur d'équation linéaire très basique (ax+b=c)
            
            // Exemple pour 2x+3=7
            if leftSide.contains("x+") {
                let parts = leftSide.split(separator: "x+")
                if parts.count == 2, 
                   let coefficient = Double(parts[0].isEmpty ? "1" : String(parts[0])), 
                   let constant = Double(parts[1]), 
                   let rightValue = Double(rightSide) {
                    
                    let solution = (rightValue - constant) / coefficient
                    
                    // Formater le résultat
                    if solution.truncatingRemainder(dividingBy: 1) == 0 {
                        return "x = \(Int(solution))"
                    } else {
                        // Vérifier si c'est une fraction simple
                        let (num, denom) = approximateFraction(solution)
                        if denom <= 10 { // Afficher uniquement les "belles" fractions
                            return "x = \(num)/\(denom)"
                        }
                        return "x = \(solution)"
                    }
                }
            }
            
            return "Impossible de résoudre l'équation pour le moment"
        } else {
            // C'est une équation sans x, vérifier si elle est vraie
            do {
                let leftExpr = NSExpression(format: leftSide)
                let rightExpr = NSExpression(format: rightSide)
                
                if let leftValue = leftExpr.expressionValue(with: nil, context: nil) as? NSNumber,
                   let rightValue = rightExpr.expressionValue(with: nil, context: nil) as? NSNumber {
                    
                    if abs(leftValue.doubleValue - rightValue.doubleValue) < 0.0001 {
                        return "L'équation est vraie"
                    } else {
                        return "L'équation est fausse"
                    }
                }
            } catch {
                return "Erreur d'évaluation de l'équation"
            }
        }
        
        return "Impossible de résoudre l'équation"
    }
    
    // Fonction auxiliaire pour approximer un décimal en fraction
    private func approximateFraction(_ value: Double) -> (Int, Int) {
        let tolerance = 1.0E-6
        
        // Vérifier les fractions courantes
        if abs(value - 0.5) < tolerance { return (1, 2) }
        if abs(value - 0.25) < tolerance { return (1, 4) }
        if abs(value - 0.75) < tolerance { return (3, 4) }
        if abs(value - 0.33333) < tolerance { return (1, 3) }
        if abs(value - 0.66667) < tolerance { return (2, 3) }
        if abs(value - 0.2) < tolerance { return (1, 5) }
        
        // Pour les fractions plus complexes, utiliser un algorithme de fraction continue
        var x = value
        var a = floor(x)
        var h1 = 1.0
        var h2 = 0.0
        var k1 = 0.0
        var k2 = 1.0
        var h = a * h1 + h2
        var k = a * k1 + k2
        var n = 1
        
        while abs(value - h / k) > tolerance && n < 10000 {
            x = 1.0 / (x - a)
            a = floor(x)
            h2 = h1
            h1 = h
            k2 = k1
            k1 = k
            h = a * h1 + h2
            k = a * k1 + k2
            n += 1
        }
        
        return (Int(h), Int(k))
    }
}

// Stratégie utilisant une API web pour résoudre les équations
class ApiMathSolverStrategy: MathSolverStrategy {
    private let apiUrl: URL
    
    init(apiUrl: URL = URL(string: "https://api.mathcam.com/solve")!) {
        self.apiUrl = apiUrl
    }
    
    func solve(_ equation: String) -> String {
        // Version synchrone non recommandée pour les appels API
        return "Veuillez utiliser la méthode asynchrone pour les appels API"
    }
    
    func solveAsync(_ equation: String) -> AnyPublisher<String, Error> {
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["equation": equation]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            return Fail(error: MathSolverError.parsingError("Erreur de sérialisation: \(error.localizedDescription)"))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw MathSolverError.networkError("Erreur de réponse serveur")
                }
                return data
            }
            .decode(type: ApiResponse.self, decoder: JSONDecoder())
            .map { $0.result }
            .mapError { error -> Error in
                if let error = error as? MathSolverError {
                    return error
                }
                return MathSolverError.parsingError("Erreur de décodage: \(error.localizedDescription)")
            }
            .eraseToAnyPublisher()
    }
    
    // Structure pour décoder la réponse API
    private struct ApiResponse: Decodable {
        let result: String
    }
}

// Stratégie utilisant WebKit et JavaScript pour résoudre les équations
#if canImport(WebKit)
import WebKit

class WebMathSolverStrategy: NSObject, MathSolverStrategy, WKNavigationDelegate {
    private var webView: WKWebView!
    private var isReady = false
    private var pendingEquations: [(String, (Result<String, Error>) -> Void)] = []
    
    override init() {
        super.init()
        setupWebView()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        
        // Charger la bibliothèque math.js
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjs/11.0.0/math.min.js"></script>
        </head>
        <body>
            <script>
                function solveEquation(equation) {
                    try {
                        // Gérer les équations avec =
                        if (equation.includes('=')) {
                            // Solveur d'équation très basique
                            if (equation.includes('x')) {
                                const sides = equation.split('=');
                                if (sides.length === 2) {
                                    // Déplacer tout du côté gauche
                                    const expr = math.parse(sides[0] + '-(' + sides[1] + ')');
                                    // Résoudre pour x
                                    const solution = math.solve(expr, 'x');
                                    return 'x = ' + solution;
                                }
                            }
                            return 'Impossible de résoudre l\\'équation';
                        } else {
                            // Évaluer l'expression
                            return math.evaluate(equation).toString();
                        }
                    } catch (e) {
                        return 'Erreur: ' + e.message;
                    }
                }
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isReady = true
        processPendingEquations()
    }
    
    private func processPendingEquations() {
        guard isReady else { return }
        
        for (equation, completion) in pendingEquations {
            evaluateEquation(equation, completion: completion)
        }
        pendingEquations.removeAll()
    }
    
    func solve(_ equation: String) -> String {
        // Version synchrone non recommandée pour WebKit
        return "Veuillez utiliser la méthode asynchrone pour WebKit"
    }
    
    func solveAsync(_ equation: String) -> AnyPublisher<String, Error> {
        return Future<String, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(MathSolverError.parsingError("Instance WebMathSolver non disponible")))
                return
            }
            
            if self.isReady {
                self.evaluateEquation(equation) { result in
                    promise(result)
                }
            } else {
                self.pendingEquations.append((equation, promise))
            }
        }.eraseToAnyPublisher()
    }
    
    private func evaluateEquation(_ equation: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Échapper les guillemets
        var processedEquation = equation
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
        
        let js = "solveEquation('\(processedEquation)')"
        
        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                completion(.failure(MathSolverError.parsingError("Erreur JavaScript: \(error.localizedDescription)")))
                return
            }
            
            if let result = result as? String {
                completion(.success(result))
            } else {
                completion(.failure(MathSolverError.parsingError("Résultat inconnu")))
            }
        }
    }
}
#endif