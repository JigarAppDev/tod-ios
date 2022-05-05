//
//  HelpViewController.swift
//  TOD
//
//  Created by My Mac on 22/05/21.
//

import UIKit

class HelpViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var viwNavigation: UIView!
    @IBOutlet private weak var lblHelp: UILabel!
    @IBOutlet private weak var tblQuestions: UITableView!
    
    // MARK: - Variables
    private var arrOfQuestions: [FAQs] = []
    private var arrOfIndex: [Int] = [-1, -1, -1]
    private var defaultTableHeight: CGFloat = 80.0
    private var extraSpace: CGFloat = 50.0
    private var extraBottomSpace: CGFloat = 25.0
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTabBar()
        arrOfQuestions = []
        getFAQDocument()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupView()
    }
    
    // MARK: - Methods
    private func setupUI() {
        setupTableView()
    }
    
    private func setupView() {
        viwNavigation.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.5, offset: CGSize(width: 0.0, height: 1.0), radius: 1.0)
    }
    
    private func setupTableView() {
        tblQuestions.delegate = self
        tblQuestions.dataSource = self
        tblQuestions.backgroundColor = .clear
        tblQuestions.tableFooterView = UIView()
        tblQuestions.register(HelpQuestionCell.nib, forCellReuseIdentifier: HelpQuestionCell.identifier)
        tblQuestions.reloadData()
    }
    
    private func selectedQuestion(at index: Int) {
        if arrOfIndex.contains(index) {
            if let index = arrOfIndex.firstIndex(where: { $0 == index}) {
                arrOfIndex.remove(at: index)
            }
            let indexPath: IndexPath = IndexPath(row: index, section: 0)
            self.tblQuestions.reloadRows(at: [indexPath], with: .automatic)
        } else {
            arrOfIndex.append(index)
            let indexPath: IndexPath = IndexPath(row: index, section: 0)
            self.tblQuestions.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - API Call
    private func getFAQDocument() {
        showLoader()
        APIHandler.shared.getFAQS { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                DLog(error.localizedDescription)
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            }
            
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    self.getFAQDocumentFromDocumentID(documentID: document.documentID)
                }
                
                hideLoader()
                self.tblQuestions.reloadData()
            }
        }
        
    }
    
    private func getFAQDocumentFromDocumentID(documentID: String) {
        APIHandler.shared.getFAQSFromDocumentID(for: documentID) { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                DLog(error.localizedDescription)
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            }
            
            if let documentSnapshot = documentSnapshot {
                if let documentData = documentSnapshot.data() {
                    let faqs: FAQs = FAQs(data: documentData)
                    self.arrOfQuestions.append(faqs)
                    self.tblQuestions.reloadData()
                }
            }
        }
    }

    private func computeHeight(text: String, width: CGFloat) -> CGFloat {
        
        let label = UILabel()

        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = AppFont.SFPRO_DISPLAY_LIGHT_15

        label.preferredMaxLayoutWidth = width
        label.text = text
        label.invalidateIntrinsicContentSize()

        let height = label.intrinsicContentSize.height
        return height
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HelpViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tblQuestions.dequeueReusableCell(withIdentifier: HelpQuestionCell.identifier, for: indexPath) as? HelpQuestionCell else { return UITableViewCell() }
        
        if arrOfQuestions.count > indexPath.row {
            let faq: FAQs = arrOfQuestions[indexPath.row]
            let isSelected: Bool = arrOfIndex.contains(indexPath.row)
            cell.setData(faq: faq, isSelected: isSelected)
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrOfQuestions.count > indexPath.row {
            let faq: FAQs = arrOfQuestions[indexPath.row]
            let height: CGFloat = computeHeight(text: faq.description, width: ScreenSize.SCREEN_WIDTH - extraSpace)
            return arrOfIndex.contains(indexPath.row) ? defaultTableHeight + height + extraBottomSpace :  defaultTableHeight
        }
        
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedQuestion(at: indexPath.row)
    }
    
}
