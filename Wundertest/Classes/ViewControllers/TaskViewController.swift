//
//  TaskViewController.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import MessageUI
import Async
import PullToRefresh
import RealmSwift

class TaskViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, TaskSectionHeaderViewDelegate, TaskCellDelegate, ComposeTaskViewControllerDelegate, MFMailComposeViewControllerDelegate {

    private var tableView = UITableView(frame: .zero, style: .plain)
    private var noTaskLabel = UILabel()
    private var toolBar = UIToolbar()
    private var exportButton = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
    private var sortButton = UIBarButtonItem(image: UIImage(named: "sort"), style: .plain, target: nil, action: nil)
    private var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private var pullToAddView: PullToAddView?
    private var pullToAddControl: PullToRefresh?
    
    private var toolBarHeightConstraint = NSLayoutConstraint()

    private var tasks: Results<Task> {
        get {
            if (self._tasks == nil) {
                self._tasks = TaskManager.sharedInstance.getTasks(from: RealmManager.sharedInstance.realm)
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
        self.tableView.removePullToRefresh(at: .top)
    }
    
    // MARK: - Implementation of UITableViewDataSource Protocols
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.navigationItem.rightBarButtonItem?.isEnabled = (self.incompletedTasks.count > 0)
        self.noTaskLabel.isHidden = (self.tasks.count > 0)
        self.exportButton.isEnabled = (self.tasks.count > 0)
        self.sortButton.isEnabled = (self.tasks.count > 0)
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
        header.titleLabel.attributedText = NSAttributedString(string: headerTitle, attributes: FONT_ATTR_MEDIUM_BLACK)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.showsReorderControl = true
        let tasks = ((indexPath.section == 0) ? self.incompletedTasks : self.completedTasks)
        let task = tasks[indexPath.row]
        cell.titleLabel.attributedText = nil
        cell.dueDateLabel.attributedText = nil
        var attributes: [NSAttributedStringKey: Any] = FONT_ATTR_LARGE_BLACK
        if (task.isCompleted) {
            attributes[NSAttributedStringKey.strikethroughStyle] = NSUnderlineStyle.styleSingle.rawValue
        }
        cell.titleLabel.attributedText = NSAttributedString(string: task.title, attributes: attributes)
        if (indexPath.section == 0) {
            if let date = task.dueDate {
                let calendar = Calendar.current

                let todayYear = calendar.component(.year, from: Date())
                let todayMonth = calendar.component(.month, from: Date())
                let todayDay = calendar.component(.day, from: Date())

                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                
                let attributes: [NSAttributedStringKey: Any] = ((todayYear >= year && todayMonth >= month && todayDay > day) ? FONT_ATTR_SMALL_RED : FONT_ATTR_SMALL_DEFAULT_TINT)
                let date = String(format: "%d-%d-%d", day, month, year)
                cell.dueDateLabel.attributedText = NSAttributedString(string: date, attributes: attributes)
            }
        }
        cell.checkBoxImageView.image = ((task.isCompleted) ? UIImage(named: "tick_white") : nil)
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
        self.tableView.beginUpdates()
        self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        self.tableView.endUpdates()
    }
    
    // MARK: - Implementation of TaskCellDelegate Protocols
    
    func completed(indexPath: IndexPath) {
        let tasks = ((indexPath.section == 0) ? self.incompletedTasks : self.completedTasks)
        let task = tasks[indexPath.row]
        let realm = RealmManager.sharedInstance.realm
        let isCompleted = !task.isCompleted
        TaskManager.sharedInstance.update(taskId: task.id, isCompleted: isCompleted, order: (isCompleted ? -1 : 0), realm: realm)
        self.getIncompletedTasks()
        self.getCompletedTasks()
        
        self.tableView.reloadData()
        self.updateTasksOrder()
        self.tableView.setContentOffset(.zero, animated: true)
    }
    
    // MARK: - Implementation of ComposeTaskViewControllerDelegate Protocols
    
    func composed() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.getIncompletedTasks()
        self.getCompletedTasks()
        self.tableView.reloadData()
        self.updateTasksOrder()
    }
    
    func saved() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.tableView.reloadData()
    }
    
    func cancel() {
        self.navigationItem.rightBarButtonItem?.isEnabled = (self.incompletedTasks.count > 0)
    }
    
    // MARK: - Implementation of MFMailComposeViewControllerDelegate Protocols
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)

        switch (result) {
        case .sent:
            let sentAlertController = UIAlertController(title: nil, message: NSLocalizedString("sent.message", comment: ""), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("ok.title", comment: ""), style: .cancel, handler: nil)
            sentAlertController.addAction(cancelAction)
            self.navigationController?.present(sentAlertController, animated: true, completion: nil)

        case .failed:
            let failedAlertController = UIAlertController(title: nil, message: NSLocalizedString("failed.message", comment: ""), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("ok.title", comment: ""), style: .cancel, handler: nil)
            failedAlertController.addAction(cancelAction)
            self.navigationController?.present(failedAlertController, animated: true, completion: nil)
            
        default:
            // No alert for MFMailComposeResultCancelled, MFMailComposeResultSaved
            break;
        }
    }
    
    // MARK: - Events
    
    @objc func rightBarButtonAction() {
        self.tableView.setEditing(!(self.tableView.isEditing), animated: true)
        let itemType = ((self.tableView.isEditing) ? UIBarButtonSystemItem.done : UIBarButtonSystemItem.edit)
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: itemType, target: self, action: .rightBarButtonAction)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
        self.tableView.alwaysBounceVertical = !(self.tableView.isEditing)
    }
    
    @objc func exportButtonAction() {
        let exportAlertController = UIAlertController(title: NSLocalizedString("export.title", comment: ""), message: nil, preferredStyle: .actionSheet)
        let exportByCDAction = UIAlertAction(title: NSLocalizedString("exportByCD.title", comment: ""), style: .default, handler: { [unowned self] (action) in
            let csvFileURL = TaskManager.sharedInstance.exportTasksToCSV(sortBy: .createdDate, realm: RealmManager.sharedInstance.realm)
            self.exportCSVFileByEmail(url: csvFileURL)
        })
        let exportByAOAction = UIAlertAction(title: NSLocalizedString("exportByAO.title", comment: ""), style: .default, handler: { [unowned self] (action) in
            let csvFileURL = TaskManager.sharedInstance.exportTasksToCSV(sortBy: .alphabeticalOrder, realm: RealmManager.sharedInstance.realm)
            self.exportCSVFileByEmail(url: csvFileURL)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel.title", comment: ""), style: .cancel, handler: nil)
        exportAlertController.addAction(exportByCDAction)
        exportAlertController.addAction(exportByAOAction)
        exportAlertController.addAction(cancelAction)
        if (IS_IPAD) {
            exportAlertController.popoverPresentationController?.sourceView = self.navigationController!.view
            exportAlertController.popoverPresentationController?.barButtonItem = self.sortButton
            exportAlertController.popoverPresentationController?.canOverlapSourceViewRect = true
        }
        self.navigationController?.present(exportAlertController, animated: true, completion: nil)
    }
    
    @objc func sortButtonAction() {
        let sortAlertController = UIAlertController(title: NSLocalizedString("sort.title", comment: ""), message: nil, preferredStyle: .actionSheet)
        let sortByCDAction = UIAlertAction(title: NSLocalizedString("sortByCD.title", comment: ""), style: .default, handler: { [unowned self] (action) in
            self.getIncompletedTasks(sortBy: .createdDate)
            self.tableView.reloadData()
            self.updateTasksOrder()
        })
        let sortByAOAction = UIAlertAction(title: NSLocalizedString("sortByAO.title", comment: ""), style: .default, handler: { [unowned self] (action) in
            self.getIncompletedTasks(sortBy: .alphabeticalOrder)
            self.tableView.reloadData()
            self.updateTasksOrder()
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel.title", comment: ""), style: .cancel, handler: nil)
        sortAlertController.addAction(sortByCDAction)
        sortAlertController.addAction(sortByAOAction)
        sortAlertController.addAction(cancelAction)
        if (IS_IPAD) {
            sortAlertController.popoverPresentationController?.sourceView = self.navigationController!.view
            sortAlertController.popoverPresentationController?.barButtonItem = self.sortButton
            sortAlertController.popoverPresentationController?.canOverlapSourceViewRect = true
        }
        self.navigationController?.present(sortAlertController, animated: true, completion: nil)
    }
    
    @objc func addButtonAction() {
        self.composeTask()
    }
    
    // MARK: - Public Methods
    
    override func setup() {
        super.setup()
    }
    
    func composeTask() {
        guard !(self.tableView.isEditing) else {
            self.tableView.endRefreshing(at: .top)
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
        self.tableView.endRefreshing(at: .top)
    }

    // MARK: - Private Methods
    
    private func getIncompletedTasks(sortBy type: SortType = .order) {
        let realm = RealmManager.sharedInstance.realm
        self.incompletedTasks.removeAll()
        TaskManager.sharedInstance.getIncompletedTasks(sortBy: type, from: realm).forEach { (task) in
            self.incompletedTasks.append(task)
        }
    }
    
    private func getCompletedTasks() {
        let realm = RealmManager.sharedInstance.realm
        self.completedTasks.removeAll()
        TaskManager.sharedInstance.getCompletedTasks(from: realm).forEach { (task) in
            self.completedTasks.append(task)
        }
    }
    
    private func deleteTaskAt(indexPath: IndexPath) {
        var tasks = ((indexPath.section == 0) ? self.incompletedTasks : self.completedTasks)
        let task = tasks[indexPath.row]
        tasks.remove(at: indexPath.row)
        TaskManager.sharedInstance.delete(task: task, realm: RealmManager.sharedInstance.realm)
        self.getIncompletedTasks()
        self.getCompletedTasks()
        
        if (tasks.count == 0) {
            self.tableView.reloadData()
        } else {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
        self.updateTasksOrder()
    }
    
    private func updateTasksOrder() {
        let realm = RealmManager.sharedInstance.realm
        for (index, task) in self.incompletedTasks.enumerated() {
            TaskManager.sharedInstance.update(taskId: task.id, order: (index + 1), realm: realm)
        }
    }
    
    private func exportCSVFileByEmail(url: URL) {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setSubject(NSLocalizedString("export.title", comment: ""))
        let data = try! Data(contentsOf: url)
        mailComposeViewController.addAttachmentData(data, mimeType: "text/csv", fileName: url.lastPathComponent)
        self.navigationController?.present(mailComposeViewController, animated: true, completion: nil)
    }
    
    // MARK: - Subviews
    
    private func setupTableView() {
        self.tableView.backgroundColor = .white
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: TOOL_BAR_HEIGHT))
        self.tableView.rowHeight = GENERAL_CELL_HEIGHT
        self.tableView.separatorStyle = .singleLine
        
        self.pullToAddView = PullToAddView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: PULL_TO_ADD_VIEW_HEIGHT))
        let pullToAddAnimator = PullToAddAnimator(pullToAddView: self.pullToAddView!)
        self.pullToAddControl = PullToRefresh(refreshView: self.pullToAddView!, animator: pullToAddAnimator, height: 0.0, position: .top)
        self.pullToAddControl?.hideDelay = 2.0 * ANIMATION_DURATION
        self.pullToAddControl?.animationDuration = ANIMATION_DURATION
        self.pullToAddControl?.springDamping = 1.0
        self.pullToAddControl?.initialSpringVelocity = 0.0
        self.tableView.addPullToRefresh(self.pullToAddControl!, action: { [unowned self] in
            self.composeTask()
        })
    }
    
    private func setupNoTaskLabel() {
        self.noTaskLabel.backgroundColor = .clear
        self.noTaskLabel.numberOfLines = 1
        self.noTaskLabel.textAlignment = .center
        self.noTaskLabel.attributedText = NSAttributedString(string: NSLocalizedString("pullToAdd.message", comment: ""), attributes: FONT_ATTR_LARGE_BLACK)
        self.noTaskLabel.isUserInteractionEnabled = false
    }
    
    private func setupToolBar() {
        self.toolBar.barStyle = .default
        self.toolBar.tintColor = TINT_COLOUR
        
        self.exportButton.target = self
        self.exportButton.action = .exportButtonAction
        self.sortButton.target = self
        self.sortButton.action = .sortButtonAction
        self.addButton.target = self
        self.addButton.action = .addButtonAction
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.toolBar.items = [self.exportButton, flexibleSpace, self.sortButton, flexibleSpace, self.addButton]
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        self.setupTableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        
        self.setupNoTaskLabel()
        self.noTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.noTaskLabel)

        self.setupToolBar()
        self.toolBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.toolBar)
    }
    
    override func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["table": self.tableView,
                                        "noTask": self.noTaskLabel,
                                        "bar": self.toolBar]
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[table]|", options: .directionMask, metrics: nil, views: views))

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[noTask]|", options: .directionMask, metrics: nil, views: views))

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[bar]|", options: .directionMask, metrics: nil, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[table]|", options: .directionMask, metrics: nil, views: views))

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[noTask]|", options: .directionMask, metrics: nil, views: views))

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bar]|", options: .directionMask, metrics: nil, views: views))
            
            self.toolBarHeightConstraint = NSLayoutConstraint(item: self.toolBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: TOOL_BAR_HEIGHT)
            self.view.addConstraint(self.toolBarHeightConstraint)

            self.hasLoadedConstraints = true
        }
        if #available(iOS 11.0, *) {
            let bottomPadding = self.view.safeAreaInsets.bottom
            self.tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: bottomPadding + TOOL_BAR_HEIGHT))
            self.toolBarHeightConstraint.constant = bottomPadding + TOOL_BAR_HEIGHT
        } else {
            self.tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: TOOL_BAR_HEIGHT))
            self.toolBarHeightConstraint.constant = TOOL_BAR_HEIGHT
        }

        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.pullToAddView?.layoutSubviews()
        self.updateViewConstraints()
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: .rightBarButtonAction)
        self.navigationItem.rightBarButtonItem = editBarButton
        
        self.tableView.register(TaskSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "TaskSectionHeaderView")
        self.tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        
        self.getIncompletedTasks()
        self.getCompletedTasks()
        self.tableView.reloadData()
    }
}

private extension Selector {
    static let rightBarButtonAction = #selector(TaskViewController.rightBarButtonAction)
    static let exportButtonAction = #selector(TaskViewController.exportButtonAction)
    static let sortButtonAction = #selector(TaskViewController.sortButtonAction)
    static let addButtonAction = #selector(TaskViewController.addButtonAction)
}
