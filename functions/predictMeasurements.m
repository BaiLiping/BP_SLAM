% Florian Meyer, 08/01/16.

function [predictedMeans, predictedUncertainties, predictedRange] = predictMeasurements(predictedParticles, anchorPositions, weightsAnchor)
[~, numParticles, numAnchors] = size(anchorPositions);

predictedMeans = zeros(numAnchors,1);
predictedUncertainties = zeros(numAnchors,1);
predictedRange = zeros(numParticles,1);
for anchor = 1:numAnchors    
    predictedRange(:,anchor) = sqrt((predictedParticles(1,:) - anchorPositions(1,:,anchor)).^2+(predictedParticles(2,:) - anchorPositions(2,:,anchor)).^2)';    
    predictedMeans(anchor) = predictedRange(:,anchor).'*weightsAnchor(:,anchor)/sum(weightsAnchor(:,anchor),1);
    predictedUncertainties(anchor) = (((predictedRange(:,anchor) - predictedMeans(anchor)).*(predictedRange(:,anchor) - predictedMeans(anchor))).'*weightsAnchor(:,anchor))/sum(weightsAnchor(:,anchor),1);
end

end