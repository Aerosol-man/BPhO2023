import QtQuick 2.15
import QtQuick3D
import QtQuick3D.Helpers

Item {
    width: 640
    height: 480
    anchors.centerIn: parent

    property var planets: [mercury, venus, earth, mars, jupiter, saturn, uranus, neptune, pluto]
    property var planetPaths: []
    property var animationProgress: [0, 0, 0, 0, 0, 0, 0, 0, 0]
    property int numPoints: 300
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

    View3D {
        id: view
        anchors.fill: parent

        environment: SceneEnvironment {
            clearColor: "black"
            backgroundMode: SceneEnvironment.Color

            InfiniteGrid {
                gridInterval: 20
            }
        }

        OrthographicCamera {
            id: camera
            position: Qt.vector3d(200, 200, 200)
        }

        DirectionalLight {
            eulerRotation.x: -30
            eulerRotation.y: -70
            ambientColor: Qt.rgba(0.5, 0.5, 0.5, 1)
        }

        Timer {
            id: timer
            interval: 32; repeat: true; running: false
            onTriggered: {
                for (let i = 0; i < 9; i++) {
                    animationProgress[i] += animationSpeed / planetData.orbitalPeriods[i]
                    animationProgress[i] -= Math.floor(animationProgress[i])
                    updatePlanet(i, animationProgress[i])
                }
            }
        }

        Model {
            id: mercury
            position: Qt.vector3d(0, 0, 0)
            source: "#Sphere"
            scale: Qt.vector3d(0.1, 0.1, 0.1)

            materials:[ DefaultMaterial {
                diffuseColor: "skyblue"
            }
            ]
        }
        Model {
            id: venus
            position: Qt.vector3d(0, 0, 0)
            source: "#Sphere"
            scale: Qt.vector3d(0.1, 0.1, 0.1)

            materials:[ DefaultMaterial {
                diffuseColor: "skyblue"
            }
            ]
        }
        Model {
            id: earth
            position: Qt.vector3d(0, 0, 0)
            source: "#Sphere"
            scale: Qt.vector3d(0.1, 0.1, 0.1)

            materials:[ DefaultMaterial {
                diffuseColor: "skyblue"
            }
            ]
        }
        Model {
            id: mars
            position: Qt.vector3d(0, 0, 0)
            source: "#Sphere"
            scale: Qt.vector3d(0.1, 0.1, 0.1)

            materials:[ DefaultMaterial {
                diffuseColor: "skyblue"
            }
            ]
        }
        Model {
            id: jupiter
            position: Qt.vector3d(0, 0, 0)
            source: "#Sphere"
            scale: Qt.vector3d(0.1, 0.1, 0.1)

            materials:[ DefaultMaterial {
                diffuseColor: "skyblue"
            }
            ]
        }
        Model {
            id: saturn
            position: Qt.vector3d(0, 0, 0)
            source: "#Sphere"
            scale: Qt.vector3d(0.1, 0.1, 0.1)

            materials:[ DefaultMaterial {
                diffuseColor: "skyblue"
            }
            ]
        }
        Model {
            id: uranus
            position: Qt.vector3d(0, 0, 0)
            source: "#Sphere"
            scale: Qt.vector3d(0.1, 0.1, 0.1)

            materials:[ DefaultMaterial {
                diffuseColor: "skyblue"
            }
            ]
        }
        Model {
            id: neptune
            position: Qt.vector3d(0, 0, 0)
            source: "#Sphere"
            scale: Qt.vector3d(0.1, 0.1, 0.1)

            materials:[ DefaultMaterial {
                diffuseColor: "skyblue"
            }
            ]
        }
        Model {
            id: pluto
            position: Qt.vector3d(0, 0, 0)
            source: "#Sphere"
            scale: Qt.vector3d(0.1, 0.1, 0.1)

            materials:[ DefaultMaterial {
                diffuseColor: "skyblue"
            }
            ]
        }

    }

    Component.onCompleted: {
        for (let i = 0; i < 9; i++) {
            planetPaths.push(orbits.getOrbit3D(i, numPoints))
            let scale = i * 0.01
            planets[i].scale = Qt.vector3d(scale, scale, scale)
        }
        timer.running = true
        camera.lookAt(Qt.vector3d(0, 0, 0))
    }
}
