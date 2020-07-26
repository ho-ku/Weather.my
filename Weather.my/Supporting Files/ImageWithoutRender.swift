//
//  ImageWithoutRender.swift
//  Weather.my
//
//  Created by Денис Андриевский on 26.07.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import UIKit

class ImageWithoutRender: UIImage {
    override func withRenderingMode(_ renderingMode: UIImage.RenderingMode) -> UIImage {
        return self
    }
}
