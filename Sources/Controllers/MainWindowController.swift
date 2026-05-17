import AppKit

final class MainWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Untitled — NovaCibes Runner"
        window.minSize = NSSize(width: 600, height: 400)
        
        let mainVC = MainViewController()
        window.contentViewController = mainVC
        
        self.init(window: window)
        mainVC.window = window
    }
}
