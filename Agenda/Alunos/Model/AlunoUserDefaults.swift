//
//  AlunoUserDefaults.swift
//  Agenda
//
//  Created by Jonattan Moises Sousa on 21/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit

class AlunoUserDefaults: NSObject {
    
    let preferencias = UserDefaults.standard
    
    func salvaVersao(_ json:Dictionary<String, Any>) {
        guard let versao = json["momentoDaUltimaModificacao"] as? String else { return }
        preferencias.set(versao, forKey: "ultima-versao")
    }
    
    func recuperaUltimaVersao() -> String? {
        let versao = preferencias.object(forKey: "ultima-versao") as? String
        return versao
    }
    
    
}
