//
//  ViewController.swift
//  Project1
//
//  Created by Javier Rodríguez Gómez on 24/4/21.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [String]()
    var numOfViews = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Storm viewer"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareApp))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteViews))
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //performSelector(inBackground: #selector(nsslImages), with: nil)
        
        let fm = FileManager.default
            // Es un tipo de dato que nos permite trabajar con filesystem, y lo usaremos para buscar archivos
        let path = Bundle.main.resourcePath!
            // path se establece en la ruta de los recursos del directorio (bundle) de la app. Viene a ser "dime donde puedo encontrar las imágenes que añadimos"
        let items = try! fm.contentsOfDirectory(atPath: path)
            // items is set a los contenidos del directorio de la ruta indicada, en este caso, la creada en la línea anterior. Tendremos un array de strings con nombres de archivo
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
                //numOfViews.append(0)
            }
        }
        pictures.sort()
        
        loadNumOfViews()
        
    }
    
    /*@objc func nsslImages() {
        let fm = FileManager.default
            // Es un tipo de dato que nos permite trabajar con filesystem, y lo usaremos para buscar archivos
        let path = Bundle.main.resourcePath!
            // path se establece en la ruta de los recursos del directorio (bundle) de la app. Viene a ser "dime donde puedo encontrar las imágenes que añadimos"
        let items = try! fm.contentsOfDirectory(atPath: path)
            // items is set a los contenidos del directorio de la ruta indicada, en este caso, la creada en la línea anterior. Tendremos un array de strings con nombres de archivo
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        pictures.sort()
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }*/
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        cell.detailTextLabel?.text = "\(numOfViews[indexPath.row]) views"
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1. Try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            // 2. Set its selectedImage property
            vc.selectedImage = pictures[indexPath.row]
            // estas dos líneas son del challenge
            vc.selectedPictureNumber = indexPath.row + 1
            vc.totalPictures = pictures.count
            // 3. Now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
            
            numOfViews[indexPath.row] += 1
            tableView.reloadData()
            save()
        }
    }
    
    @objc func shareApp() {
        let alert = UIAlertController(title: "Share the app", message: "Please, share this app with friends!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "May'be later", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { _ in
        
            let vc = UIActivityViewController(activityItems: ["No sé qué poner aquí para compartir la app"], applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
            self.present(vc, animated: true)
        } ))
        present(alert, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(numOfViews) {
            let defaults = UserDefaults.standard
            defaults.setValue(savedData, forKey: "views")
        } else {
            print("Failed to save data.")
        }
    }
    
    func loadNumOfViews() {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "views") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                numOfViews = try jsonDecoder.decode([Int].self, from: savedData)
            } catch {
                print("Failed to load data")
            }
        }
    }
    
    @objc func deleteViews() {
        let ac = UIAlertController(title: "Delete data views", message: "Are you sure?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .destructive) {_ in
            self.numOfViews = Array(repeating: 0, count: self.pictures.count)
            self.tableView.reloadData()
        })
        present(ac, animated: true)
    }

}

