%% runMatch
% Simulates two learning agents playing each other in the steal-punish game.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Inputs
% envParams: a 5x1 vector with the parameters: [N s sp c p]
% agentParams: a 7x1 vector with the parameters: [lr gamma invTemp stealBias punishBias pctPunCost agentMem]

%% Outputs
% recordQthief: the thief's Q value for every state-action pair on every
%   turn
% recordQpun: same for victim
% earnings: a 1x2 vector with the thief's (1) and victim's (2) accumulated objective payoffs

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
lr = agentParams(1); % learning rate
gamma = agentParams(2); % discount parameter
invTemp = agentParams(3); % inverse temperature for softmax selection function
stealBias = agentParams(4); % bias in reward function for theft
punishBias = agentParams(5); % bias in reward function for punishing theft
pctPunCost = agentParams(6); % the % of punishment's objective costliness to be used in the reward function
agentMem = agentParams(7); % the agents' memory lengths

nStates = (nActions ^ agentMem) * 2;

%% Initialize
% Agents' Q value matrices
Qthief = zeros(nStates, nActions); % thief's Q values
Qpun = zeros(nStates, nActions); % punisher's Q values

% Recording the Q values at each point in the game
recordQthief = zeros(nStates, 1 + N * 2);
recordQpun = zeros(nStates, 1 + N * 2);
recordCounter = 1;

% Rather than record all the Q values, we just record the relative
% preference for theft / punishment
recordQthief(:, recordCounter) = Qthief(:, 2) - Qthief(:, 1);
recordQpun(:, recordCounter) = Qpun(:, 2) - Qpun(:, 1);
recordCounter = recordCounter + 1;

% Record earnings (for thief and punisher)
earnings = [0 0];

% Record the actions of each player (to get state index)
thiefActions = zeros(N + agentMem, 1);
punActions = zeros(N + agentMem, 1);

% Set up for first few rounds
% Fill in NOSTEAL/NOPUN for agent's beginning agentMem. (We need to do this
% to give the agent's some fake "memory" to start off the game, so they're
% in a well-defined state.)
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
    actionThief = fastrandsample(getSoftmax(Qthief(curState, availThief), invTemp), 1);
    actionPun = availPun; % punisher "acts" too, but it's just a placeholder
    
    % Transition, get rewards
    thiefActions(thisRound) = actionThief;
    nextState = getStateNum(nonzeros(thiefActions), nonzeros(punActions), agentMem);
    
    if actionThief == ACTION_NOSTEAL
        rewardThief = 0;
        rewardPun = 0;
    else
         % subjective reward
        rewardThief = s + stealBias;
        rewardPun = -sp; % subjective reward
        
        % real earnings
        earnings(1) = earnings(1) + s;
        earnings(2) = earnings(2) - sp;
    end
    
    % Get available actions in next state (i.e. the victim's turn)
    nextAvailThief = ACTION_NOSTEAL;
    nextAvailPun = [ACTION_NOPUN ACTION_PUN];
    
    % Update Q-learners
    Qthief(curState, actionThief) = Qthief(curState, actionThief) + ...
        lr * (rewardThief + gamma*max(Qthief(nextState, nextAvailThief)) - Qthief(curState, actionThief));
    Qpun(curState, actionPun) = Qpun(curState, actionPun) + ...
        lr * (rewardPun + gamma*max(Qpun(nextState, nextAvailPun)) - Qpun(curState, actionPun));
    
    % Continue recording Q values
    recordQthief(:, recordCounter) = Qthief(:, 2) - Qthief(:, 1);
    recordQpun(:, recordCounter) = Qpun(:, 2) - Qpun(:, 1);
    recordCounter = recordCounter + 1;
    
    %% Punisher's turn
    curState = nextState;
    availThief = nextAvailThief;
    availPun = nextAvailPun;
    
    % Punisher acts
    actionPun = fastrandsample(getSoftmax(Qpun(curState, availPun), invTemp), 1);
    actionThief = availThief; % thief "acts" too, but it's just a placeholder
    
    % Transition, get rewards
    punActions(thisRound) = actionPun;
    nextState = getStateNum(nonzeros(thiefActions), nonzeros(punActions), agentMem);
    
    if actionPun == ACTION_NOPUN
        rewardThief = 0;
        rewardPun = 0;
    else
        rewardThief = -p;
        % This line is complicated. pctPunCost controls the % of
        % punishment's objective cost that gets through to the reward
        % function. (We use this to manipulate whether punishment is
        % subjectively costly or not in the embedded simulations.) Thus,
        % the first part of rewardPun is pctPunCost * (-c).
        % The second part is the agent's hedonic bias for punishing theft.
        % If punishBias > 0, then the bias is meant to be instantiating
        % "always punish theft", in which case we want it to only apply if
        % the thief stole last round. But if punishBias < 0, then the bias
        % is meant to be instantiating "never punish", in which case we
        % want it to apply no matter what the thief did. Hence, punishBias
        % * (punishBias < 0 | thiefActions(thisRound) == ACTION_STEAL).
        rewardPun = pctPunCost * (-c) + punishBias * (punishBias < 0 | thiefActions(thisRound) == ACTION_STEAL);
        
        earnings(1) = earnings(1) - p;
        earnings(2) = earnings(2) - c;
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
% Get rid of the "fake memory" we gave agents to start off the game.
thiefActions = thiefActions((agentMem + 1):(N + agentMem));
punActions = punActions((agentMem + 1):(N + agentMem));