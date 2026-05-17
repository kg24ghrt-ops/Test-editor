import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var editorViewController: EditorViewController!

    // This handles the early lifecycle to force the app to show a UI window
    override init() {
        super.init()
        // Force macOS to treat this as a standard desktop application with a window
        NSApp.setActivationPolicy(.regular)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Setup window properties
        let mask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: mask,
            backing: .buffered,
            defer: false
        )
        
        // 2. Load our content view controller
        editorViewController = EditorViewController()
        window.contentViewController = editorViewController
        
        // 3. Make the window visible, center it, and bring it to the front
        window.title = "Python Runner"
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        // 4. Force focus over other windows
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Clean up and close the process when the user clicks the 'X' button
        return true
    }
}
