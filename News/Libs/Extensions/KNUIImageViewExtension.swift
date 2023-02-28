//  Created by Ky Nguyen

import UIKit
import Kingfisher
import func AVFoundation.AVMakeRect

extension UIImageView {

    func freshDownload(from url: String?) {
        guard let url = url, let nsurl = URL(string: url) else { return }
        DispatchQueue(label: "DownloadImage").async { [weak self] in
            if let data = try? Data(contentsOf: nsurl) {
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
        }
    }
}

