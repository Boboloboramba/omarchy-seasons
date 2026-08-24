import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

Item {
  id: root

  property var shell: null
  property bool opened: false
  property real screenW: 1920
  property real screenH: 1080
  property int overrideMonth: -1
  property var seasonNames: ["winter", "spring", "summer", "autumn"]
  property var seasonMonths: [1, 4, 7, 10]
  property bool themeActive: false
  property string currentThemeName: ""

  function open(payloadJson) { root.opened = true }
  function close() { root.opened = false }
  function ping() { return "ok" }
  function state() { return root.opened ? "open" : "closed" }

  function cycleSeason() {
    var idx = seasonNames.indexOf(season)
    var nextIdx = (idx + 1) % 4
    overrideMonth = seasonMonths[nextIdx]
  }

  function resetSeason() {
    overrideMonth = -1
  }

  function setSeason(name) {
    var idx = seasonNames.indexOf(name)
    if (idx >= 0) overrideMonth = seasonMonths[idx]
  }

  function updateTheme(name) {
    var trimmed = name.trim()
    if (trimmed === currentThemeName) return
    currentThemeName = trimmed
    var wasActive = themeActive
    themeActive = (trimmed === "seasons")
    if (wasActive && !themeActive) {
      particleModel.clear()
    }
  }

  Process {
    id: themeCheckProc
    command: ["cat", Quickshell.env("HOME") + "/.local/state/omarchy/current/theme.name"]
    running: false
    stdout: SplitParser {
      onRead: data => root.updateTheme(data)
    }
  }

  Timer {
    id: themePollTimer
    interval: 2000
    repeat: true
    running: true
    onTriggered: {
      if (!themeCheckProc.running) themeCheckProc.running = true
    }
  }

  Component.onCompleted: {
    themeCheckProc.running = true
  }

  // Current month (1-12)
  property int currentMonth: overrideMonth > 0 ? overrideMonth : new Date().getMonth() + 1

  // Season detection
  property string season: {
    switch (currentMonth) {
      case 12: case 1: case 2: return "winter"
      case 3: case 4: case 5: return "spring"
      case 6: case 7: case 8: return "summer"
      case 9: case 10: case 11: return "autumn"
    }
  }

  // Season-specific color palettes
  property var snowColors: ["#ffffff", "#e8f0ff", "#d4e8ff", "#c0d8ff", "#f0f8ff"]
  property var rainColors: ["#7eb8da", "#6ba8cc", "#94ccf0", "#5a9abc", "#a0d4f0"]
  property var leafColors: ["#d19a66", "#e06c75", "#e5c07b", "#c678dd", "#8b6f5a", "#aed48a"]
  property var dandelionColors: ["#ffffff", "#f0f8ff", "#e8f0ff", "#ffd700", "#ffec8b"]

  // Particle model
  ListModel { id: particleModel }

  // Spawn a new particle based on current season
  function spawnParticle() {
    if (particleModel.count > 180) return

    var w = root.screenW
    var h = root.screenH

    if (season === "winter") {
      // Snowflakes
      var colors = snowColors
      particleModel.append({
        px: Math.random() * w,
        py: -10,
        vx: (Math.random() - 0.5) * 20,
        vy: 20 + Math.random() * 40,
        gravity: 2 + Math.random() * 3,
        drag: 0.998,
        life: (h + 20) / 35,
        age: 0,
        size: 6 + Math.random() * 10,
        rotation: Math.random() * 360,
        rotationSpeed: (Math.random() - 0.5) * 60,
        color: colors[Math.floor(Math.random() * colors.length)],
        opacity: 0.75 + Math.random() * 0.25,
        type: "snow",
        wobbleOffset: Math.random() * Math.PI * 2,
        wobbleSpeed: 1 + Math.random() * 2,
        wobbleAmp: 15 + Math.random() * 25
      })
    } else if (season === "spring") {
      // Raindrops
      var colors = rainColors
      particleModel.append({
        px: Math.random() * w * 1.2 - w * 0.1,
        py: -20,
        vx: -15 + Math.random() * 10,
        vy: 350 + Math.random() * 200,
        gravity: 40,
        drag: 0.999,
        life: (h + 40) / 450,
        age: 0,
        size: 2 + Math.random() * 2,
        rotation: 0,
        rotationSpeed: 0,
        color: colors[Math.floor(Math.random() * colors.length)],
        opacity: 0.6 + Math.random() * 0.3,
        type: "rain",
        length: 18 + Math.random() * 20,
        wobbleOffset: 0,
        wobbleSpeed: 0,
        wobbleAmp: 0
      })
    } else if (season === "summer") {
      // Dandelion seeds floating upward
      var colors = dandelionColors
      particleModel.append({
        px: Math.random() * w,
        py: h + 10,
        vx: (Math.random() - 0.5) * 30,
        vy: -15 - Math.random() * 30,
        gravity: -1,
        drag: 0.997,
        life: (h + 20) / 25,
        age: 0,
        size: 4 + Math.random() * 5,
        rotation: Math.random() * 360,
        rotationSpeed: (Math.random() - 0.5) * 40,
        color: colors[Math.floor(Math.random() * colors.length)],
        opacity: 0.7 + Math.random() * 0.3,
        type: "dandelion",
        wobbleOffset: Math.random() * Math.PI * 2,
        wobbleSpeed: 0.8 + Math.random() * 1.5,
        wobbleAmp: 20 + Math.random() * 35,
        stemLength: 14 + Math.random() * 16
      })
    } else if (season === "autumn") {
      // Falling leaves
      var colors = leafColors
      particleModel.append({
        px: Math.random() * w * 1.3 - w * 0.15,
        py: -15,
        vx: 20 + Math.random() * 40,
        vy: 30 + Math.random() * 50,
        gravity: 15 + Math.random() * 20,
        drag: 0.996,
        life: (h + 30) / 60,
        age: 0,
        size: 10 + Math.random() * 12,
        rotation: Math.random() * 360,
        rotationSpeed: 40 + Math.random() * 80,
        color: colors[Math.floor(Math.random() * colors.length)],
        opacity: 0.8 + Math.random() * 0.2,
        type: "leaf",
        wobbleOffset: Math.random() * Math.PI * 2,
        wobbleSpeed: 1.5 + Math.random() * 2,
        wobbleAmp: 30 + Math.random() * 40
      })
    }
  }

  // Update all particles each frame
  function stepParticles(dt) {
    var t = Math.min(dt, 0.05)
    for (var i = particleModel.count - 1; i >= 0; i--) {
      var it = particleModel.get(i)
      it.age += t
      if (it.age >= it.life) {
        particleModel.remove(i)
        continue
      }

      // Apply drag
      it.vx *= Math.pow(it.drag, t * 60)
      it.vy = it.vy * Math.pow(it.drag, t * 60) + it.gravity * t

      // Apply wobble for snow, leaves, dandelion
      if (it.wobbleAmp > 0) {
        var wobble = Math.sin(it.age * it.wobbleSpeed + it.wobbleOffset) * it.wobbleAmp * t
        it.px += it.vx * t + wobble
      } else {
        it.px += it.vx * t
      }
      it.py += it.vy * t

      // Rotate
      it.rotation += it.rotationSpeed * t

      particleModel.set(i, {
        px: it.px, py: it.py, vx: it.vx, vy: it.vy,
        gravity: it.gravity, drag: it.drag, life: it.life,
        age: it.age, size: it.size, rotation: it.rotation,
        rotationSpeed: it.rotationSpeed, color: it.color,
        opacity: it.opacity, type: it.type,
        wobbleOffset: it.wobbleOffset, wobbleSpeed: it.wobbleSpeed,
        wobbleAmp: it.wobbleAmp,
        length: it.length || 0, stemLength: it.stemLength || 0
      })
    }
  }

  // Spawn timer - controls particle density
  Timer {
    id: spawnTimer
    interval: {
      switch (root.season) {
        case "winter": return 400
        case "spring": return 80
        case "summer": return 600
        case "autumn": return 500
      }
    }
    repeat: true
    running: root.themeActive
    onTriggered: root.spawnParticle()
  }

  // Physics update timer (~60fps)
  Timer {
    id: tickTimer
    interval: 16
    repeat: true
    running: root.themeActive
    property real lastTime: Date.now()
    onTriggered: {
      var now = Date.now()
      var dt = (now - lastTime) / 1000
      lastTime = now
      root.stepParticles(dt)
    }
  }

  IpcHandler {
    target: "seasons"

    function cycle(): string {
      root.cycleSeason()
      return "season: " + root.season
    }

    function set(name: string): string {
      root.setSeason(name)
      return "season: " + root.season
    }

    function reset(): string {
      root.resetSeason()
      return "season: " + root.season
    }

    function current(): string {
      return root.season + " (month " + root.currentMonth + ")"
    }

    function status(): string {
      return "theme=" + root.currentThemeName + " active=" + root.themeActive + " particles=" + particleModel.count
    }

    function ping(): string {
      return "ok"
    }
  }

  // Particle delegate component
  Component {
    id: particleDelegate

    Item {
      id: particleRoot
      property real px: model.px
      property real py: model.py
      property real size: model.size
      property real rot: model.rotation
      property string color: model.color
      property real particleOpacity: model.opacity
      property string type: model.type
      property real length: model.length || 0
      property real stemLength: model.stemLength || 0

      x: px - size / 2
      y: py - size / 2
      width: size
      height: type === "rain" ? length : (type === "dandelion" ? size + stemLength : size)
      rotation: rot
      opacity: {
        var fadeIn = Math.min(1, model.age * 3)
        var fadeOut = Math.max(0, 1 - (model.age / model.life) * 0.4)
        return particleOpacity * fadeIn * fadeOut
      }

      layer.enabled: true
      layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#60000000"
        shadowBlur: 0.6
        shadowVerticalOffset: 3
        shadowHorizontalOffset: 1
      }

      // Snowflake - 6-armed crystalline shape
      Canvas {
        visible: type === "snow"
        anchors.centerIn: parent
        width: particleRoot.size * 1.8
        height: particleRoot.size * 1.8
        onPaint: {
          var ctx = getContext("2d")
          ctx.clearRect(0, 0, width, height)
          ctx.save()
          ctx.translate(width / 2, height / 2)
          ctx.strokeStyle = particleRoot.color
          ctx.fillStyle = particleRoot.color
          ctx.lineWidth = Math.max(1, particleRoot.size * 0.08)
          ctx.lineCap = "round"
          var armLen = particleRoot.size * 0.7
          // Draw 6 arms
          for (var i = 0; i < 6; i++) {
            ctx.save()
            ctx.rotate(i * Math.PI / 3)
            // Main arm
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(0, -armLen)
            ctx.stroke()
            // Side branches
            var bLen = armLen * 0.35
            var bPos = armLen * 0.55
            ctx.beginPath()
            ctx.moveTo(0, -bPos)
            ctx.lineTo(-bLen * 0.5, -bPos - bLen * 0.5)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(0, -bPos)
            ctx.lineTo(bLen * 0.5, -bPos - bLen * 0.5)
            ctx.stroke()
            // Tip branch
            var tLen = armLen * 0.22
            ctx.beginPath()
            ctx.moveTo(0, -armLen * 0.8)
            ctx.lineTo(-tLen, -armLen)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(0, -armLen * 0.8)
            ctx.lineTo(tLen, -armLen)
            ctx.stroke()
            ctx.restore()
          }
          // Center dot
          ctx.beginPath()
          ctx.arc(0, 0, particleRoot.size * 0.06, 0, Math.PI * 2)
          ctx.fill()
          ctx.restore()
        }
        Component.onCompleted: requestPaint()
        Connections {
          target: particleRoot
          function onRotChanged() { particleRoot.children[0].requestPaint() }
        }
      }

      // Raindrop - teardrop shape
      Canvas {
        visible: type === "rain"
        anchors.centerIn: parent
        width: particleRoot.size * 3
        height: particleRoot.length
        onPaint: {
          var ctx = getContext("2d")
          ctx.clearRect(0, 0, width, height)
          var cx = width / 2
          var dropH = height * 0.7
          var dropW = particleRoot.size * 1.2
          var tailH = height * 0.3
          ctx.fillStyle = particleRoot.color
          ctx.globalAlpha = 0.75
          ctx.beginPath()
          ctx.moveTo(cx, 0)
          ctx.bezierCurveTo(cx - dropW, dropH * 0.4, cx - dropW, dropH, cx, dropH + tailH)
          ctx.bezierCurveTo(cx + dropW, dropH, cx + dropW, dropH * 0.4, cx, 0)
          ctx.fill()
          // Highlight
          ctx.fillStyle = "#ffffff"
          ctx.globalAlpha = 0.3
          ctx.beginPath()
          ctx.ellipse(cx - dropW * 0.3, dropH * 0.45, dropW * 0.2, dropH * 0.15, 0, 0, Math.PI * 2)
          ctx.fill()
        }
        Component.onCompleted: requestPaint()
      }

      // Leaf - organic shape with veins
      Canvas {
        visible: type === "leaf"
        anchors.centerIn: parent
        width: particleRoot.size * 1.8
        height: particleRoot.size * 1.4
        onPaint: {
          var ctx = getContext("2d")
          ctx.clearRect(0, 0, width, height)
          var cx = width / 2
          var cy = height / 2
          var leafW = particleRoot.size * 0.7
          var leafH = particleRoot.size * 0.55
          // Leaf body
          ctx.fillStyle = particleRoot.color
          ctx.globalAlpha = 0.9
          ctx.beginPath()
          ctx.moveTo(cx - leafW, cy)
          ctx.bezierCurveTo(cx - leafW * 0.8, cy - leafH, cx + leafW * 0.3, cy - leafH, cx + leafW, cy)
          ctx.bezierCurveTo(cx + leafW * 0.3, cy + leafH, cx - leafW * 0.8, cy + leafH, cx - leafW, cy)
          ctx.fill()
          // Center vein
          ctx.strokeStyle = "#000000"
          ctx.globalAlpha = 0.15
          ctx.lineWidth = 1
          ctx.beginPath()
          ctx.moveTo(cx - leafW * 0.9, cy)
          ctx.lineTo(cx + leafW * 0.9, cy)
          ctx.stroke()
          // Side veins
          for (var i = 1; i <= 3; i++) {
            var vx = cx - leafW * 0.9 + i * leafW * 0.5
            ctx.beginPath()
            ctx.moveTo(vx, cy)
            ctx.lineTo(vx + leafW * 0.2, cy - leafH * 0.6)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(vx, cy)
            ctx.lineTo(vx + leafW * 0.2, cy + leafH * 0.6)
            ctx.stroke()
          }
        }
        Component.onCompleted: requestPaint()
      }

      // Dandelion seed - pappus (fluffy top) with achene (seed body)
      Canvas {
        visible: type === "dandelion"
        anchors.centerIn: parent
        width: particleRoot.size * 4
        height: particleRoot.size + particleRoot.stemLength
        onPaint: {
          var ctx = getContext("2d")
          ctx.clearRect(0, 0, width, height)
          var cx = width / 2
          var headR = particleRoot.size * 0.6
          // Pappus filaments (fluffy top)
          ctx.strokeStyle = particleRoot.color
          ctx.lineWidth = 0.8
          ctx.globalAlpha = 0.7
          for (var i = 0; i < 12; i++) {
            var angle = (i / 12) * Math.PI * 2
            var filLen = headR * (1.2 + Math.sin(i * 2.5) * 0.4)
            ctx.beginPath()
            ctx.moveTo(cx, 2)
            ctx.lineTo(cx + Math.cos(angle) * filLen, 2 + Math.sin(angle) * filLen)
            ctx.stroke()
          }
          // Seed body
          ctx.fillStyle = "#887744"
          ctx.globalAlpha = 0.8
          ctx.beginPath()
          ctx.ellipse(cx, 4 + particleRoot.stemLength * 0.4, particleRoot.size * 0.12, particleRoot.stemLength * 0.35, 0, 0, Math.PI * 2)
          ctx.fill()
          // Stem
          ctx.strokeStyle = "#aaaaaa"
          ctx.globalAlpha = 0.6
          ctx.lineWidth = 1.2
          ctx.beginPath()
          ctx.moveTo(cx, 2)
          ctx.lineTo(cx, 4 + particleRoot.stemLength * 0.2)
          ctx.stroke()
        }
        Component.onCompleted: requestPaint()
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      visible: root.themeActive
      color: "transparent"

      WlrLayershell.namespace: "omarchy-seasons"
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore

      Component.onCompleted: {
        root.screenW = width
        root.screenH = height
      }
      onWidthChanged: root.screenW = width
      onHeightChanged: root.screenH = height

      Repeater {
        model: particleModel
        delegate: particleDelegate
      }
    }
  }
}
