function [ samples ] = sampleFromLikelihood(measurementToAnchor, measurementVariance, agentPosition, numParticles)
samples = zeros(2,numParticles);

r = measurementToAnchor + sqrt(measurementVariance)*randn(1,numParticles);
phi = 2*pi*rand(1,numParticles);

samples(1,:) = agentPosition(1,:) + r.*cos(phi);
samples(2,:)= agentPosition(2,:) + r.*sin(phi);

end

