function [ messageOut ] = getInputBP( existence, messageTargetIsPresent)
[lenMessage, ~] = size(messageTargetIsPresent);

messageTargetIsAbsent = zeros(lenMessage,1);
messageTargetIsAbsent(1) = 1;

messageOut = existence*messageTargetIsPresent + (1-existence)*messageTargetIsAbsent;
end
