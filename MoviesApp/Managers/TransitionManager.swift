//
//  TransitionManager.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 18.12.2023.
//

import UIKit

enum TransitionType {
    case presentation
    case dismissal
    
    var blurAlpha: CGFloat { return self == .presentation ? 1 : 0 }
    var dimAlpha: CGFloat { return self == .presentation ? 0.5 : 0 }
    var cornerRadius: CGFloat { return self == .presentation ? 20 : 0 }
    var next: TransitionType { return self == .presentation ? .dismissal : .presentation }
    
}

class TransitionManager: NSObject {
    
    let transitionDuration: Double = 1
    var transition: TransitionType = .presentation
    let shrinkDuration: Double = 0.2
    
    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        return visualEffectView
    }()
    
    lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Helpers
    private func addBackgroundViews(to containerView: UIView) {
        blurEffectView.frame = containerView.frame
        blurEffectView.alpha = 0
        containerView.addSubview(blurEffectView)
        
        dimmingView.frame = containerView.frame
        dimmingView.alpha = 0
        containerView.addSubview(dimmingView)
    }
    
    private func createMainCellCopy(cell: MainCollectionViewCell) -> MainCollectionViewCell {
        let cellCopy = MainCollectionViewCell(frame: cell.frame)
        cellCopy.configure(with: cell.posterImageView.image, title: cell.titleLabel.text ?? "")
        return cellCopy
    }
    
    private func createPosterViewCopy(poster: UIImage, posterFrame: CGRect) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = poster
        imageView.frame = posterFrame
        return imageView
    }
    
    private func createPosterViewCopy(posterView: UIImageView) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = posterView.image
        imageView.frame = posterView.frame
        imageView.layer.shadowColor = posterView.layer.shadowColor
        imageView.layer.shadowOpacity = posterView.layer.shadowOpacity
        imageView.layer.shadowOffset =  posterView.layer.shadowOffset
        imageView.layer.shadowRadius =  posterView.layer.shadowRadius
        return imageView
    }
}



extension TransitionManager: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func present(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        containerView.subviews.forEach( {$0.removeFromSuperview() })
        
        addBackgroundViews(to: containerView)

        guard let toViewController = transitionContext.viewController(forKey: .to) as? DetailViewController else { return }
        
        let posterPadding: CGFloat = 5
        let posterFrame = CGRect(
            x: 20 - posterPadding,
            y: UIWindow.topPadding + 50 - posterPadding + 30,
            width: 180 + 2 * posterPadding,
            height: 180 * (3 / 2) + 2 * posterPadding)
 
        guard let fromNavVC = transitionContext.viewController(forKey: .from) as? UINavigationController else { return }
        guard let fromViewController = fromNavVC.viewControllers.first as? MainViewController else { return }
        guard let cell = fromViewController.selectedCell() else { return }
        guard let origin = fromViewController.getOrigin() else { return }

        let cellCopy = createMainCellCopy(cell: cell)
        containerView.addSubview(cellCopy)
        cell.isHidden = true
        cellCopy.frame.origin = origin
        print("origin: \(origin)")
        cellCopy.layoutIfNeeded()

        whiteView.frame = transition == .presentation ? cellCopy.contentView.frame : containerView.frame
        whiteView.layer.cornerRadius = transition.cornerRadius
        cellCopy.addSubview(whiteView)
        cellCopy.sendSubviewToBack(whiteView)
        
        let detailViewController = toViewController
        containerView.addSubview(detailViewController.view)
        detailViewController.view.isHidden = true
        
        moveAndConvert(cell: cellCopy, containerView: containerView, frame: posterFrame) {
            detailViewController.view.isHidden = false
            //cellCopy.removeFromSuperview()
            cellCopy.isHidden = true
            detailViewController.createSnapshotOfView()
            cell.isHidden = false
            transitionContext.completeTransition(true)
        }
    }
    
    func dismiss(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let cell = containerView.subviews[2] as? MainCollectionViewCell else { return }
        let whiteView = cell.subviews[0]
        containerView.subviews.forEach( {$0.removeFromSuperview() })
        addBackgroundViews(to: containerView)
        cell.isHidden = false
        containerView.addSubview(cell)
        
        guard let detailViewController = transitionContext.viewController(forKey: .from) as? DetailViewController else { return }
        let posterView = detailViewController.getPosterView()
        posterView.isHidden = true
        
        whiteView.frame = containerView.frame
        whiteView.layer.cornerRadius = transition.cornerRadius

        
        guard let fromNavVC = transitionContext.viewController(forKey: .to) as? UINavigationController else { return }
        guard let mainViewController = fromNavVC.viewControllers.first as? MainViewController else { return }
        
        guard let mainCollectionViewCell = mainViewController.selectedCell() else { return }
        mainCollectionViewCell.isHidden = true
        var mainViewCollectionCellFrame = mainCollectionViewCell.frame
        guard let origin =  mainViewController.getOrigin() else { return }
        mainViewCollectionCellFrame.origin = origin
        
        let springTiming = UISpringTimingParameters(dampingRatio: 0.75, initialVelocity: CGVector(dx: 0, dy: 4))
        let animator = UIViewPropertyAnimator(duration: transitionDuration, timingParameters: springTiming)
        animator.addAnimations {
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 8
            cell.layer.cornerRadius = 30
            cell.frame = mainViewCollectionCellFrame
            cell.titleLabel.alpha = 1
            self.blurEffectView.alpha = self.transition.blurAlpha
            self.dimmingView.alpha = self.transition.dimAlpha
            self.whiteView.layer.cornerRadius = self.transition.next.cornerRadius
            containerView.layoutIfNeeded()
            whiteView.frame.size = mainViewCollectionCellFrame.size
            whiteView.frame.origin = CGPoint(x: 0, y: 0)
        }
        
        animator.addCompletion { _ in
            mainCollectionViewCell.isHidden = false
            transitionContext.completeTransition(true)
        }
        
        animator.startAnimation()
        
    }
    
     
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        if transition == .presentation {
            present(using: transitionContext)
        } else {
            dismiss(using: transitionContext)
        }
    }
    
    
    func makeShrinkAnimator(for cell: MainCollectionViewCell) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: shrinkDuration, curve: .easeOut) {
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.dimmingView.alpha = 0.05
        }
    }
    
    func makeExpandAnimator(for cell: MainCollectionViewCell, in containerView: UIView, frame: CGRect) -> UIViewPropertyAnimator {
        let springTiming = UISpringTimingParameters(dampingRatio: 0.75, initialVelocity: CGVector(dx: 0, dy: 4))
        let animator = UIViewPropertyAnimator(duration: transitionDuration - shrinkDuration, timingParameters: springTiming)
        
        animator.addAnimations {
            
            cell.transform = .identity
            cell.contentView.layer.borderWidth = 0
            cell.contentView.layer.cornerRadius = 0
            cell.posterImageView.layer.cornerRadius = 0
            cell.titleLabel.alpha = 0
            cell.frame = frame
   
            self.blurEffectView.alpha = self.transition.blurAlpha
            self.dimmingView.alpha = self.transition.dimAlpha
            
            self.whiteView.layer.cornerRadius = self.transition.next.cornerRadius
            
            containerView.layoutIfNeeded()
            cell.layoutIfNeeded()


            let whiteViewFrame = CGRect(
                x: -frame.origin.x,
                y: -frame.origin.y,
                width: containerView.frame.width,
                height: containerView.frame.height)
            self.whiteView.frame = self.transition == .presentation ? whiteViewFrame : cell.frame
        }
        
        return animator
    }
    
    func moveAndConvert(cell: MainCollectionViewCell, containerView: UIView, frame: CGRect, completion: @escaping() -> Void) {
        let shrinkAnimator = makeShrinkAnimator(for: cell)
        let expandAnimator = makeExpandAnimator(for: cell, in: containerView, frame: frame)
        
        expandAnimator.addCompletion { _ in
            completion()
        }
        
        if transition == .presentation {
            shrinkAnimator.addCompletion { _ in
                cell.layoutIfNeeded()
                expandAnimator.startAnimation()
            }
            
            shrinkAnimator.startAnimation()
        }
            
    }
    
}


extension TransitionManager: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition = .presentation
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition = .dismissal
        return self
    }
}

