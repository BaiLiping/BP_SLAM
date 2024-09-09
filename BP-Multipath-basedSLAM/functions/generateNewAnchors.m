% Florian Meyer, Erik Leitinger, 20/05/17.

function [newParticlesAnchors,inputBP] = generateNewAnchors(newMeasurements,undetectedTargetsIntensity,predictedParticlesAgent,parameters)
clutterIntensity = parameters.clutterIntensity;
numParticles = parameters.numParticles;
numMeasurements = length(newMeasurements(1,:));
detectionProbability = parameters.detectionProbability;

inputBP = zeros(numMeasurements,1);
newParticlesAnchors = [];
if(numMeasurements)
    newParticlesAnchors = struct('x',zeros(4,numParticles),'w',zeros(numParticles,1),'posteriorExistence',0);
end
constants = calculateConstantsUniform(predictedParticlesAgent, newMeasurements, parameters);
for measurement = 1:numMeasurements
    %inputBP(measurement) = clutterIntensity + constants(measurement) * %undetectedTargetsIntensity * detectionProbability;  % "Williams style"
    inputBP(measurement) = 1 + (constants(measurement) * undetectedTargetsIntensity * detectionProbability)/clutterIntensity;  % "BP style"
    
    % new anchor state
    measurementToAnchor = newMeasurements(1,measurement);
    measurementVariance = newMeasurements(2,measurement);
    newParticlesAnchors(measurement).x = sampleFromLikelihood(measurementToAnchor, measurementVariance, predictedParticlesAgent, numParticles);
    %     newParticlesAnchors(measurement).posteriorExistence = constants(measurement) * undetectedTargetsIntensity * detectionProbability /(clutterIntensity + constants(measurement) * undetectedTargetsIntensity * detectionProbability);
    newParticlesAnchors(measurement).constant = constants(measurement) * undetectedTargetsIntensity * detectionProbability /clutterIntensity;
    newParticlesAnchors(measurement).w = ones(numParticles,1)/numParticles;
end

end