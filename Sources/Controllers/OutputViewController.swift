import AppKit

final class OutputViewController: NSViewController {
    private var scrollView: NSScrollView!
    private var textView: NSTextView!
    
    override func loadView() {
        self.view = NSView()
        setupViews()
    }
    
    private func setupViews() {
        scrollView = NSScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        
        textView = NSTextView(frame: .zero)
        textView.isEditable = false
        textView.isSelectable = true
        textView.autoresizingMask = [.width, .height]
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textColor = .textColor
        textView.backgroundColor = .textBackgroundColor
        
        scrollView.documentView = textView
        self.view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func append(stdout: String, stderr: String) {
        guard let storage = textView.textStorage else { return }
        
        if !stdout.isEmpty {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.textColor,
                .font: textView.font ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
            ]
            storage.append(NSAttributedString(string: stdout, attributes: attributes))
        }
        
        if !stderr.isEmpty {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.systemRed,
                .font: textView.font ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
            ]
            storage.append(NSAttributedString(string: stderr, attributes: attributes))
        }
        
        // Auto-scroll to the bottom
        textView.scrollToEndOfDocument(nil)
    }
    
    func clear() {
        textView.string = ""
    }
}
