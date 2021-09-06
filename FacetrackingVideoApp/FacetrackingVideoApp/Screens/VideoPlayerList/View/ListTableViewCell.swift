//
//  ListTableViewCell.swift
//  FacetrackingVideoApp
//
//  Created by Abdul Karim on 04/09/21.
//

import UIKit
import Kingfisher

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var ivVideoBackground: UIImageView!
    @IBOutlet weak var lVideoLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(withData:VideoListModel) {
        let url = URL(string: withData.videoImage)
        ivVideoBackground.kf.setImage(with: url)
        lVideoLabel.text = withData.videoTitle
    }
    
}

extension ListTableViewCell:ViewFromNib {}
