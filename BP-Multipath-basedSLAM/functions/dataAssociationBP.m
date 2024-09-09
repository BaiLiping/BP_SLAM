function [assocProbExisting,assocProbNew,messagelhfRatios,messagelhfRatiosNew] = dataAssociationBP( legacy, new, checkConvergence, threshold, numIterations )
[m,n] = size(legacy);
m = m - 1;
assocProbNew = ones(m,1);
assocProbExisting = ones(m+1,n);
messagelhfRatios = ones(m,n);
messagelhfRatiosNew = ones(m,1);

if(n==0 || m==0)
  return;
end

if(isempty(new))
  new = 1;
end

om = ones(1,m);
on = ones(1,n);
muba = ones(m,n);
for iteration = 1:numIterations
  mubaOld = muba;
  
  prodfact = muba .* legacy(2:end,:);
  sumprod = legacy(1,:) + sum(prodfact,1);
  
  normalization = (sumprod(om,:) - prodfact);
  % hard association if message value is very large
  normalization(normalization == 0) = eps;
  muab = legacy(2:end,:) ./ normalization;
  summuab = new + sum(muab,2);
  normalization = summuab(:,on) - muab;
  % hard association if message value is very large
  normalization(normalization == 0) = eps;
  muba = 1 ./ normalization;
  
  if(mod(iteration,checkConvergence) == 0)
    distance = max(max(abs(log(muba./mubaOld))));
    if(distance < threshold)
      break
    end
  end
end
assocProbExisting(1,:) = legacy(1,:);
assocProbExisting(2:end,:) = legacy(2:end,:).*muba;

for target=1:n
  assocProbExisting(:,target) = assocProbExisting(:,target)/sum(assocProbExisting(:,target));
end

messagelhfRatios = muba;
assocProbNew = new./summuab;

messagelhfRatiosNew = [ones(m,1),muab];
messagelhfRatiosNew = messagelhfRatiosNew./repmat(sum(messagelhfRatiosNew,2),[1,n+1]);
messagelhfRatiosNew = messagelhfRatiosNew(:,1);
end