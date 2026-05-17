import AppKit
import UniformTypeIdentifiers

// Replace the old openDocument and saveDocumentAs implementations with these native macOS 11 equivalents:

@objc func openDocument(_ sender: Any?) {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [UTType.pythonScript]
    panel.allowsMultipleSelection = false
    
    panel.beginSheetModal(for: self.view.window!) { [weak self] response in
        guard response == .OK, let url = panel.url else { return }
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
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

    // ... rest of your existing MainViewController methods above ...

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
                let content = try String(contentsOf: url, encoding: .utf8)
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
            try document.content.write(to: url, atomically: true, encoding: .utf8)
            document.fileURL = url
            document.isDirty = false
            window?.isDocumentEdited = false
            window?.title = "\(url.lastPathComponent) — NovaCibes Runner"
        } catch {
            let errorAlert = NSAlert(error: error)
            errorAlert.runModal()
        }
    }
} // <--- This final closing brace must wrap ALL the methods above

@objc func saveDocumentAs(_ sender: Any?) {
    let panel = NSSavePanel()
    panel.allowedContentTypes = [UTType.pythonScript]
    panel.nameFieldStringValue = document.fileURL?.lastPathComponent ?? "script.py"
    
    panel.beginSheetModal(for: self.view.window!) { [weak self] response in
        guard response == .OK, let url = panel.url else { return }
        self?.writeDocumentData(to: url)
    }
}
