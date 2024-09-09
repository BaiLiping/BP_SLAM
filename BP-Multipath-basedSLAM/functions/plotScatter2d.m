function h = plotScatter2d( X, newFigureFlag, color, l_style, linewidth, marker, markersize)
% Description:  Scatterplot of 2d matrix
% X = dxn matrix: d..dimension, n..samples
% newFigureflag: 1..plot in new figure, 0..otherwise
% Author:       Markus Froehle
% Date:         2012-07-26
% Status:       ok


if(nargin == 0)
    return
end

if(nargin < 2 || isempty(newFigureFlag))
    newFigureFlag = 1;
end

if(nargin < 3 || isempty(color))
    color = [0 0 1];
end

if(nargin < 4 || isempty(l_style))
    l_style = 'none';
end

if(nargin < 5 || isempty(linewidth))
    linewidth = 1;
end

if(nargin < 6 || isempty(marker))
    marker = 'x';
end

if(nargin < 7 || isempty(markersize))
    markersize = 6;
end

if newFigureFlag
    figure;
    xlabel('dim 1');
    ylabel('dim 2');
    title('2d scatter plot of X');
end

if size(X,1) < 1
    return
end

if size(X,1) == 1
    hold on;
    plot( X, color);
    return
end

if size(X,2) < 1
    return
end


hold on;

h = plot( X(1,:), X(2,:),'color', color,'linestyle',l_style,'linewidth',...
    linewidth,'markersize',markersize, 'marker', marker);