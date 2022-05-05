//
//  LaunchingViewController.swift
//  TOD
//
//  Created by iMac on 21/05/21.
//

import UIKit

class LaunchingViewController: UIViewController {
    
    //MARK:- IbOutlet
    
    @IBOutlet weak var launchingImageCollectionView: UICollectionView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var indicator01: UILabel!
    @IBOutlet weak var indicator02: UILabel!
    @IBOutlet weak var indicator03: UILabel!
    //MARK:- Variable Declaration
    var currentndex = 0;
    var arryOfImage = [#imageLiteral(resourceName: "walkthrough1"),#imageLiteral(resourceName: "walkthrough2"),#imageLiteral(resourceName: "walkthrough3")]
    var imageText = ["We provider over 50+ services","1000+ Trusted",
    "1 Million+"]
    var imageText1 = [" at your doorstep",
    "Service Professionals","Happy Customers"]
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK:- Function
    private func setUpUI() {
        setUpButton()
        setUpCollectionView()
        setUpLabel()
    }
    private func setUpButton() {
        self.nextButton.addTarget(self, action: #selector(timeraction), for: .touchUpInside)
    }
    private func setUpCollectionView() {
        launchingImageCollectionView.register(UINib(nibName:"LaunchingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
    private func setUpLabel() {
        self.indicator01.layer.masksToBounds = true
        self.indicator02.layer.masksToBounds = true
        self.indicator03.layer.masksToBounds = true
        self.indicator01.layer.cornerRadius = 3.5
        self.indicator02.layer.cornerRadius = 3.5
        self.indicator03.layer.cornerRadius = 3.5
       
        
    }
    
    
    //MARK:- Button Action
    @objc func timeraction() {
        self.launchingImageCollectionView.isPagingEnabled = false
        if currentndex == arryOfImage.count - 2 {
            indicator01.backgroundColor = .black
            indicator02.backgroundColor = .black
            indicator03.backgroundColor = .black
            
            let desiredscrollpostion = (currentndex < arryOfImage.count - 1) ? currentndex + 1 : 0
            launchingImageCollectionView.scrollToItem(at: IndexPath(item: desiredscrollpostion, section: 0), at: .right, animated: true)
            
            currentndex += 1
            skipButton.isHidden = true
            print(currentndex)
            
        }
        else if (currentndex == self.arryOfImage.count - 1) {
            
            let loginVc = LoginViewController.instantiate(fromAppStoryboard: .Login)
            self.navigationController?.pushViewController(loginVc, animated: true)
        }
        else {
            let desiredscrollpostion = (currentndex < arryOfImage.count - 1) ? currentndex + 1 : 0
            launchingImageCollectionView.scrollToItem(at: IndexPath(item: desiredscrollpostion, section: 0), at: .right, animated: true)
            currentndex += 1
            indicator01.backgroundColor = .black
            indicator02.backgroundColor = .black
            indicator03.backgroundColor = .lightGray
        }
        self.launchingImageCollectionView.isPagingEnabled = true
        
    }
    
    //MARK:- IbButton Action
    @IBAction func skipButtonAction(_ sender: Any) {
        let loginVc = LoginViewController.instantiate(fromAppStoryboard: .Login)
        self.navigationController?.pushViewController(loginVc, animated: true)
    }
}

//MARK:- Collection View
extension LaunchingViewController : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arryOfImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! LaunchingCollectionViewCell
        cell.launchImageView.image = self.arryOfImage[indexPath.row]
        cell.launchingTextLabel.text = self.imageText[indexPath.row]
        cell.launchingTextLabel1.text = self.imageText1[indexPath.row]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.size.width-40), height: 740.0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / scrollView.frame.size.width
        currentndex = Int(index)
        switch currentndex {
        case 0:
            indicator01.backgroundColor = .black
            indicator02.backgroundColor = .lightGray
            indicator03.backgroundColor = .lightGray
        case 1:
            indicator01.backgroundColor = .black
            indicator02.backgroundColor = .black
            indicator03.backgroundColor = .lightGray
        case 2:
            indicator01.backgroundColor = .black
            indicator02.backgroundColor = .black
            indicator03.backgroundColor = .black
        default:
            break
        }
        self.skipButton.isHidden = currentndex == 2 ? true : false
    }
}
