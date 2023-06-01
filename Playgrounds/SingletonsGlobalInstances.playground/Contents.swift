import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct User: Decodable {
    let id: Int
    let login: String
    let bio: String?
}

enum CustomError: Error {
    case invalideURL
    case error
    case invalidData(_ error: Error)
    case invalidResponse(_ response: URLResponse?)
}

class ApiClient {
    static let share = ApiClient()
    private init() {}
    
    func execute<T: Decodable>(url: String) async throws -> T {
        guard let url = URL(string: url) else {
            throw CustomError.invalideURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw CustomError.invalidResponse(response)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            throw CustomError.invalidData(error)
        }
    }
    
}
func getUser(userName: String) async throws -> User {
    try await ApiClient.share.execute(url: "https://api.github.com/users/\(userName)")
}


let data = try await getUser(userName: "jaugeni")
print(data)
PlaygroundPage.current.finishExecution()
