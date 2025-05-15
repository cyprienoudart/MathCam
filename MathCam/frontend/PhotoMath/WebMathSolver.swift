import Foundation
import WebKit

class WebMathSolver: NSObject, WKNavigationDelegate {
    private var webView: WKWebView!
    private var completion: ((String) -> Void)?
    
    override init() {
        super.init()
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        
        // Load math.js library
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
                        // Handle equations with =
                        if (equation.includes('=')) {
                            // Very basic equation solver
                            if (equation.includes('x')) {
                                const sides = equation.split('=');
                                if (sides.length === 2) {
                                    // Move everything to left side
                                    const expr = math.parse(sides[0] + '-(' + sides[1] + ')');
                                    // Solve for x
                                    const solution = math.solve(expr, 'x');
                                    return 'x = ' + solution;
                                }
                            }
                            return 'Cannot solve equation';
                        } else {
                            // Evaluate expression
                            return math.evaluate(equation).toString();
                        }
                    } catch (e) {
                        return 'Error: ' + e.message;
                    }
                }
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // WebView is ready
    }
    
    func solve(_ equation: String, completion: @escaping (String) -> Void) {
        self.completion = completion
        
        // Replace symbols
        var processedEquation = equation
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "−", with: "-")
            .replacingOccurrences(of: "π", with: "PI")
        
        // Escape quotes
        processedEquation = processedEquation.replacingOccurrences(of: "'", with: "\\'")
        processedEquation = processedEquation.replacingOccurrences(of: "\"", with: "\\\"")
        
        let js = "solveEquation('\(processedEquation)')"
        
        webView.evaluateJavaScript(js) { [weak self] (result, error) in
            if let error = error {
                self?.completion?("Error: \(error.localizedDescription)")
                return
            }
            
            if let result = result as? String {
                self?.completion?(result)
            } else {
                self?.completion?("Unknown result")
            }
        }
    }
}