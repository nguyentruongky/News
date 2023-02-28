import Alamofire
import Foundation
import UIKit

struct ApiConnector {
    static fileprivate var connector = AlamofireConnector()
    static private func getHeaders() -> [String: String]? {
        var headers = [
            "Content-Type": "application/json"
        ]
        return headers
    }
    private static func getUrl(from api: String) -> URL? {
        let baseUrl = AppConfig.baseUrl
        let apiUrl = api.contains("http") ? api : baseUrl + api
        return URL(string: apiUrl)
    }

    static private func request(_ api: String,
                                method: HTTPMethod,
                                params: [String: Any]? = nil,
                                headers: [String: String]? = nil,
                                success: @escaping (_ result: AnyObject) -> Void,
                                fail: ((_ error: KNError) -> Void)? = nil) {
        let finalHeaders = headers ?? getHeaders()
        let apiUrl = getUrl(from: api)
        connector.request(withApi: apiUrl,
                          method: method,
                          params: params,
                          headers: finalHeaders,
                          onSuccess: success,
                          onFailure: fail)
    }

    static private func request(_ api: String,
                                method: HTTPMethod,
                                params: [String: Any]? = nil,
                                headers: [String: String]? = nil,
                                returnData: @escaping (Data) -> Void,
                                fail: ((_ error: KNError) -> Void)? = nil) {
        let finalHeaders = headers ?? getHeaders()
        let apiUrl = getUrl(from: api)
        connector.request(withApi: apiUrl,
                          method: method,
                          params: params,
                          headers: finalHeaders,
                          onSuccessWithData: returnData,
                          onFailure: fail)
    }

    static func get(_ api: String,
                    params: [String: Any]? = nil,
                    headers: [String: String]? = nil,
                    success: @escaping (_ result: AnyObject) -> Void,
                    fail: ((_ error: KNError) -> Void)? = nil) {
        request(api,
                method: .get,
                params: params,
                headers: headers,
                success: success,
                fail: fail)
    }

    static func get(_ api: String,
                    params: [String: Any]? = nil,
                    headers: [String: String]? = nil,
                    returnData: @escaping (Data) -> Void,
                    fail: ((_ error: KNError) -> Void)? = nil) {
        request(api, method: .get,
                params: params,
                headers: headers,
                returnData: returnData,
                fail: fail)
    }

    static func put(_ api: String,
                    params: [String: Any]? = nil,
                    headers: [String: String]? = nil,
                    success: @escaping (_ result: AnyObject) -> Void,
                    fail: ((_ error: KNError) -> Void)? = nil) {
        request(api,
                method: .put,
                params: params,
                headers: headers,
                success: success,
                fail: fail)
    }

    static func put(_ api: String,
                    params: [String: Any]? = nil,
                    headers: [String: String]? = nil,
                    returnData: @escaping (Data) -> Void,
                    fail: ((_ error: KNError) -> Void)? = nil) {
        request(api,
                method: .put,
                params: params,
                headers: headers,
                returnData: returnData,
                fail: fail)
    }

    static func post(_ api: String,
                     params: [String: Any]? = nil,
                     headers: [String: String]? = nil,
                     success: @escaping (_ result: AnyObject) -> Void,
                     fail: ((_ error: KNError) -> Void)? = nil) {
        request(api,
                method: .post,
                params: params,
                headers: headers,
                success: success,
                fail: fail)
    }

    static func post(_ api: String,
                     params: [String: Any]? = nil,
                     headers: [String: String]? = nil,
                     returnData: @escaping (Data) -> Void,
                     fail: ((_ error: KNError) -> Void)? = nil) {
        request(api,
                method: .post,
                params: params,
                headers: headers,
                returnData: returnData,
                fail: fail)
    }

    static func delete(_ api: String,
                       params: [String: Any]? = nil,
                       headers: [String: String]? = nil,
                       success: @escaping (_ result: AnyObject) -> Void,
                       fail: ((_ error: KNError) -> Void)? = nil) {
        request(api, method: .delete, params: params, headers: headers, success: success, fail: fail)
    }

    static func delete(_ api: String,
                       params: [String: Any]? = nil,
                       headers: [String: String]? = nil,
                       returnData: @escaping (Data) -> Void,
                       fail: ((_ error: KNError) -> Void)? = nil) {
        request(api,
                method: .delete,
                params: params,
                headers: headers,
                returnData: returnData,
                fail: fail)
    }

    static func download(url: URL, fileName: String, completion: @escaping(URL?) -> Void) {
        let destination: DownloadRequest.Destination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL = documentsURL.appendingPathComponent("infinidus/media/\(fileName)")
            return (documentsURL, [.removePreviousFile])
        }
        AF.download(url, to: destination).responseData { response in
            if let destinationUrl = response.fileURL {
                completion(destinationUrl)
            }
        }
    }
}

struct AlamofireConnector {
    func request(withApi api: URL?,
                 method: HTTPMethod,
                 params: [String: Any]? = nil,
                 headers: [String: String]? = nil,
                 onSuccess: @escaping (_ result: AnyObject) -> Void,
                 onFailure: ((_ error: KNError) -> Void)?) {

        guard let api = api else { return }
        let encoding: ParameterEncoding = method == .get ? URLEncoding.queryString : JSONEncoding.default
        let mappedHeaders = headers != nil ? HTTPHeaders(headers!) : HTTPHeaders()
        AF.request(api, method: method,
                          parameters: params, encoding: encoding,
                          headers: mappedHeaders)
        .responseJSON(emptyResponseCodes: [200, 201]) { (returnData) in
                let url = returnData.request?.url?.absoluteString ?? ""
                print(url)
                print("=====")
//                print(returnData.result)
                print("=====")

                if returnData.response?.statusCode == 401 {
                    handle401()
                    return
                }

                switch returnData.result {
                case .success(let data):
                    onSuccess(data as AnyObject)
                case .failure(let error):
                    onFailure?(KNError(error: error))
                }

        }
    }

    func handle401() {
    }

    func request(withApi api: URL?,
                 method: HTTPMethod,
                 params: [String: Any]? = nil,
                 headers: [String: String]? = nil,
                 onSuccessWithData onSuccess: @escaping (Data) -> Void,
                 onFailure: ((_ error: KNError) -> Void)?) {
        guard let api = api else { return }
        let encoding: ParameterEncoding = method == .get ? URLEncoding.httpBody : JSONEncoding.default
        let mappedHeaders = headers != nil ? HTTPHeaders(headers!) : HTTPHeaders()

        AF.request(api, method: method,
                          parameters: params, encoding: encoding,
                          headers: mappedHeaders)
            .responseData(completionHandler: { rawData in
                let url = rawData.request?.url?.absoluteString ?? ""
                print(url)
                if rawData.response?.statusCode == 401 {
//                    handle401()
                    return
                }

                switch rawData.result {
                case .success(let data):
                    if rawData.response?.statusCode ?? 200 > 300 {
                        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                        let message = json?["message"] as? String ?? "Something went wrong"
                        onFailure?(KNError(message: message))
                    } else {
                        onSuccess(data)
                    }
                case .failure(let error):
                    onFailure?(KNError(error: error))
                }
            })
    }
}

struct KNError {
    let errorType: String
    let message: String?
    let rawData: Any?
    var displayMessage: String? {
        return message
    }

    init(message: String) {
        errorType = "custom"
        self.message = message
        rawData = nil
    }

    init(error: AFError) {
        if error.isSessionDeinitializedError {
            errorType = ErrorType.sessionDeinitialized.rawValue
        } else if error.isSessionInvalidatedError {
            errorType = ErrorType.sessionInvalidated.rawValue
        } else if error.isExplicitlyCancelledError {
            errorType = ErrorType.explicitlyCancelled.rawValue
        } else if error.isInvalidURLError {
            errorType = ErrorType.invalidURL.rawValue
        } else if error.isParameterEncoderError || error.isParameterEncodingError {
            errorType = ErrorType.parameterEncodingFailed.rawValue
        } else if error.isMultipartEncodingError {
            errorType = ErrorType.multipartEncodingFailed.rawValue
        } else if error.isRequestAdaptationError {
            errorType = ErrorType.requestAdaptationFailed.rawValue
        } else if error.isResponseValidationError {
            errorType = ErrorType.responseValidationFailed.rawValue
        } else if error.isResponseSerializationError {
            errorType = ErrorType.responseSerializationFailed.rawValue
        } else if error.isRequestRetryError {
            errorType = ErrorType.requestRetryFailed.rawValue
        } else if error.isCreateUploadableError {
            errorType = ErrorType.createUploadableFailed.rawValue
        } else if error.isCreateURLRequestError {
            errorType = ErrorType.createURLRequestFailed.rawValue
        } else if error.isDownloadedFileMoveError {
            errorType = ErrorType.downloadedFileMoveFailed.rawValue
        } else if error.isSessionTaskError {
            errorType = ErrorType.sessionTaskFailed.rawValue
        } else {
            errorType = "unknown"
        }

        message = error.failureReason
        rawData = error.localizedDescription
    }

    enum ErrorType: String {
        case sessionDeinitialized
        case sessionInvalidated
        case explicitlyCancelled
        case invalidURL
        case parameterEncodingFailed
        case multipartEncodingFailed
        case requestAdaptationFailed
        case responseValidationFailed
        case responseSerializationFailed
        case requestRetryFailed
        case createUploadableFailed
        case createURLRequestFailed
        case downloadedFileMoveFailed
        case sessionTaskFailed
    }
}
