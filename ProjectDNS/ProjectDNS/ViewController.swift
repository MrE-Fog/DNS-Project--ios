//
//  ViewController.swift
//  ProjectDNS
//
//  Created by venky N on 11/01/23.
//

import UIKit

class ViewController: UIViewController {
    
    let DOMAIN = "local"
    let ServiceTYPE = "_http._tcp"
    let PORT : CInt = 8000
    var ServiceNAME  : String = ""
    
    var netService : NetService?
    var netServiceBrow : NetServiceBrowser?
    var arrayNetServices = [NetService]()

    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var serviceNameTextField: UITextField!
    
    @IBOutlet weak var serviceTypeTextField: UITextField!
    
    @IBOutlet weak var domainTextField: UITextField!
    
    @IBOutlet weak var portTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        listTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        configureDetails()
    }

    
    func configureDetails() {
        self.ServiceNAME = UIDevice.current.name
        self.serviceNameTextField.text = "\(ServiceNAME)"
        self.portTextField.text = "\(PORT)"
        self.serviceTypeTextField.text = "\(ServiceTYPE)"
        self.domainTextField.text = "\(DOMAIN)"
        self.listTableView.tableFooterView = UIView()
        self.arrayNetServices.removeAll()
    }
    
    func ConfigureUI () {
        for service in self.arrayNetServices {
            if service.port == -1 {
                print("service \(service.name) of type \(service.type)" +
                    " not yet resolved")
                service.delegate = self
                service.resolve(withTimeout:10)
            } else {
                print("service \(service.name) of type \(service.type)," +
                      "port \(service.port), addresses \(service.addresses)")
            }
        }
        self.listTableView.reloadData()

    }

}
// MARK: - Net service Action Methods.

extension ViewController {
    @IBAction func onTapScanButton(_ sender: UIButton) {
        print("listening for services...")
        netServiceBrow = NetServiceBrowser()
        netServiceBrow?.delegate = self
        netServiceBrow?.searchForServices(ofType: ServiceTYPE, inDomain: DOMAIN)
    }
    
    @IBAction func onTapPublishButton(_ sender: UIButton) {
        if self.serviceNameTextField.text?.count ?? 0 > 1 && self.portTextField.text?.count ?? 0 > 1  && self.serviceTypeTextField.text?.count ?? 0 > 1 && self.domainTextField.text?.count ?? 0 > 1 {
            netService = NetService(domain: DOMAIN,
                                    type: ServiceTYPE, name:  self.serviceNameTextField.text ?? "", port: Int32(self.portTextField?.text ?? "") ?? 0)
            netService?.delegate = self
            netService?.publish()
            self.serviceNameTextField.text = ""
            self.portTextField.text = "\(PORT)"
        }
    }
}
extension ViewController: NetServiceDelegate {
    
    
    func netServiceWillPublish(sender: NetService!) {
        print("netServiceWillPublish:\(sender)")
    }
    
    func netService(sender: NetService, didNotPublish errorDict: [NSObject : AnyObject]) {
        print("didNotPublish:\(sender)")
    }
    
    func netServiceDidPublish(sender: NetService) {
        print("netServiceDidPublish:\(sender)")
    }
    
    func netServiceWillResolve(sender: NetService) {
        print("netServiceWillResolve:\(sender)")
    }
    
    func netService(sender: NetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        print("netServiceDidNotResolve:\(sender)")
    }
    
    internal func netServiceDidResolveAddress(_ sender: NetService) {
        print("netServiceDidResolve:\(sender)")
        self.ConfigureUI()
        for address in sender.addresses ?? [] {
            do {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                try address.withUnsafeBytes { (pointer:UnsafePointer<sockaddr>) -> Void in
                    guard getnameinfo(pointer, socklen_t(address.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                        throw NSError(domain: "domain", code: 0, userInfo: ["error":"unable to get ip address"])
                    }
                }
                let ipAddress = String(cString: hostname)
                print("ipAddress = ", ipAddress)
                // heres your IP!
            } catch {
                print(error)
            }
        }
    }
    
    private func netService(sender: NetService, didUpdateTXTRecordData data: NSData) {
        print("netServiceDidUpdateTXTRecordData:\(sender)");
    }
    
    func netServiceDidStop(sender: NetService) {
        print("netServiceDidStopService:\(sender)");
    }
    
    internal func netService(_ sender: NetService,
                    didAcceptConnectionWith inputStream: InputStream,
                    outputStream stream: OutputStream) {
        print("netServiceDidAcceptConnection:\(sender)");
    }
}
extension ViewController : NetServiceBrowserDelegate {
    
    internal func netServiceBrowser(_ netServiceBrowser: NetServiceBrowser,
                                    didFindDomain domainName: String,
                                    moreComing moreDomainsComing: Bool) {
        print("netServiceDidFindDomain")
    }
    
    internal func netServiceBrowser(_ netServiceBrowser: NetServiceBrowser,
                                    didRemoveDomain domainName: String,
                                    moreComing moreDomainsComing: Bool) {
        print("netServiceDidRemoveDomain")
    }
    
    internal func netServiceBrowser(_ netServiceBrowser: NetServiceBrowser,
                                    didFind netService: NetService,
                                    moreComing moreServicesComing: Bool) {
        print("netServiceDidFindService =\( netService.domain) = \(netService.type ) = \(netService.name) = \(netService.port) = \(netService.addresses)")
        print("adding a service")
        self.arrayNetServices.append(netService)
        if !moreServicesComing {
            self.ConfigureUI()
        }
        
        for address in netService.addresses ?? [] {
            do {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                try address.withUnsafeBytes { (pointer:UnsafePointer<sockaddr>) -> Void in
                    guard getnameinfo(pointer, socklen_t(address.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                        throw NSError(domain: "domain", code: 0, userInfo: ["error":"unable to get ip address"])
                    }
                }
                let ipAddress = String(cString: hostname)
                print("ipAddress = ", ipAddress)
                // heres your IP!
            } catch {
                print(error)
            }
        }
    }
    
    internal func netServiceBrowser(_ netServiceBrowser: NetServiceBrowser,
                                    didRemove netService: NetService,
                                    moreComing moreServicesComing: Bool) {
        print("netServiceDidRemoveService")
        //        if let ix = self.arrayNetServices.index(of:netService) {
        //            self.arrayNetServices.remove(at:ix)
        //            print("removing a service")
        //            if !moreServicesComing {
        //                self.updateInterface()
        //            }
        //        }
    }
    
    func netServiceBrowserWillSearch(aNetServiceBrowser: NetServiceBrowser!){
        print("netServiceBrowserWillSearch")
    }
    
    private func netServiceBrowser(netServiceBrowser: NetServiceBrowser,
                                   didNotSearch errorInfo: [NSObject : AnyObject]) {
        print("netServiceDidNotSearch")
    }
    
    func netServiceBrowserDidStopSearch(_ netServiceBrowser: NetServiceBrowser) {
        print("netServiceDidStopSearch")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayNetServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath as IndexPath) as! CustomTableViewCell
        let service = arrayNetServices[indexPath.row]
        
        for address in service.addresses ?? [] {
            do {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                try address.withUnsafeBytes { (pointer:UnsafePointer<sockaddr>) -> Void in
                    guard getnameinfo(pointer, socklen_t(address.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                        throw NSError(domain: "domain", code: 0, userInfo: ["error":"unable to get ip address"])
                    }
                }
                if  let numAddress = String(validatingUTF8: hostname)  {
                    cell.configure(data: service, IpAddressData: numAddress)
                }
                
            } catch {
                print(error)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
    }
}

