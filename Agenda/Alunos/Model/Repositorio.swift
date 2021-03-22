//
//  Repositorio.swift
//  Agenda
//
//  Created by Jonattan Moises Sousa on 20/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit

class Repositorio: NSObject {

    func recuperaAlunos(completion:@escaping(_ listaDeAlunos: Array<Aluno>) -> Void) {
        var alunos = AlunoDAO().recuperaAlunos().filter({ $0.desativado == false })
        if alunos.count == 0 {
            AlunoAPI().recuperaAlunos { //Essa linha executa função chamada, possui um 'completion'. O codigo abaixo somente será executado depois que a requisição do servidor voltar, sexa com êxito ou falha
                alunos = AlunoDAO().recuperaAlunos()
                completion(alunos)
            }
        }
        else {
            completion(alunos)
        }
    }
    
    func recuperaUltimosAlunos(_ versao: String, completion: @escaping() -> Void) {
        AlunoAPI().recuperaUltimosAlunos(versao) {
            completion()
        }
    }
    
    func salvaAluno(aluno: Dictionary<String, Any>){
        AlunoDAO().salvaAluno(dicionarioDeAluno: aluno)
        AlunoAPI().salvaAlunosNoServidor(parametros: [aluno]) { (salvo) in
            if salvo {
                self.atualizaAlunoSincronizado(aluno)
            }//Mudar atributo de sincronizado para verdadeiro
        }
        
    }
    
    func deletaAluno(aluno: Aluno) {
        aluno.desativado = true
        AlunoDAO().atualizaContexto()
        guard let id = aluno.id else { return }
        AlunoAPI().deletaAluno(id: String(describing: id).lowercased()) { (apagado) in
            if apagado {
                AlunoDAO().deletaAluno(aluno: aluno)
            }
        }
    }
    
    func sincronizaAlunos() {
        enviaAlunosNaoSincronizados()
        sincronizaAlunosDeletados()
    }
    
    func enviaAlunosNaoSincronizados() {
        let alunos = AlunoDAO().recuperaAlunos().filter({ $0.sincronizado == false })
        let listaDeParametros = criaJsonAluno(alunos)
        AlunoAPI().salvaAlunosNoServidor(parametros: listaDeParametros) { (salvo) in
            for aluno in listaDeParametros {
                self.atualizaAlunoSincronizado(aluno)
            }
        }
    }
    
    func sincronizaAlunosDeletados() {
        let alunos = AlunoDAO().recuperaAlunos().filter({ $0.desativado == true})
        for aluno in alunos {
            //AlunoDAO().deletaAluno(aluno: aluno)
            deletaAluno(aluno: aluno)
        }
    }
    
    func criaJsonAluno(_ alunos: Array<Aluno>) -> Array<[String:Any]>{
        var listaDeParametros:Array<Dictionary<String, String>> = []
        for aluno in alunos {
            guard let id = aluno.id else { return []}
            let parametros: Dictionary<String, String> = [
                "id" : String(describing: id).lowercased(),
                "nome" : aluno.nome ?? "", //Uma outra opção de extrair o valor, para que este não seja opcional, fora 'if let/ guard let'. Caso não consiga extrair, vai passar vazio ("")
                "endereco" : aluno.endereco ?? "",
                "telefone" : aluno.telefone ?? "",
                "site" : aluno.site ?? "",
                "nota" : "\(aluno.nota)"
            ]
            listaDeParametros.append(parametros)
        }
        return listaDeParametros
    }
    
    func atualizaAlunoSincronizado(_ aluno: Dictionary<String, Any>) {
        var dicionario = aluno
        dicionario["sincronizado"] = true
        AlunoDAO().salvaAluno(dicionarioDeAluno: dicionario)
    }
}
