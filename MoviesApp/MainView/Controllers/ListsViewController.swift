//
//  ListsViewController.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 17.12.2023.
//

import UIKit

protocol ListsViewControllerDelegate: AnyObject {
    func didDismiss(with message: String)
}

class ListsViewController: UIViewController {
    
    private let coreDataManager = CoreDataManager.shared

    let movieTitle: String
    let movieImage: UIImage?
    let movieId: Int
    
    var type: ControllerType?
    
    enum ControllerType {
        case addMovie
        case deleteMovie
    }
    
    weak var delegate: ListsViewControllerDelegate?
    
    init(movieTitle: String, movieImage: UIImage? = nil, movieId: Int, delegate: ListsViewControllerDelegate? = nil) {
        self.movieTitle = movieTitle
        self.movieImage = movieImage
        self.movieId = movieId
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "ListTableViewCell")
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "No available lists"
        label.textColor = .black
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var allLists = [MovieList]()
    private var listsToRemoveFromOrAddMovie = [MovieList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        switch type {
        case .addMovie:
            allLists = coreDataManager.fetchListsInWhichMovieIsNotStored(movieId: movieId)
        case .deleteMovie:
            allLists = coreDataManager.fetchListsInWhichMovieIsStored(movieId: movieId)
        default: break
        }
    
        
        if allLists.isEmpty {
            tableView.isHidden = true
            view.addSubview(messageLabel)
            
            
            let screenHeight = UIScreen.main.bounds.height
            messageLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset((screenHeight / 2.0) - (screenHeight / 4.0))
            }
            
        }
    }

    @objc func doneButtonTapped() {
        if !listsToRemoveFromOrAddMovie.isEmpty {
            switch type {
            case .addMovie:
                delegate?.didDismiss(with: "added successfully")
                coreDataManager.createAndAddMovieToLists(listsToRemoveFromOrAddMovie, title: movieTitle, poster: movieImage, id: movieId)
            case .deleteMovie:
                delegate?.didDismiss(with: "removed successfully")
                coreDataManager.deleteMovieFromLists(listsToRemoveFromOrAddMovie, movieId: movieId)
            default: break
            }
        }
        
        dismiss(animated: true)
    }
    
}

extension ListsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell {
            cell.listNameLabel.text = allLists[indexPath.row].name
            return cell
        }
        
        return UITableViewCell()
    }

}

extension ListsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell {
            if !cell.isCellSelected {
                cell.isCellSelected = true
                cell.contentView.backgroundColor = cell.contentViewBackgroundColor()
                cell.checkmarkImageView.isHidden = false
                listsToRemoveFromOrAddMovie.append(allLists[indexPath.row])
            } else {
                cell.isCellSelected = false
                cell.contentView.backgroundColor = cell.contentViewBackgroundColor()
                cell.checkmarkImageView.isHidden = true
                listsToRemoveFromOrAddMovie.removeAll(where: {$0.name == allLists[indexPath.row].name})
            }
            
        }
    }
    
}
