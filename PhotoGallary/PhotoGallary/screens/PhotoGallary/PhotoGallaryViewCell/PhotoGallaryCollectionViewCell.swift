//
//  PhotoGallaryCollectionViewCell.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import UIKit
import SnapKit

class PhotoGallaryCollectionViewCell: UICollectionViewCell {

    static let identifier = "PhotoGallaryCollectionViewCell"
    
    private var cellModel: PhotoGallaryCellModel? = nil

    private var representedIdentifier: String = ""

    //MARK: - Constants
    private enum Constants {
        static let inset = 16
        static let shadowOpacity: Float = 1
        static let shadowRadius: CGFloat = 8
        static let imageCornerRadius: CGFloat = 25
        static let maxFontSize: CGFloat = 40
    }
    //MARK: - UI Property
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .large
        return view
    }()

     private lazy var outerView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = Constants.shadowOpacity
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = Constants.shadowRadius
        view.backgroundColor = .clear
        return view
    }()

     private lazy var imageView: UIImageView = {
        var view = UIImageView()
        view.frame = outerView.bounds
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.imageCornerRadius
         view.contentMode = .scaleAspectFill
        let tap = UILongPressGestureRecognizer(
            target: self,
            action: #selector(imageViewTapped)
        )
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)

        return view
     }()

    private lazy var userName: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Settings.Colors.fontColor
        label.font = UIFont(name: Settings.Fonts.appleSDGothicNeo, size: Constants.maxFontSize)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.numberOfLines = 0
        return label
    }()

    var image: UIImage? {
        didSet {
            activityIndicator.stopAnimating()
            guard let image = image else { return }
            self.imageView.image = image
            UIView.animate(withDuration: 0.3) {
                self.changeOpacity(value: 1)
            }
            self.imageView.image = image
        }
    }

    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .clear

        contentView.addSubviews([outerView, activityIndicator, userName])

        outerView.addSubview(imageView)

        changeOpacity(value: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        outerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.inset)
            make.top.bottom.equalToSuperview().inset(Constants.inset)
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        userName.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(outerView).inset(Constants.inset * 2)
        }
    }

    //MARK: - Reusing
    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        userName.text = nil
    }

    //MARK: - Cell Methods
    func updateCellWith(model: PhotoGallaryCellModel) {
        changeOpacity(value: 0)

        cellModel = model

        userName.text = model.userName
        
        image = model.image
    }

    func getCellRepresentedIdentifier() -> String {
        return representedIdentifier
    }

    func setCellRepresentedIdentifier(_ identifier: String) {
        representedIdentifier = identifier
    }

    func startActivityIndicator() {
        activityIndicator.startAnimating()
    }

    //MARK: - Private Methods
    private func changeOpacity(value: Float) {
        [outerView, userName].forEach { view in
            view.layer.opacity = value
        }
    }

    @objc private func imageViewTapped() {
        guard let cellModel = cellModel else { return }

        let dataDict: [String: String] = ["photoURL": cellModel.photoURL, "userURL": cellModel.userURL]

        NotificationCenter.default.post(
            name: Notification.Name(Settings.NotificationIdentifires.currentCell),
            object: nil,
            userInfo: dataDict
        )
    }
}
