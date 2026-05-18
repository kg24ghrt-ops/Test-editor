import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var editorViewController: EditorViewController!

    // ✅ Removed 'override init' completely to avoid the isolated context error

    func applicationDidFinishLaunching(_ notification: Notification) {
        // ✅ Safe to call NSApp here on the MainActor
        NSApp.setActivationPolicy(.regular)
        
        let mask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: mask,
            backing: .buffered,
            defer: false
        )
        
        editorViewController = EditorViewController()
        window.contentViewController = editorViewController
        
        window.title = "Python Runner"
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
