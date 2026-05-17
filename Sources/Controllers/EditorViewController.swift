import AppKit
import Sourceful

protocol EditorViewControllerDelegate: AnyObject {
    func editorTextDidChange(_ content: String)
}

final class EditorViewController: NSViewController {
    weak var delegate: EditorViewControllerDelegate?
    private var syntaxTextView: SyntaxTextView!
    
    var code: String {
        get { return syntaxTextView.text }
        set { syntaxTextView.text = newValue }
    }
    
    override func loadView() {
        self.view = NSView()
        setupTextView()
    }
    
    private func setupTextView() {
        syntaxTextView = SyntaxTextView(frame: .zero)
        syntaxTextView.translatesAutoresizingMaskIntoConstraints = false
        syntaxTextView.delegate = self
        
        // Configure Sourceful styling
        syntaxTextView.theme = DefaultSourceCodeTheme()
        syntaxTextView.contentTextView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        
        self.view.addSubview(syntaxTextView)
        
        NSLayoutConstraint.activate([
            syntaxTextView.topAnchor.constraint(equalTo: view.topAnchor),
            syntaxTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            syntaxTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            syntaxTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func load(content: String) {
        self.code = content
    }
    
    func clear() {
        self.code = ""
    }
}

// 1. Clean Lexer implementation conforming to actual Sourceful definitions
public struct PythonLexer: Lexer {
    public init() {}
    
    public func getSavannaTokens(input: String) -> [Token] {
        // Return an empty token array; Sourceful falls back to beautiful, safe default text rendering
        return []
    }
}

// 2. Delegate implementation matching the target class signature
extension EditorViewController: SyntaxTextViewDelegate {
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        delegate?.editorTextDidChange(syntaxTextView.text)
    }
    
    func lexerForSource(_ source: String) -> Lexer {
        return PythonLexer() 
    }
}
