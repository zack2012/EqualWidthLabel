// Created by Bohua Zheng on 2022/1/14.

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    let label = JSONViewTextView(frame: CGRect(x: 40, y: 100, width: 300, height: 300))
    label.backgroundColor = .red
    view.addSubview(label)
    let str = """
    iPhoneSE3应该是最早和我们见面的，预计将在2022年3月份或者4月份发布。先说说我个人的观点：智能手机和智能电视同理，小屏就意味着功能更弱，当然也意味着低端、廉价。正因如此，比起华而不实的iPhone 13 mini，iPhone SE系列更适合“小屏手机”的定位——4.7英寸的小屏已经严重影响正常使用了，苹果就算随便降价，也不用担心它影响主流iPhone的销量。
    """

    let text = JSONViewTextView.Text(attributedString: NSAttributedString(string: str, attributes: [.font: UIFont.systemFont(ofSize: 16)]))
    label.text = text
    label.frame.size = text.intrinsicRect.size
  }


}

