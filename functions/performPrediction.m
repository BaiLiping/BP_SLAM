function [ predictedParticles ] = performPrediction( oldParticles, parameters )
scanTime = parameters.scanTime;
drivingNoiseVariance = parameters.drivingNoiseVariance;

[~, numParticles] = size(oldParticles);

[A, W] = getTransitionMatrices(scanTime);
predictedParticles = A*oldParticles + W*sqrt(drivingNoiseVariance)*randn(2,numParticles);
end

