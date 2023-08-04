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
    property rect bounds: Qt.rect(-2.2, -2.2, 4.4, 4.4)
    property real scale: 0.75
    property int planetView: 0

    function lerp(p1, p2, t) {

        return p1 + (p2 - p1) * t
    }
    function vLerp(p1, p2, t) {
        return Qt.vector2d(p1.x + (p2.x - p1.x) * t, p1.y + (p2.y - p1.y) * t)
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
        for (let i = 0; i < 5; i++){
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

//        ctx.fillText("x", points[5].x - 5, points[5].y + 5)
//        ctx.fillText("y", points[0].x, points[0].y - 5)
//        ctx.fillText("z", points[7].x + 5, points[7].y + 5)
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
            if (planetView === 1)
                start = 4

            for (let i = start; i < 9; i++) {
                ctx.fillStyle = colours[i]
                ctx.strokeStyle = colours[i]
                drawPlanet(ctx, i, animationProgress[i])
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
        x: 10
        y: 10
        width: 180
        height: 120
        background: Rectangle {
            radius: 5
            border.color: "gray"
            border.width: 5
            color: "white"
        }
        padding: 8

        ColumnLayout {
            Label {
                text: "Control Animation:"
            }
            Label { text: "Planet view:" }
            RadioButton {
                text: "Inner planets"
                checked: true
                onClicked: {
                    if (checked)
                        setPlanetView(0)
                }
            }
            RadioButton {
                text: "Outer planets"
                onClicked: {
                    if (checked)
                        setPlanetView(1)
                }
            }
        }
    }

    Button {
        x: 20
        y: parent.height - 30
        text: "Close"
        onClicked: {
            solarSystem3d.parent.closePage()
        }
    }

    Component.onCompleted: {
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
