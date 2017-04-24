//
//  ViewController.swift
//  AHPinterest
//
//  Created by Andy Hurricane on 3/26/17.
//  Copyright © 2017 AndyHurricane. All rights reserved.
//

import UIKit


class AHPinVC: AHCollectionVC {
    
    weak var pinVM: AHPinViewModel?
    weak var selectedCell: AHPinCell? {
        let currentItem = AHPublicObjects.shared.currentItem
        let index = IndexPath(item: currentItem, section: self.pinLayout.layoutSection)
        
        // scroll using system method to make the cell visible
        if AHNavigationVCDelegate.delegate.operation  == .pop {
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.bottom, animated: false)
            self.collectionView?.layoutIfNeeded()
        }
        
        // now the cell is not nil
        let cell = self.collectionView!.cellForItem(at: index) as? AHPinCell
        
        // custom scroll to make cell center
        if AHNavigationVCDelegate.delegate.operation == .pop {
            self.scrollToItem(cell: cell!)
            self.collectionView?.layoutIfNeeded()
        }
        return cell
    }
    
    let pinLayout = AHPinLayout()
    
    let refreshLayout = AHRefreshLayout()
    fileprivate let refreshLayoutHanlder = AHRefreshLayoutHandler()
    
    let pinDataSource = AHPinDataSource()
    let pinDelegate = AHPinDelegate()
    
    let optionsHandler = AHOptionsHandler()
    
    
    // should the VC refreshes data at first loading
    var initialAutoRefresh = true
    
    var showLayoutHeader = false
    
    func scrollToItem(cell: AHPinCell) {
        let relativeP = cell.convert(cell.center, to: collectionView)
        if relativeP.y < collectionView!.frame.size.height * 0.5 {
            // the cell is on the upper half of the screen
            return
        }
        // scroll to make the cell center
        let pt = CGPoint(x: 0, y: cell.center.y - collectionView!.frame.size.height * 0.5)
        collectionView?.setContentOffset(pt, animated: false)
    }
}


// MARK:- VC Cycles
extension AHPinVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        collectionView?.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        
        let headerNib = UINib(nibName: "AHPinLayoutHeader", bundle: nil)
        collectionView?.register(headerNib, forSupplementaryViewOfKind: AHPinLayoutHeaderKind, withReuseIdentifier: AHPinLayoutHeaderKind)
        
        collectionView?.register(AHRefreshHeader.self, forSupplementaryViewOfKind: AHHeaderKind, withReuseIdentifier: AHHeaderKind)
        
        collectionView?.register(AHRefreshFooter.self, forSupplementaryViewOfKind: AHFooterKind, withReuseIdentifier: AHFooterKind)
        
        setup()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialAutoRefresh {
            initialAutoRefresh = false
            AHRefershUI.show()
            pinDataSource.loadNewData(completion: { (success) in
                AHRefershUI.dismiss()
                if success {
                    // dismiss refresh control
                }else{
                    // do something about it and dismiss refresh control too
                }
            })
        }
        
        
        
    }
    

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
}

// MARK:- Setups
extension AHPinVC {
    
    func setup() {

        setupPinLayout()
        setupRefreshLayout()
        setupOptionsHandler()
    }
    
    func setupRefreshLayout() {
        refreshLayoutHanlder.pinVC = self
        refreshLayout.delegate = refreshLayoutHanlder
        refreshLayout.enableFooterRefresh = true
        refreshLayout.enableHeaderRefresh = true
        addGlobelSupplement(layout: refreshLayout, delegate: refreshLayoutHanlder, dataSource: refreshLayoutHanlder)
    }
    
    func setupPinLayout() {
        pinDataSource.pinVC = self
        
        pinDelegate.pinVC = self

        let layoutHanlder = AHLayoutHandler()
        layoutHanlder.pinVC = self
        pinLayout.delegate = layoutHanlder
        
        addLayout(layout: pinLayout, delegate: pinDelegate, dataSource: pinDataSource)
    }
    
    func setupOptionsHandler() {
        optionsHandler.pinVC = self
        optionsHandler.collectionView = collectionView
    }
    
}



extension AHPinVC: AHTransitionPushFromDelegate {
    func transitionPushFromSelectedCell() -> AHPinCell? {
        return self.selectedCell
    }
}

extension AHPinVC : AHTransitionPopToDelegate {
    func transitionPopToSelectedCell() -> AHPinCell? {
        return self.selectedCell
    }
}










