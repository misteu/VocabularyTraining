//
//  VocabularyDateFormatter.swift
//  VocabularyTrainer
//
//  Created by Michael Steudter on 06.04.21.
//  Copyright © 2021 mic. All rights reserved.
//

import Foundation

class VocabularyDateFormatter {
	static let dateFormatter: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		return formatter
	}()

	static let prettyDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		return formatter
	}()
}
