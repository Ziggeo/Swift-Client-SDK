//
//  TopClientsViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit

final class TopClientsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var logoCollectionView: UICollectionView!
    
    // MARK: - Private variables
    private let sectionInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        logoCollectionView.delegate = self
        logoCollectionView.dataSource = self
        logoCollectionView.register(cell: LogoCollectionViewCell.self)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension TopClientsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Common.ClientList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LogoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath as IndexPath)
        cell.setData(icon: Common.ClientList[indexPath.row].image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Common.openWebBrowser(Common.ClientList[indexPath.row].url)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TopClientsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2 - sectionInsets.left - sectionInsets.right, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.sectionInsets.left
    }
}
