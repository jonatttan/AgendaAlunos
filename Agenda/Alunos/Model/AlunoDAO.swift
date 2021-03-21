//
//  AlunoDAO.swift
//  Agenda
//
//  Created by Jonattan Moises Sousa on 20/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit
import CoreData

class AlunoDAO: NSObject {
    
    var gerenciadorDeResultados:NSFetchedResultsController<Aluno>?
    
    var contexto:NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func recuperaAlunos() -> Array<Aluno>{
        
        let pesquisaAluno:NSFetchRequest<Aluno> = Aluno.fetchRequest()
        let ordenaPorNome = NSSortDescriptor(key: "nome", ascending: true)
        pesquisaAluno.sortDescriptors = [ordenaPorNome]
        
        gerenciadorDeResultados = NSFetchedResultsController(fetchRequest: pesquisaAluno, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try gerenciadorDeResultados?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        guard let listaDeAlunos = gerenciadorDeResultados?.fetchedObjects else { return [] }
        
        return listaDeAlunos
    }
    
    func salvaAluno(dicionarioDeAluno: Dictionary<String, Any>) {
        let aluno = Aluno(context: contexto)
        aluno.nome = dicionarioDeAluno["nome"] as? String
        aluno.endereco = dicionarioDeAluno["endereco"] as? String
        aluno.telefone = dicionarioDeAluno["telefone"] as? String
        aluno.site = dicionarioDeAluno["site"] as? String
        guard let nota = dicionarioDeAluno["nota"] else { return }
        
        if (nota is String) {
            aluno.nota = (dicionarioDeAluno["nota"] as! NSString).doubleValue
        }
        else {
            let conversaoDeNota = String(describing: nota)
            aluno.nota = (conversaoDeNota as NSString).doubleValue
        }
        
        atualizaContexto()
    }
    
    func atualizaContexto() {
        
        do {
            try contexto.save()
            //print("Salvei no device!")
        } catch {
            print(error.localizedDescription)
        }
        
    }

}
