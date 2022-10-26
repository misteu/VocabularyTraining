//
//  VocabularyCell.swift
//  VocabularyTrainer
//
//  Created by Michael Steudter on 06.04.21.
//  Copyright © 2021 mic. All rights reserved.
//

import UIKit

class VocabularyCell: UITableViewCell {
    
    lazy var vocabularyRoot: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = BackgroundColor.japaneseIndigo
        label.textAlignment = .left
        return label
    }()
    
    lazy var vocabularyTranslation: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = BackgroundColor.japaneseIndigo
        label.textAlignment = .left
        return label
    }()
    
    lazy var dateAddedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = BackgroundColor.japaneseIndigo
        label.textAlignment = .left
        return label
    }()
    
    lazy var vocabularyProgress: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = BackgroundColor.red
        progressView.trackTintColor = BackgroundColor.mediumSpringBud
        return progressView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            contentView.backgroundColor = BackgroundColor.hansaYellow
        } else {
            contentView.backgroundColor = UIColor.clear
        }
    }
    
    func setupUI() {
        
        backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        
        contentView.addSubview(stackView)
        contentView.addSubview(vocabularyProgress)
        stackView.addArrangedSubview(vocabularyRoot)
        stackView.addArrangedSubview(vocabularyTranslation)
        stackView.addArrangedSubview(dateAddedLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.contentView, attribute: .trailingMargin, relatedBy: .equal, toItem: stackView, attribute: .trailingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: stackView, attribute: .leadingMargin, relatedBy: .equal, toItem: self.contentView, attribute: .leadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: stackView, attribute: .topMargin, relatedBy: .equal, toItem: contentView, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.contentView, attribute: .bottomMargin, relatedBy: .equal, toItem: stackView, attribute: .bottomMargin, multiplier: 1, constant: 4),
            
            NSLayoutConstraint(item: self.contentView, attribute: .trailingMargin, relatedBy: .equal, toItem: vocabularyProgress, attribute: .trailingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: vocabularyProgress, attribute: .leadingMargin, relatedBy: .equal, toItem: stackView, attribute: .leadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: vocabularyProgress, attribute: .bottomMargin, relatedBy: .equal, toItem: contentView, attribute: .bottomMargin, multiplier: 1, constant: 0)
        ])
    }
    
}
