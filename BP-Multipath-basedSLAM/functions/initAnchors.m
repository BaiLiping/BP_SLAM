function [ estimatedAnchors, posteriorParticlesAnchors ] = initAnchors( parameters, dataVA, numSteps, numSensors )
numParticles = parameters.numParticles;
posteriorParticlesAnchors = cell(numSensors,1);
estimatedAnchors = cell(numSensors,numSteps);
for sensor = 1:numSensors
    anchorPositions = dataVA{sensor}.positions(:,parameters.priorKnownAnchors{sensor});
    [~, numAnchors] = size(anchorPositions);
    posteriorParticlesAnchors{sensor} = cell(1,numAnchors);
    estimatedAnchors{sensor,1} = cell(1,numAnchors);
end
priorCovarianceAnchor = parameters.priorCovarianceAnchor;


for sensor = 1:numSensors
    anchorPositions = dataVA{sensor}.positions(:,parameters.priorKnownAnchors{sensor});
    [~, numAnchors] = size(anchorPositions);
    for anchor = 1:numAnchors
        posteriorParticlesAnchors{sensor}{anchor}.x = zeros(2,numParticles);
        posteriorParticlesAnchors{sensor}{anchor}.w = zeros(numParticles,1);
        posteriorParticlesAnchors{sensor}{anchor}.posteriorExistence = 1;
        
        posteriorParticlesAnchors{sensor}{anchor}.w(:) = posteriorParticlesAnchors{sensor}{anchor}.posteriorExistence/numParticles*ones(numParticles,1);
        if(anchor == 1)
            % physical anchors
            posteriorParticlesAnchors{sensor}{anchor}.x =  mvnrnd(anchorPositions(:,anchor),priorCovarianceAnchor,numParticles)';
            estimatedAnchors{sensor,1}{anchor}.x = anchorPositions(:,anchor);
            estimatedAnchors{sensor,1}{anchor}.posteriorExistence = posteriorParticlesAnchors{sensor}{anchor}.posteriorExistence;
            estimatedAnchors{sensor,1}{anchor}.generatedAt = 1;
        else
            % geometry anchors
            anchorPositions(:,anchor) = mvnrnd(anchorPositions(:,anchor),priorCovarianceAnchor,1);
            posteriorParticlesAnchors{sensor}{anchor}.x =  mvnrnd(anchorPositions(:,anchor),priorCovarianceAnchor,numParticles)';
            estimatedAnchors{sensor,1}{anchor}.x = anchorPositions(:,anchor);
            estimatedAnchors{sensor,1}{anchor}.posteriorExistence  = posteriorParticlesAnchors{sensor}{anchor}.posteriorExistence;
            estimatedAnchors{sensor,1}{anchor}.generatedAt = 1;
        end
    end
end

end

