//
//  CarouselCollectionView.swift
//  CarouselCollectionView
//
//  Created by Indrajit Chavda on 20/05/22.
//

import UIKit

/// This class helps to show carousel like view which scrolls horizontally.
final class CarouselCollectionView<Model, Cell: UICollectionViewCell>: UIView,
                                                                       UICollectionViewDelegate,
                                                                       UICollectionViewDataSource,
                                                                       UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    
    private var makeSingleCellFullSized: Bool = true
    private var visibilitySizeForNextCell: CGFloat = 0
    private var spacingBetweenCells: CGFloat = 0
    private var bottomAnchorOfCollectionView,
                heightOfPageController: NSLayoutConstraint!
    
    typealias CellForItemAtObserver = (_ model: Model, _ cell: Cell, _ indexPath: IndexPath) -> Void
    
    private let cellForItemAtObserver: CellForItemAtObserver
    
    private var models: [Model] = []
    
    private var cellID: String {
        return String(describing: Cell.self)
    }
    
    private let collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: self.collectionLayout)
        cv.backgroundColor = .yellow
        cv.delegate = self
        cv.dataSource = self
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        return cv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = .gray
        pc.pageIndicatorTintColor = .lightGray
        pc.isUserInteractionEnabled = false
        return pc
    }()
    
    // MARK: Life cycle methods
    
    required init(cellForItemAtObserver: @escaping CellForItemAtObserver) {
        self.cellForItemAtObserver = cellForItemAtObserver
        
        super.init(frame: .zero)
        
        self.registerCell()
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Other methods
    
    private func setupViews() {
        self.addSubview(collectionView)
        self.addSubview(pageControl)
        
        self.bottomAnchorOfCollectionView = collectionView.bottomAnchor.constraint(equalTo: self.pageControl.topAnchor)
        self.heightOfPageController = pageControl.heightAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.bottomAnchorOfCollectionView,
            
            pageControl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.heightOfPageController
        ])
    }
    
    private func registerCell() {
        self.collectionView.register(Cell.self, forCellWithReuseIdentifier: self.cellID)
    }
    
    /// Default it is visible.
    func hideShowPageControl(shouldHide: Bool) {
        self.pageControl.isHidden = shouldHide
        
        if shouldHide {
            self.bottomAnchorOfCollectionView = collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        } else {
            self.bottomAnchorOfCollectionView = collectionView.bottomAnchor.constraint(equalTo: self.pageControl.topAnchor)
        }
    }
    
    func setHeightOfPageController(height: CGFloat) {
        self.heightOfPageController.constant = height
    }
    
    func setColorOfPageControllerDots(selected: UIColor, unSelected: UIColor) {
        self.pageControl.currentPageIndicatorTintColor = selected
        self.pageControl.pageIndicatorTintColor = unSelected
    }
    
    func setModelsAndReloadView(models: [Model]) {
        self.models = models
        self.pageControl.numberOfPages = self.models.count
        reloadView()
    }
    
    func reloadView() {
        self.collectionView.reloadData()
    }
    
    /// Default value is set true. Manual  reloading is required after calling thing function.
    func setScrollPaging(isEnable: Bool) {
        self.collectionView.isPagingEnabled = isEnable
    }
    
    /// This will turn off the paging. This will also turn off the bottom page indicator. Manual  reloading is required after calling thing function.
    func setNextComingCellVisibility(visibilitySize: CGFloat, makeSingleCellFullSized: Bool = true, isPagingEnabled: Bool = false) {
        self.setScrollPaging(isEnable: false)
        self.collectionView.isPagingEnabled = isPagingEnabled
        self.makeSingleCellFullSized = makeSingleCellFullSized
        self.visibilitySizeForNextCell = visibilitySize
    }
    
    /// Manual  reloading is required after calling thing function.
    func setSpacingBetweenCells(spacing: CGFloat) {
        self.spacingBetweenCells = spacing
        self.collectionLayout.minimumLineSpacing = spacing
        self.collectionLayout.minimumInteritemSpacing = spacing
    }
    
    // MARK: Collection view delegate & data sources.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID,
                                                      for: indexPath) as! Cell
        cellForItemAtObserver(models[indexPath.item], cell, indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (self.visibilitySizeForNextCell != 0 && self.makeSingleCellFullSized && self.models.count == 1) {
            return .init(width: collectionView.bounds.width, height: collectionView.frame.height)
        } else  {
            let width: CGFloat = collectionView.bounds.width - self.visibilitySizeForNextCell - spacingBetweenCells
            return .init(width: width,
                         height: collectionView.frame.height)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let horizontalCenter = width / 2
        if width != 0 {
            self.pageControl.currentPage = Int(offSet + horizontalCenter) / Int(width)
        }
    }
}
