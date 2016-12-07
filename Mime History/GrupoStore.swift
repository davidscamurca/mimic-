//
//  GrupoStore.swift
//  Mimica
//
//  Created by David Camurça on 22/11/16.
//  Copyright © 2016 Anderson Oliveira. All rights reserved.
//

import UIKit

class GrupoStore {
    
    static let singleton = GrupoStore()
    
    
    let datagrupos: [(String, Int, Int, UIImage, String)] = [
        
       //   Nome        Pontos     id          imagem           Frases
        ("Legionários",   0,      0,    #imageLiteral(resourceName: "romaAntiga"),      "Por Roma!"),
        
        ("Beserkers",     0,      1,    #imageLiteral(resourceName: "beserkers"),       "Biiirl!!"),
        
        ("Espartanos",    0,      2,    #imageLiteral(resourceName: "espartanos"),      "Nós somos Esparta!!!"),
        
        ("Cruzados",      0,      3,    #imageLiteral(resourceName: "cruzados"),        "Viva os Templários!")
    ]
    
    //MARK: Pega grupos
    func pegarGrupo(_ value: Int)-> [Grupo] {
        
        var grupos = [Grupo]()
        
        for i in 0...value {
            
            let grupo = Grupo()

            grupo.nome = datagrupos[i].0
            grupo.pontos = datagrupos[i].1
            grupo.id = datagrupos[i].2
            grupo.avatar = datagrupos[i].3
            grupo.frase = datagrupos[i].4
        
            grupos.append(grupo)
        }
        return grupos
    }
}
