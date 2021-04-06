//
//  LanugageTableViewCell.swift
//  VocabularyTrainer
//
//  Created by Michael Steudter on 06.04.21.
//  Copyright © 2021 mic. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {

	@IBOutlet weak var languageLabel: UILabel!
	@IBOutlet weak var languageWordsLabel: UILabel!

	override func layoutSubviews() {
		super.layoutSubviews()
		backgroundColor = UIColor(white: 1.0, alpha: 0.0)
		if let background = backgroundView {
			background.frame = background.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
		}

		languageLabel.textColor = .black
		languageWordsLabel.textColor = .black


		guard let selected = selectedBackgroundView else { return }
		selected.frame = selected.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		if selected {
			contentView.backgroundColor = BackgroundColor.hansaYellow
		} else {
			contentView.backgroundColor = UIColor.clear
		}
	}
}
