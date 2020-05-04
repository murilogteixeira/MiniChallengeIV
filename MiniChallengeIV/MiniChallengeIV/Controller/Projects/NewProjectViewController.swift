//
//  NewProjectViewController.swift
//  MiniChallengeIV
//
//  Created by Murilo Teixeira on 29/04/20.
//  Copyright © 2020 Murilo Teixeira. All rights reserved.
//

import UIKit

protocol NewProjectViewControllerDelegate: AnyObject {
    func reloadList()
}

class NewProjectViewController: UIViewController {

    @IBOutlet weak var projectNameLabel: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

    let projectBO = ProjectBO()
    
    var project: Project?
    var projectName = String()
    var projectColor = UIColor()
    
    weak var delegate: NewProjectViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let project = project {
            projectNameLabel.text = project.name
            deleteButton.isHidden = false
        }
        else {
            deleteButton.isHidden = true
        }
    }
    
    @IBAction func onClickColor(_ sender: UIButton) {
        if let color = sender.backgroundColor {
            projectColor = color
        }
    }
    
    @IBAction func onClickDelete(_ sender: Any) {
        projectBO.delete(uuid: project!.id) { success, error in
            if success {
                delegate?.reloadList()
                dismiss(animated: true)
            }
            else {
                showOkAlert(title: "Error", message: error ?? "")
            }
        }
        
    }
    
    @IBAction func onClickSave(_ sender: Any) {
        saveProject()

    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func saveProject() {
        

    
        guard project == nil else {
            project?.name = projectNameLabel.text ?? ""
            project?.color = projectColor
            projectBO.update(project: project!) { success, error in
                if success {
                    dismiss(animated: true)
                    delegate?.reloadList()

                }
                else {
                    self.showOkAlert(title: "Error", message: error ?? "")
                }
            }
            return
        }

        projectBO.create(name: projectNameLabel.text ?? "MurilloTrouxa", color: UIColor(red: 0.00, green: 0.30, blue: 0.81, alpha: 1.00), completion: { success, error in
            if success {
                dismiss(animated: true)
                delegate?.reloadList()

            }
            else {
                self.showOkAlert(title: "Error", message: error ?? "")

            }
        })
   
        
    }
    
    func showOkAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
}