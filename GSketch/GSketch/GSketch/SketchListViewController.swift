//
//  SketchListViewController.swift
//  GSketch
//
//  Created by user on 11/25/18.
//  Copyright © 2018 user. All rights reserved.
//

import UIKit

class SketchListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var viewController: ViewController?
    var imageNames = ["1", "2", "7", "guse"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SketchViewCell", bundle: nil),  forCellReuseIdentifier:"SketchViewCell")
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SketchListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "SketchViewCell", for: indexPath) as? SketchViewCell)!
        cell.imageContent.image = UIImage(named: self.imageNames[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            self.viewController?.selectImage(imageName: self.imageNames[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 244
    }
    
}

extension SketchListViewController: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
}
