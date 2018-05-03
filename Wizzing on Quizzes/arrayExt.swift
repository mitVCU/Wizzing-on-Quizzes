
//
//  Created by Mit Amin on 4/29/18.
//  Copyright © 2018 Mit Amin. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    func random() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
