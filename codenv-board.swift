// codenv-board:用滑鼠排列 tmux 的格子(2026-10-14 加)
// 開一個 Mac 視窗,列出 tmux 所有的工作階段、分頁和格子,每個分頁畫成小縮圖:
//   把格子拖到別的分頁 → 合併進去(join-pane);拖到「新分頁」→ 拆出來(break-pane)
//   把分頁拖到另一個分頁上 → 交換位置(swap-window);拖到別的工作階段 → 搬過去(move-window)
//   點一下格子 → 切換過去;雙擊名字或按右鍵 → 改名、換排列方式
// 用法: codenv-board [--socket tmux的socket路徑] [--client tmux的client名稱]
//   沒給 --socket 時用 $TMUX 指的那個 tmux(從 tmux 選單打開時就是目前這個)
// 編譯: swiftc -O -swift-version 5 codenv-board.swift -o ~/.codenv-board

import AppKit
import SwiftUI
import UniformTypeIdentifiers

// MARK: - tmux

struct Pane: Identifiable, Equatable {
    let id: String          // %3
    let index: Int
    let active: Bool
    let left, top, width, height: Int
    let command: String
    let name: String        // @codenv-pane-name(自己取的名字)
    let title: String       // 程式設定的標題(Claude Code 會寫目前在做的事)
}

struct Window: Identifiable, Equatable {
    let id: String          // @2
    let index: Int
    let name: String
    let active: Bool
    let bell: Bool
    let width, height: Int
    var panes: [Pane]
    var activePane: Pane? { panes.first(where: { $0.active }) ?? panes.first }
}

struct Session: Identifiable, Equatable {
    let id: String          // $0
    let name: String
    let attached: Bool
    var windows: [Window]
}

final class Tmux {
    let socket: String?
    let client: String?
    let path: String

    init(socket: String?, client: String?) {
        self.socket = socket
        self.client = client
        let candidates = ["/opt/homebrew/bin/tmux", "/usr/local/bin/tmux", "/usr/bin/tmux"]
        path = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) ?? "tmux"
    }

    @discardableResult
    func run(_ args: [String]) -> (ok: Bool, out: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: path == "tmux" ? "/usr/bin/env" : path)
        var full = path == "tmux" ? ["tmux"] : []
        if let socket { full += ["-S", socket] }
        task.arguments = full + args
        // 不讓 tmux 自己去讀 $TMUX,一律用上面指定的 socket
        var env = ProcessInfo.processInfo.environment
        if socket != nil { env.removeValue(forKey: "TMUX") }
        task.environment = env
        let out = Pipe(), err = Pipe()
        task.standardOutput = out
        task.standardError = err
        guard (try? task.run()) != nil else { return (false, "") }
        let data = out.fileHandleForReading.readDataToEndOfFile()
        _ = err.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        return (task.terminationStatus == 0, String(decoding: data, as: UTF8.self))
    }

    func load() -> [Session]? {
        let sep = "\u{1F}"
        let fields = ["session_id", "session_name", "session_attached",
                      "window_id", "window_index", "window_name", "window_active", "window_bell_flag",
                      "window_width", "window_height",
                      "pane_id", "pane_index", "pane_active", "pane_left", "pane_top", "pane_width", "pane_height",
                      "pane_current_command", "@codenv-pane-name", "pane_title"]
        let format = fields.map { "#{\($0)}" }.joined(separator: sep)
        let r = run(["list-panes", "-a", "-F", format])
        guard r.ok else { return nil }
        var sessions: [Session] = []
        for line in r.out.split(separator: "\n", omittingEmptySubsequences: true) {
            let f = line.components(separatedBy: sep)
            guard f.count == fields.count else { continue }
            let pane = Pane(id: f[10], index: Int(f[11]) ?? 0, active: f[12] == "1",
                            left: Int(f[13]) ?? 0, top: Int(f[14]) ?? 0, width: Int(f[15]) ?? 1, height: Int(f[16]) ?? 1,
                            command: f[17], name: f[18], title: f[19])
            if sessions.last?.id != f[0] {
                if let i = sessions.firstIndex(where: { $0.id == f[0] }) {
                    let s = sessions.remove(at: i); sessions.append(s)
                } else {
                    sessions.append(Session(id: f[0], name: f[1], attached: f[2] != "0", windows: []))
                }
            }
            var s = sessions.removeLast()
            if let wi = s.windows.firstIndex(where: { $0.id == f[3] }) {
                s.windows[wi].panes.append(pane)
            } else {
                s.windows.append(Window(id: f[3], index: Int(f[4]) ?? 0, name: f[5], active: f[6] == "1", bell: f[7] == "1",
                                        width: Int(f[8]) ?? 1, height: Int(f[9]) ?? 1, panes: [pane]))
            }
            sessions.append(s)
        }
        for i in sessions.indices {
            sessions[i].windows.sort { $0.index < $1.index }
            for j in sessions[i].windows.indices { sessions[i].windows[j].panes.sort { $0.index < $1.index } }
        }
        return sessions.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    // 名字裡的 # 會被 tmux 當成特殊寫法,改名時要寫成 ##
    func escaped(_ s: String) -> String { s.replacingOccurrences(of: "#", with: "##") }
    var clientArgs: [String] { client.map { ["-c", $0] } ?? [] }
}

// MARK: - 狀態

final class Board: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var message = ""
    @Published var offline = false
    let tmux: Tmux
    private var timer: Timer?
    private var dragStarted: Date?

    init(tmux: Tmux) {
        self.tmux = tmux
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in self?.refresh() }
    }

    func refresh(force: Bool = false) {
        // 拖曳中不更新畫面,不然拖到一半目標會不見
        if !force, let d = dragStarted, Date().timeIntervalSince(d) < 8 { return }
        dragStarted = nil
        guard let s = tmux.load() else { offline = true; sessions = []; return }
        offline = false
        if s != sessions { sessions = s }
    }

    func beginDrag() { dragStarted = Date() }

    private func act(_ args: [String], _ done: String) {
        let r = tmux.run(args)
        message = r.ok ? done : "沒有成功,可能那一格或那個分頁已經不在了"
        refresh(force: true)
    }

    func window(of pane: String) -> Window? {
        sessions.flatMap(\.windows).first(where: { $0.panes.contains(where: { $0.id == pane }) })
    }
    func session(of window: String) -> Session? {
        sessions.first(where: { $0.windows.contains(where: { $0.id == window }) })
    }

    // 格子搬到某個分頁(排在那個分頁目前選到的格子旁邊)
    func movePane(_ pane: String, to w: Window) {
        guard let from = window(of: pane) else { return }
        if from.id == w.id { message = "已經在這個分頁裡了"; return }
        guard let target = w.activePane else { return }
        act(["join-pane", "-d", "-h", "-s", pane, "-t", target.id], "已經把格子搬到「\(w.name)」")
    }

    // 格子搬到另一格旁邊:目標比較寬就左右放,比較高就上下放
    func movePane(_ pane: String, nextTo target: Pane) {
        if pane == target.id { return }
        let side = target.width >= target.height * 2 ? "-h" : "-v"
        act(["join-pane", "-d", side, "-s", pane, "-t", target.id], "已經把格子搬過去")
    }

    // 格子拆出來,變成某個工作階段裡的新分頁
    func breakPane(_ pane: String, into s: Session) {
        guard let from = window(of: pane) else { return }
        if from.panes.count == 1, session(of: from.id)?.id == s.id { message = "這個分頁只有這一格,不用拆"; return }
        act(["break-pane", "-d", "-s", pane, "-t", "\(s.id):"], "已經拆成新的分頁")
    }

    func swapWindows(_ a: String, _ b: Window) {
        if a == b.id { return }
        guard let sa = session(of: a), let sb = session(of: b.id) else { return }
        if sa.id == sb.id {
            act(["swap-window", "-d", "-s", a, "-t", b.id], "已經交換位置")
        } else {
            act(["move-window", "-d", "-s", a, "-t", "\(sb.id):"], "已經搬到工作階段 \(sb.name)")
        }
    }

    func moveWindow(_ a: String, to s: Session) {
        if session(of: a)?.id == s.id { return }
        act(["move-window", "-d", "-s", a, "-t", "\(s.id):"], "已經搬到工作階段 \(s.name)")
    }

    func renameWindow(_ w: Window, _ name: String) {
        let n = name.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { return }
        act(["rename-window", "-t", w.id, "--", tmux.escaped(n)], "已經改名")
    }

    func renamePane(_ p: Pane, _ name: String) {
        guard let w = window(of: p.id) else { return }
        let n = name.trimmingCharacters(in: .whitespaces)
        if n.isEmpty {
            tmux.run(["set", "-p", "-u", "-t", p.id, "@codenv-pane-name"])
            if !w.panes.contains(where: { $0.id != p.id && !$0.name.isEmpty }) {
                tmux.run(["set", "-w", "-u", "-t", w.id, "pane-border-status"])
            }
            message = "已經拿掉名字"
        } else {
            tmux.run(["set", "-p", "-t", p.id, "@codenv-pane-name", n])
            tmux.run(["set", "-w", "-t", w.id, "pane-border-status", "top"])
            message = "已經幫格子取名"
        }
        refresh(force: true)
    }

    func layout(_ w: Window, _ kind: String) {
        act(["select-layout", "-t", w.id, kind], "已經重新排列")
    }

    func renumber(_ s: Session) {
        act(["move-window", "-r", "-t", "\(s.id):"], "已經重新編號")
    }

    func newWindow(_ s: Session) {
        act(["new-window", "-d", "-t", "\(s.id):"], "已經開新分頁")
    }

    func focus(_ p: Pane) {
        guard let w = window(of: p.id), let s = session(of: w.id) else { return }
        tmux.run(["switch-client"] + tmux.clientArgs + ["-t", s.id])
        tmux.run(["select-window", "-t", w.id])
        tmux.run(["select-pane", "-t", p.id])
        message = "已經切換到「\(w.name)」"
        refresh(force: true)
    }
}

// MARK: - 畫面

let paneType = UTType.plainText

func label(_ p: Pane) -> String {
    if !p.name.isEmpty { return p.name }
    // tmux 預設把標題設成電腦名稱,那種不用顯示;Claude Code 這類程式會把標題寫成目前在做的事
    let host = ProcessInfo.processInfo.hostName.lowercased().replacingOccurrences(of: ".local", with: "")
    let t = p.title.trimmingCharacters(in: .whitespaces)
    let tl = t.lowercased().replacingOccurrences(of: ".local", with: "")
    if !t.isEmpty, tl != host, !host.hasPrefix(tl), !tl.hasPrefix(host), t != p.command { return "\(p.command) · \(t)" }
    return p.command
}

// 拖曳的內容用文字傳:pane:%3 或 window:@2
func dropString(_ providers: [NSItemProvider], _ handle: @escaping (String) -> Void) -> Bool {
    guard let item = providers.first else { return false }
    _ = item.loadObject(ofClass: NSString.self) { obj, _ in
        if let s = obj as? String { DispatchQueue.main.async { handle(s) } }
    }
    return true
}

struct Prompt: Identifiable {
    let id = UUID()
    let title: String
    var text: String
    let apply: (String) -> Void
}

struct BoardView: View {
    @ObservedObject var board: Board
    @State private var prompt: Prompt?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("tmux 排列").font(.title2.bold())
                Text("把格子拖到別的分頁就會合併,拖到「新分頁」會拆出來;分頁拖到分頁上會交換位置。點格子切換過去,雙擊名字或按右鍵可以改名。")
                    .font(.callout).foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 8)
            if !board.message.isEmpty {
                Text(board.message).font(.callout).foregroundStyle(.tint)
                    .padding(.horizontal, 16).padding(.bottom, 6)
            }
            Divider()
            if board.offline {
                VStack(spacing: 8) {
                    Text("找不到 tmux").font(.title3)
                    Text("請先輸入 codenv 或 tmux 開好畫面,再從 Ctrl+A 兩下的選單打開這個視窗。").foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        ForEach(board.sessions) { s in SessionView(board: board, session: s, prompt: $prompt) }
                    }.padding(16)
                }
            }
        }
        .frame(minWidth: 620, minHeight: 380)
        .sheet(item: $prompt) { p in PromptView(prompt: p) { prompt = nil } }
        .onChange(of: prompt?.id) { _ in
            // 跳出改名框時把自己叫到最前面,打的字才會進到這裡
            if prompt != nil { NSApp.activate(ignoringOtherApps: true); NSApp.keyWindow?.makeKeyAndOrderFront(nil) }
        }
    }
}

struct PromptView: View {
    @State var prompt: Prompt
    let close: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(prompt.title).font(.headline)
            TextField("名字", text: $prompt.text).frame(width: 300).onSubmit { prompt.apply(prompt.text); close() }
            HStack {
                Spacer()
                Button("取消", role: .cancel) { close() }.keyboardShortcut(.cancelAction)
                Button("確定") { prompt.apply(prompt.text); close() }.keyboardShortcut(.defaultAction)
            }
        }.padding(20)
    }
}

struct SessionView: View {
    @ObservedObject var board: Board
    let session: Session
    @Binding var prompt: Prompt?
    @State private var targeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("工作階段 \(session.name)").font(.headline)
                if session.attached { Text("正在看").font(.caption).padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Capsule().fill(Color.accentColor.opacity(0.18))) }
                Text("\(session.windows.count) 個分頁").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("重新編號") { board.renumber(session) }.controlSize(.small)
                Button("開新分頁") { board.newWindow(session) }.controlSize(.small)
            }
            .padding(6)
            .background(RoundedRectangle(cornerRadius: 6).fill(targeted ? Color.accentColor.opacity(0.15) : .clear))
            .onDrop(of: [paneType], isTargeted: $targeted) { providers in
                dropString(providers) { s in
                    if s.hasPrefix("window:") { board.moveWindow(String(s.dropFirst(7)), to: session) }
                    if s.hasPrefix("pane:") { board.breakPane(String(s.dropFirst(5)), into: session) }
                }
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 230, maximum: 320), spacing: 12)], alignment: .leading, spacing: 12) {
                ForEach(session.windows) { w in WindowCard(board: board, window: w, prompt: $prompt) }
                NewWindowDrop(board: board, session: session)
            }
        }
    }
}

struct NewWindowDrop: View {
    @ObservedObject var board: Board
    let session: Session
    @State private var targeted = false
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            .foregroundStyle(targeted ? Color.accentColor : Color.secondary.opacity(0.5))
            .background(RoundedRectangle(cornerRadius: 10).fill(targeted ? Color.accentColor.opacity(0.1) : .clear))
            .overlay(Text("新分頁\n把格子拖到這裡,拆成新的分頁").multilineTextAlignment(.center)
                .font(.callout).foregroundStyle(.secondary))
            .frame(height: 176)
            .onDrop(of: [paneType], isTargeted: $targeted) { providers in
                dropString(providers) { s in
                    if s.hasPrefix("pane:") { board.breakPane(String(s.dropFirst(5)), into: session) }
                    if s.hasPrefix("window:") { board.moveWindow(String(s.dropFirst(7)), to: session) }
                }
            }
    }
}

struct WindowCard: View {
    @ObservedObject var board: Board
    let window: Window
    @Binding var prompt: Prompt?
    @State private var targeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "line.3.horizontal").foregroundStyle(.secondary).help("按住這裡拖曳整個分頁")
                Text("[\(window.index)] \(window.name)").font(.system(.body, design: .monospaced).bold()).lineLimit(1)
                if window.bell { Circle().fill(Color.orange).frame(width: 7, height: 7).help("這個分頁有新的動靜(例如 Claude 回覆完了)") }
                Spacer()
                Text("\(window.panes.count) 格").font(.caption).foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) { renameWindow() }
            .onDrag { board.beginDrag(); return NSItemProvider(object: "window:\(window.id)" as NSString) }
            Preview(board: board, window: window, prompt: $prompt)
                .frame(height: 140)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 10)
            .strokeBorder(targeted ? Color.accentColor : (window.active ? Color.accentColor.opacity(0.5) : Color.secondary.opacity(0.25)),
                          lineWidth: targeted ? 2.5 : 1))
        .onDrop(of: [paneType], isTargeted: $targeted) { providers in
            dropString(providers) { s in
                if s.hasPrefix("pane:") { board.movePane(String(s.dropFirst(5)), to: window) }
                if s.hasPrefix("window:") { board.swapWindows(String(s.dropFirst(7)), window) }
            }
        }
        .contextMenu {
            Button("切換到這個分頁") { if let p = window.activePane { board.focus(p) } }
            Button("改分頁名字…") { renameWindow() }
            Divider()
            Button("排成左右並排") { board.layout(window, "even-horizontal") }
            Button("排成上下堆疊") { board.layout(window, "even-vertical") }
            Button("左邊一大格,右邊幾小格") { board.layout(window, "main-vertical") }
            Button("排成方格") { board.layout(window, "tiled") }
        }
    }

    func renameWindow() {
        prompt = Prompt(title: "分頁 [\(window.index)] 的新名字", text: window.name) { board.renameWindow(window, $0) }
    }
}

struct Preview: View {
    @ObservedObject var board: Board
    let window: Window
    @Binding var prompt: Prompt?

    var body: some View {
        GeometryReader { geo in
            // 終端機的一格大約是寬 1、高 2,照這個比例縮小
            let ww = CGFloat(max(window.width, 1)), wh = CGFloat(max(window.height, 1)) * 2
            let scale = min(geo.size.width / ww, geo.size.height / wh)
            let ox = (geo.size.width - ww * scale) / 2, oy = (geo.size.height - wh * scale) / 2
            ZStack(alignment: .topLeading) {
                ForEach(window.panes) { p in
                    PaneBox(board: board, pane: p, prompt: $prompt)
                        .frame(width: max(CGFloat(p.width) * scale - 3, 8), height: max(CGFloat(p.height) * 2 * scale - 3, 8))
                        .offset(x: ox + CGFloat(p.left) * scale, y: oy + CGFloat(p.top) * 2 * scale)
                }
            }
        }
    }
}

struct PaneBox: View {
    @ObservedObject var board: Board
    let pane: Pane
    @Binding var prompt: Prompt?
    @State private var targeted = false

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(targeted ? Color.accentColor.opacity(0.35) : (pane.active ? Color.accentColor.opacity(0.22) : Color.secondary.opacity(0.14)))
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(pane.active ? Color.accentColor : Color.secondary.opacity(0.35), lineWidth: 1))
            .overlay(
                Text(label(pane)).font(.caption).lineLimit(2).multilineTextAlignment(.center)
                    .padding(3).foregroundStyle(.primary)
            )
            .contentShape(Rectangle())
            .help("\(label(pane))(\(pane.width)×\(pane.height))\n拖到別的分頁就會搬過去;點一下切換到這格")
            .onTapGesture(count: 2) { renamePane() }
            .onTapGesture { board.focus(pane) }
            .onDrag { board.beginDrag(); return NSItemProvider(object: "pane:\(pane.id)" as NSString) }
            .onDrop(of: [paneType], isTargeted: $targeted) { providers in
                dropString(providers) { s in
                    if s.hasPrefix("pane:") { board.movePane(String(s.dropFirst(5)), nextTo: pane) }
                    if s.hasPrefix("window:"), let w = board.window(of: pane.id) { board.swapWindows(String(s.dropFirst(7)), w) }
                }
            }
            .contextMenu {
                Button("切換到這格") { board.focus(pane) }
                Button("幫這格取名…") { renamePane() }
                if !pane.name.isEmpty { Button("拿掉這格的名字") { board.renamePane(pane, "") } }
                if let w = board.window(of: pane.id), w.panes.count > 1, let s = board.session(of: w.id) {
                    Button("拆出去,變成新的分頁") { board.breakPane(pane.id, into: s) }
                }
            }
    }

    func renamePane() {
        prompt = Prompt(title: "這格的名字(留空就是拿掉名字)", text: pane.name) { board.renamePane(pane, $0) }
    }
}

// MARK: - 啟動

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var board: Board!

    func applicationDidFinishLaunching(_ note: Notification) {
        let args = CommandLine.arguments
        func value(_ flag: String) -> String? {
            guard let i = args.firstIndex(of: flag), i + 1 < args.count else { return nil }
            return args[i + 1]
        }
        var socket = value("--socket")
        if socket == nil, let t = ProcessInfo.processInfo.environment["TMUX"], let first = t.split(separator: ",").first {
            socket = String(first)
        }
        board = Board(tmux: Tmux(socket: socket, client: value("--client")))
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 900, height: 620),
                          styleMask: [.titled, .closable, .resizable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "tmux 排列"
        window.contentView = NSHostingView(rootView: BoardView(board: board))
        window.isReleasedWhenClosed = false
        window.level = .floating            // 浮在 iTerm 上面,拖曳時不會被蓋住
        window.center()
        window.setFrameAutosaveName("codenv-board")
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        if let path = value("--print-window-id") {
            try? String(window.windowNumber).write(toFile: path, atomically: true, encoding: .utf8)
        }
        // 已經開著的話,再打開一次就把舊的叫到最前面(新的自己結束)
        DistributedNotificationCenter.default().addObserver(forName: Notification.Name("codenv-board.show"), object: socket, queue: .main) { [weak self] _ in
            self?.window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            self?.board.refresh(force: true)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool { true }
}

// 同一個 tmux 只開一個視窗:已經有的話請它出來,自己結束
let lockSocket: String? = {
    let args = CommandLine.arguments
    if let i = args.firstIndex(of: "--socket"), i + 1 < args.count { return args[i + 1] }
    return ProcessInfo.processInfo.environment["TMUX"]?.split(separator: ",").first.map(String.init)
}()
// Swift 的 hashValue 每次執行都不一樣,自己算一個固定的
let lockKey = (lockSocket ?? "default").utf8.reduce(UInt32(5381)) { ($0 &* 33) &+ UInt32($1) }
let lockPath = NSTemporaryDirectory() + "codenv-board-" + String(lockKey, radix: 16) + ".pid"
if let old = try? String(contentsOfFile: lockPath, encoding: .utf8), let pid = Int32(old.trimmingCharacters(in: .whitespacesAndNewlines)),
   pid != getpid(), kill(pid, 0) == 0 {
    DistributedNotificationCenter.default().postNotificationName(Notification.Name("codenv-board.show"), object: lockSocket, userInfo: nil, deliverImmediately: true)
    exit(0)
}
try? String(getpid()).write(toFile: lockPath, atomically: true, encoding: .utf8)

let app = NSApplication.shared
// 一般 App:開著時 Dock 有圖示,點視窗一定拿得到鍵盤(改名時打的字才不會跑到 iTerm)
app.setActivationPolicy(.regular)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
