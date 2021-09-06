//
//  VideoPlayerList.swift
//  FacetrackingVideoApp
//
//  Created by Abdul Karim on 04/09/21.
//

import Foundation

class VideoPlayerListViewModel {
    
    var launch: Bool = false
    var dataModel = [VideoListModel]()
    
    init() {
        addData()
    }
    
    func addData(){
        let obj1 = VideoListModel(videoImage: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg", videoTitle: "Big Buck Bunny", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        let obj2 = VideoListModel(videoImage: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg", videoTitle: "Elephant Dream", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")
        
        dataModel.append(obj1)
        dataModel.append(obj2)
    }
    
}
