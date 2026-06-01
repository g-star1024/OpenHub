import AppKit

let width: CGFloat = 1600
let height: CGFloat = 1050
let scale: CGFloat = 2

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: r / 255, green: g / 255, blue: b / 255, alpha: a)
}

let bg = color(246, 247, 249)
let panel = color(255, 255, 255)
let border = color(224, 226, 230)
let text = color(31, 35, 40)
let subtext = color(101, 109, 118)
let blue = color(9, 105, 218)
let softBlue = color(230, 241, 255)
let green = color(31, 136, 61)
let orange = color(191, 105, 0)
let purple = color(130, 80, 223)

let image = NSImage(size: NSSize(width: width, height: height))
image.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .high
bg.setFill()
NSRect(x: 0, y: 0, width: width, height: height).fill()

func rounded(_ rect: NSRect, radius: CGFloat, fill: NSColor, stroke: NSColor? = nil, lineWidth: CGFloat = 1) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    fill.setFill()
    path.fill()
    if let stroke {
        stroke.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
}

func line(_ from: CGPoint, _ to: CGPoint, _ stroke: NSColor = border, _ lineWidth: CGFloat = 1) {
    let path = NSBezierPath()
    path.move(to: from)
    path.line(to: to)
    stroke.setStroke()
    path.lineWidth = lineWidth
    path.stroke()
}

func textDraw(_ string: String, _ rect: NSRect, size: CGFloat, weight: NSFont.Weight = .regular, color: NSColor = text, align: NSTextAlignment = .left) {
    let style = NSMutableParagraphStyle()
    style.alignment = align
    style.lineBreakMode = .byTruncatingTail
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: style
    ]
    (string as NSString).draw(in: rect, withAttributes: attrs)
}

func pill(_ string: String, _ rect: NSRect, fill: NSColor, color: NSColor = text) {
    rounded(rect, radius: rect.height / 2, fill: fill)
    textDraw(string, rect.insetBy(dx: 12, dy: 5), size: 15, weight: .semibold, color: color, align: .center)
}

func symbolButton(_ title: String, symbol: String, rect: NSRect, primary: Bool = false) {
    rounded(rect, radius: 9, fill: primary ? blue : panel, stroke: primary ? blue : border)
    let iconColor = primary ? NSColor.white : text
    if let icon = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) {
        icon.isTemplate = true
        icon.draw(in: NSRect(x: rect.minX + 14, y: rect.minY + 8, width: 19, height: 19), from: .zero, operation: .sourceOver, fraction: 1)
    }
    textDraw(title, NSRect(x: rect.minX + 40, y: rect.minY + 7, width: rect.width - 52, height: 22), size: 16, weight: .semibold, color: iconColor)
}

func smallSymbol(_ symbol: String, _ rect: NSRect, color: NSColor) {
    if let icon = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) {
        icon.isTemplate = true
        color.set()
        icon.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
    }
}

let window = NSRect(x: 40, y: 40, width: width - 80, height: height - 80)
rounded(window, radius: 22, fill: panel, stroke: color(207, 211, 216))

let sidebarW: CGFloat = 330
let toolbarH: CGFloat = 74
let bottomH: CGFloat = 250
let content = NSRect(x: window.minX + sidebarW, y: window.minY, width: window.width - sidebarW, height: window.height)

// Sidebar
rounded(NSRect(x: window.minX, y: window.minY, width: sidebarW, height: window.height), radius: 22, fill: color(252, 253, 255))
line(CGPoint(x: window.minX + sidebarW, y: window.minY), CGPoint(x: window.minX + sidebarW, y: window.maxY))
textDraw("代码工作区", NSRect(x: window.minX + 26, y: window.maxY - 76, width: 220, height: 32), size: 24, weight: .bold)
textDraw("/Users/huluobo/Documents/OpenHub", NSRect(x: window.minX + 26, y: window.maxY - 105, width: 250, height: 24), size: 14, color: subtext)
symbolButton("路径", symbol: "folder", rect: NSRect(x: window.minX + 174, y: window.maxY - 92, width: 70, height: 34))
symbolButton("刷新", symbol: "arrow.clockwise", rect: NSRect(x: window.minX + 252, y: window.maxY - 92, width: 70, height: 34))
rounded(NSRect(x: window.minX + 24, y: window.maxY - 142, width: sidebarW - 48, height: 36), radius: 8, fill: panel, stroke: border)
textDraw("g-star1024/OpenHub", NSRect(x: window.minX + 38, y: window.maxY - 134, width: 240, height: 20), size: 16)
rounded(NSRect(x: window.minX + 24, y: window.maxY - 188, width: sidebarW - 48, height: 36), radius: 8, fill: panel, stroke: border)
textDraw("搜索文件", NSRect(x: window.minX + 38, y: window.maxY - 180, width: 230, height: 20), size: 16, color: color(170, 176, 184))

let files = ["Package.swift", "README.md", "Sources/GitHubAppHub/main.swift", "docs/product-development-doc.md", "backend/cloudflare/src/worker.js", "windows/openhub-tauri/web/app.js", "scripts/package_app.sh"]
for (idx, file) in files.enumerated() {
    let y = window.maxY - 240 - CGFloat(idx) * 38
    if idx == 0 {
        rounded(NSRect(x: window.minX + 24, y: y - 4, width: sidebarW - 48, height: 32), radius: 7, fill: color(229, 231, 235))
    }
    textDraw(file, NSRect(x: window.minX + 38, y: y + 3, width: sidebarW - 70, height: 18), size: 14, weight: idx == 0 ? .semibold : .regular)
}
symbolButton("删除本地", symbol: "trash", rect: NSRect(x: window.minX + 24, y: window.minY + 24, width: 118, height: 36))
symbolButton("Finder", symbol: "folder", rect: NSRect(x: window.minX + 154, y: window.minY + 24, width: 102, height: 36))

// Top editor header
rounded(NSRect(x: content.minX, y: window.maxY - toolbarH, width: content.width, height: toolbarH), radius: 0, fill: color(248, 249, 251))
line(CGPoint(x: content.minX, y: window.maxY - toolbarH), CGPoint(x: content.maxX, y: window.maxY - toolbarH))
textDraw("Package.swift", NSRect(x: content.minX + 28, y: window.maxY - 48, width: 190, height: 28), size: 22, weight: .bold)
pill("main", NSRect(x: content.minX + 205, y: window.maxY - 52, width: 70, height: 32), fill: softBlue)
pill("有 2 个本地提交未推送", NSRect(x: content.minX + 290, y: window.maxY - 50, width: 178, height: 28), fill: color(255, 247, 237), color: orange)
symbolButton("刷新状态", symbol: "arrow.clockwise", rect: NSRect(x: content.maxX - 446, y: window.maxY - 54, width: 112, height: 36))
symbolButton("保存文件", symbol: "square.and.arrow.down", rect: NSRect(x: content.maxX - 322, y: window.maxY - 54, width: 112, height: 36))
symbolButton("同步到 GitHub", symbol: "arrow.up.circle", rect: NSRect(x: content.maxX - 196, y: window.maxY - 54, width: 168, height: 36), primary: true)

// Editor
let editor = NSRect(x: content.minX, y: window.minY + bottomH, width: content.width, height: window.height - toolbarH - bottomH)
rounded(editor, radius: 0, fill: color(255, 255, 255))
line(CGPoint(x: content.minX, y: editor.minY), CGPoint(x: content.maxX, y: editor.minY))
let codeX = editor.minX + 38
let codeTop = editor.maxY - 50
let codeLines = [
    ("// swift-tools-version: 6.0", color(139, 148, 158)),
    ("import PackageDescription", text),
    ("", text),
    ("let package = Package(", blue),
    ("    name: \"OpenHub\",", text),
    ("    platforms: [", text),
    ("        .macOS(.v14)", text),
    ("    ],", text),
    ("    products: [", text),
    ("        .executable(name: \"OpenHub\", targets: [\"GitHubAppHub\"])", text),
    ("    ],", text),
    (")", text)
]
for (idx, lineItem) in codeLines.enumerated() {
    let y = codeTop - CGFloat(idx) * 33
    textDraw(lineItem.0, NSRect(x: codeX, y: y, width: editor.width - 80, height: 26), size: 22, weight: idx == 3 ? .semibold : .regular, color: lineItem.1)
}

// Bottom Git workspace
let bottom = NSRect(x: content.minX, y: window.minY, width: content.width, height: bottomH)
rounded(bottom, radius: 0, fill: color(250, 251, 252))
line(CGPoint(x: content.minX, y: bottom.maxY), CGPoint(x: content.maxX, y: bottom.maxY))
textDraw("Git 工作区", NSRect(x: bottom.minX + 28, y: bottom.maxY - 48, width: 160, height: 28), size: 20, weight: .bold)
pill("main ahead 2", NSRect(x: bottom.minX + 142, y: bottom.maxY - 49, width: 110, height: 28), fill: softBlue)
textDraw("上次同步：刚刚失败，远端未更新", NSRect(x: bottom.minX + 270, y: bottom.maxY - 44, width: 280, height: 20), size: 14, color: subtext)
smallSymbol("checkmark.circle.fill", NSRect(x: bottom.maxX - 336, y: bottom.maxY - 43, width: 18, height: 18), color: green)
textDraw("文件已保存", NSRect(x: bottom.maxX - 312, y: bottom.maxY - 44, width: 86, height: 20), size: 14, color: green)
smallSymbol("exclamationmark.triangle.fill", NSRect(x: bottom.maxX - 215, y: bottom.maxY - 43, width: 18, height: 18), color: orange)
textDraw("有本地提交未推送", NSRect(x: bottom.maxX - 190, y: bottom.maxY - 44, width: 142, height: 20), size: 14, color: orange)

let changes = NSRect(x: bottom.minX + 24, y: bottom.minY + 24, width: 430, height: 160)
rounded(changes, radius: 12, fill: panel, stroke: border)
smallSymbol("circle.fill", NSRect(x: changes.minX + 18, y: changes.maxY - 35, width: 10, height: 10), color: blue)
textDraw("变更", NSRect(x: changes.minX + 38, y: changes.maxY - 42, width: 100, height: 24), size: 17, weight: .bold)
textDraw("4 个文件已修改", NSRect(x: changes.maxX - 132, y: changes.maxY - 39, width: 105, height: 18), size: 13, color: subtext, align: .right)
let changedFiles = ["M  README.md", "M  Sources/GitHubAppHub/main.swift", "M  docs/product-development-doc.md", "A  docs/code-module-redesign.png"]
for (idx, file) in changedFiles.enumerated() {
    textDraw(file, NSRect(x: changes.minX + 22, y: changes.maxY - 76 - CGFloat(idx) * 24, width: changes.width - 44, height: 18), size: 13, color: subtext)
}

let diff = NSRect(x: bottom.minX + 474, y: bottom.minY + 24, width: 390, height: 160)
rounded(diff, radius: 12, fill: panel, stroke: border)
smallSymbol("circle.fill", NSRect(x: diff.minX + 18, y: diff.maxY - 35, width: 10, height: 10), color: purple)
textDraw("Diff 预览", NSRect(x: diff.minX + 38, y: diff.maxY - 42, width: 150, height: 24), size: 17, weight: .bold)
textDraw("+ OAuth App 登录文案\n+ scope=read:user public_repo\n- GitHub App 权限提示", NSRect(x: diff.minX + 22, y: diff.maxY - 84, width: diff.width - 44, height: 76), size: 14, color: subtext)

let commit = NSRect(x: bottom.minX + 884, y: bottom.minY + 24, width: bottom.width - 908, height: 160)
rounded(commit, radius: 12, fill: panel, stroke: border)
textDraw("提交与同步", NSRect(x: commit.minX + 20, y: commit.maxY - 42, width: 140, height: 24), size: 17, weight: .bold)
rounded(NSRect(x: commit.minX + 20, y: commit.maxY - 84, width: commit.width - 40, height: 36), radius: 8, fill: panel, stroke: border)
textDraw("Update from OpenHub", NSRect(x: commit.minX + 34, y: commit.maxY - 77, width: commit.width - 66, height: 20), size: 15)
symbolButton("提交并同步", symbol: "arrow.up.circle", rect: NSRect(x: commit.minX + 20, y: commit.maxY - 130, width: commit.width - 40, height: 40), primary: true)
textDraw("流程：保存文件 → git add → commit → push", NSRect(x: commit.minX + 22, y: commit.minY + 16, width: commit.width - 44, height: 20), size: 13, color: subtext, align: .center)

image.unlockFocus()

guard let data = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: data),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Failed to render mockup")
}

let output = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "docs/code-module-redesign.png")
try png.write(to: output)
