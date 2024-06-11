//
//  SearchViewController.swift
//  McCurrency
//
//  Created by Mac on 6/9/24.
//


protocol CircularViewControllerDelegate: AnyObject {
    func countrySelected(_ countryName: String)
}



import UIKit
import AVKit

protocol CircularViewControllerDelegate: AnyObject {
    func modalDidDismiss()
}

class CircularViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate {
    
    weak var delegate: CircularViewControllerDelegate?
    
    let countries = [


            "노르웨이 / NOK","말레이시아 / MYR", "미국 / USD", "스웨덴 / SEK",  "스위스 / CHF ",
             "영국 / GBP", "인도네시아 / IDR", "일본 / JPY",  "중국 / CNY","캐나다 / CAD", "홍콩 / HKD",  "태국 / THB ","호주/AUD","뉴질랜드/NZD ","싱가포르/SGD"
            //"노르웨이 / NOK","말레이시아 / MYR", "미국 / USD", "스웨덴 / SEK",  "스위스 / CHF ",
//            "영국 / GBP", "인도네시아 / IDR", "일본 / JPY",  "중국 / CNY","캐나다 / CAD", "홍콩 / HKD",  "태국 / THB ","호주/AUD",
//           "뉴질랜드/NZD ","싱가포르/SGD"
         
        


    ]

    var labels: [UILabel] = []
    var lastAngle: CGFloat = 0
    var counter: CGFloat = 0
    var currentRotationAngle: CGFloat = 0
    
    var lastText: String?
    
    var centerLabel: UILabel!

    var searchBar: UISearchBar!
    var searchBarWidthConstraint: NSLayoutConstraint!

    var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.view.addSubview(blurEffectView)
        

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        


        closeButton.frame = CGRect(x: -30, y: 55, width: 100, height: 50)
        self.view.addSubview(closeButton)
        
        addButton = UIButton(type: .system)
        addButton.setTitle("추가하기", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.backgroundColor = .AddButton
        addButton.tintColor = .black
        addButton.addTarget(self, action: #selector(addCounntryButtonTapped), for: .touchUpInside)
        addButton.layer.cornerRadius = 10
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -55),
            addButton.widthAnchor.constraint(equalToConstant: 350),
            addButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
        
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        
        searchBar.backgroundImage = UIImage()
        
        let searchTextField = searchBar.searchTextField
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.masksToBounds = true
        searchTextField.backgroundColor = .darkGray
        searchTextField.textColor = .white
        searchTextField.leftView?.tintColor = .secondaryTextColor
        
        self.view.addSubview(searchBar)
        
        searchBar.placeholder = ""
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([
            searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            searchBar.heightAnchor.constraint(equalToConstant: 40),
            searchBarWidthConstraint
        ])
        
        // 초기화 시 모든 countries를 표시
        filteredCountries = countries
        
        displayCountries(filteredCountries)
        
        centerLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.height / 2, width: self.view.frame.width, height: 40))
        centerLabel.layer.borderColor = UIColor.CenterHighlighted.cgColor
        centerLabel.layer.borderWidth = 1.0
        centerLabel.textColor = .white
        self.view.addSubview(centerLabel)
        
        let addButton:UIButton = UIButton()
        addButton.setTitle("추가하기", for: .normal)
        addButton.tintColor = .white
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        self.view.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 300),
            addButton.heightAnchor.constraint(equalToConstant: 50),
        
        
        ])

        
        

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.modalDidDismiss()
    }
    
    func attributedString(for text: String, fittingWidth width: CGFloat, in label: UILabel) -> NSAttributedString {
        let font = label.font ?? UIFont.systemFont(ofSize: 16)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .kern: 1.8
        ]
        let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
        return attributedText
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)

    }

    @objc func addButtonTapped() {
        self.dismiss(animated: true)

    }
    
    // 재현님 코드 추가
    @objc func addCounntryButtonTapped() {
        
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        let centerX = UIScreen.main.bounds.minX
        let centerY = UIScreen.main.bounds.height / 2
        var angle = atan2(location.y - centerY, location.x - centerX) * 180 / .pi
        
        if angle < 0 { angle += 360 }
        let theta = lastAngle - angle
        lastAngle = angle
        
        if abs(theta) < 12 {
            counter += theta
        }
        if counter > 12 {
            rotateLabels(by: -1)
            AudioServicesPlaySystemSound(1104)
        } else if counter < -12 {
            rotateLabels(by: 1)
            AudioServicesPlaySystemSound(1104)
        }
        if abs(counter) > 12 { counter = 0 }
        if gesture.state == .ended {
            counter = 0
        }
    }
    
    func rotateLabels(by steps: Int) {
        let angleStep = 2 * CGFloat.pi / CGFloat(labels.count)
        currentRotationAngle += CGFloat(steps) * angleStep
        
        let circleCenter = CGPoint(x: -70, y: view.frame.height / 2 + 20)
        let circleRadiusX: CGFloat = 250
        let circleRadiusY: CGFloat = 320
        
        UIView.animate(withDuration: 0.2, animations: {
            for (index, label) in self.labels.enumerated() {
                let baseAngle = 2 * CGFloat.pi * CGFloat(index) / CGFloat(self.labels.count) + self.currentRotationAngle
                let labelX = circleCenter.x + circleRadiusX * cos(baseAngle)
                let labelY = circleCenter.y + circleRadiusY * sin(baseAngle)
                
                label.center = CGPoint(x: labelX, y: labelY)
                label.transform = CGAffineTransform(rotationAngle: baseAngle)
            }
        }, completion: { _ in self.labelTextSending() })
    }
    
    func labelTextSending() {

    }
    

    func blurEffect() {
        
                 let blurEffect = UIBlurEffect(style: .dark)
                      let blurEffectView = UIVisualEffectView(effect: blurEffect)
      
      
                      blurEffectView.frame = self.view.bounds
                      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
      
                      view.addSubview(blurEffectView)
      
      
                      let backgroundView = UIView(frame: self.view.bounds)
                      backgroundView.backgroundColor = UIColor.backgroundColor.withAlphaComponent(0.3)
                      backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                      blurEffectView.contentView.addSubview(backgroundView)
        
        
        
        
    }
    
    

    func filterCountries(for searchText: String) {
        if (searchText.isEmpty) {
            filteredCountries = countries
        } else {
            filteredCountries = countries.filter { country in
                return country.lowercased().contains(searchText.lowercased())
            }
        }
        displayCountries(filteredCountries)
    }
    
    func displayCountries(_ countries: [String]) {
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        let circleCenter = CGPoint(x: -70, y: view.frame.height / 2 + 20)
        let circleRadiusX: CGFloat = 250
        let circleRadiusY: CGFloat = 320
        
        let Countries = countries
        
        for (index, country) in Countries.enumerated() {
            let angle = 2 * CGFloat.pi * CGFloat(index) / CGFloat(Countries.count)
            let labelX = circleCenter.x + circleRadiusX * cos(angle)
            let labelY = circleCenter.y + circleRadiusY * sin(angle)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
            label.center = CGPoint(x: labelX, y: labelY)
            label.text = country
            label.font = UIFont(name: AppFontName.interLight, size: 17) ?? UIFont.systemFont(ofSize: 17)
            label.textColor = .white
            label.textAlignment = .left
            label.attributedText = attributedString(for: country, fittingWidth: 150, in: label)
            label.transform = CGAffineTransform(rotationAngle: angle)
            
            self.labels.append(label)
            self.view.addSubview(label)
        }
    }
    
    // UITextFieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        filterCountries(for: currentText)
        return true
    }

    
    // UISearchBarDelegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 포커스가 가면 직사각형 모양으로 펼쳐지는 애니메이션
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.searchBarWidthConstraint.constant = self.view.frame.size.width - 60
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // 포커스가 가지 않으면 정사각형 모양으로 되돌리는 애니메이션
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut) {
            self.searchBarWidthConstraint.constant = 50
            self.view.layoutIfNeeded()
            searchBar.text = nil
        }
    }
}
