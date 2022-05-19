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
    func showAlert(_ alert: UIAlertController)
    func moveToNextPhoto()
    func openSettings()
    func deleteCell()
}

final class PhotoGallaryViewController: UIViewController {

    var presenter: PhotoGallaryPresenterProtocol!

    private var prevIndexPathAtCenter: IndexPath?

    private var currentIndexPath: IndexPath? {
        let center = view.convert(collectionView.center, to: collectionView)
        return collectionView.indexPathForItem(at: center)
    }

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
        layout.minimumInteritemSpacing = Constants.collectionViewMinimumLineSpacing
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
        view.backgroundColor = .clear
        view.allowsSelection = true

        return view
    }()

//MARK: - ViewDidLoad
    override func viewDidLoad() -> () {
        super.viewDidLoad()

        setupViews()
        setupLayout()
        presenter.fetchCredits()
    }

//MARK: - Layout
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        if let indexAtCenter = currentIndexPath {
            prevIndexPathAtCenter = indexAtCenter
        }
        collectionView.collectionViewLayout.invalidateLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()

    }

//MARK: - Setuping Views
    private func setupViews() {
        navigationController?.navigationBar.isHidden = true

        view.backgroundColor = Settings.Colors.main
        view.addSubview(collectionView)

        collectionView.delegate = self
        collectionView.dataSource = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rotated),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

//MARK: - Elements layout
    private func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.inset)
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

    @objc func rotated() {
        if let indexAtCenter = currentIndexPath {
            prevIndexPathAtCenter = indexAtCenter
        }
        collectionView.collectionViewLayout.invalidateLayout()
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

        let representedIdentifier = "cellID=\(indexPath.item)"

        cell.setCellRepresentedIdentifier(representedIdentifier)

        let request = RequestCellModel(
            size: cell.frame.size,
            indexPath: indexPath.item,
            id: representedIdentifier
        )

        cell.setCellRepresentedIdentifier(representedIdentifier)
        cell.startActivityIndicator()

        presenter.fetchCollectionViewCellModel(request: request) { [weak self] model in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if cell.getCellRepresentedIdentifier() == model.id {
                    cell.updateCellWith(model: model)

                    self.presenter.fetchTimerStarted()
                }
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {

        guard let oldCenter = prevIndexPathAtCenter else { return proposedContentOffset }

        let attrs =  collectionView.layoutAttributesForItem(at: oldCenter)

        let newOriginForOldIndex = attrs?.frame.origin

        return newOriginForOldIndex ?? proposedContentOffset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calculateTransforms(with:scrollView.contentOffset)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        presenter.fetchTimerStopped()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageFloat = (scrollView.contentOffset.x / scrollView.frame.size.width)
        let pageInt = Int(round(pageFloat))

        switch pageInt {
        case 0:
            collectionView.scrollToItem(at: [0, presenter.fetchModelForCollectionView().count - 2], at: .left, animated: false)
        case presenter.fetchModelForCollectionView().count - 1:
            collectionView.scrollToItem(at: [0, 1], at: .left, animated: false)
        default:
            break
        }
    }
}

//MARK: - Protocol methods
extension PhotoGallaryViewController: PhotoGallaryViewControllerProtocol {

    func showAlert(_ alert: UIAlertController) {
        presenter.fetchTimerStopped()

        present(alert, animated: true)
    }

    func updateCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()

            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
        }
    }

    func openSafari(url: URL) {
        let svc = SFSafariViewController(url: url)

        present(svc, animated: true, completion: nil)

        presenter.fetchTimerStopped()
    }

    func moveToNextPhoto() {
        collectionView.scrollToNextItem()
    }

    func openSettings() {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func deleteCell() {
        if let currentIndexPath = currentIndexPath {
            collectionView.deleteItems(at: [currentIndexPath])

            presenter.deleteCell(indexPath: currentIndexPath.item)

            collectionView.reloadData()
        }
    }
}
