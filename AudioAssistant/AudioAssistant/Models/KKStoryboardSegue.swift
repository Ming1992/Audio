//
//  KKStoryboardSegue.swift
//  AudioAssistant
//
//  Created by liaozhenming on 2020/10/16.
//

import UIKit

class KKStoryboardSegue: UIStoryboardSegue {
    
    override func perform() {
        source.navigationController?.pushViewController(destination, animated: true)
    }
}
