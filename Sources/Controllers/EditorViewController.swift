import AppKit
import Sourceful

// ✅ Add @MainActor and mark the closure parameter as @Sendable
@MainActor
protocol EditorViewControllerDelegate: AnyObject {
    func editorTextDidChange(_ content: String)
}


final class EditorViewController: NSViewController {
    weak var delegate: EditorViewControllerDelegate?
    private var syntaxTextView: SyntaxTextView!
    
    // Translucent system blur effect view for a modern UI look
    private let blurVisualEffectView = NSVisualEffectView()
    // Separate container view to isolate our editor and manage safe layout margins
    private let editorContainerView = NSView()
    
    var code: String {
        get { return syntaxTextView.text }
        set { syntaxTextView.text = newValue }
    }
    
    override func loadView() {
        // Core design: Establish a standard starting resolution canvas
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 900, height: 650))
        setupVisualInterfaceHierarchy()
    }
    
    private func setupVisualInterfaceHierarchy() {
        // 1. Setup the Background Visual Effect (Translucent Dark Theme Canvas)
        blurVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurVisualEffectView.state = .active
        blurVisualEffectView.material = .underWindowBackground // Dynamic system depth blend
        blurVisualEffectView.blendingMode = .behindWindow
        self.view.addSubview(blurVisualEffectView)
        
        // 2. Setup Card Container Layer (Creates a crisp workspace panel inside the blur)
        editorContainerView.translatesAutoresizingMaskIntoConstraints = false
        editorContainerView.wantsLayer = true
        if let layer = editorContainerView.layer {
            layer.backgroundColor = NSColor(white: 0.07, alpha: 0.65).cgColor // Clean dark editor deck
            layer.cornerRadius = 10.0
            layer.borderColor = NSColor(white: 1.0, alpha: 0.08).cgColor     // Super-subtle inner border outline
            layer.borderWidth = 1.0
        }
        self.view.addSubview(editorContainerView)
        
        // 3. Setup the Actual Source Code TextView Engine
        syntaxTextView = SyntaxTextView(frame: .zero)
        syntaxTextView.translatesAutoresizingMaskIntoConstraints = false
        syntaxTextView.delegate = self
        
        // Style Sourceful to match the dark environment seamlessly
        syntaxTextView.theme = DefaultSourceCodeTheme()
        syntaxTextView.contentTextView.font = NSFont.monospacedSystemFont(ofSize: 13.5, weight: .regular)
        
        // Adjust underlying standard NSTextView settings if accessible for clean drawing
        syntaxTextView.contentTextView.backgroundColor = .clear
        syntaxTextView.wantsLayer = true
        syntaxTextView.layer?.backgroundColor = NSColor.clear.cgColor
        
        editorContainerView.addSubview(syntaxTextView)
        
        // 4. Activate Comprehensive UI Layout Constraints
        NSLayoutConstraint.activate([
            // Fill background completely with blur backdrop
            blurVisualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurVisualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurVisualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurVisualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Give the core container layout some breathing room (16pt margins from edges)
            editorContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            editorContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            editorContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            editorContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Padding buffer inside container for the code editor component itself (12pt layout inset)
            syntaxTextView.topAnchor.constraint(equalTo: editorContainerView.topAnchor, constant: 12),
            syntaxTextView.bottomAnchor.constraint(equalTo: editorContainerView.bottomAnchor, constant: -12),
            syntaxTextView.leadingAnchor.constraint(equalTo: editorContainerView.leadingAnchor, constant: 12),
            syntaxTextView.trailingAnchor.constraint(equalTo: editorContainerView.trailingAnchor, constant: -12)
        ])
    }
    
    func load(content: String) {
        self.code = content
    }
    
    func clear() {
        self.code = ""
    }
}

// Keep your clean Lexer matching Sourceful spec
public struct PythonLexer: Lexer {
    public init() {}
    
    public func getSavannaTokens(input: String) -> [Token] {
        return []
    }
}

// ✅ Add @preconcurrency here to quiet down the compiler regarding Sourceful's layout rules
extension EditorViewController: @preconcurrency SyntaxTextViewDelegate {
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        delegate?.editorTextDidChange(syntaxTextView.text)
    }
    
    func lexerForSource(_ source: String) -> Lexer {
        return PythonLexer() 
    }
}
