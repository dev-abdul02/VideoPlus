//
//  UIViewController+Protocol.swift
//  FacetrackingVideoApp
//
//  Created by Abdul Karim on 04/09/21.
//

import UIKit

protocol ViewFromNib {}

extension ViewFromNib {
    
    static var nibName: String {
        return String(describing: Self.self)
    }

    static var nib: UINib {
        return UINib(nibName: self.nibName, bundle: nil)
    }
    
    static func view() -> Self? {
        let objects = self.nib.instantiate(withOwner: nil, options: nil)
        return objects.first as? Self
    }
    
    static func viewController<T: UIViewController>() -> T? {
        return T(nibName: nibName, bundle: nil)
    }
    
    static func registerCellForTableView(_ tableView: UITableView) {
        tableView.register(nib, forCellReuseIdentifier: nibName)
    }
    
    static func cell<T: UITableViewCell>(tableView: UITableView, forRowAt indexPath: IndexPath) -> T {
        return tableView.dequeueReusableCell(withIdentifier: nibName, for: indexPath) as! T
    }
    
    static func registerCellForCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(nib, forCellWithReuseIdentifier: nibName)
    }
    
    static func cell<T: UICollectionViewCell>(collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> T {
        return collectionView.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath) as! T
    }
}

