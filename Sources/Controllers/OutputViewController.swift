import AppKit

protocol OutputViewControllerDelegate: AnyObject {
    func outputRequestedStdinSubmission(_ input: String)
}

final class OutputViewController: NSViewController, NSTextFieldDelegate {
    weak var delegate: OutputViewControllerDelegate?
    
    private let scrollView = NSScrollView()
    private let textView = NSTextView()
    private let inputField = NSTextField()
    private let containerStack = NSStackView()
    
    override func loadView() {
        self.view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.orientation = .vertical
        containerStack.spacing = 4
        containerStack.alignment = .centerX
        view.addSubview(containerStack)
        
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        
        textView.isEditable = false
        textView.isRichText = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = NSColor.windowBackgroundColor
        textView.autoresizingMask = [.width]
        scrollView.documentView = textView
        
        inputField.placeholderString = "Type interactive stdin payload here and hit Enter..."
        inputField.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        inputField.isEditable = true
        inputField.delegate = self
        
        containerStack.addArrangedSubview(scrollView)
        containerStack.addArrangedSubview(inputField)
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            containerStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            
            scrollView.widthAnchor.constraint(equalTo: containerStack.widthAnchor),
            inputField.widthAnchor.constraint(equalTo: containerStack.widthAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func appendText(_ text: String, color: NSColor) {
        guard let storage = textView.textStorage else { return }
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        ]
        let attrString = NSAttributedString(string: text, attributes: attributes)
        
        storage.append(attrString)
        textView.scrollToEndOfDocument(nil)
    }
    
    func clear() {
        textView.string = ""
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            let input = inputField.stringValue
            if !input.isEmpty {
                appendText("\(input)\n", color: .systemGray)
                delegate?.outputRequestedStdinSubmission(input)
                inputField.stringValue = ""
            }
            return true
        }
        return false
    }
}
