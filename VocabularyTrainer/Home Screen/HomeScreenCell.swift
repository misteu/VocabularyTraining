//
//  HomeScreenCell.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

final class HomeScreenCell: UITableViewCell {

  let stackView = UIStackView()
  let languageLabel = UILabel()
  let wordCountLabel = UILabel()

  static let identifier = "HomeScreenCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    stackView.addArrangedSubview(languageLabel)
    stackView.addArrangedSubview(wordCountLabel)
    contentView.addSubview(stackView)
    [stackView, languageLabel, wordCountLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    ])

    backgroundColor = .clear
  }

  required init?(coder: NSCoder) { nil }
}
