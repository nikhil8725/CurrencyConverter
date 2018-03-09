
import UIKit
import Alamofire

protocol ServiceDelegate : class{
    func responseDelegateFunc(response : NSDictionary)
}


class WebService{
    weak var delegate: ServiceDelegate?
    func CallService (url : String)  {
        var rVal : NSDictionary = NSDictionary()
        Alamofire.request(url).responseJSON(completionHandler: {response in

            let resp  = response.result.value
            rVal = resp as! NSDictionary
            
            let header = rVal.object(forKey: "rates")! as! NSDictionary

            self.delegate?.responseDelegateFunc(response : header)
        })
        
       
    }
}
