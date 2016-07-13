%% runMatch
% Simulates two learning agents playing each other in the steal-punish game.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Inputs
% envParams: [N s sp c p]
% agentParams: [lr gamma temp stealBias punishBias pctPunCost agentMem]

%% Outputs
% recordQthief: the thief's Q value for every state-action pair on every
%   turn
% recordQpun: same for punisher

function [recordQthief, recordQpun, earnings, thiefActions, punActions] = runMatch(envParams, agentParams)

if nargin < 2, agentParams = [.2 .95 10 0 0 1 2]; end
if nargin < 1, envParams = [10000 2 2 1 5]; end

%% Set up environment
nActions = 2;
ACTION_NOSTEAL = 1;
ACTION_STEAL = 2;
ACTION_NOPUN = 1;
ACTION_PUN = 2;

N = envParams(1); % # of rounds in each match
s = envParams(2); % reward for stealing
sp = envParams(3); % |loss when stolen from|
c = envParams(4); % |cost of punishing|
p = envParams(5); % |loss when punished|

%% Set up agents
lr = agentParams(1);
gamma = agentParams(2);
temp = agentParams(3);
stealBias = agentParams(4);
punishBias = agentParams(5);
pctPunCost = agentParams(6);
agentMem = agentParams(7);

nStates = (nActions ^ agentMem) * 2;

%% Initialize
% Agents' Q value matrices
Qthief = zeros(nStates, nActions); % thief's Q values
Qpun = zeros(nStates, nActions); % punisher's Q values

recordQthief = zeros(nStates, 1 + N * 2);
recordQpun = zeros(nStates, 1 + N * 2);
recordCounter = 1;

recordQthief(:, recordCounter) = Qthief(:, 2) - Qthief(:, 1);
recordQpun(:, recordCounter) = Qpun(:, 2) - Qpun(:, 1);
recordCounter = recordCounter + 1;

% Record earnings (for thief and punisher)
earnings = [0 0];

% Record the actions of each player (to determine state)
thiefActions = zeros(N + agentMem, 1);
punActions = zeros(N + agentMem, 1);

% Set up for first few rounds
% Fill in NOSTEAL/NOPUN for agent's beginning agentMem
thiefActions(1:agentMem) = ACTION_NOSTEAL;
punActions(1:agentMem) = ACTION_NOPUN;
nextState = getStateNum(nonzeros(thiefActions), nonzeros(punActions), agentMem);
nextAvailThief = [ACTION_NOSTEAL ACTION_STEAL];
nextAvailPun = ACTION_NOPUN;

for thisRound = (agentMem + 1):(N + agentMem)
    %% Thief's turn
    % Update state info
    curState = nextState;
    availThief = nextAvailThief; % available actions
    availPun = nextAvailPun;
    
    % Thief acts
    actionThief = fastrandsample(getSoftmax(Qthief(curState, availThief), temp), 1);
    actionPun = availPun; % punisher "acts" too, but it's just a placeholder
    
    % Transition, get rewards
    thiefActions(thisRound) = actionThief;
    nextState = getStateNum(nonzeros(thiefActions), nonzeros(punActions), agentMem);
    
    if actionThief == ACTION_NOSTEAL
        rewardThief = 0;
        rewardPun = 0;
    else
        rewardThief = s + stealBias;
        earnings(1) = earnings(1) + s; % real earnings
        
        rewardPun = -sp;
        earnings(2) = earnings(2) - sp; % real earnings
    end
    
    % Update
    nextAvailThief = ACTION_NOSTEAL;
    nextAvailPun = [ACTION_NOPUN ACTION_PUN];
    
    Qthief(curState, actionThief) = Qthief(curState, actionThief) + ...
        lr * (rewardThief + gamma*max(Qthief(nextState, nextAvailThief)) - Qthief(curState, actionThief));
    Qpun(curState, actionPun) = Qpun(curState, actionPun) + ...
        lr * (rewardPun + gamma*max(Qpun(nextState, nextAvailPun)) - Qpun(curState, actionPun));
    
    recordQthief(:, recordCounter) = Qthief(:, 2) - Qthief(:, 1);
    recordQpun(:, recordCounter) = Qpun(:, 2) - Qpun(:, 1);
    recordCounter = recordCounter + 1;
    
    %% Punisher's turn
    curState = nextState;
    availThief = nextAvailThief;
    availPun = nextAvailPun;
    
    % Punisher acts
    actionPun = fastrandsample(getSoftmax(Qpun(curState, availPun), temp), 1);
    actionThief = availThief; % thief "acts" too, but it's just a placeholder
    
    % Transition, get rewards
    punActions(thisRound) = actionPun;
    nextState = getStateNum(nonzeros(thiefActions), nonzeros(punActions), agentMem);
    
    if actionPun == ACTION_NOPUN
        rewardThief = 0;
        rewardPun = 0;
    else
        rewardThief = -p;
        earnings(1) = earnings(1) - p;
        
        rewardPun = pctPunCost * (-c) + punishBias * (punishBias < 0 | thiefActions(thisRound) == ACTION_STEAL); % subjective payoff
        earnings(2) = earnings(2) - c; % real payoff
    end
    
    % Update
    nextAvailThief = [ACTION_NOSTEAL ACTION_STEAL];
    nextAvailPun = ACTION_NOPUN;

    Qthief(curState, actionThief) = Qthief(curState, actionThief) + ...
        lr * (rewardThief + gamma*max(Qthief(nextState, nextAvailThief)) - Qthief(curState, actionThief));
    Qpun(curState, actionPun) = Qpun(curState, actionPun) + ...
        lr * (rewardPun + gamma*max(Qpun(nextState, nextAvailPun)) - Qpun(curState, actionPun));
    
    recordQthief(:, recordCounter) = Qthief(:, 2) - Qthief(:, 1);
    recordQpun(:, recordCounter) = Qpun(:, 2) - Qpun(:, 1);
    recordCounter = recordCounter + 1;
end

%% Clean up
thiefActions = thiefActions((agentMem + 1):(N + agentMem));
punActions = punActions((agentMem + 1):(N + agentMem));