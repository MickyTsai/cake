//
//  ScheduleClassifyModel.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/30.
//

import Foundation


protocol ScheduleClassifyDelegate: AnyObject {
    func didFetchData(delegateResult: Result<[ScheduleClassifyData], Error>)
}

class ScheduleClassifyModel {
    
    private var scheduleClassifyList = [ScheduleClassifyData]()
    
    weak var delegat: ScheduleClassifyDelegate? = nil
    
    // 數量
    func getDataCount() -> Int {
        
        return scheduleClassifyList.count
    }
    
    // 取得單一班別檔案
    func getData(index: Int) -> ScheduleClassifyData? {
        
        if scheduleClassifyList.indices.contains(index) {
            
            return scheduleClassifyList[index]
            
        }else{
            
            return nil
        }
    }
    
    func fetchData() {
        
        APIManager.getAllschedualClassify {
            result in
            switch result {
             
            case .success(let data):
                
                self.scheduleClassifyList = data
                
                self.delegat?.didFetchData(delegateResult: .success(self.scheduleClassifyList))
                
            case .failure(let error):
                
                self.delegat?.didFetchData(delegateResult: .failure(error))
               
            }
        }
    }
}
