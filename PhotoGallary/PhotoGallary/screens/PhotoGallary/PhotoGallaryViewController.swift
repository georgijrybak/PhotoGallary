// 
//  PhotoGallaryViewController.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import UIKit
import SnapKit
import SafariServices


protocol PhotoGallaryViewControllerProtocol: AnyObject {
    func openSafari(url: URL)
    func updateCollectionView()
    func showAlert(alertModel: AlertModel)
}

final class PhotoGallaryViewController: UIViewController {

    var presenter: PhotoGallaryPresenterProtocol!

//MARK: - Constants
    private enum Constants {
        static let inset = 8
        static let collectionViewMinimumLineSpacing: CGFloat = 0
    }

//MARK: - UI Property
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Constants.collectionViewMinimumLineSpacing
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        view.showsHorizontalScrollIndicator = true
        view.showsVerticalScrollIndicator = false
        view.register(
            PhotoGallaryCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoGallaryCollectionViewCell.identifier
        )
        view.isPagingEnabled = true
        
        return view
    }()

//MARK: - ViewDidLoad
    override func viewDidLoad() -> () {
        super.viewDidLoad()

        setupViews()
        setupLayout()
        presenter.fetchCredits()
    }

//MARK: - Setuping Views
    private func setupViews() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = Settings.Colors.main
        view.addSubview(collectionView)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
    }

//MARK: - Layout
    private func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constants.inset * 2)
        }
    }

//MARK: - Private methods
    private func calculateTransforms(with offset:CGPoint) {
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) {
                let halfWidth = cell.contentView.frame.size.width / 2.0
                let realCenter = collectionView.convert(cell.center, to: collectionView.superview)
                let diff = abs(halfWidth - realCenter.x)
                let scale = 1.0 - diff / 2000.0
                let scaleTransform = CGAffineTransform.init(scaleX: scale, y: scale)
                cell.transform = scaleTransform
                cell.alpha = scale
            }
        }
    }
}

//MARK: - CollectionView methods
extension PhotoGallaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.fetchModelForCollectionView().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoGallaryCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoGallaryCollectionViewCell else { return UICollectionViewCell() }

        let cellModel = presenter.fetchCollectionViewCellModel(
            collectionViewModel: presenter.fetchModelForCollectionView(),
            indexPath: indexPath.item
        )
        cell.updateCellWith(model: cellModel)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calculateTransforms(with:scrollView.contentOffset)
    }
}

//MARK: - Protocol methods
extension PhotoGallaryViewController: PhotoGallaryViewControllerProtocol {
    func showAlert(alertModel: AlertModel) {
        let alert = AlertManager.shared.getAlert(title: alertModel.title, message: alertModel.message)

        switch alertModel.type {
        case .cantDownloadData:
            let action = UIAlertAction(title: alertModel.actionTitle, style: .default) { _ in
                self.presenter.fetchCredits()
            }
            alert.addAction(action)
        case .noItnernet:
            //туть обработка когда нет интернета
            print("no inet")
        }
        present(alert, animated: true)
    }

    func updateCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func openSafari(url: URL) {
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
}
