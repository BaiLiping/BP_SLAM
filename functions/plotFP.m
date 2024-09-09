function plotFP(s_scen, VAidx, posvec)
%function plotFP(s_scen, VAidx, posvec)
%
%plots a floor plan in MINT format. s_scen is the standard MINT
%scenario structure containing:
%   .fp:   the structure containing the floorplan
%   .VAData:  VA data set structure
% VAidx: Optional, VAs to plot
% posvec: Optional, (2xN) Array of points to plot

% Author Paul Meissner, SPSC Lab, 2010 / Mar. 2015

fp = s_scen.fp;
if(isfield(s_scen, 'VAData'))
  VAData = s_scen.VAData;
end

%Settings
load_fp_coeffs;
plot_text_VAind = 1;  %annotate the VAs (VA indices)
plot_seg_number = 0;   %plots the wall segment numbers in the floorplan
plot_dummy = 1;   %plot dummy segments or not
MS_Anchors = 8;  %marker size for BSs and VAs
VAcolors = [0 0 .2;   %colors of the different VA orders
            0 .5 .5;
            0 .75 .75;
            0 1 1];
plot_deac = 1;   %also plot deactivated ones
margin = 1;  %axis margin on all sides
annotate_points = 0;  %if 1, some trajectory points are annotated with their index

hold on; grid on


%% Floor plan
N_seg = size(fp.segments,1);

for i = 1:N_seg
  curr_seg = fp.segments(i,:);
  segment_prop = curr_seg(5);
  
  switch segment_prop
    %%%%%%%%%%%%%%%%%%
    case fp_coeffs.unspec_VA
      lw = 1;
      ls = '-';
      color = .3*[1 1 1];
      %%%%%%%%%%%%%%%%%%
    case fp_coeffs.door_var    
      lw = 2;
      ls = '-';
      color = .4*[1 1 1];
      %%%%%%%%%%%%%%%%%%
    case fp_coeffs.concrete_wall  
      lw = 2;
      ls = '-';
      color = 0*[1 1 1];
      %%%%%%%%%%%%%%%%%%
    case fp_coeffs.glass
      lw = 3;
      ls = '-';
      color = .6*[1 1 1];
      %%%%%%%%%%%%%%%%%%
    case fp_coeffs.metal
      lw = 2;
      ls = '-';
      color = .3*[1 1 1];
      %%%%%%%%%%%%%%%%%%
    case fp_coeffs.dummy   %dummy
      lw = 1;
      ls = '--';
      color = .5*[1 1 1];
      %%%%%%%%%%%%%%%%%%
    case fp_coeffs.trans   %transmission segment
      lw = 1;
      ls = '-';
      color = .4*[1 1 1];
    case fp_coeffs.absorb   %absorber segment
      lw = 1;
      ls = '-';
      color = .2*[1 1 1];
    otherwise   %make a yellow line to alert
      lw = 2;
      ls = '--';
      color = 'y';
  end
  
  %Plot the wall segment
  if(segment_prop == fp_coeffs.dummy && plot_dummy == 0)
    continue;
  end
  h = plot([curr_seg(1), curr_seg(3)], [curr_seg(2), curr_seg(4)], 'LineWidth', lw, 'LineStyle', ls, ...
    'Color', color);
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  if(plot_seg_number)

    P_plot = mean([ curr_seg(1), curr_seg(2); curr_seg(3), curr_seg(4) ]);
    text(P_plot(1), P_plot(2), sprintf('%d', i ), 'Color', 'b', 'FontWeight', 'bold')
  end
  
end  %loop over segments - FP plot

x_coords = [fp.edges(1) fp.edges(2)];
y_coords = [fp.edges(3) fp.edges(4)];

min_x = min(x_coords) - margin;
max_x = max(x_coords) + margin;
min_y = min(y_coords) - margin;
max_y = max(y_coords) + margin;

axis([min_x max_x min_y max_y])

%% VAs
if(nargin >= 2)  %Plot VAs
  
  N_VAs = length(VAidx);
  textshift = .07;
  
  for i = 1:N_VAs
    i_VA = VAidx(i);
    
    %de-activated VAs - plot and annotate them in grey
    if(plot_deac && ~VAData.active(i_VA))
      h = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'ks', 'MarkerSize', MS_Anchors-1, 'MarkerEdgeColor', .9*[1 1 1]);
      h2 = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'kx', 'MarkerSize', MS_Anchors-1, 'MarkerEdgeColor', .9*[1 1 1]);
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      if(plot_text_VAind)  %plot the VA indices
        text(VAData.VA(1,i_VA), VAData.VA(2,i_VA)+textshift, sprintf('%d', i_VA), 'FontSize', 8, ...
          'Color', .9*[1 1 1]);
      end
      continue;
    elseif(~plot_deac && ~VAData.active(i_VA))
      continue;
      
    end
    
    if(VAData.VAtype(i_VA) == 0 )
      h = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA),'color','b','marker','square', 'MarkerSize', MS_Anchors);
      h2 = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA),'bx', 'MarkerSize', MS_Anchors);
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    elseif(VAData.VAtype(i_VA) == 1 )
      h = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'ks', 'MarkerSize', MS_Anchors, 'MarkerEdgeColor', VAcolors(1,:));
      h2 = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'kx', 'MarkerSize', MS_Anchors, 'MarkerEdgeColor', VAcolors(1,:));
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    elseif(VAData.VAtype(i_VA) == 2)
      h = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'ks', 'MarkerSize', MS_Anchors, 'MarkerEdgeColor', VAcolors(2,:));
      h2 = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'kx', 'MarkerSize', MS_Anchors, 'MarkerEdgeColor', VAcolors(2,:));
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    elseif(VAData.VAtype(i_VA) == 3)
      h = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'ks', 'MarkerSize', MS_Anchors, 'MarkerEdgeColor', VAcolors(3,:));
      h2 = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'kx', 'MarkerSize', MS_Anchors, 'MarkerEdgeColor', VAcolors(3,:));
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    elseif(VAData.VAtype(i_VA) == 4)
      h = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'ks', 'MarkerSize', MS_Anchors, 'MarkerEdgeColor', VAcolors(4,:));
      h2 = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'kx', 'MarkerSize', MS_Anchors, 'MarkerEdgeColor', VAcolors(4,:));
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    elseif(VAData.VAtype(i_VA) == 5)
      h = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'ks', 'MarkerSize', MS_Anchors, 'MarkerEdgeColor', .5*[1 1 1]);
      h2 = plot(VAData.VA(1,i_VA), VAData.VA(2,i_VA), 'kx', 'MarkerSize', MS_Anchors, 'MarkerEdgeColor', .5*[1 1 1]);
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    if(plot_text_VAind )  %plot the VA indices
      if(VAData.VAtype(i_VA) == 0)  %base station can have a different text
        text(VAData.VA(1,i_VA)+textshift, VAData.VA(2,i_VA), sprintf('A%d', i_VA), 'FontSize', 10, 'VerticalAlignment', 'middle');
      else
        text(VAData.VA(1,i_VA), VAData.VA(2,i_VA)+textshift, sprintf('A%d', i_VA), 'FontSize', 10);
      end
    end
  end
  
  %Axis scaling
  x_coords = [fp.edges(1) fp.edges(2) VAData.VA(1,VAidx)];
  y_coords = [fp.edges(3) fp.edges(4) VAData.VA(2,VAidx)];
  
  min_x = min(x_coords) - margin;
  max_x = max(x_coords) + margin;
  min_y = min(y_coords) - margin;
  max_y = max(y_coords) + margin;
  
  axis([min_x max_x min_y max_y])

  
end


%% Motion trajectory
if(nargin >= 3)  
  step = 1;  %every step-th step is plotted (for clarity in printouts)
  
  if(~isempty(posvec))
    h = plot(posvec(1,1:step:end), posvec(2,1:step:end), 'b.-', 'MarkerSize', 6, 'Color', 1*[0 0 0]);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  end
  

end

%% manually annotate specific trajectory points
if(annotate_points)
  annot = [1 10:10:220];
  %annot = [1 71  98 118 140 180 220];
  for i_t = 1:length(annot)  %annotate the points
    text(posvec(1, annot(i_t)), posvec(2, annot(i_t))+.09, sprintf('%d', annot(i_t)),'FontSize',8, 'HorizontalAlignment', 'center')
  end

end

axis equal;

xlabel('x [m]')
ylabel('y [m]')

