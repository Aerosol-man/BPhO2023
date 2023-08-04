import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: spirograph
    signal close
    width: 800
    height: 600

    property var plotSize
    property real scale: .475
    property var lines
    property int planet1
    property int planet2

    function fitToScreen(p) {
        if (!p.x && p.x !== 0.0) { return }
        let x = (p.x / plotSize.x) * canvas.width * scale
        x += canvas.width / 2
        let y = (p.y / plotSize.y) * canvas.height * scale
        y += canvas.height / 2

        return Qt.vector2d(x, y)
    }

    function fit4ToScreen(p) {
        let x = (p.x / plotSize.x) * canvas.width * scale
        x += canvas.width / 2
        let y = (p.y / plotSize.y) * canvas.height * scale
        y += canvas.height / 2
        let z = (p.z / plotSize.x) * canvas.width * scale
        z += canvas.width / 2
        let w = (p.w / plotSize.y) * canvas.height * scale
        w += canvas.height / 2

        return Qt.vector4d(x, y, z, w)
    }

    function setLines(p1, p2, n, s) {
        planet1 = p1
        planet2 = p2

        plotSize = orbits.getMaxDisplacement(Math.max(p1, p2))
        plotSize.y = plotSize.x
        lines = lineGenerator.lines(p1, p2, n, s).map(fit4ToScreen)
    }

    Timer {
        id: timeout
        interval: 500
        repeat: false

        onTriggered: {
            controlPanel.planetSelected()
        }
    }

    ColumnLayout {
        id: controlPanel
        width: 300
        anchors.left: parent.left
        spacing: 10

        function planetSelected() {
            if (planet1Selector.currentValue == planet2Selector.currentValue)
                genButton.enabled = false
            else if (!timeout.running)
                genButton.enabled = true
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "Generate Spirograph:"
        }
        
        ComboBox {
            id: planet1Selector
            Layout.alignment: Qt.AlignHCenter

            textRole: "text"
            valueRole: "value"
            currentIndex: 1
            model: [
                 {text: "Mercury", value: 0},
                 {text: "Venus", value: 1},
                 {text: "Earth", value: 2},
                 {text: "Mars", value: 3},
                 {text: "Jupiter", value: 4},
                 {text: "Saturn", value: 5},
                 {text: "Uranus", value: 6},
                 {text: "Neptune", value: 7},
                 {text: "Pluto", value: 8}
            ]
            onCurrentValueChanged: {
                parent.planetSelected()
            }
        }

        ComboBox {
            id: planet2Selector
            Layout.alignment: Qt.AlignHCenter

            textRole: "text"
            valueRole: "value"
            currentIndex: 2
            model: [
                 {text: "Mercury", value: 0},
                 {text: "Venus", value: 1},
                 {text: "Earth", value: 2},
                 {text: "Mars", value: 3},
                 {text: "Jupiter", value: 4},
                 {text: "Saturn", value: 5},
                 {text: "Uranus", value: 6},
                 {text: "Neptune", value: 7},
                 {text: "Pluto", value: 8}
            ]
            onCurrentValueChanged: {
                parent.planetSelected()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Label { text: "Number of orbits" }
            SpinBox {
                id: numOrbits
                from: 1
                to: 30
                value: 10
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Label { text: "Samples per orbit" }
            SpinBox {
                id: numSamples
                from: 10
                to: 300
                value: 100
                stepSize: 20
            }
        }

        CheckBox {
            id: showPathBox
            text: "Show paths"
            checked: true
            Layout.alignment: Qt.AlignHCenter

            onClicked: {
                canvas.pathsVisible = checked
            }
        }

        Button {
            id: genButton
            Layout.alignment: Qt.AlignHCenter

            text: "Generate Spirograph"
            onClicked: {
                setLines(planet1Selector.currentValue,
                         planet2Selector.currentValue,
                         numOrbits.value,
                         numSamples.value)

                enabled = false
                canvas.requestPaint()
                canvasHeading.text = `${planet1Selector.currentText}-${planet2Selector.currentText} spirograph`
                timeout.start()
            }
        }
        Button {
            Layout.alignment: Qt.AlignHCenter

            text: "Close"
            onClicked: spirograph.parent.closePage()
        }
    }

    Label {
        id: canvasHeading
        anchors.left: controlPanel.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: canvas.top

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 18

        text: "Venus-Earth spirograph"

    }

    Canvas {
        id: canvas
        width: 440
        height: 440
        y: 20
        anchors.left: controlPanel.right

        property bool pathsVisible: true

        onPathsVisibleChanged: requestPaint()

        function drawPaths(ctx) {
            ctx.strokeStyle = "yellow"
            let data = orbits.getOrbit(planet1, 100, true).map(fitToScreen)

            for (let i = 0; i < data.length; i++) {
                ctx.beginPath()
                ctx.moveTo(data[i].x, data[i].y)
                ctx.lineTo(data[(i + 1) % data.length].x, data[(i + 1) % data.length].y)
                ctx.stroke()
            }

            ctx.strokeStyle = "blue"
            data = orbits.getOrbit(planet2, 100, true).map(fitToScreen)

            for (let i = 0; i < data.length; i++) {
                ctx.beginPath()
                ctx.moveTo(data[i].x, data[i].y)
                ctx.lineTo(data[(i + 1) % data.length].x, data[(i + 1) % data.length].y)
                ctx.stroke()
            }
        }

        function drawLines(ctx) {
            if (!lines) { return }
            for (let i = 0; i < lines.length; i++) {
                ctx.beginPath()
                ctx.moveTo(lines[i].x, lines[i].y)
                ctx.lineTo(lines[i].z, lines[i].w)
                ctx.stroke()
            }
        }

        onPaint: {
            let ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            ctx.strokeStyle = "black"
            drawLines(ctx)

            if (pathsVisible) {
                drawPaths(ctx)
            }
        }
    }

    Component.onCompleted: {
        setLines(1, 2, 10, 100)
        canvas.requestPaint()
    }
}
