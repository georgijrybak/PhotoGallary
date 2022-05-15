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

    private let networkManager = NetworkManager()

    //MARK: - Constants
    private enum Constants {
        static let inset = 16
        static let shadowOpacity: Float = 1
        static let shadowRadius: CGFloat = 8
        static let imageCornerRadius: CGFloat = 25
        static let maxFontSize: CGFloat = 60
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
        let view = UIImageView()
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
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(userNameTapped)
        )
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()

    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .clear

        contentView.addSubviews([outerView, activityIndicator, userName])

        outerView.addSubview(imageView)
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
            make.height.equalTo(self.contentView.frame.width / 7)
        }
    }

    //MARK: - Reusing
    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        userName.text = nil
    }

    //MARK: - UpdateCell Method
    func updateCellWith(model: PhotoGallaryCellModel) {
        activityIndicator.startAnimating()

        cellModel = model

        let URL = URL(string: model.imageURL)

        changeOpacity(value: 0)

        userName.text = model.userName

        networkManager.downloadImage(url: URL!) { image in

            self.imageView.image = image

            self.activityIndicator.stopAnimating()

            UIView.animate(withDuration: 0.3) {
                self.changeOpacity(value: 1)
            }
        }
    }

    //MARK: - Private Methods
    private func changeOpacity(value: Float) {
        [outerView, userName].forEach { view in
            view.layer.opacity = value
        }
    }

    @objc private func userNameTapped() {
        guard let cellModel = cellModel, let url = URL(string: cellModel.userURL) else { return }

        NotificationCenter.default.post(name: Notification.Name("openSafariWithURL"), object: url)
    }

    @objc private func imageViewTapped() {
        guard let cellModel = cellModel, let url = URL(string: cellModel.photoURL) else { return }

        NotificationCenter.default.post(name: Notification.Name("openSafariWithURL"), object: url)
    }
}
