//
//  APIManager.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/16.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper
import UIKit
import SystemConfiguration

class APIManager {
    
    // 註冊
    static func register(account: String,
                         password: String,
                         name: String, result: @escaping(Result<Bool, Error>) -> Void) {
        
        let params = ["account": account, "password": password, "name": name]
        let url = "https://rostercake-337301.de.r.appspot.com/api/Auth/register"
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: nil).response {
            response in
            switch response.result {
                
            case .success(_):
                
                result(.success(true))
                
            case .failure(let error):

                result(.failure(error))
                
            }
        }
    }

    
    // 登入
    static func singIn(userAccount: String, userPassword: String, singInResult: @escaping (Result< SingInData, Error>) -> Void) {
        
        let params = ["account": userAccount, "password": userPassword]
        let url = "https://rostercake-337301.de.r.appspot.com/api/Auth/login"
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                if let data = data {
                    let tokenString = String(data: data, encoding: .utf8) ?? ""
                    
                    if KeychainWrapper.standard.set(tokenString, forKey: "tokenKey") {
                        
                        print("token儲存成功:\(tokenString)")
                    }
                    if KeychainWrapper.standard.set(userAccount, forKey: "accountKey"),
                        KeychainWrapper.standard.set(userPassword, forKey: "passwordKey") {
                        
                        print("帳號/密碼儲存成功"
                        )
                    }
                    print("SingIn成功")
                    
                    // 取得token 索取會員資料
                    getUserInformation() {
                        result in
                        switch result {
                            
                        case .success(let data):
                            
                            singInResult(.success(data))
                            
                        case .failure(let error):
                            
                            singInResult(.failure(error))
                        }
                    }
                }
                
            case .failure(let error):
                print("SingIn錯誤： \(error)")
            }
        }
        
    }
    
    // 取得會員資料
    private static func getUserInformation(result: @escaping(Result<SingInData, Error>) -> Void) {

        let url = "https://rostercake-337301.de.r.appspot.com/api/Auth/UserInformation"
        
        // 先抓取token
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
                  print("[getUserInformation]找不到token")
                  return
        }
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    print("[getUserInformation] 失敗：資料為空")
                    return
                }
                guard let object = try? JSONDecoder().decode(SingInData.self, from: data) else {
                    print("[getUserInformation] 失敗：轉換失敗")
                    return
                }
                
                print("[getUserInformation] 成功：\(object)")
                result(.success(object))
                
                
            case .failure(let error):
                
                print("[getUserInformation] 失敗：\(error)")
                result(.failure(error))
            }
        }
    }
    
    // 修改帳號個人資料
    static func editUserInfo(accountId: Int,
                             name: String,
                             phone: String,
                             email: String,
                             result: @escaping(Result<EditUserInfoData, Error>) -> Void) {

        let url = "https://rostercake-337301.de.r.appspot.com/api/Auth/editUserInfo"

        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let account = KeychainWrapper.standard.string(forKey: "accountKey"),
                let password = KeychainWrapper.standard.string(forKey: "passwordKey") else {
                    
            print("[editUserInfo]找不到token 或 account 或 password")
            return
        }
        
        let params = ["id": accountId,
                      "account1": account,
                      "password": password,
                      "name": name,
                      "phone": phone,
                      "email": email] as [String: Any]
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                guard let data = data else {
                    
                    print("[editUserInfo] 無資料")
                    return
                }
                
                guard let editUserInfoResult = try? JSONDecoder().decode(EditUserInfoData.self, from: data) else {
                    
                    print("[editUserInfo] 解析失敗")
                    return
                }
                
                print("[editUserInfo] 成功")
                result(.success(editUserInfoResult))
                
                
            case .failure(let error):
                
                result(.failure(error))
                
            }
        }
    }
    
    // 檢查帳號是否有群組
    static func checkGroup(result: @escaping(Result<[JoinGroupListData], Error>) -> Void) {

        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/joinGroupList"

        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            print("[checkGroup]找不到token")
            return
        }
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    
                    result(.success([JoinGroupListData]()))
                    print("[checkGroup] 無群組")
                    return
                }
                
                guard let groupList = try? JSONDecoder().decode([JoinGroupListData].self, from: data) else {
                    
                    print("[checkGroup] 解析失敗")
                    return
                }
            
                // 存下第一個groupName（預設）與 groupId 後續要用於將其他人加入此群組
                guard KeychainWrapper.standard.set(groupList[0].groupName, forKey: "nowGroupNameKey"),
                      KeychainWrapper.standard.set(groupList[0].groupId, forKey: "nowGroupIdKey") else {
                    
                    print("[checkGroup] 儲存失敗")
                    return
                }
                
                print("目前所在groupName：\(groupList[0].groupName) 儲存成功")
                print("目前所在groupId：\(groupList[0].groupId) 儲存成功")
                result(.success(groupList))
                
                
            case .failure(let error):
                result(.failure(error))
                print("[checkGroup] 失敗：\(error)")
            }
        }
    }
    
    // 創建群組
    static func creatGroup(groupName: String, result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/createGroup"
        let params = ["groupName": groupName]
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            print("[creatGroup]找不到token")
            return
        }
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
            case .success(_):
                
                print("[creatGroup] 成功")
                
                // 將目前所在群組存起來
                if KeychainWrapper.standard.set(groupName, forKey: "nowGroupNameKey") {
                    
                    print("新群組名稱：\(groupName) 儲存成功")
                }
                
                result(.success(true))
                
            case .failure(let error):
                
                print("[creatGroup] 失敗：\(error)")
                result(.failure(error))
                
            }
        }
    }
    
    //  取得帳號id
    static func getAccountId(account: String, result: @escaping(Result<Int, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/getAccountId"
        let params = ["account": account]
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            print("[getAccountId]找不到token")
            return
        }
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    print("[getAccountId] 無ID")
                    return
                }
                
                guard let accountId = try? JSONDecoder().decode(Int.self, from: data) else {
                    print("[getAccountId] 解析失敗")
                    return
                }
                
                print("[getAccountId] 取得帳號ID：\(accountId)")
                result(.success(accountId))
        
            case .failure(let error):
                result(.failure(error))
            }
        }
    }
    
    // 檢查帳號是否有主管權限
    static func getIsCompanyDirector() {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/getIsCompanyDirector"
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            
            print("[getIsCompanyDirector]找不到token")
            return
        }
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[getIsCompanyDirector] 資料為空")
                    return
                }
                
                guard let resultBool = try? JSONDecoder().decode(Bool.self, from: data) else {
                    
                    print("[getIsCompanyDirector] 解析失敗")
                    return
                }
                
                // 將目前帳號是否主管權限記錄下來
                if resultBool == true {
                    
                    if KeychainWrapper.standard.set(resultBool, forKey: "isCompanyDirectorKey") {
                        print("[getIsCompanyDirector] 有主管權限")
                    }
                    
                }else {
                    
                    if KeychainWrapper.standard.set(resultBool, forKey: "isCompanyDirectorKey") {
                        print("[getIsCompanyDirector] 沒有主管權限")
                    }
                }
                
            case .failure(let error):
                
                print("[getIsCompanyDirector] 失敗\(error)")
            }
        }
    }
    
    
    // 將其他人加入群組
    static func inviteGroup(accountId: Int, groupId: Int, result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/inviteGroup"
        let params = ["accountId": accountId, "groupId": groupId]
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            
            print("[inviteGroup]找不到token")
            return
        }
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[inviteGroup] 無資料")
                    return
                }
                
                let inviteGroupResult = String(data: data, encoding: .utf8) ?? ""
                
                if inviteGroupResult == "Successed" {
                    
                    print("[inviteGroup] 成功加入群組")
                    result(.success(true))
                    
                }else {
                    
                    print("[inviteGroup] 加入群組失敗")
                    result(.success(false))
                }

            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 將其他人移出群組
    static func removeGroupMember(accountId: Int, groupId: Int, result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/removeGroupMember"
        let params = ["accountId": accountId, "groupId": groupId]
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            
            print("[removeGroupMember]找不到token")
            return
        }
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[removeGroupMember] 無資料")
                    return
                }
                
                let removeGroupMemberResult = String(data: data, encoding: .utf8) ?? ""
                
                if removeGroupMemberResult == "Successed" {
                    
                    print("[removeGroupMember] 成功移出群組")
                    result(.success(true))
                    
                }else {
                    
                    print("[removeGroupMember] 移出群組失敗")
                    result(.success(false))
                }

            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 自己退出群組
    static func quitGroup(result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/quitGroup"
                
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let nowGroupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
            
            print("[quitGroup]找不到token或nowGroupId")
            return
        }
        
        let params = ["groupId": nowGroupId]
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[quitGroup] 無資料")
                    return
                }
                
                let quitGroupResult = String(data: data, encoding: .utf8) ?? ""
                
                if quitGroupResult == "Successed" {
                    
                    print("[quitGroup] 成功退出群組")
                    result(.success(true))
                    
                }else {
                    
                    print("[quitGroup] 退出群組失敗")
                    result(.success(false))
                }
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    
    // 列出群組內所有成員 （帳號 與 名稱）
    static func getAllgroupMember(groupId: Int, result: @escaping(Result<[GetAllGroupMemberData], Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/getAllgroupMember"
        let params = ["groupId": groupId]
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            
            print("[inviteGroup]找不到token")
            return
        }
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[getAllgroupMember] 資料為空")
                    return
                }
                
                guard let allGroupMemberList = try? JSONDecoder().decode([GetAllGroupMemberData].self, from: data) else {
                    
                    print("[getAllgroupMember] 解析失敗")
                    return
                }
                
                print("[getAllgroupMember] 成功取得群組成員清單")
                result(.success(allGroupMemberList))
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 取得群組內所有標籤
    static func allLabelInGroup(result: @escaping(Result<[LabelData], Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/allLabelInGroup"
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
            
            print("[allLabelInGroup]找不到token或nowGroupId")
            return
        }
        
        let params = ["groupId": groupId]
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[allLabelInGroup] 資料為空")
                    return
                }
                
                guard let labelInGroupList = try? JSONDecoder().decode([LabelData].self, from: data) else {
                    
                    print("[allLabelInGroup] 解析失敗")
                    return
                }
                
                print("[allLabelInGroup] 成功取得群組內標籤清單")
                result(.success(labelInGroupList))
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 新增 或 編輯 標籤
    static func groupAddNewLabel(labelId: Int?, labelName: String, result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/groupAddNewLabel"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
            
            print("[groupAddNewLabel]找不到token或nowGroupId")
            return
        }
        
        // 如果有labelId（要進行編輯）就帶三個參數 沒有就兩個（進行新增）
        var params = [String: Any]()
        if let labelId = labelId {
            
            params = ["id": labelId, "groupId": groupId, "customName": labelName] as [String: Any]
            print("[groupAddNewLabel] 要編輯的labelId：\(labelId)")
            
        }else {
            
            params = ["groupId": groupId, "customName": labelName]
        }
        
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[groupAddNewLabel] 無資料")
                    return
                }

                let labelEditResult = String(data: data, encoding: .utf8) ?? ""
                
                if labelEditResult == "Successed" {
                    
                    print("[groupAddNewLabel] 成功編輯或新增標籤")
                    result(.success(true))
                    
                }else {
                    
                    print("[groupAddNewLabel] 編輯或新增標籤失敗")
                    result(.success(false))
                }
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 刪除標籤
    static func removeLabelInGroup(labelId: Int, result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/removeLabelInGroup"
        let params = ["labelId": labelId]
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            
            print("[removeLabelInGroup]找不到token")
            return
        }
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[removeLabelInGroup] 無資料")
                    return
                }
                
                let labelEditResult = String(data: data, encoding: .utf8) ?? ""
                
                if labelEditResult == "Successed" {
                    
                    print("[removeLabelInGroup] 成功刪除標籤")
                    result(.success(true))
                    
                }else {
                    
                    print("[removeLabelInGroup] 刪除標籤失敗")
                    result(.success(false))
                }
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 將成員添加標籤
    static func addlabelToGroupMember(accountId: Int, labelId: Int, result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/addlabelToGroupMember"
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
            
            print("[addlabelToGroupMember]找不到token")
            return
        }
    
        let params = ["accountId": accountId, "groupId": groupId, "labelId": labelId]
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[addlabelToGroupMember] 無資料")
                    return
                }
                
                let addlabelResult = String(data: data, encoding: .utf8) ?? ""
                
                if addlabelResult == "Successed" {
                    
                    print("[addlabelToGroupMember] 帳號Id: \(accountId) 成功新增標籤Id： \(labelId)")
                    result(.success(true))
                    
                }else {
                    
                    print("[addlabelToGroupMember] 新增標籤失敗")
                    result(.success(false))
                }
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 查詢成員擁有的標籤
    static func getAllLebelOfGroupMember(accountId: Int, result: @escaping(Result<[LabelData], Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/getAllLabelOfGroupMember"
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
            
            print("[getAllLebelOfGroupMember]找不到token")
            return
        }
    
        let params = ["accountId": accountId, "groupId": groupId]
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[getAllLebelOfGroupMember] 無資料")
                    return
                }
                
                guard let getAllLebelResult = try? JSONDecoder().decode([LabelData].self, from: data) else {
                    
                    print("[getAllLebelOfGroupMember] 解析失敗")
                    return
                }
                
                print("[getAllLebelOfGroupMember] 成功")
                result(.success(getAllLebelResult))
                
                
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 查詢標籤內所有成員
    static func getAllHaveLabelAccount(labelId: Int, result: @escaping(Result<[MemberData], Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/getAllHaveLabelAccount"
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            
            print("[getAllHaveLabelAccount]找不到token")
            return
        }
    
        let params = ["labelId": labelId]
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[getAllHaveLabelAccount] 無資料")
                    return
                }
                
                guard let getAllHaveLabelAccountResult = try? JSONDecoder().decode([MemberData].self, from: data) else {
                    
                    print("[getAllHaveLabelAccount] 解析失敗")
                    return
                }
                
                print("[getAllHaveLabelAccount] 成功")
                result(.success(getAllHaveLabelAccountResult))

            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 取得自己帳號詳細資料
    static func userInformation(result: @escaping(Result<[MemberInfoData], Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Auth/UserInformation"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            
            print("[userInformation]找不到token")
            return
        }
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[userInformation] 無資料")
                    return
                }
                
                guard let memberInfo = try? JSONDecoder().decode([MemberInfoData].self, from: data) else {
                    
                    print("[userInformation] 解析失敗")
                    return
                }

                print("[userInformation] 成功")
                result(.success(memberInfo))
                    
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 取得群組單一成員詳細資料
    static func getGroupMemberInfo(accountId: Int, result: @escaping(Result<GroupMemberInfoData, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/getGroupMemberInfo"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey")  else {
            
            print("[getGroupMemberInfo]找不到token 或 groupId")
            return
        }
    
        let params = ["accountId": accountId, "groupId": groupId]
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[getGroupMemberInfo] 無資料")
                    return
                }
                
                guard let groupMemberInfo = try? JSONDecoder().decode(GroupMemberInfoData.self, from: data) else {
                    
                    print("[getGroupMemberInfo] 解析失敗")
                    return
                }

                print("[getGroupMemberInfo] 成功")
                result(.success(groupMemberInfo))
                    
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 編輯群組單一成員詳細資料
    static func editGroupMemberInfo(accountId: Int,
                                    isFullTimeJob: Bool,
                                    isCompanyDirector: Bool,
                                    holidayNum: Int,
                                    salary: Int,
                                    result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/editGroupMemberInfo"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey")  else {
            
            print("[editGroupMemberInfo]找不到token 或 groupId")
            return
        }
    
        let params = ["accountId": accountId,
                      "groupId": groupId,
                      "isFullTimeJob": isFullTimeJob,
                      "isCompanyDirector": isCompanyDirector,
                      "holidayNum": holidayNum,
                      "salary": salary]  as [String: Any]
        
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[editGroupMemberInfo] 無資料")
                    return
                }
                
                let quitGroupResult = String(data: data, encoding: .utf8) ?? ""
                
                if quitGroupResult == "Successed" {
                    
                    print("[editGroupMemberInfo] 修改資料成功")
                    result(.success(true))
                    
                }else {
                    
                    print("[editGroupMemberInfo] 修改資料敗")
                    result(.success(false))
                }
                
            case .failure(let error):
                
                result(.failure(error))
            
            }
        }
    }
    
    
    
    // 列出群組所有”班別“
    static func getAllschedualClassify(result: @escaping(Result<[ScheduleClassifyData], Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/getAllschedualClassify"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
            
            print("[getAllschedualClassify]找不到token或nowGroupId")
            return
        }
        
        let params = ["groupId": groupId]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[getAllschedualClassify] 無資料")
                    return
                }
                
                guard let getAllschedualClassifyResult = try? JSONDecoder().decode([ScheduleClassifyData].self, from: data) else {
                    
                    print("[getAllschedualClassify] 解析失敗")
                    return
                }

                print("[getAllschedualClassify] 成功")
                result(.success(getAllschedualClassifyResult))
                    
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 新增”班別“
    static func createNewSchedualClassify(customName: String,
                                          numberOfStaff: Int,
                                          workStartHour: Int,
                                          workStatrMinute: Int,
                                          workOverHour: Int,
                                          workOverMinute: Int,
                                          restStartHour: Int?,
                                          restStartMinute: Int?,
                                          restOverHour: Int?,
                                          restOverMinute: Int?,
                                          remarkContent: String?,
                                          result: @escaping(Result<Bool, Error>) -> Void) {
                                          
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/createNewSchedualClassify"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
            
            print("[createNewSchedualClassify]找不到token或nowGroupId")
            return
        }

        let params = ["groupId": groupId,
                      "customName": customName,
                      "numberOfStaff": numberOfStaff,
                      "workStartHour": workStartHour,
                      "workStatrMinute": workStatrMinute,
                      "workOverHour": workOverHour,
                      "workOverMinute": workOverMinute,
                      "restStartHour": restStartHour ?? 0 ,
                      "restStartMinute": restStartMinute ?? 0,
                      "restOverHour": restOverHour ?? 0,
                      "restOverMinute": restOverMinute ?? 0,
                      "remarkContent": remarkContent ?? ""] as [String: Any]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[createNewSchedualClassify] 無資料")
                    return
                }
                
                let createSchedualResult = String(data: data, encoding: .utf8) ?? ""
                
                if createSchedualResult == "Successed" {
                    
                    print("[createNewSchedualClassify] 新增班別 成功")
                    result(.success(true))
                    
                }else {
                    
                    print("[createNewSchedualClassify] 新增班別 失敗")
                    result(.success(false))
                }
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 編輯“班別”
    static func editSchedualClassify(id: Int,
                                     customName: String,
                                     numberOfStaff: Int,
                                     workStartHour: Int,
                                     workStatrMinute: Int,
                                     workOverHour: Int,
                                     workOverMinute: Int,
                                     restStartHour: Int?,
                                     restStartMinute: Int?,
                                     restOverHour: Int?,
                                     restOverMinute: Int?,
                                     remarkContent: String?,
                                     result: @escaping(Result<Bool, Error>) -> Void) {
                                          
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/createNewSchedualClassify"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
            
            print("[createNewSchedualClassify]找不到token或nowGroupId")
            return
        }

        let params = ["id": id,
                      "groupId": groupId,
                      "customName": customName,
                      "numberOfStaff": numberOfStaff,
                      "workStartHour": workStartHour,
                      "workStatrMinute": workStatrMinute,
                      "workOverHour": workOverHour,
                      "workOverMinute": workOverMinute,
                      "restStartHour": restStartHour ?? 0 ,
                      "restStartMinute": restStartMinute ?? 0,
                      "restOverHour": restOverHour ?? 0,
                      "restOverMinute": restOverMinute ?? 0,
                      "remarkContent": remarkContent ?? ""] as [String: Any]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[createNewSchedualClassify] 無資料")
                    return
                }
                
                let createSchedualResult = String(data: data, encoding: .utf8) ?? ""
                
                if createSchedualResult == "Successed" {
                    
                    print("[createNewSchedualClassify] 編輯班別 成功")
                    result(.success(true))
                    
                }else {
                    
                    print("[createNewSchedualClassify] 編輯班別 失敗")
                    result(.success(false))
                }
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 刪除“班別”
    static func deleteScheduleClassify(scheduleClassifyId: Int, result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/deleteSchedualClassify"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey") else {
            
            print("[deleteScheduleClassify]找不到token")
            return
        }
        
        let params = ["schedualClassifyId": scheduleClassifyId]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[deleteScheduleClassify] 無資料")
                    return
                }
                
                let createSchedualResult = String(data: data, encoding: .utf8) ?? ""
                
                if createSchedualResult == "Successed" {
                    
                    print("[deleteScheduleClassify] 刪除班別成功")
                    result(.success(true))
                    
                }else {
                    
                    print("[deleteScheduleClassify] 刪除班別失敗")
                    result(.success(false))
                    
                }
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 設定公休日
    static func setSchedulePublicHoliday(publicHolidayList: [Int], result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/setSchedualPublicHoliday"
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey"),
              let scheduleId = KeychainWrapper.standard.integer(forKey: "nowScheduleIdKey") else {
            
            print("[setSchedulePublicHoliday]找不到token 或 nowGroupId 或 nowScheduleId")
            return
        }
        
        let params = ["groupId": groupId,
                      "schedualTableId": scheduleId,
                      "publicHoliday": publicHolidayList] as [String: Any]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[setSchedulePublicHoliday] 無資料")
                    return
                }
                
                let createSchedualResult = String(data: data, encoding: .utf8) ?? ""
                
                if createSchedualResult == "Successed" {
                    
                    print("[setSchedulePublicHoliday] 班表設定公休日 成功")
                    result(.success(true))
                    
                }else {
                    
                    print("[setSchedulePublicHoliday] 班表設定公休日 失敗")
                    result(.success(false))
                    
                }
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    
    // 檢查班表
    static func checkSchedule(result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/getAllSchedual"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
            
            print("[getAllSchedule]找不到token或nowGroupId")
            return
        }
        
        let params = ["groupId": groupId]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[getAllSchedule] 無資料")
                    result(.success(false))
                    return
                }
                
                guard let getAllScheduleResult = try? JSONDecoder().decode([ScheduleData].self, from: data) else {
                    
                    print("[getAllSchedule] 解析失敗")
                    return
                }
                
                if getAllScheduleResult.isEmpty {
                    
                    print("[getAllSchedule] 無班表")
                    result(.success(false))
                    return
                }
                
                let scheduleId = getAllScheduleResult[0].id
                
                // 將目前所在班表存起來
                if KeychainWrapper.standard.set(scheduleId, forKey: "nowScheduleIdKey") {
                    
                    print("班表ID：\(scheduleId) 儲存成功")
                }
                // 擷取回傳日期的年月
                let scheduleDate = getAllScheduleResult[0].yearMonth
                let index = scheduleDate.index(scheduleDate.startIndex, offsetBy: 7)
                let scheduleDateSubString = String(scheduleDate[..<index])
                
                // 將目前所在班表日期存起來
                if KeychainWrapper.standard.set(scheduleDateSubString, forKey: "nowScheduleDateKey") {

                    print("班表日期：\(scheduleDateSubString) 儲存成功")
                }
                
                print("[getAllSchedule] 成功")
                result(.success(true))
            
                    
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }


    
    // 新增 或 修改 班表
    static func createNewSchedualTable(date: String, result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/createNewSchedualTable"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
            
            print("[createSchedualTable]找不到token或nowGroupId")
            return
        }
        
        let params = ["groupId": groupId, "yearMonth": date] as [String: Any]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[createSchedualTable] 無資料")
                    return
                }
                
                let createSchedualResult = String(data: data, encoding: .utf8) ?? ""
                
                if createSchedualResult == "0" {
                    
                    print("[createSchedualTable] 新增班表失敗")
                    result(.success(false))
                    
                }else {
                    
                    print("[createSchedualTable] 新增班表ID：\(createSchedualResult) 成功 ")
                    
                    if KeychainWrapper.standard.set(createSchedualResult,
                                                    forKey: "nowScheduleIdKey") {
                        print("[createSchedualTable] 儲存班表ID：\(createSchedualResult) 成功")
                    }
                    
                    result(.success(true))
                }
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
    
    // 設定成員劃休日
    static func staffChooseHoliday(accountId: Int, chooseHolidayList: [Int], result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/staffChooseHoliday"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey"),
              let scheduleId = KeychainWrapper.standard.integer(forKey: "nowScheduleIdKey") else {
            
            print("[createSchedualTable]找不到token 或 nowGroupId 或 nowScheduleId")
            return
        }
        
        let params = ["groupId": groupId,
                      "schedualTableId": scheduleId,
                      "accountId": accountId,
                      "chooseHoliday": chooseHolidayList] as [String: Any]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[staffChooseHoilday] 無資料")
                    return
                }
                
                let createSchedualResult = String(data: data, encoding: .utf8) ?? ""
                
                if createSchedualResult == "Successed" {
                    
                    print("[staffChooseHoilday] 上傳劃班/休 成功")
                    result(.success(true))
                    
                }else {
                    
                    print("[staffChooseHoilday] 上傳劃班/休 失敗")
                    result(.success(false))
                    
                }
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    
    }
    
    // 生成班表-步驟1（每日班別生成）
    static func generateSchedule(schedualClassifyIdList: [Int], result: @escaping(Result<[[GenerateScheduleDate]], Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/generateSchedual"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let scheduleId = KeychainWrapper.standard.integer(forKey: "nowScheduleIdKey") else {
            
            print("[generateSchedule]找不到token 或 scheduleId")
            return
        }
        
        let params = ["schedualTableId": scheduleId,
                      "schedualClassifyIdList": schedualClassifyIdList] as [String: Any]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[generateSchedule] 無資料")
                    return
                }

                guard let generateScheduleResult = try? JSONDecoder().decode([[GenerateScheduleDate]].self, from: data) else {
                    
                    print("[generateSchedule] 解析失敗")
                    return
                }

                print("[generateSchedule] 成功")
                result(.success(generateScheduleResult))
                
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    
    }
    
    // 生成班表-步驟2（每日每班別配近成員）
    static func autoRosterSchedual(result: @escaping(Result<Bool, Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/autoRosterSchedual"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey"),
              let scheduleId = KeychainWrapper.standard.integer(forKey: "nowScheduleIdKey") else {
                  
                  print("[autoRosterSchedual]找不到token 或 GroupId 或 scheduleId")
                  return
        }
        
        let params = ["groupId": groupId, "schedualTableId": scheduleId]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[autoRosterSchedual] 無資料")
                    result(.success(false))
                    return
                }

                let createSchedualResult = String(data: data, encoding: .utf8) ?? ""
                
                if createSchedualResult == "Successed" {
                    
                    print("[autoRosterSchedual] 成功")
                    result(.success(true))
                    
                }else {
                    
                    print("[autoRosterSchedual] 失敗")
                    result(.success(false))
                }
                
                
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    
    }
    
    
    // 依照需求標籤 輸出排班結果
    static func getRosterSchedualNeedLabelAccountResult() {
        
    }
        
    // 列出一般排班結果
    static func getRosterSchedualNormalAccountResult(result: @escaping(Result<[[[SchedualNormalAccountResultData]]], Error>) -> Void) {
        
        let url = "https://rostercake-337301.de.r.appspot.com/api/Data/getRosterSchedualNormalAccountResult"
        
        
        guard let token = KeychainWrapper.standard.string(forKey: "tokenKey"),
              let scheduleId = KeychainWrapper.standard.integer(forKey: "nowScheduleIdKey") else {
            
            print("[getRosterSchedualNormalAccountResult]找不到token 或 scheduleId")
            return
        }
        
        let params = ["schedualTableId": scheduleId]
    
        let header: HTTPHeaders = [ .authorization(bearerToken: token)]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).response {
            response in
            switch response.result {
                
            case .success(let data):
                
                guard let data = data else {
                    
                    print("[getRosterSchedualNormalAccountResult] 無資料")
                    return
                }

                guard let generateScheduleNormalAccountResult = try? JSONDecoder().decode([[[SchedualNormalAccountResultData]]].self, from: data) else {
                    
                    print("[getRosterSchedualNormalAccountResult] 解析失敗")
                    return
                }

                print("[getRosterSchedualNormalAccountResult] 成功")
                result(.success(generateScheduleNormalAccountResult))
                
                
            case .failure(let error):
                
                result(.failure(error))
            }
        }
    }
}
