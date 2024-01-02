//
//  TrailersCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 27.08.2023.
//

import UIKit
import WebKit

class TrailerCollectionViewCell: UICollectionViewCell, WKNavigationDelegate {
    
    let youtubeView = WKWebView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.addSubview(youtubeView)
        youtubeView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
    }
    
    func configureCell(with trailerKey: String) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(trailerKey)?rel=0") else { return }
        let urlRequest = URLRequest(url: url)
        self.youtubeView.load(urlRequest)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            // Prevent navigation to other URLs
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    
}
