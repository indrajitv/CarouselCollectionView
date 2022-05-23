//
//  ViewController.swift
//  CarouselCollectionView
//
//  Created by Indrajit Chavda on 20/05/22.
//

import UIKit

class ViewController: UIViewController {

    lazy var cv = CarouselCollectionView<SampleMode, SampleCollectionCell>(cellForItemAtObserver: { [weak self] model, cell, indexPath in
        cell.model = model
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .darkGray
        self.view.addSubview(cv)
        cv.frame = .init(x: 0, y: 100, width: self.view.frame.width, height: 400)
        
        var models: [SampleMode] = []
        for i in 1...5 {
            models.append(.init(name: "\(i)"))
        }

        cv.setModelsAndReloadView(models: models)


    }

}

struct SampleMode {
    var name: String?
}

class SampleCollectionCell: UICollectionViewCell {
    var model: SampleMode? {
        didSet {
            self.labelTitleHeader.text = model?.name
        }
    }
    
    let labelTitleHeader: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        
        self.addSubview(labelTitleHeader)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        labelTitleHeader.frame = self.bounds
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
