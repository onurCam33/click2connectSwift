//
//  ViewController.swift
//  webview2
//
//  Created by Onur ÇAM on 1.01.2025.
//

import UIKit
import WebKit
import AVFoundation
class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak var webViewContainer: UIView!
    
    var webView: WKWebView!
    let testURL = "https://www.w3schools.com/html/mov_bbb.mp4"
    let urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestMicrophonePermission()
        requestCameraPermission()
        setupWebView()
       // loadURLTest()
        loadURL()
    }
    func requestMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            print("Mikrofon izni verildi.")
                        } else {
                            print("Mikrofon izni reddedildi.")
                        }
                    }
                }
            case .denied:
                print("Mikrofon izni daha önce reddedildi. Ayarlardan manuel olarak izin verin.")
            case .granted:
                print("Mikrofon izni zaten verilmiş.")
            @unknown default:
                print("Bilinmeyen bir hata oluştu.")
        }
    }
    func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            print("Kamera izni verildi.")
                        } else {
                            print("Kamera izni reddedildi.")
                        }
                    }
                }
            case .denied:
                print("Kamera izni daha önce reddedildi. Ayarlardan manuel olarak izin verin.")
            case .authorized:
                print("Kamera izni zaten verilmiş.")
            case .restricted:
                print("Kamera kullanımı kısıtlandı.")
            @unknown default:
                print("Bilinmeyen bir hata oluştu.")
        }
    }
    func setupWebView() {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                let webConfiguration = WKWebViewConfiguration()
                webConfiguration.mediaTypesRequiringUserActionForPlayback = []
                webConfiguration.allowsInlineMediaPlayback = true
                webConfiguration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                
                self.webView = WKWebView(frame: self.webViewContainer.bounds, configuration: webConfiguration)
               // self.webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
                self.webView.uiDelegate = self
                self.webView.navigationDelegate = self
                self.webView.translatesAutoresizingMaskIntoConstraints = false
                self.webViewContainer.addSubview(self.webView)
                
                NSLayoutConstraint.activate([
                    self.webView.leadingAnchor.constraint(equalTo: self.webViewContainer.leadingAnchor),
                    self.webView.trailingAnchor.constraint(equalTo: self.webViewContainer.trailingAnchor),
                    self.webView.topAnchor.constraint(equalTo: self.webViewContainer.topAnchor),
                    self.webView.bottomAnchor.constraint(equalTo: self.webViewContainer.bottomAnchor)
                ])
            }
        }
    }
    func loadURLTest() {
        let testURL = testURL
        if let url = URL(string: testURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            print("URL geçersiz.")
        }
    }
    func loadURL() {
        if let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedUrl) {
            let request = URLRequest(url: url)
            DispatchQueue.global(qos: .background).async {
                print("URL isteği başlatılıyor: \(url.absoluteString)")
                DispatchQueue.main.async {
                    self.webView.load(request)
                    print("WebView yükleniyor...")
                }
            }
        } else {
            print("URL geçersiz veya kodlama hatası.")
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView yüklenirken hata oluştu: \(error.localizedDescription)")
    }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("WebView içeriği sonlandırıldı.")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Yükleme başlatılamadı: \(error.localizedDescription)")
    }
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.scheme == "https" {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
    

}

