//
//  Functions.swift
//  NanoProject
//
//  Created by Guilherme Martins Dalosto de Oliveira on 29/07/19.
//  Copyright © 2019 Guilherme Martins Dalosto de Oliveira. All rights reserved.
//

import Alamofire
import SwiftyJSON
import CoreData

enum typeTextObject {
    case simple
    case quotes
}

class Functions {
    
    // Get API key
    func getText(type: typeTextObject, from url: String, key: String, completion: @escaping (String) -> ()) {
        Alamofire.request(url, method: .get, parameters: [:], encoding: JSONEncoding.default, headers: ["Accept": "application/json"]).responseData { (responseData) in
            var value = ""
            let json = JSON(responseData.result.value!)
            let dict = json.dictionaryObject
            switch type {
            case .quotes:
                let quoteDict = dict!["quote"] as! [String: AnyObject]
                value = quoteDict["body"] as! String
            default:
                value = dict![key] as! String
            }
            completion(value)
        }
    }
    
    //News
    func searchTopHeadlines (api:News, completion: @escaping noticia ){
        guard var aux = api.topHeadLinesUrl else {return}
        let apiKey = api.apiKey
        let filterCountry = URLQueryItem(name: "country", value: api.country)
        
        aux.queryItems?.append(filterCountry)
        aux.queryItems?.append(apiKey)
        
        Alamofire.request(aux).responseJSON { (data) in
            
            let json = JSON(data.result.value!)
            guard let dicionario = json.dictionaryObject else {return}
            guard let artigos = dicionario["articles"] as? [[String: AnyObject]] else {return}
            
            let index = self.generateIndex(limite: artigos.count)
            let artigo = artigos[index]
            guard let urlImagem = URL(string: artigo["urlToImage"] as! String) else {return}
            self.baixarImagem(url: urlImagem, completion: { (image) in
                completion(image, artigo)
            })
        }
    }
    
    func searchSports(api:News, completion: @escaping noticia){
        guard var aux = api.topHeadLinesUrl else {return}
        let apiKey = api.apiKey
        let filterCountry = URLQueryItem(name: "country", value: api.country)
        let category = "sports"
        
        let filterCategory = URLQueryItem(name: "category", value: category)
        
        aux.queryItems?.append(filterCountry)
        aux.queryItems?.append(filterCategory)
        aux.queryItems?.append(apiKey)
        
        
        Alamofire.request(aux).responseJSON { (data) in
            
            let json = JSON(data.result.value!)
            guard let dicionario = json.dictionaryObject else {return}
            guard let artigos = dicionario["articles"] as? [[String: AnyObject]] else {return}
            
            let index = self.generateIndex(limite: artigos.count)
            let artigo = artigos[index]
            guard let stringUrlImagem = artigo["urlToImage"] as? String else {return}
            guard let urlImagem = URL(string: stringUrlImagem) else {return}
            self.baixarImagem(url: urlImagem, completion: { (image) in
                completion(image, artigo)
            })
            
        }
    }
    
    
    
    func generateIndex(limite: Int) -> Int{
        var index = Int()
        index = Int.random(in: 0...limite - 1)
        return index
    }
    
    
    
    func baixarImagem(url: URL, completion: @escaping (UIImage?) -> Void){
        var imagem: UIImage?
        
        Alamofire.request(url, method: .get).responseData { response in
            guard let imageData = response.result.value else {
                return
            }
            imagem = UIImage(data: imageData)
            completion(imagem)
        }
    }
    
    
    //Plexels
    func getImages(api: Plexels, completion: @escaping (UIImage?, [String:AnyObject]) -> Void){
        guard var url = api.url else {return}
        let apiKey = api.apiKey
        let per_page = 1
        let page = Int.random(in: 1...1000)
        
        let filterPerPage = URLQueryItem(name: "per_page", value: String(per_page))
        let filterPage = URLQueryItem(name: "page", value: String(page))
        
        url.queryItems?.append(filterPerPage)
        url.queryItems?.append(filterPage)
        
        var request = URLRequest(url: url.url!)
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
    
        Alamofire.request(request).responseJSON(completionHandler: { (data) in
            let json = JSON(data.result.value!)
            guard let dicionario = json.dictionaryObject else {return}
            guard let photos = dicionario["photos"] as? [[String: AnyObject]] else {return}
            guard let photo = photos[0] as? [String:AnyObject] else {return}
            
            
            guard let source = photo["src"] as? [String:AnyObject] else {return}
            guard let string = source ["portrait"] as? String else {return}
            guard let urlImagem = URL(string: string) else {return}

            self.baixarImagem(url: urlImagem, completion: { (imagem) in
                completion(imagem, photo)
            })
        })
    }
    
    
    
    func downloadImage(url: URL, idImage: Int64, completion: @escaping (UIImage?) -> Void){
        var imagem: UIImage?
        
        Alamofire.request(url, method: .get)
            .responseData { response in
            guard let imageData = response.result.value else {
                return
            }
            imagem = UIImage(data: imageData)
            self.saveImageCoreData(imagem: imagem!, idImage: idImage)
            completion(imagem)
            }
            .downloadProgress { (progress) in
                
                print(progress.completedUnitCount)
            }
    }
    
    
    func saveImageCoreData(imagem: UIImage, idImage: Int64){
        
        guard let imageData = imagem.jpegData(compressionQuality: 0.2) else {return}
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let manageContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "FavoriteImage", in: manageContext) else {return}
        let image = NSManagedObject(entity: entity, insertInto: manageContext)
        image.setValue(imageData, forKeyPath: "imageData")
        image.setValue(idImage, forKey: "idImage")
        
        do {
            try manageContext.save()
            print("salvou")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
  
}
