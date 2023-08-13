import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: solarSystem3d
    width: 800
    height: 600
    anchors.centerIn: parent

    signal close

    property var animationProgress: [0, 0, 0, 0, 0, 0, 0, 0, 0]
    property real animationSpeed: 0.01
    property var planetPaths: [[],[]]
    property var colours: ["orange", "red", "pink", "aqua", "cyan", "lawngreen", "salmon", "lightblue", "khaki"]
    property var planetNames: ['mercury', 'venus', 'earth', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'pluto']
    property rect bounds: Qt.rect(-2.2, -2.2, 4.4, 4.4)
    property real scale: 0.75
    property int planetView: 0

    function lerp(p1, p2, t) {

        return p1 + (p2 - p1) * t
    }
    function vLerp(p1, p2, t) {
        return Qt.vector2d(p1.x + (p2.x - p1.x) * t, p1.y + (p2.y - p1.y) * t)
    }

    function changeAnimationSpeed(amount) {
        animationSpeed *= amount
        animationSpeed = Math.min(Math.max(animationSpeed, 0.005), 2)
        speedText.text = `x${animationSpeed.toFixed(3)}`
    }

    function to2D(point) {
        const ROOT_3 = Math.sqrt(3)
        const INV_ROOT_6 = 1 / Math.sqrt(6)

        let newX = ROOT_3 * (point.x - point.z)
        let newY = point.x + point.y + point.z

        //Flip y axis for screen coodinates
        return Qt.vector2d(newX * INV_ROOT_6 * scale, -newY * INV_ROOT_6 * scale)
    }

    function fitToScreen(point) {
        let newPoint = point
        newPoint.x *= canvas.width / bounds.width
        newPoint.x += canvas.width / 2
        newPoint.y *= canvas.height / bounds.height
        newPoint.y += canvas.height / 2

        return newPoint
    }

    function drawBox(ctx) {
        const lines = [
                        [4, 5],
                        [5, 6],
                        [6, 7],
                        [7, 4],
                        [5, 1],
                        [4, 0],
                        [7, 3],
                        [1, 0],
                        [0, 3]
                    ]
        //8 vertices of the cube, top face first
        let rectBounds

        if (planetView == 0)
            rectBounds = orbits.getMaxDisplacement3D(3)
        else
            rectBounds = orbits.getMaxDisplacement3D(8)

        const points = [
                Qt.vector3d(rectBounds.x, rectBounds.y, rectBounds.z),
                Qt.vector3d(-rectBounds.x, rectBounds.y, rectBounds.z),
                Qt.vector3d(-rectBounds.x, rectBounds.y, -rectBounds.z),
                Qt.vector3d(rectBounds.x, rectBounds.y, -rectBounds.z),
                Qt.vector3d(rectBounds.x, -rectBounds.y, rectBounds.z),
                Qt.vector3d(-rectBounds.x, -rectBounds.y, rectBounds.z),
                Qt.vector3d(-rectBounds.x, -rectBounds.y, -rectBounds.z),
                Qt.vector3d(rectBounds.x, -rectBounds.y, -rectBounds.z),
            ].map(to2D).map(fitToScreen)

        //Nasty Hardcoded values
        ctx.strokeStyle = "gray"
        for (let i = 0; i < 5; i++) {
            let t = i / 5
            let end
            ctx.beginPath()
            ctx.moveTo(lerp(points[0].x, points[1].x, t), lerp(points[0].y, points[1].y, t))
            ctx.lineTo(lerp(points[4].x, points[5].x, t), lerp(points[4].y, points[5].y, t))
            end = vLerp(points[7], points[6], t)
            ctx.lineTo(end.x, end.y)
            ctx.stroke()
            ctx.fillText(lerp(-rectBounds.x, rectBounds.x, t).toPrecision(2), end.x + 5, end.y + 5)
            ctx.beginPath()
            ctx.moveTo(lerp(points[0].x, points[3].x, t), lerp(points[0].y, points[3].y, t))
            ctx.lineTo(lerp(points[4].x, points[7].x, t), lerp(points[4].y, points[7].y, t))
            end = vLerp(points[5], points[6], t)
            ctx.lineTo(end.x, end.y)
            ctx.stroke()
            ctx.fillText(lerp(-rectBounds.z, rectBounds.z, t).toPrecision(2), end.x - 12, end.y + 12)
            ctx.beginPath()
            ctx.moveTo(lerp(points[1].x, points[5].x, t), lerp(points[1].y, points[5].y, t))
            ctx.lineTo(lerp(points[0].x, points[4].x, t), lerp(points[0].y, points[4].y, t))
            end = vLerp(points[3], points[7], t)
            ctx.lineTo(end.x, end.y)
            ctx.stroke()
            ctx.fillText(lerp(-rectBounds.y, rectBounds.y, t).toPrecision(2), end.x + 3, end.y)
        }
        ctx.strokeStyle = "white"

        for (let i = 0; i < lines.length; i++) {
            let start = points[lines[i][0]]
            let end = points[lines[i][1]]
            ctx.beginPath()
            ctx.moveTo(start.x, start.y)
            ctx.lineTo(end.x, end.y)
            ctx.stroke()
        }

        ctx.fillText("x/AU", lerp(points[5].x, points[6].x, 0.25), lerp(points[5].y, points[6].y, 0.6))
        ctx.fillText("z/AU", points[7].x + 30, lerp(points[7].y, points[3].y, 0.5))
        ctx.fillText("y/AU", lerp(points[6].x, points[7].x, 0.6), lerp(points[6].y, points[7].y, 0.25))
    }

    function drawBowTop(ctx) {
        const lines = [
            [0, 1],
            [1, 2],
            [1, 3]
        ]
        let rectBounds

        if (planetView == 0)
            rectBounds = orbits.getMaxDisplacement3D(3)
        else
            rectBounds = orbits.getMaxDisplacement3D(8)

        const points = [
            Qt.vector3d(-rectBounds.x, rectBounds.y, rectBounds.z),
            Qt.vector3d(-rectBounds.x, rectBounds.y, -rectBounds.z),
            Qt.vector3d(rectBounds.x, rectBounds.y, -rectBounds.z),
            Qt.vector3d(-rectBounds.x, -rectBounds.y, -rectBounds.z)
        ].map(to2D).map(fitToScreen)

        ctx.strokeStyle = "white"

        for (let i = 0; i < lines.length; i++) {
            let start = points[lines[i][0]]
            let end = points[lines[i][1]]
            ctx.beginPath()
            ctx.moveTo(start.x, start.y)
            ctx.lineTo(end.x, end.y)
            ctx.stroke()
        }
    }

    function drawPlanet(ctx, index, progress) {
        let position = to2D(orbits.displacementAt3D(Math.PI * 2 * progress, index))

        position = fitToScreen(position)

        ctx.beginPath()
        ctx.arc(position.x, position.y, 7.5, 0, Math.PI * 2)
        ctx.fill()

        let path = planetPaths[planetView][index]

        for (let i = 0; i < path.length; i++) {
            ctx.beginPath()
            ctx.moveTo(path[i].x, path[i].y)
            ctx.lineTo(path[(i + 1) % path.length].x, path[(i + 1) % path.length].y)
            ctx.stroke()
        }
    }

    function drawPlanetName(ctx, planet, position) {
        ctx.fillStyle = colours[planet]
        ctx.fillRect(600, 30 + position * 20, 10, 10)
        ctx.fillText(planetNames[planet], 620, 40 + position * 20)
    }
    
    function setPlanetView(newValue) {
        if (newValue === 0) {
            bounds = Qt.rect(-2.2, -2.2, 4.4, 4.4)
            planetView = newValue
        }
        else if (newValue === 1) {
            bounds = Qt.rect(-56, -56, 112, 112)
            planetView = newValue
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            let ctx = getContext("2d")

            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = "black"
            ctx.fillRect(0, 0, width, height)

            ctx.strokeStyle = "white"
            ctx.fillStyle = "white"
            drawBox(ctx)

            let start = 0
            let end = 4
            if (planetView === 1) {
                start = 4
                end = 9
            }

            for (let i = start; i < end; i++) {
                ctx.fillStyle = colours[i]
                ctx.strokeStyle = colours[i]
                drawPlanet(ctx, i, animationProgress[i])
                drawPlanetName(ctx, i, i - start)
            }

            drawBowTop(ctx)
        }
    }
    
    Timer {
        id: timer
        interval: 32; repeat: true; running: true

        onTriggered: {
            for (let i = 0; i < 9; i++) {
                animationProgress[i] += animationSpeed / planetData.orbitalPeriods[i]
                animationProgress[i] -= Math.floor(animationProgress[i])
            }

            canvas.requestPaint()
        }
    }

    Control {
        id: controlPanel
        x: 10
        y: 10
        width: 180
        height: 200
        background: Rectangle {
            radius: 5
            border.color: "gray"
            border.width: 5
            color: "white"
        }

        property bool shown: true

        ColumnLayout {
            Label {
                Layout.topMargin: 10
                Layout.leftMargin: 20
                text: "Control Animation:"
            }
            Label { text: "Planet view:"; Layout.leftMargin: 20; Layout.topMargin: 5}
            RadioButton {
                Layout.leftMargin: 20
                font.pointSize: 10
                text: "Inner planets"
                checked: true
                onClicked: {
                    if (checked)
                        setPlanetView(0)
                }
            }
            RadioButton {
                Layout.leftMargin: 20
                font.pointSize: 10
                text: "Outer planets"
                onClicked: {
                    if (checked)
                        setPlanetView(1)
                }
            }
            Label { text: "Animation speed:"; Layout.leftMargin: 20; font.pointSize: 10 }
            RowLayout {
                Layout.leftMargin: 20
                width: 150

                Button {
                    Layout.fillWidth: false
                    Layout.preferredWidth: 40
                    font.pointSize: 7
                    text: "-"
                    onClicked: {
                        changeAnimationSpeed(.75)
                    }
                }
                Label {id:speedText; text: `x${animationSpeed}`; font.pointSize: 10 }
                Button {
                    Layout.fillWidth: false
                    Layout.preferredWidth: 40
                    font.pointSize: 7
                    text: "+"
                    width: 30
                    onClicked: {
                        changeAnimationSpeed(1.25)
                    }
                }
            }
            Button {
                id: showButton
                Layout.leftMargin: 20
                font.pointSize: 10
                text: "Hide"
                onClicked: {
                    controlPanel.shown = !controlPanel.shown
                    if (controlPanel.shown) {
                        text = "Hide"
                        for (let i = 0; i < parent.children.length; i++) {
                            let child = parent.children[i]
                            if (child !== showButton)
                                child.visible = true
                        }
                        controlPanel.background.visible = true
                    }
                    else {
                        text = "Show"
                        for (let i = 0; i < parent.children.length; i++) {
                            let child = parent.children[i]
                            if (child !== showButton)
                                child.visible = false
                        }
                        controlPanel.background.visible = false
                    }
                }
            }
        }
    }

    Button {
        x: 20
        y: parent.height - 40
        text: "Close"
        onClicked: {
            solarSystem3d.parent.closePage()
        }
    }

    Component.onCompleted: {
        if (platform === 1) {
            controlPanel.height = 300
        }

        for (let i = 0; i < 9; i++) {
            planetPaths[0].push(orbits.getOrbit3D(i, 100, true).map(to2D).map(fitToScreen))
        }
        setPlanetView(1)
        for (let i = 0; i < 9; i++) {
            planetPaths[1].push(orbits.getOrbit3D(i, 100, true).map(to2D).map(fitToScreen))
        }
        setPlanetView(0)
    }
}
