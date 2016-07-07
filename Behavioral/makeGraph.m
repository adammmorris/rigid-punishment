%% makeGraph
% Visualizes the behavioral results from people playing the steal/punish
% game.
% Assumes "data.csv" has been loaded manually into MATLAB.

% Adam Morris, James MacGlashan, Michael Littman, and Fiery Cushman
% July 2016

%% Parse data

% Convert string subject names to numeric ID
id = zeros(length(subject), 1);
curID = 1;
id(1) = curID;
for thisDataPt = 2:length(subject)
    if strcmpi(subject(thisDataPt), subject(thisDataPt - 1)) == 0
        % We've hit a new person
        curID = curID + 1;
    end
    
    id(thisDataPt) = curID;
end

numSubjects = curID;

% Set constants

% Roles
ROLE_THIEF = 0;
ROLE_VICTIM = 1;

% Opponents
OPP_INFLEXIBLE = 0;
OPP_FLEXIBLE = 1;

% Actions
CHOICE_NOTHING = 0;
CHOICE_ACTION = 1;

%% Make graph

numRounds = 4;

choices_t_across = zeros(numSubjects,numRounds);
choices_p_across = zeros(numSubjects,numRounds);

for thisSubj = 1:numSubjects
    choices_t_across(thisSubj,1) = mean(choice(id==thisSubj & role == ROLE_THIEF & opType == OPP_INFLEXIBLE & matchRound == 1));
    choices_p_across(thisSubj,1) = mean(choice(id==thisSubj & role == ROLE_VICTIM & opType == OPP_INFLEXIBLE & matchRound == 1));
    
    choices_t_across(thisSubj,2) = mean(choice(id==thisSubj & role == ROLE_THIEF & opType == OPP_INFLEXIBLE & (matchRound == 2 | matchRound == 3)));
    choices_p_across(thisSubj,2) = mean(choice(id==thisSubj & role == ROLE_VICTIM & opType == OPP_INFLEXIBLE & (matchRound == 2 | matchRound == 3)));
    
    choices_t_across(thisSubj,3) = mean(choice(id==thisSubj & role == ROLE_THIEF & opType == OPP_INFLEXIBLE & (matchRound == 4 | matchRound == 5)));
    choices_p_across(thisSubj,3) = mean(choice(id==thisSubj & role == ROLE_VICTIM & opType == OPP_INFLEXIBLE & (matchRound == 4 | matchRound == 5)));
    
    choices_t_across(thisSubj,4) = mean(choice(id==thisSubj & role == ROLE_THIEF & opType == OPP_INFLEXIBLE & (matchRound == 6 | matchRound == 7 | matchRound == 8)));
    choices_p_across(thisSubj,4) = mean(choice(id==thisSubj & role == ROLE_VICTIM & opType == OPP_INFLEXIBLE & (matchRound == 6 | matchRound == 7 | matchRound == 8)));
end

fh = figure; hold on; col = hsv(10);

choices_t_means = zeros(1,numRounds);
choices_t_ses = zeros(1,numRounds);
choices_p_means = zeros(1,numRounds);
choices_p_ses = zeros(1,numRounds);
for i = 1:numRounds
    good = ~isnan(choices_t_across(:,i));
    choices_t_means(i) = mean(choices_t_across(good,i));
    choices_t_ses(i) = std(choices_t_across(good,i)) / sqrt(sum(good));
    
    good = ~isnan(choices_p_across(:,i));
    choices_p_means(i) = mean(choices_p_across(good,i));
    choices_p_ses(i) = std(choices_p_across(good,i)) / sqrt(sum(good));
end

p1 = errorbar([1 2.5 4.5 7],choices_t_means,choices_t_ses, '-ro');
xlim([0 numRounds+1]);
ylim([0 1]);

p2 = errorbar([1 2.5 4.5 7],choices_p_means,choices_p_ses, '-bo');
xlim([0 8]);
ylim([0 1]);

legend('Thief','Victim');
legend('boxoff');
xlabel('Round');
ylabel('% Stealing / punishing');

set(gca,'YTick',[0 .5 1]);
set(gca,'YTickLabel',[0 50 100]);
set(gca,'XTick',[1 7]);
set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 50);
set(p1, 'LineWidth', 4, 'MarkerSize', 12);
set(p2, 'LineWidth', 4, 'MarkerSize', 12);