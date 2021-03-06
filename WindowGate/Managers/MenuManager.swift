//
//  MenuManager.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 3/6/22.
//

import Cocoa

class MenuManager: NSObject {
    let windowManager: WindowManager
    
    let statusBarMenu: NSMenu
    let statusBarItem: NSStatusItem
    
    var windows: [Window] = []

    init(windowManager: WindowManager) {
        self.windowManager = windowManager
        self.statusBarMenu = NSMenu(title: "Status Menu")
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        super.init()
        
        statusBarItem.button?.title = "😐"
        statusBarItem.menu = statusBarMenu
        
        statusBarMenu.delegate = self
        statusBarMenu.autoenablesItems = true
    }

    @objc func exitApp() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func selectedItem(_ menuItem: NSMenuItem) {
        guard let window = windows.first(where: { $0.number == menuItem.tag })
        else { return }
        windowManager.moveWindowIfNeeded(window)
        windowManager.activate(window)
    }
}

extension MenuManager: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        menu.removeAllItems()
        windows = windowManager.enumerate()
        for window in windows {
            if window.isOnScreen && window.windowLayer == 0 {
                let item = statusBarMenu.addItem(
                    withTitle: "\(window.name ?? "") (\(window.ownerName ?? ""))",
                    action: #selector(MenuManager.selectedItem(_:)),
                    keyEquivalent: "")
                item.target = self
                item.tag = window.number ?? -1
            }
        }
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(
            withTitle: "Exit",
            action: #selector(MenuManager.exitApp),
            keyEquivalent: "").target = self
    }
}
