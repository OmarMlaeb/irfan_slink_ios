import Foundation
import UIKit
import IBAnimatable

@IBDesignable
class TextField : AnimatableTextField, UITextFieldDelegate {

    @IBInspectable var leftImageSize: CGFloat = 20 {
        didSet {
            updateView()
        }
    }
    @IBInspectable var rightImageSize: CGFloat = 20 {
        didSet {
            updateView()
        }
    }

    @IBInspectable override var paddingLeft: CGFloat {
        didSet {
            updateView()
        }
    }

    @IBInspectable override var paddingRight: CGFloat {
        didSet {
            updateView()
        }
    }

    @IBInspectable var paddingTop: CGFloat = 5.0 {
        didSet {
            updateView()
        }
    }

    @IBInspectable var paddingBottom: CGFloat = 5.0 {
        didSet {
            updateView()
        }
    }

    @IBInspectable override var paddingSide: CGFloat {
        didSet {
            updateView()
        }
    }

    @IBInspectable var showBottomLine: Bool = false {
        didSet {
            updateView()
        }
    }

    @IBInspectable var maxLength: Int = Int.max

    @IBInspectable override var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }

    @IBInspectable override var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }

    @IBInspectable override var leftImageLeftPadding: CGFloat {
        didSet {
            updateView()
        }
    }

    @IBInspectable override var rightImageRightPadding: CGFloat {
        didSet {
            updateView()
        }
    }

    @IBInspectable override var opacity: CGFloat {
        didSet {
            configureOpacity()
        }
    }

    @IBInspectable override var leftImageTopPadding: CGFloat {
        didSet {
            configureImages()
        }
    }

    @IBInspectable override var rightImageLeftPadding: CGFloat {
        didSet {
            configureImages()
        }
    }

    @IBInspectable override var rightImageTopPadding: CGFloat {
        didSet {
            configureImages()
        }
    }

    @IBInspectable override var autoRun: Bool {
        didSet {

        }
    }

    @IBInspectable override var duration: Double {
        didSet {

        }
    }

    @IBInspectable override var delay: Double {
        didSet {

        }
    }

    @IBInspectable override var damping: CGFloat {
        didSet {

        }
    }

    @IBInspectable override var velocity: CGFloat {
        didSet {

        }
    }

    @IBInspectable override var force: CGFloat {
        didSet {

        }
    }

    private weak var userDelegate: UITextFieldDelegate?

    override var delegate: UITextFieldDelegate? {
        get { return userDelegate }
        set { userDelegate = newValue }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initCustomTextField()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCustomTextField()
    }

    override func awakeFromNib() {
        //        super.awakeFromNib()
        initCustomTextField()
    }

    private func initCustomTextField() {
        super.delegate = self // Note the super qualifier.
        //        self.layer.borderWidth = borderWidth
        //        self.layer.cornerRadius = self.cornerRadius
        if textAlignment != .center {
            if UIApplication.isRTL()  {
                if self.textAlignment == .right {
                    return
                }
                self.textAlignment = .right
            } else {
                if self.textAlignment == .left {
                    return
                }
                self.textAlignment = .left
            }
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var padding = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        if leftImage != nil {
            if UIApplication.isRTL() {
                padding.right = paddingRight + rightImageSize + leftImageLeftPadding
            }
            else {
                padding.left = paddingLeft + leftImageSize + leftImageLeftPadding
            }
        }
        if rightImage != nil {
            if UIApplication.isRTL() {
                padding.left = paddingLeft + leftImageSize + leftImageLeftPadding
            }
            else {
                padding.right = paddingRight + 8 + rightImageRightPadding
            }
        }
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var padding = UIEdgeInsets(top:paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)

        if leftImage != nil {
            if UIApplication.isRTL() {
                padding.right = paddingRight + rightImageSize + leftImageLeftPadding
            }
            else {
                padding.left = paddingLeft + leftImageSize + leftImageLeftPadding
            }
        }
        if rightImage != nil {
            if UIApplication.isRTL() {
                padding.left = paddingLeft + leftImageSize + leftImageLeftPadding
            }
            else {
                padding.right = paddingRight + 8 + rightImageRightPadding
            }
        }
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var padding = UIEdgeInsets(top:paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        if leftImage != nil {
            if UIApplication.isRTL() {
                padding.right = paddingRight + rightImageSize + leftImageLeftPadding
            }
            else {
                padding.left = paddingLeft + leftImageSize + leftImageLeftPadding
            }
        }
        if rightImage != nil {
            if UIApplication.isRTL() {
                padding.left = paddingLeft + leftImageSize + leftImageLeftPadding
            }
            else {
                padding.right = paddingRight + 8 + rightImageRightPadding
            }
        }
        return bounds.inset(by: padding)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let leftView = leftView as? UIImageView {
            leftView.image = leftImage
        }

        if let rightView = rightView as? UIImageView {
            rightView.image = rightImage
        }
    }

    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftImageLeftPadding
        return textRect
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= rightImageRightPadding
        return textRect
    }

    func updateView() {
        if showBottomLine {
            self.addBorders(edges: [.bottom], color: .white, thickness: 1)
        }
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: leftImageSize, height: leftImageSize))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image.scaleImage(scaledToSize: CGSize(width: leftImageSize, height: leftImageSize))

            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = placeholderColor
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }

        if let image = rightImage {
            rightViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: rightImageSize, height: rightImageSize))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image.scaleImage(scaledToSize: CGSize(width: rightImageSize, height: rightImageSize))
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = placeholderColor
            rightView = imageView
        } else {
            rightViewMode = UITextField.ViewMode.never
            rightView = nil
        }

        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: placeholderColor ?? UIColor.white])
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return self.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? (newLength <= maxLength)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        return self.delegate?.textFieldDidBeginEditing?(textField) ?? ()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.delegate?.textFieldShouldReturn?(self) ?? true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self.delegate?.textFieldShouldBeginEditing?(self) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        return self.delegate?.textFieldDidEndEditing?(self) ?? ()
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self.delegate?.textFieldShouldClear?(self) ?? true
    }
}
