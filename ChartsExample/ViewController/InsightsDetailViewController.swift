//
//  InsightsDetailViewController.swift
//  ChartsExample
//
//  Created by Ethan Lillie on 11/6/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit

class InsightsDetailViewController: UIViewController {

    var graphVC: UIViewController?
    var graphDetailVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        graphVC = PainGraphViewController.instantiateViewControllerFromStoryboard()
        addChildViewController(graphVC ?? UIViewController())
        view.addSubview(graphVC?.view ?? UIView())

        graphDetailVC = UIViewController()
        addChildViewController(graphDetailVC ?? UIViewController())
        view.addSubview(graphDetailVC?.view ?? UIView())
        graphDetailVC?.view.backgroundColor = .purple

        setConstraints()
    }

    private func setConstraints() {

        guard let graphView = graphVC?.view, let graphDetailView = graphDetailVC?.view else {
            fatalError("No views to speak of!")
        }

        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphDetailView.translatesAutoresizingMaskIntoConstraints = false

        graphView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        graphView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        graphView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        graphView.bottomAnchor.constraint(equalTo: graphDetailView.topAnchor).isActive = true

        graphDetailView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        graphDetailView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        graphDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        graphView.heightAnchor.constraint(equalTo: graphDetailView.heightAnchor, multiplier: 2.0).isActive = true

        view.layoutSubviews()
    }
}
