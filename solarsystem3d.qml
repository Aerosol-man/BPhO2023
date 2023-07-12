import QtQuick 2.15

Item {
    width: 640
    height: 480
    anchors.centerIn: parent

    property var animationProgress: [0, 0, 0, 0, 0, 0, 0, 0, 0]
    property real animationSpeed: 0.01
    property var planetPaths: []
    property rect bounds: Qt.rect(-2.2, -2.2, 4.4, 4.4)

    function to2D(point) {
        const ROOT_3 = Math.sqrt(3)
        const INV_ROOT_6 = 1 / Math.sqrt(6)

        let newX = ROOT_3 * (point.x - point.z)
        let newY = point.x + point.y + point.z

        //Flip y axis for screen coodinates
        return Qt.vector2d(newX * INV_ROOT_6, -newY * INV_ROOT_6)
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
        //8 vertices of the cube, top face first
        let points = [
                Qt.vector3d(bounds.x, bounds.y, bounds.x),
                Qt.vector3d(-bounds.x, bounds.y, bounds.x),
                Qt.vector3d(-bounds.x, bounds.y, -bounds.x),
                Qt.vector3d(bounds.x, bounds.y, -bounds.x),
                Qt.vector3d(bounds.x, -bounds.y, bounds.x),
                Qt.vector3d(-bounds.x, -bounds.y, bounds.x),
                Qt.vector3d(-bounds.x, -bounds.y, -bounds.x),
                Qt.vector3d(bounds.x, -bounds.y, -bounds.x),
            ].map(to2D).map(fitToScreen)

        //Draw both faces
        for (let i = 0; i < 2; i++) {
            for (let j = 0; j < 4; j++) {
                ctx.beginPath()
                let start = points[j + i * 4]
                let end = points[(j + 1) % 4 + i * 4]
                ctx.moveTo(start.x, start.y)
                ctx.lineTo(end.x, end.y)
                ctx.stroke()
            }
        }
        //Draw the connecting lines
        for (let i = 0; i < 4; i++) {
            ctx.beginPath()
            let start = points[i]
            let end = points[i + 4]
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

        let path = planetPaths[index]

        for (let i = 0; i < path.length; i++) {
            ctx.beginPath()
            ctx.moveTo(path[i].x, path[i].y)
            ctx.lineTo(path[(i + 1) % path.length].x, path[(i + 1) % path.length].y)
            ctx.stroke()
        }
    }
    
    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            let ctx = getContext("2d")

            ctx.clearRect(0, 0, width, height)

            ctx.fillStyle = "black"
            ctx.strokeStyle = "black"

            drawBox(ctx)

            for (let i = 0; i < 9; i++) {
                drawPlanet(ctx, i, animationProgress[i])
            }
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

    Component.onCompleted: {
        for (let i = 0; i < 9; i++) {
            planetPaths.push(orbits.getOrbit3D(i, 100, true).map(to2D).map(fitToScreen))
        }
    }
}
