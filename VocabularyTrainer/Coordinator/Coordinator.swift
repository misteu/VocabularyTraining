//
//  Coordinator.swift
//  VocabularyTrainer
//
//  Created by Pranjal Verma on 30/10/22.
//  Copyright © 2022 mic. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinator: [Coordinator] {get set}
    var navigationController: UINavigationController {get set}
    
    func start()
}
