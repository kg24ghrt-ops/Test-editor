import AppKit

final class MainViewController: NSViewController, EditorViewControllerDelegate, OutputViewControllerDelegate, APIServiceDelegate {
    
    private let splitView = NSSplitView()
    private let editorVC = EditorViewController()
    private let outputVC = OutputViewController()
    private let apiService = APIService()
    
    private var currentDocument = Document()
    
    override func loadView() {
        self.view = NSView()
        view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        
        splitView.translatesAutoresizingMaskIntoConstraints = false
        splitView.isVertical = false
        splitView.dividerStyle = .thin
        view.addSubview(splitView)
        
        addChild(editorVC)
        addChild(outputVC)
        
        splitView.addArrangedSubview(editorVC.view)
        splitView.addArrangedSubview(outputVC.view)
        
        NSLayoutConstraint.activate([
            splitView.topAnchor.constraint(equalTo: view.topAnchor),
            splitView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            splitView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splitView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        editorVC.delegate = self
        outputVC.delegate = self
        apiService.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyTokenPresence()
        apiService.connect()
    }
    
    private func verifyTokenPresence() {
        if TokenManager.shared.getToken() == nil {
            let alert = NSAlert()
            alert.messageText = "Hugging Face Access Token Required"
            alert.informativeText = "Please enter your authentication token to communicate securely with NovaCibes spaces:"
            let input = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
            alert.accessoryView = input
            alert.addButton(withTitle: "Save")
            
            if alert.runModal() == .alertFirstButtonReturn {
                _ = TokenManager.shared.saveToken(input.stringValue)
            }
        }
    }
    
    // MARK: - Actions Flow Engine
    
    @objc func runActiveScript() {
        let code = editorVC.getText()
        guard !code.isEmpty else { return }
        outputVC.clear()
        outputVC.appendText("🚀 Initializing execution process tunnel...\n", color: .systemGreen)
        apiService.runCode(code)
    }
    
    @objc func stopActiveScript() {
        apiService.stopExecution()
        outputVC.appendText("\n🛑 Terminate signal sent by client user.\n", color: .systemRed)
    }
    
    // MARK: - Delegate Pipelines
    
    func editorTextDidChange(newText: String) {
        currentDocument.content = newText
        if !currentDocument.isDirty {
            currentDocument.isDirty = true
            view.window?.isDocumentEdited = true
        }
    }
    
    func outputRequestedStdinSubmission(_ input: String) {
        apiService.sendStdin(input)
    }
    
    func apiServiceDidReceiveStdout(_ text: String) {
        outputVC.appendText(text, color: .textColor)
    }
    
    func apiServiceDidReceiveStderr(_ text: String) {
        outputVC.appendText(text, color: .systemRed)
    }
    
    func apiServiceDidReceiveError(_ message: String) {
        outputVC.appendText("\n❌ Engine Error: \(message)\n", color: .systemOrange)
    }
    
    func apiServiceExecutionDidComplete() {
        outputVC.appendText("\n✨ Process finished execution cycle.\n", color: .systemGreen)
    }
    
    func apiServiceConnectionStatusChanged(isConnected: Bool) {
        if !isConnected {
            outputVC.appendText("⚠️ WebSocket connection dropped. Retrying tunnel connection...\n", color: .systemOrange)
        }
    }
}
