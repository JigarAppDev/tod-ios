//
//  APIHandler.swift
//  TOD
//
//  Created by My Mac on 26/05/21.
//

import Foundation
import Alamofire
import Firebase
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage

class APIHandler: NSObject {
    
    static let shared: APIHandler = APIHandler()
    
    func signIn(withEmail: String, password: String, completion: @escaping ((AuthDataResult?, Error?) -> Void)) {
        Auth.auth().signIn(withEmail: withEmail, password: password) {  authResult, error in
            completion(authResult, error)
        }
    }
    
    func createUser(withEmail: String, password: String, completion: @escaping ((AuthDataResult?, Error?) -> Void)) {
        Auth.auth().createUser(withEmail: withEmail, password: password) { authResult, error in
            completion(authResult, error)
        }
    }
    
    func resetPassword(withEmail: String, completion: @escaping ((Error?) -> Void)) {
        Auth.auth().sendPasswordReset(withEmail: withEmail) { (error) in
            completion(error)
        }
    }
    
    func verifyPhoneNumber(phoneNumber: String, completion: @escaping ((String?, Error?) -> Void)) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            completion(verificationID, error)
        }
    }
    
    func addUserProfileDetails(for userID: String, documentData: [String: Any], completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.TRADIES_PROFILE)
            .document(userID)
            .setData(documentData) { (error) in
                completion(error)
            }
    }
    
    func uploadDrivingLicense(for userID: String, documentData: [String: Any], completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.TRADIES_PROFILE)
            .document(userID)
            .setData(documentData, merge: true) { (error) in
                completion(error)
            }
    }
    
    func uploadDrivingLicenseOnStorage(for userID: String, imageData: Data, imageName: String, completion: @escaping ((StorageMetadata?, Error?, URL?, Error?) -> Void)) {
        let storgaeRef = Storage.storage().reference()
            .child(URLConstants.USERS)
            .child(URLConstants.DL)
            .child(userID)
            .child(imageName)
        storgaeRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
            storgaeRef.downloadURL { (url, downlodError) in
                completion(metadata, error, url, downlodError)
            }
        })
    }
    
    func getServicesList(completion: @escaping ((QuerySnapshot?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.SERVICES_LIST)
            .getDocuments { (querySnapshot, error) in
                completion(querySnapshot, error)
            }
    }
    
    func getServiceDetails(for documentID: String, completion: @escaping ((DocumentSnapshot?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.SERVICES_LIST)
            .document(documentID)
            .getDocument(completion: { (documentSnapshot, error) in
                 completion(documentSnapshot, error)
            })
    }
    
    func addService(for userID: String, documentData: [String: Any], completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.TRADIES_SERVICES)
            .document(userID)
            .setData(documentData, merge: true) { (error) in
                completion(error)
            }
    }
    
    func uploadPermitOnStorage(for userID: String, imageData: Data, imageName: String, serviceName: String, completion: @escaping ((StorageMetadata?, Error?, URL?, Error?) -> Void)) {
        let storgaeRef = Storage.storage().reference()
            .child(URLConstants.USERS)
            .child(URLConstants.SERVICES)
            .child(userID)
            .child(serviceName)
            .child(imageName)
        storgaeRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
            storgaeRef.downloadURL { (url, downlodError) in
                completion(metadata, error, url, downlodError)
            }
        })
    }
    
    func getFAQS(completion: @escaping ((QuerySnapshot?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.FAQS)
            .getDocuments { (querySnapshot, error) in
                completion(querySnapshot, error)
            }
    }
    
    func getFAQSFromDocumentID(for documentID: String, completion: @escaping ((DocumentSnapshot?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.FAQS)
            .document(documentID)
            .getDocument { (querySnapshot, error) in
                completion(querySnapshot, error)
            }
    }
    
    func getProfileDetails(for userID: String, completion: @escaping ((DocumentSnapshot?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.TRADIES_PROFILE)
            .document(userID)
            .getDocument { (documentSnapshot, error) in
                completion(documentSnapshot, error)
            }
    }
    
    func editProfileDetails(for userID: String, documentData: [String: Any], completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.TRADIES_PROFILE)
            .document(userID)
            .setData(documentData, merge: true) { (error) in
                completion(error)
            }
    }
    
    func getTradiesService(userID: String, completion: @escaping (( [String:Any]?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.TRADIES_SERVICES)
            .document(userID)
            .getDocument(completion: { (value, error) in
                let val = value?.data()
                if let service = val?[ApiParameterStatics.service] as? [String:Any] {
                    completion(service, error)
                } else {
                    completion([:],error)
                }
            })
    }
    
    func getProfileData(userID: String, completion: @escaping (( [String:Any]?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.TRADIES_PROFILE)
            .document(userID)
            .getDocument(completion: { (value, error) in
                if let val = value?.data() {
                    completion(val, error)
                } else {
                    completion([:],error)
                }
                
            })
    }
    
    func getActiveTradiesServic(completion: @escaping ((QuerySnapshot?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.ACTIVE_TRADIES)
            .getDocuments { (querySnapshot, error) in
                completion(querySnapshot, error)
            }
        
    }
    
    func getActiveTradiesServices(for documentID: String, userID: String, completion: @escaping ((DocumentSnapshot?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.ACTIVE_TRADIES)
            .document(documentID)
            .collection(URLConstants.AU)
            .document(userID)
            .getDocument { (documentSnapshot, error) in
                completion(documentSnapshot, error)
            }
    }
    
    
    func updateActiveTradiesServices(forDocumentID documentID: String, forUserID userID: String, with documentData: [String: Any], completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.ACTIVE_TRADIES)
            .document(documentID)
            .collection(URLConstants.AU)
            .document(userID)
            .setData(documentData, merge: true) { (error) in
                completion(error)
            }
    }
    
    func makeCall(with url: URL, parameters: [String: Any], headers: HTTPHeaders, completion: @escaping (([String: Any]?, Error?) -> Void)) {
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate(statusCode: 200...504)
            .responseJSON { (response) in
                
                switch response.result {
                case .success(let json):
                    if let json = json as? [String: Any] {
                        completion(json, nil)
                    }
                case .failure(let error):
                    completion(nil, error)
                    
                }
                
            }
    }
    
    func addQueries(forUserID userID: String, with documentData: [String: Any], completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.QUERIES)
            .document(userID)
            .setData(documentData, merge: true) { (error) in
            completion(error)
        }
    }
    
    func getJobDetail(userID:String ,completion: @escaping (( QuerySnapshot?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.JOBS)
            .getDocuments(completion: { (value, error) in
                completion(value,error)
            })
    }
    
    func updateJobStatus(jobId:String,data:[String:Any], completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.JOBS)
            .document(jobId)
            .setData(data, merge: true){ (error) in
                completion(error)
            }
    }

    func signOut() -> Bool {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            return true
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            return false
        }
    }
    
    func verifyOtp(credential:AuthCredential , completion: @escaping ((AuthDataResult?, Error?) -> Void)) {
        Auth.auth().currentUser?.link(with: credential, completion: { (authResult, error) in
            completion(authResult,error)
        })
    }
    
    func getTwilioClient(for userID:String, completion: @escaping ((DocumentSnapshot?, Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.TRADIES_TWILIO_CLIENT)
            .document(userID)
            .getDocument { (documentSnapshot, error) in
                completion(documentSnapshot, error)
            }
    }
    
    func callAccessTokenAPI(with url: URL, parameters: [String: Any], completion: @escaping (String) -> Void) {
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default)
            .responseJSON { (dataResponse) in
                if let response = dataResponse.value as? [String: Any] {
                    if let token = response[ApiParameterStatics.token_ios] as? String {
                        completion(token)
                    }
                }
            }
    }

    
    func updateOpportunity(for opportunityID: String, documentData: [String: Any], completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.OPPORTUNITY)
            .document(opportunityID)
            .setData(documentData, merge: true) { (error) in
                completion(error)
            }
    }
    
    func updateActiveTradiesLocation(userID:String, serviceName:String, data:[String:Any], completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore()
            .collection(URLConstants.V1)
            .document(URLConstants.TRADIES)
            .collection(URLConstants.ACTIVE_TRADIES)
            .document(serviceName)
            .collection(URLConstants.AU)
            .document(userID)
            .setData(data, merge: true){ (error) in
                completion(error)
            }
    }
    
    func getTwilioAccessTokenFromCloudFunction(data: [String:Any], completion: @escaping ((HTTPSCallableResult?, Error?) -> Void)) {
        Functions.functions()
            .httpsCallable(URLConstants.GET_TWILIO_ACCESS_TOKEN)
            .call(data) { (httpScallableResult, error) in
                completion(httpScallableResult, error)
            }
    }
    
}
