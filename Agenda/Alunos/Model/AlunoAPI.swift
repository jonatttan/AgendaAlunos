//
//  AlunoAPI.swift
//  Agenda
//
//  Created by Jonattan Moises Sousa on 20/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit
import Alamofire

class AlunoAPI: NSObject {
    
    //MARK: - Atributos
    
    lazy var url:String = {
        guard let url = Configuracao().getUrlPadrao() else { return ""}
        return url
    }()
    
    
    //MARK: - GET
    
    func recuperaAlunos(completion:@escaping() -> Void) {
        Alamofire.request(url + "api/aluno/", method: .get).responseJSON { (response) in
            switch response.result {
            case .success:
                //print(response.result.value!)
                if let resposta = response.result.value as?	Dictionary<String, Any> {
                    self.serializaAlunos(resposta)
                    AlunoUserDefaults().salvaVersao(resposta)
                    completion()
                }
                break
            case .failure:
                print(response.error!)
                break
            }
        }
    }
    
    func recuperaUltimosAlunos(_ versao:String, completion:@escaping() -> Void) {
        Alamofire.request(url + "api/aluno/diff", method: .get, headers: ["datahora":versao]).responseJSON { (response) in
            switch response.result {
            case .success:
                print("ultimos alunos")
                if let resposta = response.result.value as? Dictionary<String, Any> {
                    self.serializaAlunos(resposta)
                }
                completion()
                break
            case .failure:
                print("falha")
                break
            }
        }
    }
    
    //MARK: - PUT
    
    func salvaAlunosNoServidor(parametros:Array<Dictionary<String, Any>>, completion:@escaping(_ salvo:Bool) -> Void) {
        guard let urlPadrao = Configuracao().getUrlPadrao() else { return }
        
        guard let url = URL(string: urlPadrao + "api/aluno/lista")
        else { return}
        
        var requisicao = URLRequest(url: url)
        requisicao.httpMethod = "PUT"
        let json = try! JSONSerialization.data(withJSONObject: parametros, options: [])
        requisicao.httpBody = json
        requisicao.addValue("application/json", forHTTPHeaderField: "Content-Type")
        Alamofire.request(requisicao).responseData { (resposta) in
            if resposta == nil {
                completion(true)
            }
        }
        //print("Salvei no servidor!")
        
    }
    
    //MARK: - DELETE
    
    func deletaAluno(id:String, completion:@escaping(_ apagado:Bool) -> Void) {
        Alamofire.request(url + "api/aluno/\(id)", method: .delete).responseJSON { (resposta) in
            switch resposta.result {
            case .success:
                completion(true)
                break
            case .failure:
                completion(false)
                print(resposta.error as Any)// Aqui não tinha um as Any, em observação.
                break
            }
        }
    }
    
    //MARK: - Serialização
    
    func serializaAlunos(_ resposta:Dictionary<String, Any>) {
        print("executei")
        guard let listaDeAlunos = resposta["alunos"] as? Array<Dictionary<String, Any>> else { return }
        for dicionarioDeAluno in listaDeAlunos {
            guard let status = dicionarioDeAluno["desativado"] as? Bool else { return }
            if status {
                guard let idDoAluno = dicionarioDeAluno["id"] as? String else { return }
                guard let UUIDAluno = UUID(uuidString: idDoAluno) else { return }
                if let aluno = AlunoDAO().recuperaAlunos().filter({$0.id == UUIDAluno }).first {
                    AlunoDAO().deletaAluno(aluno: aluno)
                }
            }
            else {
                AlunoDAO().salvaAluno(dicionarioDeAluno: dicionarioDeAluno)
            }
        }
        AlunoUserDefaults().salvaVersao(resposta)
    }
    
}
	
