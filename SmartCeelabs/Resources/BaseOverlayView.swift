//
//  BaseOverlayView.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 11/04/2022.
//

import Foundation
import UIKit

class BaseOverlayView: UIViewController {
    
    var hasSetPointOrigin = false
//    var hasAddAnotation: Bool = false
    var hasTouched: Bool = false
    var pointOrigin: CGPoint?
    var isFromSearchView: Bool = true
    
    override func viewDidLoad() {
        //Keyboard recognizer
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Overlay recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
   
    @objc func keyboardWillShow(notification: NSNotification) {
//        self.view.frame.origin.y = self.view.safeAreaInsets.bottom
        if !isFromSearchView {
            if !hasTouched {
                hasTouched = true
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardHeight = keyboardFrame.cgRectValue.height
                    self.view.frame.origin.y -= (keyboardHeight)
//                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                }
            }
//            self.navigationController?.hidesBarsWhenKeyboardAppears = true
        }

    }
    
    private func hideNavigaitonWhenKeyboardAppear() {
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    @objc private func keyboardWillHide() {
        guard let pointOrigin = self.pointOrigin?.y else { return }
        hasTouched = false
        self.view.frame.origin.y = pointOrigin
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        if let pointOrigin = pointOrigin {
            view.frame.origin = CGPoint(x: 0, y: pointOrigin.y + translation.y)
        }
    
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}
