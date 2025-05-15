import Foundation

class ApiMathSolver {
    static func solve(_ equation: String, completion: @escaping (String) -> Void) {
        // Replace with your actual API endpoint
        let apiUrl = URL(string: "https://your-math-solver-api.com/solve")!
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["equation": equation]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion("No data received")
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let result = json["result"] as? String {
                    DispatchQueue.main.async {
                        completion(result)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion("Invalid response format")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion("Error parsing response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}