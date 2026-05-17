import AppKit
import UniformTypeIdentifiers

final class MainViewController: NSViewController, EditorViewControllerDelegate {
    weak var window: NSWindow?
    
    private var splitView: NSSplitView!
    private let editorVC = EditorViewController()
    private let outputVC = OutputViewController()
    private let apiService = APIService()
    private var document = Document()
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        setupSplitView()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        checkTokenRequirement()
    }
    
    private func setupSplitView() {
        splitView = NSSplitView(frame: self.view.bounds)
        splitView.autoresizingMask = [.width, .height]
        splitView.isVertical = false
        splitView.dividerStyle = .thin
        
        addChild(editorVC)
        addChild(outputVC)
        
        splitView.addSubview(editorVC.view)
        splitView.addSubview(outputVC.view)
        self.view.addSubview(splitView)
        
        editorVC.delegate = self
    }
    
    func editorTextDidChange(_ content: String) {
        document.content = content
        if !document.isDirty {
            document.isDirty = true
            window?.isDocumentEdited = true
        }
    }
    
    private func checkTokenRequirement() {
        if TokenManager.shared.getToken() == nil {
            let alert = NSAlert()
            alert.messageText = "Hugging Face Token Required"
            alert.informativeText = "Please paste your NovaCibes API validation token below:"
            alert.addButton(withTitle: "Save")
            
            let input = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 240, height: 24))
            alert.accessoryView = input
            
            alert.beginSheetModal(for: self.view.window!) { response in
                if response == .alertFirstButtonReturn {
                    TokenManager.shared.save(token: input.stringValue)
                }
            }
        }
    }
    
    // MARK: - Core Execution Actions
    @objc func runScript(_ sender: Any?) {
        outputVC.clear()
        outputVC.append(stdout: "Executing script on NovaCibes Runner...\n", stderr: "")
        
        apiService.run(code: document.content) { [weak self] result in
            switch result {
            case .success(let output):
                self?.outputVC.append(stdout: output.stdout, stderr: output.stderr)
            case .failure(let error):
                self?.outputVC.append(stdout: "", stderr: "\n[Error]: \(error.localizedDescription)\n")
            }
        }
    }
    
    @objc func cancelRun(_ sender: Any?) {
        apiService.cancelRun()
        outputVC.append(stdout: "\nExecution canceled by user.\n", stderr: "")
    }
    
    // MARK: - File I/O Actions
    @objc func newDocument(_ sender: Any?) {
        editorVC.clear()
        outputVC.clear()
        document = Document()
        window?.title = "Untitled — NovaCibes Runner"
        window?.isDocumentEdited = false
    }
    
    @objc func openDocument(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.pythonScript]
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: self.view.window!) { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            do {
                let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
                self?.document = Document(fileURL: url, content: content, isDirty: false)
                self?.editorVC.load(content: content)
                self?.window?.title = "\(url.lastPathComponent) — NovaCibes Runner"
                self?.window?.isDocumentEdited = false
            } catch {
                let errorAlert = NSAlert(error: error)
                errorAlert.runModal()
            }
        }
    }
    
    @objc func saveDocument(_ sender: Any?) {
        if let url = document.fileURL {
            writeDocumentData(to: url)
        } else {
            saveDocumentAs(sender)
        }
    }
    
    @objc func saveDocumentAs(_ sender: Any?) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.pythonScript]
        panel.nameFieldStringValue = document.fileURL?.lastPathComponent ?? "script.py"
        
        panel.beginSheetModal(for: self.view.window!) { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            self?.writeDocumentData(to: url)
        }
    }
    
    private func writeDocumentData(to url: URL) {
        do {
            try document.content.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            document.fileURL = url
            document.isDirty = false
            window?.isDocumentEdited = false
            window?.title = "\(url.lastPathComponent) — NovaCibes Runner"
        } catch {
            let errorAlert = NSAlert(error: error)
            errorAlert.runModal()
        }
    }
}
