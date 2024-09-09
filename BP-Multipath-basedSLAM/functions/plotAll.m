function [] = plotAll(trueTrajectory, estimatedTrajectory, estimatedAnchors, posteriorParticlesAnchors, numEstimatedAnchors, dataVA, parameters, mode, numSteps )
% [~, numSteps, ~] = size(trueTrajectory);
% numSteps = min(numSteps,parameters.maxSteps);
[numSensors,~] = size(dataVA);
load scen_semroom_new;

mycolors = [ ...
  0.66,0.00,0.00; ...
  0.00,0.30,0.70; ...
  0.60,0.90,0.16; ...
  0.54,0.80,0.99; ...
  0.99,0.34,0.00; ...
  0.92,0.75,0.33; ...
  0.00,0.00,0.00; ...
  ];

for step = 1:numSteps
  if(mode == 0)
    tmp = numSteps;
  else
    tmp = step;
  end
  
  figure(1);
  plotFP(s_scen)
  hold on
  plot(trueTrajectory(1,:),trueTrajectory(2,:),'-','color',[.5 .5 .5],'linewidth',1.5);
  for sensor = 1:numSensors
    trueAnchorPositions = dataVA{sensor}.positions;
    numPositions = size(trueAnchorPositions,2);    
    if(sensor == 1)
      for anchor = 1:numPositions
        h = plot(trueAnchorPositions(1,:), trueAnchorPositions(2,:),'linestyle','none','linewidth',1,'color',mycolors(sensor,:),'marker','s', 'MarkerSize', 8, 'MarkerEdgeColor', mycolors(sensor,:));
        h2 = plot(trueAnchorPositions(1,:), trueAnchorPositions(2,:),'linestyle','none','linewidth',1,'color',mycolors(sensor,:),'marker','x', 'MarkerSize', 7.9, 'MarkerEdgeColor', mycolors(sensor,:));
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      end
    else
      for anchor = 1:length(dataVA{sensor}.positions)
        h = plot(trueAnchorPositions(1,:), trueAnchorPositions(2,:),'linestyle','none','linewidth',1,'color',mycolors(sensor,:),'marker','s', 'MarkerSize', 8, 'MarkerEdgeColor', mycolors(sensor,:));
        h2 = plot(trueAnchorPositions(1,:), trueAnchorPositions(2,:),'linestyle','none','linewidth',1,'color',mycolors(sensor,:),'marker','x', 'MarkerSize', 7.9, 'MarkerEdgeColor', mycolors(sensor,:));
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      end
    end
    
    numPositions = size(estimatedAnchors{sensor,tmp},2);
    estimatedAnchorExistence = zeros(1,numPositions);
    estimatedAnchorPositions = zeros(2,numPositions);
    for anchor = 1:numPositions
      estimatedAnchorPositions(:,anchor) = estimatedAnchors{sensor,tmp}{anchor}.x;
      estimatedAnchorExistence(anchor) = estimatedAnchors{sensor,tmp}{anchor}.posteriorExistence;
    end
    for anchor = 1:numPositions
      if(estimatedAnchorExistence(anchor) > parameters.detectionThreshold)
        if(sensor==1)
          plotScatter2d(posteriorParticlesAnchors{sensor}{anchor}.x(:,:),0,mycolors(sensor,:),'',1,'.');
        else
          plotScatter2d(posteriorParticlesAnchors{sensor}{anchor}.x(:,:),0,mycolors(sensor,:),'',1,'.');
        end
        plot(estimatedAnchorPositions(1,anchor),estimatedAnchorPositions(2,anchor),'color','k','marker','+', 'MarkerSize', 8);
      end
    end
    numPositions = size(parameters.priorKnownAnchors{sensor},2);
    estimatedAnchorPositions_1 = zeros(2,numPositions);
    for anchor = 1:numPositions
      estimatedAnchorPositions_1(:,anchor) = estimatedAnchors{sensor,1}{anchor}.x;
    end
  end
  
  plot(estimatedTrajectory(1,tmp),estimatedTrajectory(2,tmp),'color',[0 .5 0],'marker','+', 'MarkerSize', 8,'LineWidth', 1.5)

  hold off
  xlabel('xaxis'), ylabel('yaxis');
  pbaspect('manual')
  axis([-7 15 -8 15.5]);
  box on;
  drawnow;
  if(step == 1 && mode ~= 0)
    pause
  end
  
  if(mode == 0)
    break
  elseif(mode == 2)
    pause
  else
    pause(0.01)
  end
end
positionErrorAgent = zeros(1,numSteps);
dist_ospa_map = zeros(numSensors,numSteps);

for sensor = 1:numSensors
  trueAnchorPositions = dataVA{sensor}.positions;
  
  for step = 1:numSteps
    estimatedAnchorPositions = zeros(2,numEstimatedAnchors(sensor,step));
    estimatedAnchorExistence = zeros(1,numEstimatedAnchors(sensor,step));
    for anchor = 1:numEstimatedAnchors(sensor,step)
      estimatedAnchorPositions(1:2,anchor) = estimatedAnchors{sensor,step}{anchor}.x;
      estimatedAnchorExistence(anchor) = estimatedAnchors{sensor,step}{anchor}.posteriorExistence;
    end
    estimatedAnchorPositions(:,estimatedAnchorExistence < parameters.detectionThreshold) = [];
    positionErrorAgent(step) = calcDistance_(trueTrajectory(:,step),estimatedTrajectory(1:2,step));   
    dist_ospa_map(sensor,step) = ospa_dist(trueAnchorPositions,estimatedAnchorPositions,10,1);
  end
end


figure(2);hold on;
for sensor = 1:numSensors
  plot(1:numSteps,dist_ospa_map(sensor,:),'-','color',mycolors(sensor,:),'linewidth',1.5);
end
xlabel('trajectory steps'), ylabel('OSPA map error [m]');grid on;
xlim([0 numSteps])
drawnow;

figure(3);hold on;
plot(1:numSteps,positionErrorAgent,'k')
xlabel('trajectory steps'), ylabel('position error agent [m]');grid on;
xlim([0 numSteps])
drawnow;
end

















