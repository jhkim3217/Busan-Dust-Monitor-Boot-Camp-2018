//
//  ViewController.swift
//  BusanMap02
//
//  Created by 김종현 on 30/10/2018.
//  Copyright © 2018 김종현. All rights reserved.
//  XCode 108.1

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, XMLParserDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var stepper: UIStepper!
    
    var locationManager = CLLocationManager()
    
//    var annotationPM10: BusanDataPM10?
//    var annotationPM25: BusanDataPM25?
    
//    var annotationsPM10: Array = [BusanDataPM10]()
//    var annotationsPM25: Array = [BusanDataPM25]()
    
    var annotation: BusanData?
    var annotations: Array = [BusanData]()
    
    
    var item:[String:String] = [:]  // item[key] => value
    var items:[[String:String]] = []
    var currentElement = ""
    
    var address: String?
    var lat: String?
    var long: String?
    var loc: String?
    var dLat: Double?
    var dLong: Double?
    var dArea: String? // 용도
    var dNet: String? // 측정망
    
    var tPM10: String?
    var vPM10Cai: String?
    var mPM10Cai: String?
    
    var tPM25: String?
    var vPM25Cai: String?
    var mPM25Cai: String?
    
    // 1시간 마다 호출위해 타이머 객체 생성
    var timer = Timer()
    var currentTime: String?
    
//    var label: UILabel?
    
    @IBOutlet weak var segControlBtn: UISegmentedControl!
   
    // 광복동, 초량동
    let addrs:[String:[String]] = [
        "태종대" : ["영도구 전망로 24", "35.0597260", "129.0798400", "태종대유원지관리사무소", "도시대기", "녹지지역"],
        "전포동" : ["부산진구 전포대로 175번길 22", "35.1530480", "129.0635640","경남공고 옥상", "도시대기",  "상업지역"],
        "광복동" : ["중구 광복로 55번길 10", "35.0999630", "129.0304170", "광복동 주민센터", "도시대기", "상업지역"],
        "장림동" : ["사하구 장림로 161번길 2", "35.0829920", "128.9668750", "사하여성회관", "도시대기","공업지역"],
        "학장동" : ["사상구 대동로 205", "35.1460850", "128.9838270", "학장초등학교", "도시대기","공업지역"],
        "덕천동" : ["북구 만덕대로 155번길 81", "35.2158660", "129.0197570", "한국환경공단", "도시대기", "주거지역"],
        "연산동" : ["연제구 중앙대로 1065번길 14", "35.1841140", "129.0786090", "연제초등학교", "도시대기", "주거지역"],
        "대연동" : ["남구수영로 196번길 80", "35.1303210", "129.0876850", "부산공업고등학교", "도시대기", "주거지역"],
        "청룡동" : ["금정구 청룡로 25", "35.2752570", "129.0898810","청룡노포동 주민센터 옥상", "도시대기", "주거지역"],
        "기장읍" : ["기장군 기장읍 읍내로 69", "35.2460560", "129.2118280","기장초등학교 옥상", "도시대기", "주거지역"],
        "대저동" : ["강서구 낙동북로 236", "35.2114600", "128.9547110","대저차량사업소 옥상", "도시대기", "녹지지역"],
        "부곡동" : ["금정구 부곡로 156번길 7", "35.2298390", "129.0927140","부곡2동 주민센터 옥상", "도시대기", "주거지역"],
        "광안동" : ["수영구 수영로 521번길 55", "35.1527040", "129.1078090","구 보건환경연구원 3층", "도시대기", "주거지역"],
        "명장동" : ["동래구 명장로 32", "35.2047550", "129.1043270","명장동 주민센터 옥상", "도시대기", "주거지역"],
        "녹산동" : ["강서구 녹산산업중로 333", "35.0953270", "128.8556680", "(주)삼성전기부산사업장 옥상", "도시대기",  "공업지역"],
        "용수리" : ["기장군 정관면 용수로4", "35.3255580", "129.1801400", "정관면 주민센터 2층 옥상", "도시대기", "주거지역"],
        "좌동"  : ["해운대구 양운로 91", "35.1708900", "129.1742250", "좌1동 주민센터 옥상", "도시대기", "주거지역"],
        "수정동" : ["동구 구청로 1", "35.1293350", "129.0454230", "동구청사 옥상", "도시대기", "주거지역"],
        "대신동" : ["서구 대신로 150", "35.1173230", "129.0156410", "부산국민체육센터", "도시대기", "주거지역"],
        "온천동" : ["동래구 중앙대로 동래역", "35.2056140", "129.0785020", "동래지하철 앞", "도로변", "상업지역"],
        "초량동" : ["동구 초량동 윤흥신장군 동상앞", "35.11194650", "129.0354560", "윤흥신장군 동상 앞", "도로변", "상업지역"],
        "부산신항" : ["부산 강서구 신항남로 416 부산신항다목적터미널(주) 본관 옥상", "35.0595018", "128.8121243", "부산신항다목적터미널(주) 본관 옥상", "도로변", "공업지역"],
        "부산북항" : ["부산 동구 충장대로 314 관공선부두 내", "35.1173881", "129.0465578", "관공선부두 내", "도로변", "공업지역"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "부산 미세먼지 지도"
        // Do any additional setup after loading the view, typically from a nib.
        
        // 사용자 현재 위치 트랙킹
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        // 사용자 현재 위치, 캠파스 표시
        myMapView.showsUserLocation = true
        myMapView.showsCompass = true
        
        myParse()
        timer = Timer.scheduledTimer(timeInterval: 60*60, target: self, selector: #selector(myParse), userInfo: nil, repeats: true)
        // Map
        myMapView.delegate = self
        //  초기 맵 region 설정
        
        //zoomToRegion()
        mapDisplay()
    }
    
    // Segment Control function
    @IBAction func segControlPressed(_ sender: Any) {
        if segControlBtn.selectedSegmentIndex == 0 {
            print("Seg o pressed")
           // zoomToRegion()
            
            removeAllAnnotations()
            mapDisplay()
            
        } else if segControlBtn.selectedSegmentIndex == 1 {
            print("Seg 1 pressed")
            //zoomToRegion()
            removeAllAnnotations()
            mapDisplay()
        }
    }
    
    func mapDisplay() {
        for item in items {
            let dSite = item["site"]
            //            print("dSite = \(String(describing: dSite))")
            
            // 추가 데이터 처리
            for (key, value) in addrs {
                if key == dSite {
                    address = value[0]
                    lat = value[1]
                    long = value[2]
                    loc = value[3]
                    dArea = value[4]
                    dNet = value[5]
                    dLat = Double(lat!)
                    dLong = Double(long!)
                }
            }
            
            // 파싱 데이터 처리
            let dPM10 = item["pm10"]
            let dPM10Cai = item["pm10Cai"]
            let dPM25 = item["pm25"]
            let dPM25Cai = item["pm25Cai"]
            
            annotation = BusanData(coordinate: CLLocationCoordinate2D(latitude: dLat!, longitude: dLong!),
                                   title: dSite!, subtitle: loc!,
                                   pm10: dPM10!, pm10Cai: dPM10Cai!,
                                   pm25: dPM25!, pm25Cai: dPM25Cai!,
                                   area: dArea!, network: dNet!)
            
            annotations.append(annotation!)
        }
        myMapView.showAnnotations(annotations, animated: true)
//        myMapView.addAnnotations(annotations)
        
    }
    
    func removeAllAnnotations() {
        for annotation in self.myMapView.annotations {
            self.myMapView.removeAnnotation(annotation)
        }
    }
    
    
    @objc func myParse() {
        // XML Parsing
        let key = "aT2qqrDmCzPVVXR6EFs6I50LZTIvvDrlvDKekAv9ltv9dbO%2F8i8JBz2wsrkpr9yrPEODkcXYzAqAEX1m%2Fl4nHQ%3D%3D"
        let strURL = "http://opendata.busan.go.kr/openapi/service/AirQualityInfoService/getAirQualityInfoClassifiedByStation?ServiceKey=\(key)&numOfRows=21"
        
        if let url = URL(string: strURL) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                
                if (parser.parse()) {
                    print("parsing success")
                    
                    // 파싱이 끝난시간 시간 측정
                    let date: Date = Date()
                    let dayTimePeriodFormat = DateFormatter()
                    dayTimePeriodFormat.dateFormat = "YYYY/MM/dd HH시"
                    currentTime = dayTimePeriodFormat.string(from: date)
                    for item in items {
                        print("Station = \(item["site"]!) item pm10 = \(item["pm10"]!)")
                    }
                    
                } else {
                    print("parsing fail")
                }
            } else {
                print("url error")
            }
        }
        
    }
    
    // XML Parsing Delegate 메소드
    // XMLParseDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        // tag 이름이 elements이거나 item이면 초기화
        if elementName == "items" {
            items = []
        } else if elementName == "item" {
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //        print("data = \(data)")
        if !data.isEmpty {
            item[currentElement] = data
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
        }
    }
    
    func zoomToRegion() {
        let location = CLLocationCoordinate2D(latitude: 35.180100, longitude: 129.081017)
        let span = MKCoordinateSpan(latitudeDelta: 0.27, longitudeDelta: 0.27)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
    }
    
    @IBAction func changeToOriginLocation(_ sender: Any) {
        
        let currnetLoc: CLLocation = locationManager.location!
        let location = CLLocationCoordinate2D(latitude: currnetLoc.coordinate.latitude, longitude: currnetLoc.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.20, longitudeDelta: 0.20)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
        
    }
    
    func changeStepperLocation(sLat: Double, sLong: Double) {
        
        let currnetLoc: CLLocation = locationManager.location!
        let location = CLLocationCoordinate2D(latitude: currnetLoc.coordinate.latitude, longitude: currnetLoc.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: sLat, longitudeDelta: sLong)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func stepperPressed(_ sender: Any) {
        let stepVal = stepper.value
        switch stepVal {
        case 1:
            print("Tesp 1")
            changeStepperLocation(sLat: 0.23, sLong: 0.23)
        case 2:
            print("Tesp 2")
            changeStepperLocation(sLat: 0.17, sLong: 0.17)
        case 3:
            print("Tesp 3")
            changeStepperLocation(sLat: 0.11, sLong: 0.11)
        case 4:
            print("Tesp 4")
            changeStepperLocation(sLat: 0.05, sLong: 0.05)
        default:
            break
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseID = "MyPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView
        //let label = UILabel(frame: CGRect(x: -2, y: 12, width: 30, height: 30))
  
        let seg_index = segControlBtn.selectedSegmentIndex
        //print("s_index = \(seg_index)")
        
        var iPm10Val = 0
        var iPm25Val = 0
        
        // Leave default annotation for user location
        if annotation is MKUserLocation {
            return nil
        }
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView?.animatesWhenAdded = true
            
            //annotationView?.animatesDrop = true
            
//            annotationView!.clusteringIdentifier = "re"
//            annotationView?.markerTintColor = UIColor.red

            let castBusanData = annotationView!.annotation as? BusanData
            
            if seg_index == 0 {
                let pm10Val = castBusanData?.pm10

                //let pm10Val = castBusanData?.pm10
                let pm10Station = castBusanData?.title
                //let pm10ValCai = castBusanData?.pm10Cai
                print("\(String(describing: pm10Station)) pm10 val = \(String(describing: pm10Val))")
                
//                label.textColor = UIColor.red
//                label.text = pm10Val
//                annotationView!.addSubview(label)
//                print("pm10 = \(String(describing: label.text))")
                //print("pm10 Cai = \(String(describing: pm10ValCai))")
                annotationView?.glyphTintColor = UIColor.lightGray
                annotationView?.glyphText = pm10Val
                
                if pm10Val != nil {
                    iPm10Val = Int(pm10Val!)!
                } else {
                    // dumy value
                    iPm10Val = 30
                }
                
                switch iPm10Val {
                    case 0..<31:
                        annotationView?.markerTintColor = UIColor.blue // 좋음
                    case 31..<81:
                        annotationView?.markerTintColor = UIColor.green // 보통
                    case 81..<151:
                        annotationView?.markerTintColor = UIColor.yellow
                    case 151..<600:
                        annotationView?.markerTintColor = UIColor.red // 매우나쁨
                    default : break
                }
                
                
//                switch pm10ValCai {
//                    case "4": annotationView?.markerTintColor = UIColor.red // 매우나쁨
//                    case "3": annotationView?.markerTintColor = UIColor.orange // 나쁨
//                    case "2": annotationView?.markerTintColor = UIColor.green // 보통
//                    case "1" : annotationView?.markerTintColor = UIColor.blue // 좋음
//                    //default: annotationView?.markerTintColor = UIColor.black// 오류
//                    default : break
//                }
                
            } else if seg_index == 1 {
                
                if let pm25Val = castBusanData?.pm25 {
                    iPm25Val = Int(pm25Val)!
                } else {
                    // dumy value
                    iPm25Val = 20
                }
                
//                if pm25Val != nil {
//                    iPm25Val = Int(pm25Val!)!
//                } else {
//                    iPm25Val = 20
//                }
                //let pm25CalCai = castBusanData?.pm25Cai
                //print("pm25 val = \(String(describing: pm25CalCai))")

//                label.textColor = UIColor.blue
//                label.text = pm25Val
//                annotationView!.addSubview(label)
                //print("pm25 = \(String(describing: pm25CalCai))")
                //print("pm25 Cai = \(String(describing: pm25CalCai))")
                
                annotationView?.glyphTintColor = UIColor.lightGray
                annotationView?.glyphText = String(iPm25Val)

                switch iPm25Val {
                case 0..<16:
                    annotationView?.markerTintColor = UIColor.blue // 좋음
                case 16..<36:
                    annotationView?.markerTintColor = UIColor.green // 보통
                case 36..<75:
                    annotationView?.markerTintColor = UIColor.yellow // 나쁨
                case 76..<500:
                    annotationView?.markerTintColor = UIColor.red // 매우나쁨
                default : break
                }

//                switch pm25CalCai {
//                    case "4": annotationView?.markerTintColor = UIColor.red // 매우나쁨
//                    case "3": annotationView?.markerTintColor = UIColor.orange // 나쁨
//                    case "2": annotationView?.markerTintColor = UIColor.green // 보통
//                    case "1" : annotationView?.markerTintColor = UIColor.blue // 좋음
//                    //default: annotationView?.markerTintColor = UIColor.black // 오류
//                default : break
//                }
            }
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        return annotationView
    }

    // rightCalloutAccessoryView를 눌렀을때 호출되는 delegate method
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let viewAnno = view.annotation as! BusanData // 데이터 클래스로 형변환(Down Cast)
        
        if segControlBtn.selectedSegmentIndex == 0 {
            let vPM10 = viewAnno.pm10
            let vStation = viewAnno.title
            
            print("vPm10 = \(String(describing: vPM10))")
            let dPM10: Int = Int(vPM10!)!
            
            switch Int(dPM10) {
            case 0..<31:
                mPM10Cai = "좋음" // 좋음
            case 31..<81:
                mPM10Cai = "보통"// 보통
            case 81..<151:
                mPM10Cai = "나쁨" // 나쁨
            case 76..<500:
                mPM10Cai = "매우나쁨" // 매우나쁨
            default : break
            }
            
//            switch vPM10Cai {
//                case "1": mPM10Cai = "좋음"
//                case "2": mPM10Cai = "보통"
//                case "3": mPM10Cai = "나쁨"
//                case "4": mPM10Cai = "아주나쁨"
//                default : break
//            }
            
            let mTitle = "미세먼지(PM 10) : \(mPM10Cai!)(\(vPM10!) ug/m3)"
            let ac = UIAlertController(title: vStation! + " 대기질 측정소", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "측정시간 : " + currentTime! , style: .default, handler: nil))
            ac.addAction(UIAlertAction(title: mTitle, style: .default, handler: nil))
            ac.addAction(UIAlertAction(title: "용도 : " + dArea!, style: .default, handler: nil))
            ac.addAction(UIAlertAction(title: "측정망 : " + dNet!, style: .default, handler: nil))
            ac.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
            self.present(ac, animated: true, completion: nil)
            
        } else if segControlBtn.selectedSegmentIndex == 1 {
            let vPM25 = viewAnno.pm25
            let vStation = viewAnno.title
            //let vPM25Cai = viewAnno.pm10Cai
            
            print("PM25 = \(String(describing: vPM25))")
            
            let dPM25: Int = Int(vPM25!)!
            
            switch Int(dPM25) {
            case 0..<31:
                mPM25Cai = "좋음" // 좋음
            case 31..<81:
                mPM25Cai = "보통"// 보통
            case 81..<151:
                mPM25Cai = "나쁨" // 나쁨
            case 76..<500:
                mPM25Cai = "매우나쁨" // 매우나쁨
            default : break
            }
            
//            switch vPM25Cai {
//                case "1": mPM25Cai = "좋음"
//                case "2": mPM25Cai = "보통"
//                case "3": mPM25Cai = "나쁨"
//                case "4": mPM25Cai = "아주나쁨"
//                default : mPM25Cai = "오류"
//            }
            
            let mTitle = "미세먼지(PM 2.5) : \(mPM25Cai!)(\(vPM25!) ug/m3)"
            let ac = UIAlertController(title: vStation! + " 대기질 측정소", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "측정시간 : " + currentTime! , style: .default, handler: nil))
            ac.addAction(UIAlertAction(title: mTitle, style: .default, handler: nil))
            ac.addAction(UIAlertAction(title: "용도 : " + dArea!, style: .default, handler: nil))
            ac.addAction(UIAlertAction(title: "측정망 : " + dNet!, style: .default, handler: nil))
            ac.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
            self.present(ac, animated: true, completion: nil)
            
        }
    }
}




