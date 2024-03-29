//
//  popoverImage.swift
//  NanoProject
//
//  Created by Guilherme Martins Dalosto de Oliveira on 29/07/19.
//  Copyright © 2019 Guilherme Martins Dalosto de Oliveira. All rights reserved.
//

import Foundation
import UIKit

class popoverNoticias : UIView {
    let screenSize = UIScreen.main.bounds.size
    
    var url: URL?
    let functions = Functions()
    
    @IBOutlet weak var verMais: UIButton!
    @IBOutlet weak var curtirOutlet: UIButton!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var noticia: UITextView!
    var autorNoticia = String()
    var entidade = String()
    
    weak var delegate: Like?

    @IBOutlet weak var tituloNoticia: UILabel!

    
    @IBAction func buttonVerMais(_ sender: Any) {
        UIApplication.shared.open(url!)
    }
    
    
    @IBAction func curtir(_ sender: Any) {
        var id = functions.buscarUltimoIdCoreData(entidade: entidade)
        curtirOutlet.isEnabled = false
        id += 1
        var autor = String()
        if autorNoticia == ""{
            autor = "Desconhecido"
        }
        functions.saveNewsCoreData(imagem: imagem.image!, idImage: id, texto: noticia.text, titulo: tituloNoticia.text!, autor: autor, entidade: entidade)
        delegate?.liked()
    }
    
}
