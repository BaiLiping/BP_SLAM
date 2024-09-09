function d = calcDistance_(p1, p2, p, mode, c)
%function d = calcDistance(p1, p2, p, mode)
%
%Calculates the order-p distance between points p1 and p2, p is optional 
%and 2 per default (Euclidean distance), p can be any value accepted by 
%the Matlab function norm().
%
%p1 and p2 are dxN matrices containing the N d-dimensional points as columns.
%Either p1 and p2 both contain N points (giving a 1xN vector d with the element-wise
%distances as result) or p1 has one element and p2 has N elements. The latter
%case results in a 1xN vector containing the distances of the point p1 to all elements
%of p2.
%Parameter 'mode' is optional, choices:
%  1: Conventional (p-th order) distance
%  2: d_c (cutoff distance), additional parameter c is the cutoff
%  3: Euclidean distance matrix computation

%Author: Paul Meissner, SPSC Lab, 2010/11/13


%Input parameters
if(nargin == 2 || isempty(p))   %p of the norm is not given, 2 (Euclidean) per default
  p = 2;
end

if( isempty(p1) || isempty(p2))
  d = nan;
  return;
end

if(nargin < 4)       %If no mode is given, just compute conventional distances
  mode = 1;
elseif(nargin == 4 && mode == 2)
  error('Cutoff mode selected without specifying cutoff value!')
end
  
%Check size of input vectors (number of cols = number of points)
N = size(p1, 2);
M = size(p2, 2);
if( (N~=M) && (N>1) && mode ~= 3  )  %Not in matrix mode
  error('Size of input vectors incorrect!')
end

%Repeat p1 to match the length of p2
if( (N == 1) && (M>N) )      
  %p1 = repmat(p1, 1, M);
  p1 = p1*ones(1,M);
end

if(mode == 3)  %calculate (euclidean) the distance matrix
  %disp('Calcdistance(): Calculating distance matrix!')
  d = zeros(N, M);
  for n = 1:N
    for m = n+1:M
       d(n,m) =  norm(p1(:,n)-p2(:,m), p);
    end
  end
  %complete matrix
  d = triu(d)+triu(d)';
  if( nargin == 5)
    d = min(c, d);
  end
  return
end

%Calculate distance
d = sum(abs(p1-p2).^p, 1).^(1/p);

if( mode == 2)   %with cutoff distance 
  d = min(c, d);
end

% %Calculate distance
% d = zeros(1,M);
% for i = 1:M
%   %if( mode == 1);   %conventional distance computation, (many points to many points)
%   d(i) = norm(p1(:,i)-p2(:,i), p);
%   if( mode == 2)   %with cutoff distance (many points to many points)
%     %d(i) = min(c, norm(p1(:,i)-p2(:,i), p));
%     d(i) = min(c, d(i));
% %   else
% %     error('Mode not recognized!')
%   end
% end
