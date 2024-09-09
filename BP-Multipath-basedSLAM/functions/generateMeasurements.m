% Florian Meyer, 19/04/17

function [ measurementsCell ] = generateMeasurements(targetTrajectory, dataVA, parameters)
measurementVarianceRange = parameters.measurementVariance;
[~, numSteps] = size(targetTrajectory);
numSensors = length(dataVA);
measurementsCell = cell(numSteps,numSensors);

for sensor = 1:numSensors
  positions = dataVA{sensor}.positions;
  visibility = dataVA{sensor}.visibility;
  for step = 1:numSteps
    k = 0;
    [~, numAnchors] = size(positions);
    measurements = zeros(2,numAnchors);
    for anchor = 1:numAnchors
      if(visibility(anchor,step))
        k = k+1;
        measurements(2,k) = measurementVarianceRange;
        measurements(1,k) = sqrt((positions(1,anchor) - targetTrajectory(1,step)).^2 + (positions(2,anchor) - targetTrajectory(2,step)).^2)' +  sqrt(squeeze(measurements(2,k))).*randn;
        measurements(2,k) = parameters.measurementVarianceLHF;
      end
    end
    measurementsCell{step,sensor} = measurements(:,1:k);
  end
end

end

