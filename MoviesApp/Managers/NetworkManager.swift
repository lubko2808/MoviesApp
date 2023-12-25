//
//  NetworkManager.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.08.2023.
//

import UIKit


func downloadImage(urlString: String ) async -> UIImage? {
    let urlString = "https://image.tmdb.org/t/p/w500/\(urlString)"
    
    guard let url = URL(string: urlString) else { return nil}
    
    do {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        let image = UIImage(data: data)
        return image
    } catch {
        return nil
    }
}


class NetworkManager {
    
    enum Endpoint: Equatable {
        
        case movieNowPlaying(page: Int)
        case movieUpcoming(page: Int)
        case movieTopRated(page: Int)
        case moviePopular(page: Int)
        case movieInfo(id: Int)
        case movieCast(id: Int)
        case movieTrailers(id: Int)
        case movieReviews(id: Int)
        case movieSearch(query: String, page: Int, isAdultIncluded: Bool?, year: String?)
        
        case image(imageUrl: String)
        
        var url: URL {
            var components = URLComponents()
            components.scheme = "https"
            
            if case .image = self {
                components.host = "image.tmdb.org"
            } else {
                components.host = "api.themoviedb.org"
            }
            
            components.queryItems = []
            switch self {
            case .movieNowPlaying(let page):
                components.path = "/3/movie/now_playing"
                components.queryItems?.append(URLQueryItem(name: "page", value: String(page)))
            case .movieUpcoming(let page):
                components.path = "/3/movie/upcoming"
                components.queryItems?.append(URLQueryItem(name: "page", value: String(page)))
            case .movieTopRated(let page):
                components.path = "/3/movie/top_rated"
                components.queryItems?.append(URLQueryItem(name: "page", value: String(page)))
            case .moviePopular(let page):
                components.path = "/3/movie/popular"
                components.queryItems?.append(URLQueryItem(name: "page", value: String(page)))
            case .image(let imageUrl):
                components.path = "/t/p/w500/\(imageUrl)"
            case .movieInfo(let id):
                components.path = "/3/movie/\(id)"
            case .movieCast(let id):
                components.path = "/3/movie/\(id)/credits"
            case .movieTrailers(let id):
                components.path = "/3/movie/\(id)/videos"
            case .movieReviews(let id):
                components.path = "/3/movie/\(id)/reviews"
            case .movieSearch(let query, let page, let isAdultIncluded, let year):
                components.path = "/3/search/movie"
                components.queryItems?.append(URLQueryItem(name: "query", value: query))
                components.queryItems?.append(URLQueryItem(name: "page", value: String(page)))
                if let isAdultIncluded {
                    components.queryItems?.append(URLQueryItem(name: "include_adult", value: String(isAdultIncluded)))
                }
                components.queryItems?.append(URLQueryItem(name: "primary_release_year", value: year))
            }
            
            components.queryItems?.append(URLQueryItem(name: "api_key", value: "7f798f1c6fb6a8225bffe3565f4a5ec2"))
        
            return components.url!
        }
    }
}

extension NetworkManager {
    
    func fetch<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        let urlRequest = URLRequest(url: endpoint.url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            //let response = response as? HTTPURLResponse
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(Response.self, from: data)
        return result
    }
    
    func fetchImage(from urlString: String) async -> UIImage? {
        let urlString = "https://image.tmdb.org/t/p/w500/\(urlString)"
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                return nil
            }
            let image = UIImage(data: data)
            return image
        } catch {
            return nil
        }
    }

}

