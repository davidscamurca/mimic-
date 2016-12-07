//
//  JogoViewController.swift
//  Mimica
//
//  Created by Anderson Oliveira on 17/11/16.
//  Copyright © 2016 Anderson Oliveira. All rights reserved.
//

import UIKit
import Wallet
import WatchConnectivity

class JogoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var session: WCSession?{
        didSet{
            if let session = session{
                session.delegate = self
                session.activate()
            }
        }
    }
    
    @IBOutlet var popoverSair: UIView!
    @IBOutlet weak var imagemTurnoAtual: UIImageView!
    @IBOutlet weak var voltar: UIButton!
    @IBOutlet weak var walletHeaderView: UIView!
    @IBOutlet weak var walletView: WalletView!
    @IBOutlet weak var viewPlacar: UIView!
    @IBOutlet weak var placarCV: UICollectionView!
    
    var viewTransparente = UIView()
    var grupos: [Grupo]? = []
    var timeAtual = 0
    var clickCV = true
    
    
    var hour = 0
    var min = 0
    var seg = 0
    
    
    var cards : [Card]?
    
    //Hint: Passe algum intervalo de tempo pro Cronometro Regressivo
    var timerCronometro = Timer()
    var Cronometro = 0
    
    var timeBase: Int?
    var coloredCardViews = [ColoredCardView]()

    
    //MARK: - Variáveis auxiliares das segues vinda da tela de Infos
    
    var quantidadeDeTimes: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if WCSession.isSupported(){
            session = WCSession.default()
        }
        
        self.grupos = GrupoStore.singleton.pegarGrupo(self.quantidadeDeTimes!-1)
        
        self.viewPlacar.backgroundColor = UIColor(patternImage: UIImage(named: "bg")!)
        self.viewPlacar.layer.shadowOpacity = 0.5
        self.cards = CardStore.singleton.getDeck()
        
        walletView.walletHeader = walletHeaderView
        walletView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        self.cards?.forEach({ (card) in
            
            let cardView = ColoredCardView.nibForClass()
            
            if let timeBase = timeBase{
                
                cardView.timeBase = TimeInterval(timeBase*60)
                cardView.image.image = card.Ilustracao
                cardView.titulo.text = card.Titulo
                cardView.descricao.text = card.Descricao
                cardView.subtitulo.text = card.Era
                
                coloredCardViews.append(cardView)
            }
        })
        
        walletView.reload(cardViews: coloredCardViews)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JogoViewController.showPlacar(_:)), name: NSNotification.Name(rawValue: "showPlacar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JogoViewController.dismissPlacar(_:)), name: NSNotification.Name(rawValue: "dismissPlacar"), object: nil)

        enviarTimeDaVez()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
            
    }
    
    func showPlacar(_ notification: Notification) {

        self.walletHeaderView.transform = CGAffineTransform(scaleX: 1.0, y: 0.0)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
        
            self.walletView.frame.size.height = 10
            self.viewPlacar.isHidden = true
        }, completion: nil)
    }
    
    func dismissPlacar(_ notification: Notification) {
        
        let pontua = notification.object as! Bool
        
        if pontua {
            self.pontua()
        }
        
        self.trocaTime()
        
        self.walletHeaderView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
            self.walletView.frame.size.height = self.view.frame.height - self.viewPlacar.frame.height - 68
            self.viewPlacar.isHidden = false
        }, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func dismiss(_ sender: Any) {
        
        self.animateInPopover(popover: self.popoverSair)
    }
    
    @IBAction func fecharPopover(_ sender: UIButton) {
        
        self.animateOutPopover(popover: self.popoverSair)
    }
    
    @IBAction func voltar(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Collection Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.grupos == nil {
            return 0
        }
        return self.grupos!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PlacarCollectionViewCell
        
        let grupo = self.grupos![indexPath.item]
        
        cell.imagem.image = grupo.avatar
        cell.pontos.text = String(describing: grupo.pontos!)
        cell.nome.text = grupo.nome
        cell.frase.text = grupo.frase
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PlacarCollectionViewCell
        
        collectionView.collectionViewLayout.invalidateLayout()
        if clickCV {
            
            self.grupos?[indexPath.item].widgth = 162
            cell.balao.isHidden = !self.clickCV
            cell.frase.isHidden = !self.clickCV
        }else {
            
            self.grupos?[indexPath.item].widgth = 100
            cell.balao.isHidden = !self.clickCV
            cell.frase.isHidden = !self.clickCV
        }
        self.clickCV = self.trocaBool(self.clickCV)
    }
    
    func pontua() {
        
        self.grupos![self.timeAtual].addPontos()
        self.placarCV.reloadData()
    }
    
    //MARK: - Troca Time
    
    func trocaTime() {
        
        if self.timeAtual == self.grupos?.last?.id {
            
            self.timeAtual = 0
            self.imagemTurnoAtual.image = self.grupos![self.timeAtual].avatar
        }else {
            
            self.timeAtual += 1
            self.imagemTurnoAtual.image = self.grupos![self.timeAtual].avatar
        }
        
        
        //Mandar sempre o time do turno da vez
        enviarTimeDaVez()
        
        
    }
    
    func enviarTimeDaVez(){
        session?.sendMessage(["Vez":timeAtual], replyHandler: { (response: [String : Any]) in
            if let timeDaVez = response["Vez"] as? String{
                print("Vez do time \(timeDaVez)")
            }
        }, errorHandler: { (Error) in
            print("Não consegui enviar o time")
        })
    }
    
    func animateInPopover(popover: UIView) {
        
        self.addViewTransparente()
        self.view.addSubview(popover)
        popover.center = self.view.center
        
        popover.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        popover.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            popover.alpha = 1
            popover.transform = CGAffineTransform.identity
        })
        
    }
    
    func animateOutPopover(popover: UIView) {
        self.viewTransparente.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            popover.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
            popover.alpha = 0
            
        }, completion: { (success:Bool) in
            popover.removeFromSuperview()
        })
    }
    
    func addViewTransparente(){
        self.viewTransparente.frame = self.view.frame
        self.viewTransparente.backgroundColor = UIColor.white
        self.viewTransparente.alpha = 0.5
        self.view.addSubview(viewTransparente)
    }
    
    func trocaBool(_ value: Bool) -> Bool {
        
        return !value
    }
}

extension JogoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = self.grupos?[indexPath.item]
        return CGSize(width: (item?.widgth)!, height: 120)
    }
    
}

extension JogoViewController: WCSessionDelegate{
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iOS: Session Ativado.")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
//        if message["comando"] as? String == "Acertou"{
//            let response = ["Acerto":"Acerto computado iOS"]
//            replyHandler(response)
//        }
        
    }
    
}

