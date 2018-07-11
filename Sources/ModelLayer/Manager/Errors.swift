import Foundation

import RxSwift

public enum APPError : Swift.Error {
    case undefined
    case message(String)
    public var title :String {
        switch self {
        default : return "Error"
        }
        
    }
    public var message:String {
        switch self {
        case .message(let message) : return message
        default :  return "Error"
        }
        
    }
}
