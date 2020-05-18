//
//  UIViewController+Keyboard.swift
//
//  Created by Håkon Bogen on 10/12/14.
//  Copyright (c) 2014 Håkon Bogen. All rights reserved.
//  MIT LICENSE

import UIKit

extension UIViewController {
    
    public func setupKeyboardNotifcationListenerForScrollView(_ scrollView: UIScrollView) {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        internalScrollView = scrollView
    }
    
    public func removeKeyboardNotificationListeners() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private struct SingleLineKeyboardResizeKeys {
        static var ScrollViewKey = "single_line_scroll_view_key"
        static var ScrollViewContentInsetsKey = "single_line_content_insets_key"
        static var ScrollIndicatorInsetsKey = "single_line_indicator_insets_key"
    }
    
    fileprivate var internalScrollView: UIScrollView! {
        get {
            return objc_getAssociatedObject(self, &SingleLineKeyboardResizeKeys.ScrollViewKey) as? UIScrollView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &SingleLineKeyboardResizeKeys.ScrollViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    fileprivate var internalScrollViewContentInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &SingleLineKeyboardResizeKeys.ScrollViewContentInsetsKey) as? NSValue {
                return value.uiEdgeInsetsValue
            }
            return .zero
        }
        set(newValue) {
            let value = NSValue.init(uiEdgeInsets: newValue)
            objc_setAssociatedObject(self, &SingleLineKeyboardResizeKeys.ScrollViewContentInsetsKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var internalScrollViewIndicatorInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &SingleLineKeyboardResizeKeys.ScrollIndicatorInsetsKey) as? NSValue {
                return value.uiEdgeInsetsValue
            }
            return .zero
        }
        set(newValue) {
            let value = NSValue.init(uiEdgeInsets: newValue)
            objc_setAssociatedObject(self, &SingleLineKeyboardResizeKeys.ScrollIndicatorInsetsKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue
        let keyboardFrameConvertedToViewFrame = view.convert(keyboardFrame!, from: nil)
        let options = UIView.AnimationOptions.beginFromCurrentState
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            let insetHeight = (self.internalScrollView.frame.height + self.internalScrollView.frame.origin.y) - keyboardFrameConvertedToViewFrame.origin.y
            self.internalScrollViewContentInsets = self.internalScrollView.contentInset
            self.internalScrollViewIndicatorInsets = self.internalScrollView.scrollIndicatorInsets
            self.internalScrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: insetHeight, right: 0)
            self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsets.init(top: 0, left: 0, bottom: insetHeight, right: 0)
            }) { (complete) -> Void in
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let options = UIView.AnimationOptions.beginFromCurrentState
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.internalScrollView.contentInset = self.internalScrollViewContentInsets
            self.internalScrollView.scrollIndicatorInsets  = self.internalScrollViewIndicatorInsets
            }) { (complete) -> Void in
        }
    }
}
