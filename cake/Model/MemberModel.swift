//
//  MemberModel.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/30.
//

import Foundation
import SwiftKeychainWrapper

protocol MemberModelDelegate: AnyObject {
    func didFetchData(delegateResult: Result<[GetAllGroupMemberData], Error>)
}

class MemberModel {
    
    private var memberList = [GetAllGroupMemberData]()
    
    weak var delegate: MemberModelDelegate? = nil
    
    // 單一標籤內成員數量
    func getDataCount() -> Int {
        return memberList.count
    }
    
    // 取得單一成員檔案
    func getData(index: Int) -> GetAllGroupMemberData? {
        if memberList.indices.contains(index) {
            return memberList[index]
        }else{
            return nil
        }
    }
    
    // 獲取單一標籤內成員清單
    func fetchData() {
        
        guard let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else { return }
        
        APIManager.getAllgroupMember(groupId: groupId) {
            result in
            switch result {
                
            case .success(let data):
                
                self.memberList = data
                
                self.delegate?.didFetchData(delegateResult: .success(self.memberList))
                
            case .failure(let error):
                
                self.delegate?.didFetchData(delegateResult: .failure(error))
            }
        }
    }
}
