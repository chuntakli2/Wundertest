//
//  TaskViewController.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import Async
import PullToRefresh
import RealmSwift

class TaskViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, TaskSectionHeaderViewDelegate, TaskCellDelegate, ComposeTaskViewControllerDelegate {

    private var noTaskLabel: UILabel?
    private var tableView: UITableView?
    private var pullToAddView: PullToAddView?
    private var pullToAddControl: PullToRefresh?

    private var tasks: Results<Task> {
        get {
            if (self._tasks == nil) {
                self._tasks = TaskManager.sharedInstance.getTasksFrom(realm: RealmManager.sharedInstance.realm)
            }
            return _tasks!
        }
    }
    private var _tasks: Results<Task>?
    private var incompletedTasks = [Task]()
    private var completedTasks = [Task]()

    private var isExpanded = false
    
    private var hasLoadedConstraints = false
    
    // MARK: - Initialisation
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        self.tableView?.removePullToRefresh((self.tableView?.topPullToRefresh)!)
    }
    
    // MARK: - Implementation of UITableViewDataSource Protocols
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.navigationItem.rightBarButtonItem?.isEnabled = (self.incompletedTasks.count > 0)
        self.noTaskLabel?.isHidden = (self.tasks.count > 0)
        return (self.tasks.count == 0 ? 0 : ((self.completedTasks.count > 0) ? 2 : 1))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((section == 0) ? self.incompletedTasks.count : (self.isExpanded ? self.completedTasks.count : 0))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ((section == 0) ? 0.0 : GENERAL_ITEM_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard (section != 0) else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TaskSectionHeaderView") as! TaskSectionHeaderView
        header.delegate = self
        let headerTitle = ((self.isExpanded) ? NSLocalizedString("hideCompleted.title", comment: "") : NSLocalizedString("showCompleted.title", comment: ""))
        header.titleLabel?.attributedText = NSAttributedString(string: headerTitle, attributes: FONT_ATTR_MEDIUM_BLACK)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.showsReorderControl = true
        let tasks = ((indexPath.section == 0) ? self.incompletedTasks : self.completedTasks)
        let task = tasks[indexPath.row]
        cell.titleLabel?.attributedText = nil
        cell.dueDateLabel?.attributedText = nil
        var attributes: [String: Any] = FONT_ATTR_LARGE_BLACK
        if (task.isCompleted) {
            attributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
        }
        cell.titleLabel?.attributedText = NSAttributedString(string: task.title, attributes: attributes)
        if (indexPath.section == 0) {
            if let date = task.dueDate {
                let calendar = Calendar.current
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                let date = String(format: "%d-%d-%d", day, month, year)
                cell.dueDateLabel?.attributedText = NSAttributedString(string: date, attributes: FONT_ATTR_SMALL_DEFAULT_TINT)
            }
        }
        cell.checkBoxImageView?.image = ((task.isCompleted) ? UIImage(named: "tick_white") : nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 0)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if (sourceIndexPath != destinationIndexPath) {
            let task = self.incompletedTasks[sourceIndexPath.row]
            self.incompletedTasks.remove(at: sourceIndexPath.row)
            self.incompletedTasks.insert(task, at: destinationIndexPath.row)
            self.updateTasksOrder()
        }
    }

    // MARK: - Implementation of UITableViewDelegate Protocols
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return (tableView.isEditing ? .none : .delete)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tasks = ((indexPath.section == 0) ? self.incompletedTasks : self.completedTasks)
        let task = tasks[indexPath.row]
        let composeTaskViewController = ComposeTaskViewController()
        composeTaskViewController.delegate = self
        composeTaskViewController.task = task
        self.navigationController?.pushViewController(composeTaskViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("delete.title", comment: "")) { [unowned self] (action, indexPath) in
            self.deleteTaskAt(indexPath: indexPath)
        }
        deleteAction.backgroundColor = .red
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return ((proposedDestinationIndexPath.section == 1) ? sourceIndexPath : proposedDestinationIndexPath)
    }
    
    // MARK: - Implementation of TaskSectionHeaderViewDelegate Protocols
    
    func toggleClicked(section: Int) {
        self.isExpanded = !self.isExpanded
        self.tableView?.beginUpdates()
        self.tableView?.reloadSections(IndexSet(integer: 1), with: .automatic)
        self.tableView?.endUpdates()
    }
    
    // MARK: - Implementation of TaskCellDelegate Protocols
    
    func completed(indexPath: IndexPath) {
        let tasks = ((indexPath.section == 0) ? self.incompletedTasks : self.completedTasks)
        let task = tasks[indexPath.row]
        let realm = RealmManager.sharedInstance.realm
        try! realm.write {
            task.isCompleted = !task.isCompleted
            task.lastUpdatedDate = Date()
            task.order = ((task.isCompleted) ? -1 : 0)
        }
        self.separateTasks()
        
        self.tableView?.reloadData()
        self.updateTasksOrder()
        self.tableView?.setContentOffset(.zero, animated: true)
    }
    
    // MARK: - Implementation of ComposeTaskViewControllerDelegate Protocols
    
    func composed() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.separateTasks()
        self.tableView?.reloadData()
        self.updateTasksOrder()
    }
    
    func saved() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.tableView?.reloadData()
    }
    
    func cancel() {
        self.navigationItem.rightBarButtonItem?.isEnabled = (self.incompletedTasks.count > 0)
    }
    
    // MARK: - Events
    
    func rightBarButtonAction() {
        self.tableView?.setEditing(!(self.tableView!.isEditing), animated: true)
        let rightBarButtonItem = ((self.tableView!.isEditing) ? UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .rightBarButtonAction) : UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: .rightBarButtonAction))
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
        self.tableView?.alwaysBounceVertical = !(self.tableView?.isEditing)!
    }
    
    // MARK: - Public Methods
    
    override func setup() {
        super.setup()
    }
    
    func composeTask() {
        guard !(self.tableView?.isEditing)! else {
            self.tableView?.endRefreshing(at: .top)
            return
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        let composeTaskViewController = ComposeTaskViewController()
        composeTaskViewController.delegate = self
        
        self.addChildViewController(composeTaskViewController)
        composeTaskViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(composeTaskViewController.view)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[compose]|", options: .directionMask, metrics: nil, views: ["compose": composeTaskViewController.view!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[compose]|", options: .directionMask, metrics: nil, views: ["compose": composeTaskViewController.view!]))
        self.tableView?.endRefreshing(at: .top)
    }

    // MARK: - Private Methods
    
    private func getTasks() {
        // TODO: Get tasks from server and update the local database
    }
    
    private func separateTasks() {
        let realm = RealmManager.sharedInstance.realm
        self.incompletedTasks.removeAll()
        self.completedTasks.removeAll()
        TaskManager.sharedInstance.getIncompletedTasksFrom(realm: realm).forEach { (task) in
            self.incompletedTasks.append(task)
        }
        TaskManager.sharedInstance.getCompletedTasksFrom(realm: realm).forEach { (task) in
            self.completedTasks.append(task)
        }
    }
    
    private func deleteTaskAt(indexPath: IndexPath) {
        var tasks = ((indexPath.section == 0) ? self.incompletedTasks : self.completedTasks)
        let task = tasks[indexPath.row]
        tasks.remove(at: indexPath.row)
        TaskManager.sharedInstance.delete(task: task, realm: RealmManager.sharedInstance.realm)
        self.separateTasks()
        
        if (tasks.count == 0) {
            self.tableView?.reloadData()
        } else {
            self.tableView?.beginUpdates()
            self.tableView?.deleteRows(at: [indexPath], with: .automatic)
            self.tableView?.endUpdates()
        }
        self.updateTasksOrder()
    }
    
    private func updateTasksOrder() {
        let realm = RealmManager.sharedInstance.realm
        realm.beginWrite()
        for (index, task) in self.incompletedTasks.enumerated() {
            task.order = index + 1
            task.orderTimestamp = Date.getCurrentTimestampInMilliseconds()
        }
        try! realm.commitWrite()
    }
    
    // MARK: - Subviews
    
    private func setupTableView() {
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.tableView?.backgroundColor = .clear
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.tableHeaderView = UIView()
        self.tableView?.tableFooterView = UIView()
        self.tableView?.rowHeight = GENERAL_CELL_HEIGHT
        self.tableView?.separatorStyle = .singleLine
        
        self.pullToAddView = PullToAddView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: PULL_TO_ADD_VIEW_HEIGHT))
        let pullToAddAnimator = PullToAddAnimator(pullToAddView: self.pullToAddView!)
        self.pullToAddControl = PullToRefresh(refreshView: self.pullToAddView!, animator: pullToAddAnimator, height: 0.0, position: .top)
        self.pullToAddControl?.hideDelay = 2.0 * ANIMATION_DURATION
        self.pullToAddControl?.animationDuration = ANIMATION_DURATION
        self.pullToAddControl?.springDamping = 1.0
        self.pullToAddControl?.initialSpringVelocity = 0.0
        self.tableView?.addPullToRefresh(self.pullToAddControl!, action: { [unowned self] in
            self.composeTask()
        })
    }
    
    private func setupNoTaskLabel() {
        self.noTaskLabel = UILabel()
        self.noTaskLabel?.numberOfLines = 1
        self.noTaskLabel?.textAlignment = .center
        self.noTaskLabel?.attributedText = NSAttributedString(string: NSLocalizedString("pullToAdd.message", comment: ""), attributes: FONT_ATTR_LARGE_BLACK)
        self.noTaskLabel?.isUserInteractionEnabled = false
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        self.setupTableView()
        self.tableView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView!)
        
        self.setupNoTaskLabel()
        self.noTaskLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.noTaskLabel!)
    }
    
    override func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["table": self.tableView!,
                                        "noTask": self.noTaskLabel!]
            
            let metrics = ["WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": GENERAL_ITEM_HEIGHT,
                           "SMALL_SPACING": SMALL_SPACING]

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[table]|", options: .directionMask, metrics: nil, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[noTask]|", options: .directionMask, metrics: nil, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[table]|", options: .directionMask, metrics: metrics, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[noTask]|", options: .directionMask, metrics: metrics, views: views))
            
            self.hasLoadedConstraints = true
        }
        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.pullToAddView?.layoutSubviews()
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: .rightBarButtonAction)
        self.navigationItem.rightBarButtonItem = editBarButton
        
        self.tableView?.register(TaskSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "TaskSectionHeaderView")
        self.tableView?.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        
        self.separateTasks()
        self.tableView?.reloadData()
        Async.background({ [unowned self] in
            self.getTasks()
        })
    }
}

private extension Selector {
    static let rightBarButtonAction = #selector(TaskViewController.rightBarButtonAction)
}
