function [estimatedAnchors, posteriorParticlesAnchors] = deleteUnreliableVA( estimatedAnchors, posteriorParticlesAnchors, unreliabilityThreshold )
numAnchors = size(posteriorParticlesAnchors,2);

unreliableAnchors = [];
for anchor = 1:numAnchors
  priorExistence = posteriorParticlesAnchors{anchor}.posteriorExistence;
  if(priorExistence < unreliabilityThreshold)
    unreliableAnchors = [unreliableAnchors anchor];
  end
end
if(size(unreliableAnchors,2))
  posteriorParticlesAnchors(unreliableAnchors) = [];
  estimatedAnchors(unreliableAnchors) = [];
end