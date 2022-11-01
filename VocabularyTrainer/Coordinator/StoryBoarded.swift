//
//  StoryBoarded.swift
//  VocabularyTrainer
//
//  Created by Pranjal Verma on 30/10/22.
//  Copyright © 2022 mic. All rights reserved.
//

import Foundation
import UIKit

protocol StoryBoarded {
   static func instantiate() -> Self
}

extension StoryBoarded where Self: UIViewController {
    
    static func instantiate() -> Self {
        let id = String(describing: self)
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyBoard.instantiateViewController(withIdentifier: id) as! Self
    }
    
}
