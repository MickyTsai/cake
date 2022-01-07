//
//  SchedualNormalAccountResultModel.swift
//  cake
//
//  Created by TSAI MICKY on 2022/1/6.
//

import Foundation

protocol SchedualNormalAccountModelDelegate: AnyObject {
    func didFetchData(delegateResult: Result<[[[SchedualNormalAccountResultData]]], Error>)
}

class SchedualNormalAccountModel {
    
    private var schedualNormalAccountList = [[[SchedualNormalAccountResultData]]]()
    
    weak var delegate: SchedualNormalAccountModelDelegate? = nil
    
    // 取得某天 班別數量
    func getScheduleClassifyCountOfDate(date: Int) -> Int {
        
        // 檢查班表是否有資料
        if schedualNormalAccountList.isEmpty {
            return 0
        }
        
        let scheduleClassifyCountOfDate = schedualNormalAccountList[date].count
        return scheduleClassifyCountOfDate
    }
    
    func getscheduleClassifyListOfDate(date: Int) -> [[SchedualNormalAccountResultData]]? {
        
        // 檢查班表是否有資料
        if schedualNormalAccountList.isEmpty {
            return nil
        }
        
        return schedualNormalAccountList[date]
    }
    
    
    // 取得某天 某班別 成員數量
    func getMemberCountOfDateOfScheduleClassify(date: Int, scheduleClassifyIndex: Int) -> Int {
        
        // 檢查班表是否有資料
        if schedualNormalAccountList.isEmpty {
            return 0
        }
        
        let  memberCountOfDateOfScheduleClassify = schedualNormalAccountList[date][scheduleClassifyIndex].count
        
        return memberCountOfDateOfScheduleClassify
    }
    
    // 取得某天 某班別 單一成員檔案
    func getMemberDataOfDateOfLabel(date: Int, lebelIndex: Int, memberIndex: Int) -> SchedualNormalAccountResultData? {
        
        if schedualNormalAccountList[date][lebelIndex].indices.contains(memberIndex) {
            
            return schedualNormalAccountList[date][lebelIndex][memberIndex]
            
        }else{
            
            return nil
        }
    }
    
//    //  設定標籤內有的成員清單
//    func setMemberList(index: Int, memberList: [MemberData]) {
//
//        labelList[index].memberList = memberList
//    }
//
//    //  取得單一標籤內有的成員清單
//    func getMemberList(index: Int) -> [MemberData]? {
//
//        return labelList[index].memberList
//    }
//
    // 獲取班表結果
    func fetchData() {
        
        APIManager.getRosterSchedualNormalAccountResult {
            result in
            switch result {
                
            case .success(let data):
                
                self.schedualNormalAccountList = data
                
                self.delegate?.didFetchData(delegateResult: .success(self.schedualNormalAccountList))
                
            case .failure(let error):
                
                self.delegate?.didFetchData(delegateResult: .failure(error))
            }
            
        }
    }
}
