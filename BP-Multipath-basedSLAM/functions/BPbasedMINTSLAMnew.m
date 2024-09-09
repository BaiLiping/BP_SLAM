% Florian Meyer, Erik Leitinger, 20/05/17.

function [ estimatedTrajectory, estimatedAnchors, posteriorParticlesAnchorsstorage, numEstimatedAnchors ] =  BPbasedMINTSLAMnew( dataVA, clutteredMeasurements, parameters, trueTrajectory )
[numSteps,numSensors] = size(clutteredMeasurements);
numSteps = min(numSteps,parameters.maxSteps);
numParticles = parameters.numParticles;
detectionProbability = parameters.detectionProbability;
priorMean = parameters.priorMean;
survivalProbability = parameters.survivalProbability;
undetectedAnchorsIntensity = parameters.undetectedAnchorsIntensity*ones(numSensors,1);
birthIntensity = parameters.birthIntensity;
clutterIntensity = parameters.clutterIntensity;
unreliabilityThreshold = parameters.unreliabilityThreshold;
execTimePerStep = zeros(numSteps,1);
known_track = parameters.known_track;

load scen_semroom_new;

% allocate memory
estimatedTrajectory = zeros(4,numSteps);
numEstimatedAnchors = zeros(2,numSteps);
storing_idx = 30:30:numSteps;
posteriorParticlesAnchorsstorage = cell(1,length(storing_idx));
% initial state vectors
if(known_track)
  posteriorParticlesAgent = repmat([trueTrajectory(:,1);0;0],1,numParticles);
else
  posteriorParticlesAgent(1:2,:) = drawSamplesUniformlyCirc(priorMean(1:2), parameters.UniformRadius_pos ,parameters.numParticles);
  posteriorParticlesAgent(3:4,:) = repmat(priorMean(3:4),1,parameters.numParticles) + 2*parameters.UniformRadius_vel * rand( 2, parameters.numParticles ) - parameters.UniformRadius_vel;  
end
estimatedTrajectory(:,1) = mean(posteriorParticlesAgent,2);


[ estimatedAnchors, posteriorParticlesAnchors ] =  initAnchors( parameters, dataVA, numSteps, numSensors );
for sensor = 1:numSensors
  numEstimatedAnchors(sensor, 1) = size(estimatedAnchors{sensor,1},2);
end

%% main loop
for step = 2:numSteps
  tic
  % perfrom prediction step
  if(known_track)
    predictedParticlesAgent = repmat([trueTrajectory(:,step);0;0],1,numParticles);
  else
    predictedParticlesAgent = performPrediction( posteriorParticlesAgent, parameters );
  end
  weightsSensors = nan(numParticles,numSensors);
  for sensor = 1:numSensors
    estimatedAnchors{sensor,step} = estimatedAnchors{sensor,step-1};
    measurements = clutteredMeasurements{step,sensor};
    numMeasurements = size(measurements,2);
    
    % predict undetected anchors intensity
    undetectedAnchorsIntensity(sensor) = undetectedAnchorsIntensity(sensor) * survivalProbability + birthIntensity;
    
    % predict "legacy" anchors
    [predictedParticlesAnchors, weightsAnchor] = predictAnchors( posteriorParticlesAnchors{sensor}, parameters );
    
    % create new anchors (one for each measurement)
    [newParticlesAnchors,newInputBP] = generateNewAnchors(measurements, undetectedAnchorsIntensity(sensor) , predictedParticlesAgent, parameters);
    
    % predict measurements from anchors
    [predictedMeasurements, predictedUncertainties, predictedRange] = predictMeasurements(predictedParticlesAgent, predictedParticlesAnchors, weightsAnchor);

    % compute association probabilities
    [associationProbabilities, associationProbabilitiesNew, messagelhfRatios, messagesNew] = calculateAssociationProbabilitiesGA(measurements, predictedMeasurements, predictedUncertainties, weightsAnchor, newInputBP, parameters);
    
    % perform message multiplication for agent state
    numAnchors = size(predictedParticlesAnchors,3);
    weights = zeros(numParticles,numAnchors);
    for anchor = 1:numAnchors
      weights(:,anchor) = repmat((1-detectionProbability),numParticles,1);
      for measurement = 1:numMeasurements
        measurementVariance = measurements(2,measurement);
        %factor = 1/sqrt(2*pi*measurementVariance)*detectionProbability; % "Williams style"
        factor = 1/sqrt(2*pi*measurementVariance)*detectionProbability/clutterIntensity; % "BP style"
        weights(:,anchor) = weights(:,anchor) + factor*messagelhfRatios(measurement,anchor)*exp(-1/(2*measurementVariance)*(measurements(1,measurement)-predictedRange(:,anchor)).^2);
      end
      
      % compute anchor predicted existance probability
      predictedExistence = sum(weightsAnchor(:,anchor));
      
      %weights(:,anchor) = weightsAnchor(:,anchor).*weights(:,anchor);
      aliveUpdate = sum(predictedExistence*1/numParticles*weights(:,anchor));
      deadUpdate = 1 - predictedExistence;
      posteriorParticlesAnchors{sensor}{anchor}.posteriorExistence = aliveUpdate/(aliveUpdate+deadUpdate);
      
      % compute anchor belief
      idx_resampling = resampleSystematic(weights(:,anchor)/sum(weights(:,anchor)),numParticles);
      posteriorParticlesAnchors{sensor}{anchor}.x = predictedParticlesAnchors(:,idx_resampling(1:numParticles),anchor);
      posteriorParticlesAnchors{sensor}{anchor}.w = posteriorParticlesAnchors{sensor}{anchor}.posteriorExistence/numParticles*ones(numParticles,1);
      
      estimatedAnchors{sensor,step}{anchor}.x = mean(posteriorParticlesAnchors{sensor}{anchor}.x,2);
      estimatedAnchors{sensor,step}{anchor}.posteriorExistence = posteriorParticlesAnchors{sensor}{anchor}.posteriorExistence;
      
      weights(:,anchor) = predictedExistence*weights(:,anchor) + deadUpdate;
      weights(:,anchor) = log(weights(:,anchor));
      weights(:,anchor) = weights(:,anchor) - max(weights(:,anchor));      
    end
    numEstimatedAnchors(sensor, step) = size(estimatedAnchors{sensor,step},2);
    weightsSensors(:,sensor) = sum(weights,2);
    weightsSensors(:,sensor) = weightsSensors(:,sensor) - max(weightsSensors(:,sensor));
  
    % update undetected anchors intensity
    undetectedAnchorsIntensity(sensor) = undetectedAnchorsIntensity(sensor) * (1-parameters.detectionProbability);
    
    % update new anchors
    for measurement = 1:numMeasurements
      posteriorParticlesAnchors{sensor}{numAnchors+measurement}.posteriorExistence = messagesNew(measurement)*newParticlesAnchors(measurement).constant/(messagesNew(measurement)*newParticlesAnchors(measurement).constant + 1);
      posteriorParticlesAnchors{sensor}{numAnchors+measurement}.x = newParticlesAnchors(measurement).x;
      posteriorParticlesAnchors{sensor}{numAnchors+measurement}.w = posteriorParticlesAnchors{sensor}{numAnchors+measurement}.posteriorExistence/numParticles;
      estimatedAnchors{sensor,step}{numAnchors+measurement}.x = mean(newParticlesAnchors(measurement).x,2);
      estimatedAnchors{sensor,step}{numAnchors+measurement}.posteriorExistence = posteriorParticlesAnchors{sensor}{numAnchors+measurement}.posteriorExistence;
      estimatedAnchors{sensor,step}{numAnchors+measurement}.generatedAt = step;
    end
    
    % delete unreliable anchors
    [estimatedAnchors{sensor,step}, posteriorParticlesAnchors{sensor}] = deleteUnreliableVA( estimatedAnchors{sensor,step}, posteriorParticlesAnchors{sensor}, unreliabilityThreshold );
    numEstimatedAnchors(sensor, step) = size(estimatedAnchors{sensor,step},2);
  end
  weightsSensors = sum(weightsSensors,2);
  weightsSensors = weightsSensors - max(weightsSensors);
  weightsSensors = exp(weightsSensors);
  weightsSensors = weightsSensors/sum(weightsSensors);
  if(any(storing_idx == step))
    posteriorParticlesAnchorsstorage{storing_idx == step} = posteriorParticlesAnchors;
  end
  if(known_track)
    estimatedTrajectory(:,step) = mean(predictedParticlesAgent,2);
    posteriorParticlesAgent = predictedParticlesAgent;
  else
    estimatedTrajectory(:,step) = predictedParticlesAgent*weightsSensors;
    posteriorParticlesAgent = predictedParticlesAgent(:,resampleSystematic(weightsSensors,numParticles));
  end
  
  % error output
  execTimePerStep(step) = toc;
  error_agent = calcDistance_(trueTrajectory(1:2,step),estimatedTrajectory(1:2,step));
  fprintf('Time instance: %d \n',step);
  fprintf('Number of Anchors Sensor 1: %d \n',numEstimatedAnchors(1, step));
  fprintf('Number of Anchors Sensor 2: %d \n',numEstimatedAnchors(2, step));
  fprintf('Position error agent: %d \n',error_agent);
  fprintf('Execution Time: %4.4f \n',execTimePerStep(step));
  fprintf('--------------------------------------------------- \n\n')
end
end

