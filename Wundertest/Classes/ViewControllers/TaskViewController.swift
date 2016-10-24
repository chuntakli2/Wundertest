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

class TaskViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, TaskSectionHeaderViewDelegate {

    private var noTaskLabel: UILabel?
    private var tableView: UITableView?
    private var pullToAddView: PullToAddView?
    private var pullToAddControl: PullToRefresh?

    private var tasks: Results<Task> {
        get {
            if (self._tasks == nil) {
                self._tasks = TaskManager.sharedInstance.getTasksFromLocal(realm: RealmManager.sharedInstance.realm)
                self.isEmptyTask = !(self._tasks!.count > 0)
            }
            return _tasks!
        }
    }
    private var _tasks: Results<Task>?
    private var incompletedTasks = [Task]()
    private var completedTasks = [Task]()
    private var displayedTasks = [Task]()
    private var isEmptyTask = false
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
    
    // MARK: - Accessors
    
    // MARK: - Implementation of UITableViewDataSource Protocols
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.isEmptyTask ? 0 : ((self.completedTasks.count > 0) ? 2 : 1))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((section == 0) ? self.incompletedTasks.count : self.displayedTasks.count)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TaskSectionHeaderView") as! TaskSectionHeaderView
        header.delegate = self
        header.isUserInteractionEnabled = (section != 0)
        let headerTitle = ((section == 0) ? "In progress" : ((self.isExpanded) ? "Hide Completed" : "Show Completed"))
        header.titleLabel?.attributedText = NSAttributedString(string: headerTitle, attributes: FONT_ATTR_MEDIUM_BLACK)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.showsReorderControl = true
        cell.titleLabel?.attributedText = NSAttributedString(string: "Setting", attributes: FONT_ATTR_LARGE_WHITE)
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
            print("moved: %@, %@", sourceIndexPath, destinationIndexPath)
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
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("edit.title", comment: "")) { (action, indexPath) in
            
        }
        editAction.backgroundColor = .blue
        let deleteAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("delete.title", comment: "")) { (action, indexPath) in

        }
        deleteAction.backgroundColor = .red
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return ((proposedDestinationIndexPath.section == 1) ? sourceIndexPath : proposedDestinationIndexPath)
    }
    
    // MARK: - Implementation of TaskSectionHeaderViewDelegate Protocols
    
    func toggleClicked(section: Int) {
        self.isExpanded = !self.isExpanded
        if self.isExpanded {
            self.displayedTasks.append(contentsOf: self.completedTasks)
        } else {
            self.displayedTasks.removeAll()
        }
        
        self.tableView?.beginUpdates()
        self.tableView?.reloadSections(IndexSet(integer: 1), with: .automatic)
        self.tableView?.endUpdates()
    }
    
    // MARK: - Implementation of TaskCellDelegate Protocols
    
    // MARK: - Implementation of ComposeTaskViewDelegate Protocols
    
    func composed(task: Task) {
        let task = Task()
        task.title = "Testing Task"
        let realm = RealmManager.sharedInstance.realm
        realm.beginWrite()
        realm.add(task)
        try! realm.commitWrite()
        self.separateTasks()
        
        self.tableView?.endRefreshing(at: .top)
    }
    
    // MARK: - Events
    
    func editBarButtonAction() {
        self.tableView?.setEditing(!(self.tableView!.isEditing), animated: true)
        let rightBarButtonItem = ((self.tableView!.isEditing) ? UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .editBarButtonAction) : UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: .editBarButtonAction))
        rightBarButtonItem.tintColor = .white
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
    }
    
    // MARK: - Public Methods
    
    override func setup() {
        super.setup()
    }
    
    // MARK: - Private Methods
    
    private func getTasks() {
        // TODO: Get tasks from server and update the local database
    }
    
    private func separateTasks() {
        self.incompletedTasks.removeAll()
        self.completedTasks.removeAll()
        self.displayedTasks.removeAll()
        self.tasks.forEach { (task) in
            if (task.isCompleted) {
                self.completedTasks.append(task)
                if (self.isExpanded) {
                    self.displayedTasks.append(task)
                }
            } else {
                self.incompletedTasks.append(task)
            }
        }
        self.tableView?.reloadData()
    }
    
    private func composeTask() {
        
    }
    
    // MARK: - Subviews
    
    private func setupTableView() {
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.tableView?.backgroundColor = .clear
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.tableHeaderView = UIView()
        self.tableView?.tableFooterView = UIView()
        self.tableView?.sectionHeaderHeight = GENERAL_ITEM_HEIGHT
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
        self.noTaskLabel?.attributedText = NSAttributedString(string: "Pull to add new task", attributes: FONT_ATTR_LARGE_BLACK)
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
                           "STATUS_BAR_HEIGHT": STATUS_BAR_HEIGHT,
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
        
        self.noTaskLabel?.isHidden = !self.isEmptyTask
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: .editBarButtonAction)
        editBarButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = editBarButton
        
        self.tableView?.register(TaskSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "TaskSectionHeaderView")
        self.tableView?.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        
        self.separateTasks()
        Async.background({ [unowned self] in
            self.getTasks()
        })
    }
}

private extension Selector {
    static let editBarButtonAction = #selector(TaskViewController.editBarButtonAction)
}
