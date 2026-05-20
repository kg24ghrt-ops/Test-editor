import AppKit

protocol EditorViewControllerDelegate: AnyObject {
    func editorTextDidChange(newText: String)
}

final class EditorViewController: NSViewController, NSTextViewDelegate {
    weak var delegate: EditorViewControllerDelegate?
    
    private let scrollView = NSScrollView()
    let textView = NSTextView()
    
    override func loadView() {
        self.view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.autoresizingMask = [.width]
        textView.delegate = self
        
        scrollView.documentView = textView
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setText(_ text: String) {
        textView.string = text
    }
    
    func getText() -> String {
        return textView.string
    }
    
    func textDidChange(_ notification: Notification) {
        delegate?.editorTextDidChange(newText: textView.string)
    }
}
