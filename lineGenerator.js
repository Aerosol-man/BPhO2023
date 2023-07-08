var integrator;

WorkerScript.onMessage = function(message) {
    let data;
    //integrator = message.integrator
    if (message.index) {
        data = integrator.fromPlanet(message.index, message.periods)
    }
    else
        data = integrator.fromValues(message.period, message.eccentricity, message.periods)

    WorkerScript.sendMessage({'reply': data})
}
