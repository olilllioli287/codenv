// codenv-ime:讓 tmux 的 Ctrl+A 在中文輸入法(注音等)開著時也能用
//
// 輸入法開著時,Ctrl+A 之後按的字母會先被輸入法拿去組字,tmux 收不到。
// 這個小程式在按下 Ctrl+A 時先把輸入法切成英文,等 tmux 的指令做完,再切回原本的輸入法。
//
// 用法:
//   codenv-ime get                    印出目前輸入法的 ID
//   codenv-ime set <ID>               切到指定的輸入法
//   codenv-ime tmux-prefix [client]   目前不是英文就切成英文,等 tmux 離開 Ctrl+A 狀態後切回原本的輸入法
//                                     (給 ~/.tmux.conf 用;本來就是英文時什麼都不做)
// 編譯: swiftc -O codenv-ime.swift -o ~/.codenv-ime

import Carbon
import Foundation

func property<T>(_ source: TISInputSource, _ key: CFString) -> T? {
    guard let raw = TISGetInputSourceProperty(source, key) else { return nil }
    return Unmanaged<AnyObject>.fromOpaque(raw).takeUnretainedValue() as? T
}

func currentSource() -> TISInputSource {
    TISCopyCurrentKeyboardInputSource().takeRetainedValue()
}

func sourceID(_ source: TISInputSource) -> String {
    property(source, kTISPropertyInputSourceID) ?? ""
}

func isEnglish(_ source: TISInputSource) -> Bool {
    let ascii: Bool = property(source, kTISPropertyInputSourceIsASCIICapable) ?? false
    let type: String = property(source, kTISPropertyInputSourceType) ?? ""
    return ascii && type == (kTISTypeKeyboardLayout as String)
}

func sources(_ filter: [String: Any]) -> [TISInputSource] {
    (TISCreateInputSourceList(filter as CFDictionary, false)?.takeRetainedValue() as? [TISInputSource]) ?? []
}

@discardableResult
func select(id: String) -> Bool {
    guard let source = sources([kTISPropertyInputSourceID as String: id]).first else { return false }
    return TISSelectInputSource(source) == noErr
}

// 英文鍵盤:優先用 ABC,其次 U.S.,再不然用任何已啟用、可以打英文的鍵盤配置
func selectEnglish() -> Bool {
    for id in ["com.apple.keylayout.ABC", "com.apple.keylayout.US"] where select(id: id) {
        return true
    }
    let layouts = sources([
        kTISPropertyInputSourceType as String: kTISTypeKeyboardLayout as String,
        kTISPropertyInputSourceIsASCIICapable as String: true,
    ])
    guard let first = layouts.first else { return false }
    return TISSelectInputSource(first) == noErr
}

// tmux 是不是還在等 Ctrl+A 之後的那個鍵(或還在可以連按的時間內)
func tmuxWaitingForKey(client: String?) -> Bool {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    task.arguments = ["tmux", "display", "-p"] + (client.map { ["-c", $0] } ?? []) + ["#{client_prefix}"]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = FileHandle.nullDevice
    guard (try? task.run()) != nil else { return false }
    task.waitUntilExit()
    let out = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    return out.trimmingCharacters(in: .whitespacesAndNewlines) == "1"
}

func tmuxPrefix(client: String?) {
    let before = currentSource()
    if isEnglish(before) { return }
    let previous = sourceID(before)
    guard selectEnglish() else { return }
    let english = sourceID(currentSource())
    // 等 tmux 離開 Ctrl+A 狀態;最多等 10 分鐘,避免一直留在背景
    let deadline = Date().addingTimeInterval(600)
    var interval = 0.05
    Thread.sleep(forTimeInterval: interval)
    while Date() < deadline && tmuxWaitingForKey(client: client) {
        Thread.sleep(forTimeInterval: interval)
        interval = min(interval * 1.5, 0.3)
    }
    // 這段時間裡自己換過輸入法的話,就不要再切回去
    if sourceID(currentSource()) == english {
        select(id: previous)
    }
}

let args = Array(CommandLine.arguments.dropFirst())
switch args.first {
case "get":
    print(sourceID(currentSource()))
case "set" where args.count == 2:
    exit(select(id: args[1]) ? 0 : 1)
case "tmux-prefix":
    tmuxPrefix(client: args.count > 1 && !args[1].isEmpty ? args[1] : nil)
default:
    FileHandle.standardError.write("用法: codenv-ime get | set <ID> | tmux-prefix [client]\n".data(using: .utf8)!)
    exit(2)
}
