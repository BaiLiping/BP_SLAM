% Florian Meyer, 08/01/16.

function [ predictedParticlesAnchors, weightsAnchor ] = predictAnchors( posteriorParticlesAnchors, parameters )
numParticles = parameters.numParticles;
anchorNoiseVariance = parameters.anchorRegularNoiseVariance;
survivalProbability = parameters.survivalProbability;

numAnchors = size(posteriorParticlesAnchors,2);
predictedParticlesAnchors = zeros(2,numParticles,numAnchors);
weightsAnchor = zeros(numParticles,numAnchors);
for anchor = 1:numAnchors
  weightsAnchor(:,anchor) = survivalProbability*posteriorParticlesAnchors{anchor}.w;
  anchorNoise = sqrt(anchorNoiseVariance)*[randn(1,numParticles); randn(1,numParticles)];
  predictedParticlesAnchors(:,:,anchor) = posteriorParticlesAnchors{anchor}.x + anchorNoise;
end
end

