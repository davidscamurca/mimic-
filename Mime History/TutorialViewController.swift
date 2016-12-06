//
//  TutorialViewController.swift
//  Mime History
//
//  Created by Anderson Oliveira on 05/12/16.
//  Copyright © 2016 Anderson Oliveira. All rights reserved.
//

import UIKit

class TutorialViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    lazy var VCArr: [UIViewController] = {
        return [self.VCInstance(name: "firstVC"), self.VCInstance(name: "fourthVC"), self.VCInstance(name: "thirdVC"), self.VCInstance(name: "secondVC")]
    }()
    
    func VCInstance(name: String) -> UIViewController {
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        if let firstVC = self.VCArr.first {
            
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = self.VCArr.index(of: viewController) else {
            
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            
            return self.VCArr.last
        }
        
        guard self.VCArr.count > previousIndex else {
            
            return nil
        }
        
        return self.VCArr[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = self.VCArr.index(of: viewController) else {
            
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < self.VCArr.count else {
            
            return self.VCArr.first
        }
        
        guard self.VCArr.count > nextIndex else {
            
            return nil
        }
        
        return self.VCArr[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return self.VCArr.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        guard let firstVC = viewControllers?.first, let firstVCIndex = self.VCArr.index(of: firstVC) else {
            
            return 0
        }
        
        return firstVCIndex
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
