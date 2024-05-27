//
//  TakeLookSwitchButton.swift
//  VocabularyTrainer
//
//  Created by Michael Steudter on 25.05.24.
//  Copyright © 2024 mic. All rights reserved.
//

import UIKit

class TakeLookSwitchButton: UIButton {

	var isOn: Bool = false

	var buttonAction: (() -> Void)?

	init(action: (() -> Void)?) {
		self.buttonAction = action
		super.init(frame: .zero)
		setupButtton()
	}

	func setupButtton() {
		addAction(.init(handler: { [weak self] _ in
			self?.isOn.toggle()
			self?.buttonAction?()
		}), for: .touchUpInside)
		var configuration = UIButton.Configuration.borderless()
		configuration.image = UIImage(systemName: "eye")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 12)))
		configuration.imagePadding = 4
		let title = NSLocalizedString("takeLook", comment: "")
		configuration.baseForegroundColor = .secondaryLabel
		configuration.attributedTitle = AttributedString(title,
														 attributes: AttributeContainer([
															.font: UIFont.preferredFont(forTextStyle: .body),
															.underlineStyle: NSUnderlineStyle.single.rawValue
		   ]))
		self.configuration = configuration
	}

	required init?(coder: NSCoder) { nil }
}
