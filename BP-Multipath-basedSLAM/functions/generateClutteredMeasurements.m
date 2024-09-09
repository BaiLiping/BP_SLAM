% Florian Meyer, 20/06/15

function [clutteredMeasurements] = generateClutteredMeasurements(trueMeasurementsCell, parameters)
measurementVarianceRange = parameters.measurementVariance;
detectionProbability = parameters.detectionProbability;
meanNumberOfClutter = parameters.meanNumberOfClutter;
maxRange = parameters.regionOfInterestSize;
[numSteps, numSensors] = size(trueMeasurementsCell);
clutteredMeasurements = cell(numSteps,1);

for sensor = 1:numSensors
    for step = 1:numSteps
        trueMeasurements = trueMeasurementsCell{step,sensor};
        [~, numAnchors] = size(trueMeasurements);
        detectionIndicator = (rand(numAnchors,1) < detectionProbability);
        detectedMeasurements = squeeze(trueMeasurements(:,detectionIndicator));
        
        numFalseAlarms = poissrnd(meanNumberOfClutter);
        falseAlarms = zeros(2,numFalseAlarms);
        if(~isempty(falseAlarms))
            falseAlarms(1,:) = maxRange*rand(numFalseAlarms,1);
            falseAlarms(2,:) = measurementVarianceRange;
        end
        clutteredMeasurement = [falseAlarms, detectedMeasurements];
        clutteredMeasurement = clutteredMeasurement(:,randperm(numFalseAlarms+sum(detectionIndicator)));
        
        clutteredMeasurements{step,sensor} = clutteredMeasurement;
    end
end

end

