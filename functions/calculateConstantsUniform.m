function [constants] = calculateConstantsUniform(predictedParticlesAgent, newMeasurements, parameters)
regionOfInterest = (2*parameters.regionOfInterestSize)^2;
upSamplingFactor = parameters.upSamplingFactor;
numParticles = parameters.numParticles*upSamplingFactor;

predictedParticlesAgent = repmat(predictedParticlesAgent,[1,upSamplingFactor]);
particles = 2*parameters.regionOfInterestSize*rand(2,numParticles)-parameters.regionOfInterestSize;
constantWeight = 1/regionOfInterest;

numMeasurements = length(newMeasurements(1,:));
constants = zeros(numMeasurements,1);
predictedRange = sqrt((particles(1,:) - predictedParticlesAgent(1,:)).^2+(particles(2,:) - predictedParticlesAgent(2,:)).^2);
for measurement = 1:numMeasurements
    constantLikelihood = 1/sqrt(2*pi*newMeasurements(2,measurement));
    constants(measurement) = sum(1/numParticles*constantLikelihood*exp((-1/2)*(repmat(newMeasurements(1,measurement),1,numParticles) - predictedRange).^2/newMeasurements(2,measurement)));
end
    constants = constants/constantWeight;
end

