//
//  NetworkManager.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.08.2023.
//

import Foundation

class DataService {
    
    enum Endpoint {
        
        case movieNowPlaying(page: Int)
        case movieUpcoming(page: Int)
        case movieTopRated(page: Int)
        case moviePopular(page: Int)
        
        var headers: [(key: String, value: String)]? {
            [(key: "api_key", value: "7f798f1c6fb6a8225bffe3565f4a5ec2")]
        }
        
        var url: URL {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.themoviedb.org"
            
            switch self {
            case .movieNowPlaying(let page):
                components.path = "/3/movie/now_playing"
                components.queryItems = [URLQueryItem(name: "page", value: String(page))]
            case .movieUpcoming(let page):
                components.path = "/3/movie/upcoming"
                components.queryItems = [URLQueryItem(name: "page", value: String(page))]
            case .movieTopRated(let page):
                components.path = "/3/movie/top_rated"
                components.queryItems = [URLQueryItem(name: "page", value: String(page))]
            case .moviePopular(let page):
                components.path = "/3/movie/popular"
                components.queryItems = [URLQueryItem(name: "page", value: String(page))]
            }
            
            return components.url!
        }
    }
}

extension DataService {
    
    func fetch<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        var urlRequest = URLRequest(url: endpoint.url)
        
        if let headers = endpoint.headers {
            for header in headers {
                urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(Response.self, from: data)
        
        return result
    }

}
