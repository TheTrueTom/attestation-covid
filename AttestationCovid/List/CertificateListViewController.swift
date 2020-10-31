//
//  CertificateListViewController.swift
//  AttestationCovid
//
//  Created by David Yang on 11/04/2020.
//  Copyright © 2020 David Yang. All rights reserved.
//

import UIKit

final class CertificateListViewController: UITableViewController {
    
    @IBOutlet private weak var deleteAllButton: UIButton!
    
    @IBAction func deleteAllCertificates(_ sender: Any) {
        for i in (0..<certificates.count).reversed() {
            let indexPath = IndexPath(row: i, section: 0)
            
            do {
                try removeCertificate(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                showAlert(message: "Une erreur s'est produite. Impossible de supprimer l'attestation")
            }
        }
    }
    
    private var certificates: [URL] = []

    private var documentDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        load {
            tableView.reloadData()
        }
    }

    private func registerCells() {
        tableView.register(FileCell.self, forCellReuseIdentifier: FileCell.identifier)
    }

    private func load(completion: () -> Void) {
        if let documentDirectory = documentDirectory, var files = try? FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: []) {
                // Sort by date, show newest on top of the list
                try? files.sort { (leftUrl: URL, rightUrl: URL) -> Bool in

                let leftAttributes = try FileManager.default.attributesOfItem(atPath: leftUrl.path)
                let rightAttributes = try FileManager.default.attributesOfItem(atPath: rightUrl.path)

                return (leftAttributes[.creationDate] as? Date ?? Date()) > (rightAttributes[.creationDate] as? Date ?? Date())
            }
            
            self.certificates = files
            completion()
        }

    }
}

extension CertificateListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return certificates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.identifier, for: indexPath) as? FileCell else {
            fatalError("Could not dequeue FileCell")
        }

        cell.textLabel?.text = certificates[indexPath.row].lastPathComponent

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let documentURL = certificates[indexPath.row]

        let attestationViewController = CertificateViewController(documentURL: documentURL)
        let navigationController = UINavigationController(rootViewController: attestationViewController)
        present(navigationController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try removeCertificate(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                showAlert(message: "Une erreur s'est produite. Impossible de supprimer l'attestation")
            }
        }
    }
}

extension CertificateListViewController {
    private func removeCertificate(at index: Int) throws {
        try FileManager.default.removeItem(at: certificates[index])
        certificates.remove(at: index)
    }
}
