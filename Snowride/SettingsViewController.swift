import UIKit

class SettingsViewController: UIViewController {
  
  
  override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     navigationController?.setNavigationBarHidden(false, animated: animated)
   }
   
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
