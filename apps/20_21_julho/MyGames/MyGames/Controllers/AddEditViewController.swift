//
//  AddEditViewController.swift
//  MyGames
//
//  Created by Douglas Frari on 20/07/18.
//  Copyright © 2018 CESAR School. All rights reserved.
//

import UIKit
import Photos

class AddEditViewController: UIViewController {

    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfConsole: UITextField!
    @IBOutlet weak var dpReleaseDate: UIDatePicker!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var btCover: UIButton!
    @IBOutlet weak var ivCover: UIImageView!
    
    
    // adicionando variavel que faz referencia ao model do Coredata
    var game: Game!
    
    var consolesManager = ConsolesManager.shared
    
    // tip. Lazy somente constroi a classe quando for usar
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .white
        return pickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        consolesManager.loadConsoles(with: context)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareDataLayout()
    }
    
    func prepareDataLayout() {
        if game != nil {
            title = "Editar jogo"
            btAddEdit.setTitle("ALTERAR", for: .normal)
            tfTitle.text = game.title
            
            // tip. alem do console pegamos o indice atual para setar o picker view
            if let console = game.console, let index = consolesManager.consoles.index(of: console) {
                tfConsole.text = console.name
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
            ivCover.image = game.cover as? UIImage
            if let releaseDate = game.releaseDate {
                dpReleaseDate.date = releaseDate
            }
            if game.cover != nil {
                btCover.setTitle(nil, for: .normal)
            }
        }
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.tintColor = UIColor(named: "main")
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let btFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [btCancel, btFlexibleSpace, btDone]
        
        // tip. faz o text field exibir os dados predefinidos pela picker view
        tfConsole.inputView = pickerView
        tfConsole.inputAccessoryView = toolbar
    }
    
    @objc func cancel() {
        tfConsole.resignFirstResponder()
    }
    
    @objc func done() {
        tfConsole.text = consolesManager.consoles[pickerView.selectedRow(inComponent: 0)].name
        cancel()
    }
    
    
    
    @IBAction func AddEditCover(_ sender: UIButton) {
        // para adicionar uma imagem da biblioteca
        
        let alert = UIAlertController(title: "Selecinoar poster", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default, handler: {(action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        })
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Album de fotos", style: .default, handler: {(action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        })
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func chooseImageFromLibrary(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.navigationBar.tintColor = UIColor(named: "main")
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    
                    self.chooseImageFromLibrary(sourceType: sourceType)
                    
                } else {
                    print("unauthorized -- TODO message")
                }
            })
        } else if photos == .authorized {
            self.chooseImageFromLibrary(sourceType: sourceType)
        }
    }
    
    
    
    @IBAction func addEditGame(_ sender: UIButton) {
        // acao salvar novo ou editar existente
        
        if game == nil {
            // trata-se de um jogo novo
            // context foi obtido via ViewController+CoreData
            game = Game(context: context)
        }
        
        game.title = tfTitle.text
        game.releaseDate = dpReleaseDate.date
        
        if !tfConsole.text!.isEmpty {
            let console = consolesManager.consoles[pickerView.selectedRow(inComponent: 0)]
            game.console = console
        }
        
        game.cover = ivCover.image
        
        do {
            // SALVAR no COREDATE
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        // Back na navigation
        navigationController?.popViewController(animated: true)
    }
    
}


extension AddEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return consolesManager.consoles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let console = consolesManager.consoles[row]
        return console.name
    }
    
}

extension AddEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // tip. implementando os 2 protocols o evento sera notificando apos user selecionar a imagem
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // ImageView won't update with new image
            // bug fixed: https://stackoverflow.com/questions/42703795/imageview-wont-update-with-new-image
            DispatchQueue.main.async {
                self.ivCover.image = pickedImage
                self.ivCover.setNeedsDisplay()
                self.btCover.setTitle(nil, for: .normal)
                self.btCover.setNeedsDisplay()
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}





