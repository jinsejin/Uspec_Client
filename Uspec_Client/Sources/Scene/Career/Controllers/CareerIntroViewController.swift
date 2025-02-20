//
//  CareerViewController.swift
//  Uspec_Client
//
//  Created by 김하람 on 2/9/24.
//

import UIKit
import SnapKit
import Then

class CareerIntroViewController: CareerViewController {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let addActivityCellIdentifier = "AddActivityCell"
    var numberOfCells = 1
    
    let semiTitleLabel = UILabel().then { label in
        label.text = "\(nickName)님의 대외활동 내역을 입력해주세요."
        label.font = UIFont.header3(size: 18)
        label.textColor = .primaryYellow
    }
    
    let doneButton = DoneButton(titleText: "참여한 대외활동 없어요")
    
    let nextPageBuuton = NextButton(titleText: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundWhite
        
        setUpLayout()

        collectionView.register(InputCareerCollectionViewCell.self, forCellWithReuseIdentifier: "InputCareerCollectionViewCell")
        collectionView.register(AddActivityCollectionViewCell.self, forCellWithReuseIdentifier: addActivityCellIdentifier)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideDropdownMenusInInputCareerCollectionViewCells()
    }

    
    @objc override func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        let infoVC = CompetitionUIViewController(currentStep: .step2)
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    @objc private func nextButtonTapped() {
        let infoVC = CompetitionUIViewController(currentStep: .step2)
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    private func setUpLayout(){
        scrollView.addSubview(collectionView)
        view.addSubview(semiTitleLabel)
        view.addSubview(doneButton)
        view.addSubview(nextButton)
       
        semiTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(32)
            make.left.equalTo(25)
            make.trailing.equalTo(view.snp.trailing)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(semiTitleLabel.snp.bottom).offset(32)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-130)
        }
        
        doneButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(343)
            make.height.equalTo(45)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-120)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(343)
            make.height.equalTo(45)
            make.top.equalTo(doneButton.snp.bottom).offset(4)
        }
        nextButton.backgroundColor = .gray2
        nextButton.layer.cornerRadius = 4
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func updateButtonColorBasedOnTextField() {
        if nextButton.isEnabled {
            nextButton.backgroundColor = .gray7
        } else {
            nextButton.backgroundColor = .gray2
        }
    }
}

extension CareerIntroViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == numberOfCells {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addActivityCellIdentifier, for: indexPath) as? AddActivityCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(title: "활동 추가하기")
            cell.tintColor = .gray4
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputCareerCollectionViewCell", for: indexPath) as? InputCareerCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.layer.borderColor = UIColor.secondaryYellow.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 20.0
            cell.delegate = self
            cell.delegateValid = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == numberOfCells {
            numberOfCells += 1
            collectionView.insertItems(at: [IndexPath(item: numberOfCells - 1, section: 0)])
            collectionView.reloadData()
        }
    }
}

extension CareerIntroViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == numberOfCells {
            return CGSize(width: 343, height: 61)
        } else {
            return CGSize(width: 343, height: 412)
        }
    }
}

extension CareerIntroViewController: InputCareerCollectionViewCellDelegate {
    func inputCareerCellDidRequestDelete(_ cell: UICollectionViewCell) {
            guard let indexPath = collectionView.indexPath(for: cell) else { return }
        numberOfCells -= 1
        collectionView.deleteItems(at: [indexPath])
        collectionView.reloadData()
    }
    
    func hideDropdownMenusInInputCareerCollectionViewCells() {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        for indexPath in visibleIndexPaths {
            if let cell = collectionView.cellForItem(at: indexPath) as? InputCareerCollectionViewCell {
                cell.selectButton1.hideDropdownMenu()
                cell.selectButton2.hideDropdownMenu()
                cell.selectButton3.hideDropdownMenu()
            }
        }
    }
}

extension CareerIntroViewController: InputCareerValidCheckDelegate {
    func inputCareerCell(_ cell: UICollectionViewCell, didChangeFieldsFilledStatus isFilled: Bool) -> Bool {
        if isFilled {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .gray7
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .gray2
           
        }
        return isFilled
    }
}
