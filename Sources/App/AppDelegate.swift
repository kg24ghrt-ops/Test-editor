import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var editorViewController: EditorViewController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Configure the window size and style masks
        let mask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: mask,
            backing: .buffered,
            defer: false
        )
        
        // 2. Initialize the view controller and inject it into the window
        editorViewController = EditorViewController()
        window.contentViewController = editorViewController
        
        // 3. Center the interface on screen and bring it to focus
        window.title = "Python Runner Editor"
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
