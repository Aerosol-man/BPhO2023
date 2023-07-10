import QtQuick 2.15

Item {
    width: 640
    height: 480
    anchors.centerIn: parent

    property var animationProgress: [0, 0, 0, 0, 0, 0, 0, 0, 0]
    property real animationSpeed: 0.5

    function updatePlanet(index, progress) {
        let n = progress * numPoints;
        let p1 = planetPaths[index][Math.min(Math.floor(n), numPoints - 1)];
        let p2 = planetPaths[index][Math.min(Math.ceil(n), numPoints - 1)];
        let position
        if (p1 !== p2)
            position = p1.plus((p2.minus(p1)).times(n - Math.floor(n))); // Linear interpolation
        else
            position = p1 // Linear interpolation is buggy for some reason

        planets[index].position = position
    }
    
    Canvas {
        id: canvas
        
        onPaint: {
            
        }
    }
    
    Timer {
        id: timer
        
        onTriggered: {
            interval: 32; repeat: true; running: true

            canvas.requestPaint()
        }
    }
}
