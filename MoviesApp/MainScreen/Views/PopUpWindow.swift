//
//  PopUpWindow.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 17.12.2023.
//

import UIKit
import Combine

class PopUpWindow: UIView {
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var message: String? {
        didSet {
            guard let message = message else { return }
            messageLabel.text = message
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        self.clipsToBounds = true
        
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 25
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PopUpWindow {
    
    public func show(with message: String, on view: UIView) {
        view.addSubview(self)
        self.message = message
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        widthAnchor.constraint(equalToConstant: view.frame.width - 64).isActive = true
        
        let distance = (view.frame.height) / 2.0
        transform = CGAffineTransform(translationX: 0, y: distance)
        alpha = 1
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3) {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }
        
        Timer.publish(every: 1.3, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink { _ in
                UIView.animate(withDuration: 0.5) {
                    self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.alpha = 0
                } completion: { _ in
                    self.removeFromSuperview()
                }
            }
            .store(in: &subscriptions)
    }
    
}
