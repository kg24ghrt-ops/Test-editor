import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let windowController = MainWindowController()
        windowController.showWindow(nil)
        self.mainWindowController = windowController
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { return true }
}
