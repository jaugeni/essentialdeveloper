//
//  UITableView+Dequeueing.swift
//  EsseintialFeedIOS
//
//  Created by Yauheni Ivaniuk on 12/15/23.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
