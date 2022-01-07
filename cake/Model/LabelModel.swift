//
//  LabelModel.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/27.
//

import Foundation
import Alamofire


protocol LabelModelDelegate: AnyObject {
    func didFetchData(delegateResult: Result<[LabelData], Error>)
}

class LabelModel {
    
    private var labelList = [LabelData]()
    
    weak var delegate: LabelModelDelegate? = nil
    
    // 標籤數量
    func getDataCount() -> Int {
        
        return labelList.count
    }
    
    // 取得單一標籤檔案
    func getData(index: Int) -> LabelData? {
        
        if labelList.indices.contains(index) {
            
            return labelList[index]
            
        }else{
            
            return nil
        }
    }
    
    //  設定標籤內有的成員清單
    func setMemberList(index: Int, memberList: [MemberData]) {
        
        labelList[index].memberList = memberList
    }
    
    //  取得單一標籤內有的成員清單
    func getMemberList(index: Int) -> [MemberData]? {
        
        return labelList[index].memberList
    }
    
    // 獲取標籤清單
    func fetchData() {
        
        APIManager.allLabelInGroup {
            result in
            switch result {
                
            case .success(let data):
                
                self.labelList = data
                
                self.delegate?.didFetchData(delegateResult: .success(self.labelList))
                
            case .failure(let error):
                
                self.delegate?.didFetchData(delegateResult: .failure(error))
            }
            
        }
    }
}
