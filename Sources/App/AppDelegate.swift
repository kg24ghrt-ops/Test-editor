import AppKit

@main
final class AppWindowDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    private let mainVC = MainViewController()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let windowMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 850, height: 600),
            styleMask: windowMask,
            backing: .buffered,
            defer: false
        )
        
        window?.title = "NovaCibes Runner — Untitled"
        window?.center()
        window?.contentViewController = mainVC
        window?.makeKeyAndOrderFront(nil)
        
        setupProgrammaticMenu()
    }
    
    private func setupProgrammaticMenu() {
        let mainMenu = NSMenu()
        
        // App Main Category Menu dropdown
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit NovaCibes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        
        // Operational Run Operations Menu dropdown
        let runMenuItem = NSMenuItem()
        mainMenu.addItem(runMenuItem)
        let runMenu = NSMenu(title: "Run")
        runMenu.addItem(withTitle: "Run Script", action: #selector(MainViewController.runActiveScript), keyEquivalent: "r")
        runMenu.addItem(withTitle: "Stop Execution", action: #selector(MainViewController.stopActiveScript), keyEquivalent: ".")
        runMenuItem.submenu = runMenu
        
        NSApp.mainMenu = mainMenu
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
