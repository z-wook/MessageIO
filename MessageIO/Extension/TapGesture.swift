//
//  TapGesture.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import UIKit

extension UIViewController {
    func hideKeyBoardWhenTappedScreen() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapHandler() {
        view.endEditing(true)
    }
}

extension UIViewController: @retroactive UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 버튼이나 특정 뷰에 대한 터치가 gestureRecognizer에 전달되지 않도록 설정
        if let view = touch.view, view is UIControl {
            return false
        }
        return true
    }
}
