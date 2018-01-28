//
//  NotesTableViewController.swift
//  belt_exam
//
//  Created by William Tsai on 1/26/18.
//  Copyright © 2018 William Tsai. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController, AddNoteDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

    var notes = [Note]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Setup for navigation:
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        if #available(iOS 11.0, *) {
            // For iOS 11 and later, we place the search bar in the navigation bar.
            navigationController?.navigationBar.prefersLargeTitles = true
            
            navigationItem.searchController = searchController
            
            // We want the search bar visible all the time.
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // For iOS 10 and earlier, we place the search bar in the table view's header.
            tableView.tableHeaderView = searchController.searchBar
        }
        navigationItem.title = "Notes"
        saveAndReload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        Following is just an exmplae of how to use searchController
//        if navigationItem.searchController?.isActive == true {
//            return notes.count
//        }
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].content
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        cell.detailTextLabel?.text = formatter.string(from: notes[indexPath.row].date!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = notes[indexPath.row]
        let data: (Note, NSIndexPath) = (selectedNote, indexPath as NSIndexPath)
        performSegue(withIdentifier: "EditNoteSegue", sender: data)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ComposeViewController
        destination.delegate = self
        if segue.identifier == "EditNoteSegue" {
            destination.data = sender as? (Note, NSIndexPath)
        }
    }

    func save(_ content: String, date: Date, indexPath: NSIndexPath?) {
        if content != "" {
            if let existingID = indexPath {
                notes[existingID.row].content = content
                notes[existingID.row].date = date
            } else {
                print("new note")
                let newNote = Note(context: managedObjectContext)
                newNote.content = content
                newNote.date = date
            }
            saveAndReload()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        managedObjectContext.delete(notes[indexPath.row])
        saveAndReload()
    }

    func fetchAndReload() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sortDescriptor]
        request.sortDescriptors = sortDescriptors
        do {
            let results = try managedObjectContext.fetch(request) as [Note]
            notes = results
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    // The updateSearchResults function will get called for every character that is typed in the search bar.
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.isEmpty == false {
            let request: NSFetchRequest<Note> = Note.fetchRequest()
            do {
                request.predicate = NSPredicate(format: "content CONTAINS[cd] %@", searchText)
                let searchResults = try managedObjectContext.fetch(request) as [Note]
                notes = searchResults
            } catch {
                print(error)
            }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchAndReload()
    }
    
    func saveAndReload() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
        fetchAndReload()
    }
}
