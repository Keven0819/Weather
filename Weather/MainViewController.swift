//
//  MainViewController.swift
//  Weather
//
//  Created by imac-2627 on 2024/9/11.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lbCity: UILabel! //地區
    @IBOutlet weak var lbWx: UILabel! //天氣狀態描述
    @IBOutlet weak var lbMinT: UILabel! //最低溫度
    @IBOutlet weak var lbMaxT: UILabel! //最高溫度
    @IBOutlet weak var lbPoP: UILabel! //下雨機率
    @IBOutlet weak var lbCI: UILabel! //溫度體感描述 ex:舒適至悶熱
    @IBOutlet weak var btnChangeTime: UIButton! //變更時段
    @IBOutlet weak var btnChangeArea: UIButton! //變更地區
    
    // MARK: - Property
    
    var weatherData: WeatherData?
    
    var selectedTimeIndex: Int = 0
    let timeOptions = ["今日白天(12:00~18:00)", "今晚明晨(18:00~06:00)", "明日白天(06:00~18:00)"]
    
    var selectedAreaIndex: Int = 0
    let areaOptions = ["宜蘭縣", "花蓮縣", "臺東縣", "澎湖縣", "金門縣", "連江縣", "臺北市", "新北市",
                        "桃園市", "臺中市", "臺南市", "高雄市", "基隆市", "新竹縣", "新竹市", "苗栗縣",
                        "彰化縣", "南投縣", "雲林縣", "嘉義縣", "嘉義市", "屏東縣"]
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChangeTimeButton()
        callAPI()
    }
    
    // MARK: - UI Settings
    
    func setupChangeTimeButton() {
        btnChangeTime.setTitle(timeOptions[selectedTimeIndex], for: .normal)
        btnChangeTime.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        btnChangeTime.addTarget(self, action: #selector(changeTimeButtonTapped), for: .touchUpInside)
        
        btnChangeArea.setTitle(areaOptions[selectedAreaIndex], for: .normal)
        btnChangeArea.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        btnChangeArea.addTarget(self, action: #selector(changeAreaButtonTapped), for: .touchUpInside)
    }
    
    func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let locationData = self.weatherData?.records.location.first else {
                return
            }
            
            self.lbCity.text = locationData.locationName
            
            for element in locationData.weatherElement {
                if element.time.count > self.selectedTimeIndex {
                    let timeData = element.time[self.selectedTimeIndex]
                    switch element.elementName {
                    case "Wx":
                        self.lbWx.text = timeData.parameter.parameterName
                    case "MinT":
                        self.lbMinT.text = "\(timeData.parameter.parameterName)°C"
                    case "MaxT":
                        self.lbMaxT.text = "\(timeData.parameter.parameterName)°C"
                    case "PoP":
                        self.lbPoP.text = "\(timeData.parameter.parameterName)%"
                    case "CI":
                        self.lbCI.text = timeData.parameter.parameterName
                    default:
                        break
                    }
                }
            }
            
            self.btnChangeTime.setTitle(self.timeOptions[self.selectedTimeIndex], for: .normal)
            btnChangeTime.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        }
    }
    
    // MARK: - IBAction
    
    // MARK: - Function
    
    func callAPI() {
        guard selectedAreaIndex < areaOptions.count else { return }
        var city = areaOptions[selectedAreaIndex]
        
        let requestURL = LegitimateURL(requestURL:
        "https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=CWA-B2E2B8D3-55CE-4C04-88EA-50ACB5AE4747&locationName=" + city)
        
        URLSession.shared.dataTask(with: requestURL) { [self]
            (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let response = response {
                print("=========================================================")
                print(response as! HTTPURLResponse)
                print("=========================================================")
            }
            
            
            if let data = data {
                let decoder = JSONDecoder()
                
                do {
                    self.weatherData = try decoder.decode(WeatherData.self, from: data)
                    self.updateUI()
                    
                    print("=========================================================")
                    print(weatherData ?? "")
                    print("=========================================================")
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
        
    }
    
    func LegitimateURL(requestURL: String) -> URL {
        
        let LegitimateURL = requestURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL.init(string: LegitimateURL!)
        
        return url!
    }
    
    @objc func changeTimeButtonTapped() {
        let alertController = UIAlertController(title: "選擇時間段", message: nil, preferredStyle: .actionSheet)
        
        for (index, option) in timeOptions.enumerated() {
            let action = UIAlertAction(title: option, style: .default) { [weak self] _ in
                self?.selectedTimeIndex = index
                self?.btnChangeTime.setTitle(option, for: .normal)
                self?.callAPI()
                self?.updateUI()
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func changeAreaButtonTapped() {
        let alertController = UIAlertController(title: "選擇地區", message: nil, preferredStyle: .actionSheet)
        
        for (index, option) in areaOptions.enumerated() {
            let action = UIAlertAction(title: option, style: .default) { [weak self] _ in
                self?.selectedAreaIndex = index
                self?.btnChangeArea.setTitle(option, for: .normal)
                self?.callAPI()
                self?.updateUI()
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Extensions
