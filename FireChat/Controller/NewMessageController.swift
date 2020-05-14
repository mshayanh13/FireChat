//
//  NewMessageController.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/13/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit

private let reuseIdentifier = "UserCell"

protocol NewMessageControllerDelegate: class {
    func controller(_ controller: NewMessageController, wantsToStartChatWithUser user: User)
}

class NewMessageController: UITableViewController {
    
    //MARK: Properties
    
    private var users = [User]()
    weak var delegate: NewMessageControllerDelegate?
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
    }
    
    //MARK: Selector
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: API
    
    func fetchUsers() {
        Service.fetchUsers() { (users) in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    //MARK: Helpers
    
    func configureUI() {
        configureNavigationBar(withTitle: "New Message", prefersLargeTitles: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismissal))
        
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 80
    }
    
}

//MARK: UITableViewDataSource

extension NewMessageController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? UserCell else { return UserCell() }
        cell.user = users[indexPath.row]
        return cell
    }
}

//MARK: UITableViewDelegate

extension NewMessageController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        delegate?.controller(self, wantsToStartChatWithUser: users[indexPath.row])
        
    }
}
