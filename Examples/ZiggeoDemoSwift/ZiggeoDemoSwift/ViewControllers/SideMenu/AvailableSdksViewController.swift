//
//  AvailableSdksViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit


class AvailableSdksViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var logoCollectionView: UICollectionView!
    
    // MARK: - Private variables
    private let reuseIdentifier = "LogoCollectionViewCell"
    private let reuseHeaderIdentifier = "LogoCollectionViewTitleCell"
    private let sectionInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        logoCollectionView.delegate = self
        logoCollectionView.dataSource = self
        logoCollectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        logoCollectionView.register(UINib(nibName: reuseHeaderIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension AvailableSdksViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Common.SdkList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Common.SdkList[section].count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath as IndexPath) as! LogoCollectionViewCell
        cell.setData(icon: Common.SdkList[indexPath.section][indexPath.row].image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Common.openWebBrowser(Common.SdkList[indexPath.section][indexPath.row].url)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview: UICollectionReusableView? = nil
        if kind == UICollectionView.elementKindSectionHeader {
            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath)
            let labelHeader = reusableview?.viewWithTag(1) as! UILabel

            if indexPath.section == 0 {
                labelHeader.text = "Mobile SDKs"
            } else {
                labelHeader.text = "Server-Side SDKs"
            }
        }
        return reusableview!
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AvailableSdksViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 50)
    }
    
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
