//
//  RecipientTableViewController.swift
//  SlapChat
//
//  Created by Rama Milaneh on 11/10/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import CoreData

class RecipientTableViewController: UITableViewController {
    
    let store = DataStore.sharedInstance
    let searchController = UISearchController(searchResultsController: nil)
    var filteredResult = [Recipient]()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        fetchRecipientData()
        self.tableView.reloadData()
        print(store.recipients.count)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchRecipientData()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredResult.count
        }
        return store.recipients.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipientCell", for: indexPath as IndexPath)
        let recipient : Recipient
        if searchController.isActive && searchController.searchBar.text != "" {
            recipient = filteredResult[indexPath.row]
        } else {
            recipient = store.recipients[indexPath.row]
        }

        let newName = (recipient.name)! + "\t\t\t\t\t\t" + (recipient.phoneNumber)!
        let anotherName = (recipient.email)! + "\t\t\t\t\t\t " + (recipient.twitterHandle)!
        cell.textLabel?.text = newName
        cell.detailTextLabel?.text = anotherName
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMessage" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let recipient : Recipient
                if searchController.isActive && searchController.searchBar.text != "" {
                    recipient = filteredResult[indexPath.row]
                } else {
                    recipient = store.recipients[indexPath.row]
                }

            let dest = segue.destination as! TableViewController
            dest.recipient = recipient
            
        }
        }
    }

// MARK: - Create Recipient Array

    func generateRecipient() {
        
       let firstRecipient = DataStore.createRecipient(name: "Jim", email: "jim.com", phoneNumber: "123456", twitterHandler: "jimcom")
        store.recipients.append(firstRecipient)
        
        let secondRecipient = DataStore.createRecipient(name: "Joel", email: "joel.com", phoneNumber: "456789", twitterHandler: "joelcom")
        store.recipients.append(secondRecipient)
        
        let thirdRecipient = DataStore.createRecipient(name: "Anas", email: "anas.com", phoneNumber: "756535", twitterHandler: "anascom")
        store.recipients.append(thirdRecipient)
        
        let fourthRecipient = DataStore.createRecipient(name: "Mary", email: "mary.com", phoneNumber: "906867", twitterHandler: "marycom")
        store.recipients.append(fourthRecipient)
        
        store.saveContext()
        
    }
    
 // MARK: - Fetch Recipient Entity
    
    func fetchRecipientData() {
        let context = store.persistentContainer.viewContext
       
        let recipientRequest: NSFetchRequest<Recipient> = Recipient.fetchRequest()
        
        do {
            store.recipients = try context.fetch(recipientRequest)
        } catch let error {
            print("Error fetching data: \(error)")
            store.recipients = []
        }
        
        if store.recipients.count == 0 {
            generateRecipient()
        }
    }
    
// MARK: - Search function
    
    func filterContentForSearchText(searchText: String)
    {
        self.filteredResult = self.store.recipients.filter { recipient in
           let newName = (recipient.name)! + (recipient.email)!
            let anotherName = (recipient.phoneNumber)! + (recipient.twitterHandle)!
            let lastName = newName + anotherName
            return (lastName.lowercased().contains(searchText.lowercased()))
            }
        
        tableView.reloadData()
    }
}
extension RecipientTableViewController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

