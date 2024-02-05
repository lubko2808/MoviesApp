//
//  FavoritesViewController.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.08.2023.
//

import UIKit
import SnapKit

class MovieListsViewController: UIViewController {
    
    // MARK: - Properties
    public var onMovieCellTapped: ((Int, UIImage) -> Void)?
    
    var currentlySelectedList: String? = nil
    private var moviesToDelete: Set<IndexPath> = []
    private var areCellsInSelectionState: Bool = false
    
    private let coreDataManager: CoreDataManagerProtocol
    
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    private enum Constants {
        static let deleteButtonHeight: CGFloat = 44
    }
    
    // MARK: - init
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    private let collectionView = MovieListsScreenCollectionVIew()
    private let deleteButton = DeleteButton()
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViews()
        setConstraints()
        getLists()
        
        collectionView.onMovieCellLongPressed = { [weak self] gestureRecognizer in
            self?.handlePressGesture(gestureRecognizer)
        }
        
        collectionView.onListSelected = { [weak self] listName in
            self?.handleListSelection(listName)
        }
        
        collectionView.onListTappedToDelete = { [weak self] index in
            self?.handleListDeletion(index)
        }
        
        collectionView.onAddListButtonTapped = { [weak self] listName in
            self?.handleListAddition(listName)
        }
        
        collectionView.onKeyboardInvoked = { [weak self] in
            self?.hideKeyboardWhenTappedAround()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    // MARK: - Other
    private func setupViews() {
        view.addSubviews(collectionView, deleteButton)
        collectionView.delegate = self
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    private func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.trailing.leading.bottom.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(Constants.deleteButtonHeight)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        
    }

    private func getLists() {
        let lists = coreDataManager.fetchMovieLists()
        collectionView.appendLists(lists)
    }

    private func refreshData() {
        guard let currentlySelectedList else { return }
        guard let movies = self.coreDataManager.fetchMovies(in: currentlySelectedList) else { return }
        collectionView.refreshData(with: movies)
    }
}

// MARK: - Helpers
extension MovieListsViewController {

    private func bringUpDeleteButton() {
        deleteButton.isHidden = false
        UIView.animate(withDuration: 0.15) {
            self.deleteButton.snp.updateConstraints { make in
                let offset = -GlobalConstants.tabBarHeight - GlobalConstants.tabBarInset - Constants.deleteButtonHeight - 18
                make.top.equalTo(self.view.snp.bottom).offset(offset)
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideDeleteButton() {
        UIView.animate(withDuration: 0.15) {
            self.deleteButton.snp.updateConstraints { make in
                make.top.equalTo(self.view.snp.bottom)
            }
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.deleteButton.isHidden = true
        }
    }
}

// MARK: - Action handlers
extension MovieListsViewController {

    @objc private func deleteButtonTapped() {
        for indexPath in moviesToDelete {
            guard let movie = collectionView.getMovie(for: indexPath) else { return }
            coreDataManager.deleteMovieFromLists(listNames: [currentlySelectedList ?? ""],
                                                 movieId: Int(movie.id))
            moviesToDelete.remove(indexPath)
        }
        
        guard let movies = coreDataManager.fetchMovies(in: currentlySelectedList ?? "") else { return }
        collectionView.refreshData(with: movies)
        
        let visibleCells = collectionView.getVisibleMovieCells()
        for cell in visibleCells {
            cell.selectedToDeleteImageView.isHidden = true
            UIView.animate(withDuration: 0.2) {
                cell.transform = .identity
            }
        }
        areCellsInSelectionState = false
        hideDeleteButton()
    }
    
    private func handlePressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let selectedCell = gestureRecognizer.view as? MovieCollectionViewCell, let selectedIndexPath = collectionView.indexPath(for: selectedCell) else {
            return
        }
        
        guard selectedIndexPath.section == 1 else { return }
        
        let visibleCells = collectionView.getVisibleMovieCells()

        if gestureRecognizer.state == .began {
            bringUpDeleteButton()
            
            areCellsInSelectionState = true
            
            for cell in visibleCells {
                cell.selectedToDeleteImageView.isHidden = false
                cell.selectedToDeleteImageView.image = UIImage.circleSymbol
                UIView.animate(withDuration: 0.2) {
                    cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }
            }
            
            selectedCell.selectedToDeleteImageView.image = UIImage.checkmarkSymbol
            moviesToDelete.insert(selectedIndexPath)
        }
    }
    
    private func handleListAddition(_ listName: String) -> String? {
        if listName.isEmpty {
            return "List name is empty"
        } else if coreDataManager.isListInStorage(listName) == true {
            return "List with this name already exists"
        } else {
            removeTapGesture()
            let initialLists = coreDataManager.fetchMovieLists()
            coreDataManager.createMovieList(name: listName)
            let currentLists = coreDataManager.fetchMovieLists()
            collectionView.addList(initialLists: initialLists, currentLists: currentLists)
            return nil
        }
    }
    
    private func handleListDeletion(_ index: Int) {
        let lists = collectionView.getLists()
        collectionView.deleteAllLists()
        let listToDelete = lists[index].name
        coreDataManager.deleteMovieList(lists[index])
        
        if currentlySelectedList == listToDelete {
            collectionView.deleteAllMovies()
            currentlySelectedList = nil
        }
        
        let movieLists = coreDataManager.fetchMovieLists()
        collectionView.refreshData(with: movieLists)
    }
    
    private func handleListSelection(_ listName: String) {
        areCellsInSelectionState = false
        hideDeleteButton()
        let visibleCells = collectionView.getVisibleMovieCells()
        for cell in visibleCells {
            cell.selectedToDeleteImageView.isHidden = true
            cell.transform = .identity
        }
        
        currentlySelectedList = listName
        guard let movies = coreDataManager.fetchMovies(in: listName) else { return }
        collectionView.refreshData(with: movies)
    }
}

// MARK: - UICollectionViewDelegate
extension MovieListsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MovieCollectionViewCell, indexPath.section == 1 else { return }
        if self.areCellsInSelectionState {
            cell.selectedToDeleteImageView.isHidden = false
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            
            if self.moviesToDelete.contains(indexPath) {
                cell.selectedToDeleteImageView.image = UIImage.checkmarkSymbol
            } else {
                cell.selectedToDeleteImageView.image = UIImage.circleSymbol
            }
        } else {
            cell.selectedToDeleteImageView.isHidden = true
            cell.transform = .identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MovieCollectionViewCell else { return }

        if self.areCellsInSelectionState {
            if moviesToDelete.contains(indexPath) {
                cell.selectedToDeleteImageView.image = UIImage.circleSymbol
                moviesToDelete.remove(indexPath)
            } else {
                cell.selectedToDeleteImageView.image = UIImage.checkmarkSymbol
                moviesToDelete.insert(indexPath)
            }

            if moviesToDelete.isEmpty {
                let visibleCells = self.collectionView.getVisibleMovieCells()
                for cell in visibleCells {
                    cell.selectedToDeleteImageView.isHidden = true
                    UIView.animate(withDuration: 0.2) {
                        cell.transform = .identity
                    }
                }
                hideDeleteButton()
                areCellsInSelectionState = false
            }
        } else {
            guard let movie = self.collectionView.getMovie(for: indexPath) else { return }
            let id = Int(movie.id)
            onMovieCellTapped?(id, cell.posterImageView.image ?? GlobalConstants.defaultImage)
        }
    }
    
}

// MARK: - Keyboard Dismissal
extension MovieListsViewController {
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer = tap
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        removeTapGesture()
    }
    
    private func removeTapGesture() {
        if let tapGestureRecognizer = tapGestureRecognizer {
            view.removeGestureRecognizer(tapGestureRecognizer)
        }
    }
    
}
