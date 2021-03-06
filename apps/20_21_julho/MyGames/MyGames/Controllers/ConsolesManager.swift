//
//  ConsolesManager.swift
//  MyGames
//
//  Created by Douglas Frari on 16/04/2018.
//  Copyright © 2018 Douglas Frari. All rights reserved.
//

import CoreData

class ConsolesManager {
    
    let name  = "Livia SOuza"
    
    static let shared = ConsolesManager()
    var consoles: [Console] = []
    
    func loadConsoles(with context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Console> = Console.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // TESTE AQUI
        
        do {
            consoles = try context.fetch(fetchRequest)
        } catch  {
            print(error.localizedDescription)
        }
    }
        
    func deleteConsole(index: Int, context: NSManagedObjectContext) {
        let console = consoles[index]
        context.delete(console)
        
        do {
            try context.save()
            consoles.remove(at: index)
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    private init() {
        
    }
}
