// 
//  PhotoGallaryViewController.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import UIKit
import SnapKit
import SafariServices


extension CreditModel: InfiniteScollingData {}

protocol PhotoGallaryViewControllerProtocol: AnyObject {
    func openSafari(url: URL)
    func updateCollectionView()
    func showAlert(alertModel: AlertModel)
    func moveToNextPhoto()
}

final class PhotoGallaryViewController: UIViewController {

    var presenter: PhotoGallaryPresenterProtocol!

    let networker = NetworkManager()

    var infiniteScrollingBehaviour: InfiniteScrollingBehaviour!

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
        view.collectionViewLayout = layout
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

//MARK: - Setuping Views
    private func setupViews() {
        navigationController?.navigationBar.isHidden = true

        view.backgroundColor = Settings.Colors.main
        view.addSubview(collectionView)
    }

//MARK: - Layout
    private func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.inset)
            make.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constants.inset * 2)
        }
    }

//MARK: - Private methods
}

//MARK: - CollectionView methods
extension PhotoGallaryViewController: InfiniteScollingData, InfiniteScrollingBehaviourDelegate {

    func didBeginScrolling(inInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) {
        presenter.fetchTimerStopped()
    }

    func didEndScrolling(inInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) {
        presenter.fetchTimerStarted()
    }

    func configuredCell(forItemAtIndexPath indexPath: IndexPath, originalIndex: Int, andData data: InfiniteScollingData, forInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: PhotoGallaryCollectionViewCell.identifier,
                   for: indexPath
               ) as? PhotoGallaryCollectionViewCell else { return UICollectionViewCell() }

        if let model = data as? CreditModel {
            cell.clearImage()

            let cellModel = presenter.fetchCollectionViewCellModel(collectionViewModel: model)

            cell.updateCellWith(model: cellModel)

            let URL = URL(string: cellModel.imageURL)

            let representedIdentifier = model.userName

            cell.setCellRepresentedIdentifier(representedIdentifier)

            networker.downloadImage(url: URL!, size: cell.frame.size) {[weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if cell.getCellRepresentedIdentifier() == representedIdentifier {
                        cell.setImage(image: image)
                        self.presenter.fetchTimerStarted()
                    }
                }
            }
        }

        return cell
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
            if let _ = self.infiniteScrollingBehaviour {}
            else {
                let configuration = CollectionViewConfiguration(
                    layoutType: .numberOfCellOnScreen(1),
                    scrollingDirection: .horizontal
                )
                self.infiniteScrollingBehaviour = InfiniteScrollingBehaviour(
                    withCollectionView: self.collectionView,
                    andData: self.presenter.fetchModelForCollectionView(),
                    delegate: self,
                    configuration: configuration
                )
            }
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
}
