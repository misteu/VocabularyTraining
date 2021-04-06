//
//  VocabularyCell.swift
//  VocabularyTrainer
//
//  Created by Michael Steudter on 06.04.21.
//  Copyright © 2021 mic. All rights reserved.
//

import UIKit

class VocabularyCell: UITableViewCell {
	@IBOutlet weak var vocabularyRoot: UILabel!
	@IBOutlet weak var vocabularyTranslation: UILabel!
	@IBOutlet weak var vocabularyProgress: UIProgressView!
	@IBOutlet weak var dateAddedLabel: UILabel!
	
	override func layoutSubviews() {
		super.layoutSubviews()
		backgroundColor = UIColor(white: 1.0, alpha: 0.0)
		vocabularyRoot.textColor = BackgroundColor.japaneseIndigo
		vocabularyTranslation.textColor = BackgroundColor.japaneseIndigo
		dateAddedLabel.textColor = BackgroundColor.japaneseIndigo
		vocabularyProgress.progressTintColor = BackgroundColor.red
		vocabularyProgress.trackTintColor = BackgroundColor.mediumSpringBud
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		if selected {
			contentView.backgroundColor = BackgroundColor.hansaYellow
		} else {
			contentView.backgroundColor = UIColor.clear
		}
	}

}
