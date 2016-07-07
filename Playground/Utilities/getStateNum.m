%% getStateNum
% Outputs the state index, given a history of behavior.
% This assumes that agents represent being in the other person's turn -
% so there's only 1 state number (at any given point) for both roles.

%% Inputs
% thiefActions: all the thief's actions up until now, in temporal order
%   (i.e. if the thief stole on turn 1 and didn't steal on turn 2,
%   thiefActions should be [ACTION_STEAL ACTION_NOSTEAL]).
% punActions: all the punisher's actions up until now, in temporal order
%   Note: if it's the thief's turn, these should be the same length. If
%   it's the punisher's turn, punActions should be 1 shorter than
%   thiefActions.
% memory: # of actions the agents remember

%% Outputs
% state: consistent state index
function [state] = getStateNum(thiefActions, punActions, memory)

%% Setup
nActions = 2;

%% Calculate indices

% If it's the thief's turn..
if length(thiefActions) == length(punActions)
    
    actions = cell(memory,1); % the actions that constitute the thief's memory

    % We need to store where we currently are (b/c memory alternates)
    curInd = length(thiefActions) - ceil(memory / 2) + 1;

    % Construct memory
    for i = memory:-1:1
        % If odd, punisher's action
        if mod(i,2) ~= 0
            actions{i} = punActions(curInd);
            curInd = curInd + 1;
        else % If even, thief's action
            actions{i} = thiefActions(curInd);
        end
    end

    % Get index
    state = fastsub2ind(repmat(nActions, memory, 1), actions{:});
    
elseif length(thiefActions) == (length(punActions) + 1)
    
    actions = cell(memory,1); % the actions that constitute the thief's memory

    % We need to store where we currently are in the thief's actions (b/c
    % memory alternates)
    curInd = length(punActions) - floor(memory / 2) + 1;

    % Construct memory
    for i = memory:-1:1
        % If even, punisher's action
        if mod(i,2) == 0
            actions{i} = punActions(curInd);
            curInd = curInd + 1;
        else % If odd, thief's action
            actions{i} = thiefActions(curInd);
        end
    end

    % Get index
    % Add nActions^memory so that we get a separate state index for the
    % punisher's turn
    state = nActions ^ memory + fastsub2ind(repmat(nActions, memory, 1), actions{:});
    
else
    error('thiefActions must be equal to or 1 longer than punActions');
end