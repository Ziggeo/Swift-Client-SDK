//
//  UICollectionView.swift
//  ZiggeoDemoSwift
//
//  Created by Severyn-Wsevolod on 11.05.2024.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(cell: T.Type) {
        register(cell.nib, forCellWithReuseIdentifier: cell.identifier)
    }
    
    func registerSupplementary<T: UICollectionReusableView>(view: T.Type, forSupplementaryViewOfKind kind: String) {
        register(view.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: view.identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Could not find collection view cell with identifier \(T.identifier)")
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T {
        guard let header = dequeueReusableSupplementaryView(ofKind: kind,
                                                            withReuseIdentifier: T.identifier,
                                                            for: indexPath) as? T
        else {
            fatalError("Could not find collection supplementary view with identifier \(T.identifier)")
        }
        return header
    }
}
