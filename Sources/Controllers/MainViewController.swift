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

@objc func saveDocumentAs(_ sender: Any?) {
    let panel = NSSavePanel()
    panel.allowedContentTypes = [UTType.pythonScript]
    panel.nameFieldStringValue = document.fileURL?.lastPathComponent ?? "script.py"
    
    panel.beginSheetModal(for: self.view.window!) { [weak self] response in
        guard response == .OK, let url = panel.url else { return }
        self?.writeDocumentData(to: url)
    }
}
