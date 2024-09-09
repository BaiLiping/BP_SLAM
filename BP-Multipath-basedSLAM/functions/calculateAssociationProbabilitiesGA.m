% Florian Meyer, 20/05/17.

function [associationProbabilities, associationProbabilitiesNew, messagelegacy, messagesNew] = calculateAssociationProbabilitiesGA(measurements, predictedMeasurements, predictedUncertaintys, weightsAnchor, newInputBP, parameters)
detectionProbability = parameters.detectionProbability;
clutterIntensity = parameters.clutterIntensity;
[~, numMeasurements] = size(measurements);
numAnchors = length(predictedMeasurements);
predictedExistence = sum(weightsAnchor,1);

%calculate incoming messages from likelihood
inputBP = zeros(numMeasurements+1,numAnchors);
inputBP(1,:) = (1-detectionProbability);
for anchor =  1:numAnchors
  for measurement = 1:numMeasurements
    predictedUncertaintyTmp = predictedUncertaintys(anchor) + measurements(2,measurement);
    %factor = 1/sqrt(2*pi*predictedUncertaintyTmp)*detectionProbability; % "Williams style"
    factor = 1/sqrt(2*pi*predictedUncertaintyTmp)*detectionProbability/clutterIntensity; % "BP style"
    inputBP(measurement+1,anchor) = factor*exp(-1/(2*predictedUncertaintyTmp)*(measurements(1,measurement)-predictedMeasurements(anchor)).^2);
  end
  inputBP(:,anchor) = getInputBP(predictedExistence(anchor), inputBP(:,anchor));
end
%calculate approximate posteriors using BP message passing
[associationProbabilities,associationProbabilitiesNew,messagelegacy,messagesNew] = dataAssociationBP( inputBP, newInputBP, 30, 10^(-6), 10^6 );

end