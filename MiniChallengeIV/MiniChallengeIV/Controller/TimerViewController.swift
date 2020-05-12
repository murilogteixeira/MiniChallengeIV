//
//  TimerViewController.swift
//  MiniChallengeIV
//
//  Created by Fábio Maciel de Sousa on 29/04/20.
//  Copyright © 2020 Murilo Teixeira. All rights reserved.
//

import UIKit

///Place holder ViewController
class TimerViewController: UIViewController {
    
    //Atributes
    
    
    let timeTracker = TimeTrackerBO()
    var lostTimeFocus: TimeRecoverBO?
    var id: UUID?
    var project: Project?
    let projectBO = ProjectBO()
    let taskBO = TaskBO()
    var taskField = ""
    //Properties
    ///the validation for the minimum value
    var minimumDecrement: Int{
        //TODO: switch 0 for a generic number
        return timeTracker.configTime - 5  < 15 ? 15 : timeTracker.configTime - 5
    }
    ///the validation for the maximum value
    var maximumDecrement: Int{
        //TODO: switch 60 for a generic number
        return timeTracker.configTime + 5  > 60 ? 60 : timeTracker.configTime + 5
    }
    
    //Buttons, Labels
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet var timeConfigButtons: [UIButton]!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var projectColor: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProject()
        
        self.btnStart.layer.cornerRadius = 25.0
        self.tableView.separatorColor = .clear
        
        // Do any additional setup after loading the view.
        timerLabel.text = String(format: "%02i:00", timeTracker.configTime)
        
        timeTracker.state = .focus
        
        self.lostTimeFocus = TimeRecoverBO(timer: timeTracker)
        
        /// Get Scene Deleegate
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            sd.timer = self.timeTracker
            sd.lostTimeFocus = self.lostTimeFocus
        }
        
        self.stateLabel.text = project?.name
        projectColor.backgroundColor = project?.color
        projectColor.layer.cornerRadius = 15.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        view.endEditing(true)
    }
    
    func loadProject(){
        guard let id = self.id else { return }
        projectBO.fetch(id: id, completion: { result in
            switch result {
            case .success(let project):
                self.project = project
                
                tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        })
    }
    
    
    //MARK: START TIMER
    @IBAction func startTimer(_ sender: UIButton) {
        if timeTracker.timer.isValid { // If it's running it stops instead
            stopTimer(sender)
            return
        }
        sender.setTitle("Stop", for: .normal)
        
        timeTracker.startTimer {time, hasEnded in
            self.timerLabel.text = time
            if hasEnded{ // Focus timer ended
                sender.setTitle("Start", for: .normal)
                self.stateLabel.text = self.timeTracker.state.rawValue
                self.setConfigurationButtons()
            }
        }
        setConfigurationButtons()
    }
    
    //MARK: STOP TIMER
    func stopTimer(_ sender: UIButton) {
        sender.setTitle("Start", for: .normal)
        
        timeTracker.stopTimer(){
            //TODO: Message for when the user gives up
            self.stateLabel.text = self.timeTracker.state.rawValue
            self.timerLabel.text = String(format: "%02i:00", self.timeTracker.configTime)
        }
        setConfigurationButtons()
    }
    
    
    ///Increment timer for the count down
    @IBAction func incrementTimer(_ sender: Any) {
        timeTracker.configTime = maximumDecrement
        timerLabel.text = String(format: "%02i:00", timeTracker.configTime)
    }
    ///Decrement timer for the count down
    @IBAction func decrementTimer(_ sender: Any) {
        timeTracker.configTime = minimumDecrement
        timerLabel.text = String(format: "%02i:00", timeTracker.configTime)
    }
    
    ///Method for disabling the buttons that are configuring the Timer
    func setConfigurationButtons(){
        let value = timeTracker.state == .focus ? true : false
        for button in timeConfigButtons{
            button.isEnabled = value
        }
    }
    
}

extension TimerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tasks = self.project?.tasks, tasks.count > 0 {
            return tasks.count+1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        
        cell.taskTextField.delegate = self
        cell.taskTextField.tag = indexPath.row
        cell.btnCheck.tag = indexPath.row
        cell.delegate = self
        
        if let tasks = project?.tasks, indexPath.row != tasks.count{
            cell.btnCheck.setImage(UIImage(named: "check"), for: .normal)
            cell.btnCheck.isSelected = tasks[indexPath.row].state
            cell.taskTextField.text = tasks[indexPath.row].description
            cell.btnCheck.btnType = .select
        }else {
            cell.btnCheck.setImage(UIImage(named: "btnAdd"), for: .normal)
            cell.taskTextField.text = "Add Task"
            cell.btnCheck.btnType = .add
        }
        
        return cell
    }
    
    
}

// Tex field

extension TimerViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let tasks = project?.tasks else { return }
        if textField.tag+1 < tasks.count{
            
            var actuallyTask = tasks[textField.tag]
            actuallyTask.description = textField.text!
            
            taskBO.update(task: actuallyTask, completion: {result in
                switch result {
                    
                case .success():
                    loadProject()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
}


extension TimerViewController: TaskBtnDelegate {
    func changeBtnState(isSelected: Bool, index: Int) {
        guard let tasks = project?.tasks else { return }
        var task = tasks[index]
        task.state = isSelected
        
        taskBO.update(task: task, completion: { result in
            switch result {
                
            case .success():
                loadProject()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func addTask(){
        guard let tasks = self.project?.tasks else { return }
        
        if let myCell = tableView.cellForRow(at: IndexPath(row: tasks.count, section: 0)) as? TaskTableViewCell, let description =
            myCell.taskTextField.text {
            
            guard let projectCD = project?.projectCD else { return }
            projectBO.addTask(description: description, projectCD: projectCD, completion: { result in
                
                switch result{
                    
                case .success():
                    loadProject()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
}
