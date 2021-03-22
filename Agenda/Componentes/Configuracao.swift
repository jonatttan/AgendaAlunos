//
//  Configuracao.swift
//  Agenda
//
//  Created by Jonattan Moises Sousa on 21/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit

class Configuracao: NSObject {

    //MARK: - Set IP
    
    func getUrlPadrao() -> String? {
        
        guard let caminhoParaPlist = Bundle.main.path(forResource: "Info", ofType: "plist") else { return nil}
        guard let dicionario = NSDictionary(contentsOfFile: caminhoParaPlist) else { return nil }
        guard let urlPadrao = dicionario["URLPadrao"] as? String else { return nil }
        //print(urlPadrao)
        return urlPadrao
    }
}
