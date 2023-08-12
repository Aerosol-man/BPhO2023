import QtQuick 2.15

Item {
    property var systemNames: ["UMA_47"]
    property real solarMass: 333030

    property var systems: {
        UMA_47: [
            {name: "UMA 47", mass: solarMass * 1.08, distance: 0},
            {name: "UMA 47 b", mass: 774.9, distance: 2.059},
            {name: "UMA 47 d", mass: 480, distance: 13.8},
            {name: "UMA 47 c", mass: 158, distance: 3.404}
        ]
        CNC_55: [
            {name: "CNC 55 A", mass: solarMass * 0.905, distance: 0},
            {name: "CNC 55 B", mass: solarMass * 0.264, distance: 34782.48},
            {name: "CNC 55 d", mass: 909, distance: 5.54},
            {name: "CNC 55 b", mass: 267, distance: 0.1162},
            {name: "CNC 55 c", mass: 54.35, distance: 0.2432},
            {name: "CNC 55 f", mass: 46.88, distance: 0792},
            {name: "CNC 55 e", mass: 7.99, distance: 0.01544}
        ]
    }

    function getSystem(i) {
        return systems[systemNames[i]]
    }
}
