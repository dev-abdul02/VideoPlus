//
//  VideoPlayerList.swift
//  FacetrackingVideoApp
//
//  Created by Abdul Karim on 04/09/21.
//

import UIKit

class VideoPlayerList: BaseViewController {
    
    var viewModel: VideoPlayerListViewModel!
    @IBOutlet weak var tvTableView: UITableView! {
        didSet {
            tvTableView.delegate = self
            tvTableView.dataSource = self
            ListTableViewCell.registerCellForTableView(tvTableView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video+"
    }

}

extension VideoPlayerList: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let videoCell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.nibName) as? ListTableViewCell
        let listObj = viewModel.dataModel[indexPath.row]
        videoCell?.setupCell(withData: listObj)
        return videoCell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController: VideoPlayerViewController = VideoPlayerViewController.viewController() {
            let data = viewModel.dataModel[indexPath.row]
            viewController.videoURL = data.videoUrl
            self.show(viewController, sender: self)
        }
    }
    
    
}


extension VideoPlayerList : NavigationControllerChild {
    func prefersNavigationBarHidden() -> Bool {
        return false
    }
}

extension VideoPlayerList : ViewFromNib {}
