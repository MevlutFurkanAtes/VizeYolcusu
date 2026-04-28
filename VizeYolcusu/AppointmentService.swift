//
//  AppointmentService.swift
//  VizeYolcusu
//
//  Created by Mevlüt Furkan Ateş on 28.04.2026.
//

import Foundation

// MARK: - DTO

struct AppointmentDTO: Decodable {
    let country:         String
    let visaType:        String
    let isAvailable:     Bool
    let confidenceScore: Double
    let lastChecked:     String
}

// MARK: - Service Errors

enum ServiceError: LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case http(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:        return "Geçersiz URL"
        case .noData:            return "Veri alınamadı"
        case .invalidResponse:   return "Geçersiz yanıt"
        case .http(let code):    return "Sunucu hatası (\(code))"
        }
    }
}

// MARK: - AppointmentService

final class AppointmentService {
    static let shared = AppointmentService()
    private init() {}

    var baseURL = "https://vizeyolcusu-api.onrender.com"

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()

    // MARK: GET /appointments

    func fetchAppointments(completion: @escaping (Result<[AppointmentDTO], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/appointments") else {
            completion(.failure(ServiceError.invalidURL))
            return
        }
        session.dataTask(with: url) { data, response, error in
            if let error { completion(.failure(error)); return }
            guard let data else { completion(.failure(ServiceError.noData)); return }
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                completion(.failure(ServiceError.http(http.statusCode)))
                return
            }
            do {
                completion(.success(try JSONDecoder().decode([AppointmentDTO].self, from: data)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: POST /report

    func sendReport(country: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/report") else {
            completion(.failure(ServiceError.invalidURL))
            return
        }
        var request        = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody   = try? JSONSerialization.data(withJSONObject: ["country": country])

        session.dataTask(with: request) { _, response, error in
            if let error { completion(.failure(error)); return }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(ServiceError.invalidResponse))
                return
            }
            (200...299).contains(http.statusCode)
                ? completion(.success(()))
                : completion(.failure(ServiceError.http(http.statusCode)))
        }.resume()
    }
}
