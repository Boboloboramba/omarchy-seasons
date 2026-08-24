import Quickshell
import Quickshell.Wayland
import QtQuick

Item {
  id: root

  property var shell: null
  property bool opened: false
  property real screenW: 1920
  property real screenH: 1080

  function open(payloadJson) { root.opened = true }
  function close() { root.opened = false }
  function ping() { return "ok" }
  function state() { return root.opened ? "open" : "closed" }

  // Current month (1-12)
  property int currentMonth: new Date().getMonth() + 1

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
        size: 3 + Math.random() * 6,
        rotation: Math.random() * 360,
        rotationSpeed: (Math.random() - 0.5) * 60,
        color: colors[Math.floor(Math.random() * colors.length)],
        opacity: 0.5 + Math.random() * 0.5,
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
        size: 1 + Math.random() * 1.5,
        rotation: 0,
        rotationSpeed: 0,
        color: colors[Math.floor(Math.random() * colors.length)],
        opacity: 0.3 + Math.random() * 0.4,
        type: "rain",
        length: 10 + Math.random() * 15,
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
        size: 2 + Math.random() * 3,
        rotation: Math.random() * 360,
        rotationSpeed: (Math.random() - 0.5) * 40,
        color: colors[Math.floor(Math.random() * colors.length)],
        opacity: 0.4 + Math.random() * 0.5,
        type: "dandelion",
        wobbleOffset: Math.random() * Math.PI * 2,
        wobbleSpeed: 0.8 + Math.random() * 1.5,
        wobbleAmp: 20 + Math.random() * 35,
        stemLength: 8 + Math.random() * 12
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
        size: 6 + Math.random() * 8,
        rotation: Math.random() * 360,
        rotationSpeed: 40 + Math.random() * 80,
        color: colors[Math.floor(Math.random() * colors.length)],
        opacity: 0.6 + Math.random() * 0.4,
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
    running: true
    onTriggered: root.spawnParticle()
  }

  // Physics update timer (~60fps)
  Timer {
    id: tickTimer
    interval: 16
    repeat: true
    running: true
    property real lastTime: Date.now()
    onTriggered: {
      var now = Date.now()
      var dt = (now - lastTime) / 1000
      lastTime = now
      root.stepParticles(dt)
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
      height: size
      rotation: rot
      opacity: {
        var fadeIn = Math.min(1, model.age * 3)
        var fadeOut = Math.max(0, 1 - (model.age / model.life) * 0.4)
        return particleOpacity * fadeIn * fadeOut
      }

      // Snowflake - soft white circle
      Rectangle {
        visible: type === "snow"
        anchors.centerIn: parent
        width: particleRoot.size
        height: particleRoot.size
        radius: width / 2
        color: particleRoot.color
        opacity: 0.8
      }

      // Raindrop - thin angled line
      Rectangle {
        visible: type === "rain"
        anchors.centerIn: parent
        width: particleRoot.size
        height: particleRoot.length
        color: particleRoot.color
        opacity: 0.6
        rotation: -8
      }

      // Leaf - rotated rectangle with rounded corners
      Rectangle {
        visible: type === "leaf"
        anchors.centerIn: parent
        width: particleRoot.size * 1.4
        height: particleRoot.size
        radius: 2
        color: particleRoot.color
        opacity: 0.85
      }

      // Dandelion seed - small circle with stem line
      Item {
        visible: type === "dandelion"
        anchors.centerIn: parent

        Rectangle {
          width: particleRoot.size
          height: particleRoot.size
          radius: width / 2
          color: particleRoot.color
          opacity: 0.9
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
        }

        Rectangle {
          width: 1
          height: particleRoot.stemLength
          color: "#cccccc"
          opacity: 0.5
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.bottom
        }
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
      visible: true
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
