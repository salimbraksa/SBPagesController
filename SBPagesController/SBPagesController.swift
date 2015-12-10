//
//  SBPagesController.swift
//  SBPagesController
//
//  Created by Salim Braksa on 11/7/15.
//  Copyright © 2015 Braksa. All rights reserved.
//

import UIKit
import Cartography

public protocol SBPagesControllerDataSource: class {
   
   func pagesSlider(viewControllerForIndex index: Int) -> UIViewController
   
   func numberOfViews() -> Int
   
}

public protocol SBPagesControllerDelegate: class {
   
   func scrollingFromPageIndex(index: Int, toIndex: Int, progress: Double)
   
   func willScrollFromPageIndex(index: Int, toIndex: Int)
   
}

public class SBPagesController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
   
   // MARK: Properties
   
   public weak var dataSource: SBPagesControllerDataSource?
   public weak var delegate: SBPagesControllerDelegate?
   
   private var views: [UIView] = []
   var scrollView: SBScrollView!
   
   private var currentIndex: Int!
   private var currentView: UIView {
      return views[currentIndex]
   }
   
   private var cancelViewDidAppear = false
   
   var initiallyDraggedFromLeft: Bool!
   
   // ScrollView behavior
   var scrollIsCancelled: Bool = false
   
   // MARK: View Lifecycle
   
   override public func viewDidLoad() {
      super.viewDidLoad()
      
      // Initialize & configure scrollView
      scrollView = SBScrollView()
      scrollView.delegate = self
      scrollView.pagingEnabled = true
      scrollView.alwaysBounceVertical = false
      scrollView.showsHorizontalScrollIndicator = false
      scrollView.showsVerticalScrollIndicator = false
      view.addSubview(scrollView)
      constrain(scrollView) { scrollView in
         scrollView.edges == scrollView.superview!.edges
      }
      automaticallyAdjustsScrollViewInsets = false
      
      // Observe
      scrollView.addObserver(scrollView, forKeyPath: "contentOffset", options: [.New, .Old], context: nil)
      
      // Set scrollView closures
      scrollView.willMoveFromIndex = { fromIndex, toIndex in
         self.currentIndex = fromIndex
         self.delegate?.willScrollFromPageIndex(fromIndex, toIndex: toIndex)
      }
      
      scrollView.movingFromIndex = { fromIndex, toIndex, progress in
         self.delegate?.scrollingFromPageIndex(fromIndex, toIndex: toIndex, progress: progress)
      }
      
      // Get all views
      let maximumNumberOfViews = dataSource?.numberOfViews() ?? 0
      for i in 0..<maximumNumberOfViews {
         
         guard let viewController = dataSource?.pagesSlider(viewControllerForIndex: i) else {
            return
         }
         addChildViewController(viewController)
         viewController.didMoveToParentViewController(self)
         
      }
      
      // Get views from view controllers
      views = childViewControllers.map {
         return $0.view
      }
      
      // Add all views to scrollView
      for view in views {
         
         view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
         view.bounds.size = self.scrollView.bounds.size
         self.scrollView.addSubview(view)
         
      }
      
      // At the beginning let's assume that currentIndex and previousIndex are equal
      currentIndex = 0
      
   }
   
   override public func viewWillAppear(animated: Bool) {
      super.viewWillAppear(animated)
      
      // Don't the parent vc to adjust scrollView insets automatically
      parentViewController?.automaticallyAdjustsScrollViewInsets = false
      
      // Send back
      view.superview?.sendSubviewToBack(view)
      
   }
   
   override public func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      
      // Do not observe contentOffset while relayouting subviews
      self.scrollView.removeObserver(self.scrollView, forKeyPath: "contentOffset")
      
      // Set contentSize
      scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(dataSource?.numberOfViews() ?? 0), height: view.bounds.height)
      
      // Set views origin
      for (index, view) in views.enumerate() {
         
         let positionX = self.view.bounds.width * CGFloat(index)
         view.frame.origin = CGPoint(x: positionX, y: 0)
         
      }
      
      // Scroll to to current index
      guard let index = currentIndex else { return }
      scrollToPage(forIndex: index, animated: false)
      
   }
   
   override public func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      
      // Observe contentOffset after relayouting subviews
      scrollView.addObserver(scrollView, forKeyPath: "contentOffset", options: [.New, .Old], context: nil)
      
   }
   
   // MARK: Gesture Recognize Delegate
   
   public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return true
   }
   
   // MARK: ScrollView Delegate
   
   public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
      currentIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
   }
   
   // MARK: Internal Helpers
   
   private func showPageForIndex(index: Int) {
      
      // If index is out of range, then nothing to show
      if index >= views.count || index < 0 {
         return
      }
      
      // Okey, index is not out of range, let's get that view
      let view = views[index]
      
      // Check if that view is not shown
      if view.window != nil {
         return
      }
      
      scrollView.addSubview(view)
      
   }
   
   public func scrollToPage(forIndex index: Int, animated: Bool) {
      
      // Update scrollView direction
      if index > currentIndex {
         scrollView.scrollDirection = .RightToLeft
      } else if index < currentIndex {
         scrollView.scrollDirection = .LeftToRight
      }
      
      // Calculate destination point
      let x = view.bounds.width * CGFloat(index)
      let y: CGFloat = 0
      let point = CGPoint(x: x, y: y)
      
      // Scroll
      scrollView.setContentOffset(point, animated: animated)
      
      // Update currentIndex
      currentIndex = index
      
   }
   
   private func getVisiblePageIndex() -> Int {
      return Int(scrollView.contentOffset.x / view.bounds.width)
   }
   
   func panGestureHandler(recognizer: UIPanGestureRecognizer) {
      
      // Associated view
      guard let view = recognizer.view else { return }
      
      let velocityX = recognizer.velocityInView(view).x
      
      // Switch state
      switch recognizer.state {
         
      case .Began:
         
         // Set bool
         if velocityX != 0 {
            initiallyDraggedFromLeft = velocityX > 0
         }
         
      case .Changed:
         
         if initiallyDraggedFromLeft == nil {
            initiallyDraggedFromLeft = velocityX > 0
         }
         
         
      case .Ended, .Cancelled, .Failed:
         
         break
         
      default: break
         
      }
      
   }
   
}