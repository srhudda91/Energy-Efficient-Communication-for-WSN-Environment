close all;
clear;
clc;

%% Define the params structure directly here for use of DDMPEA, DWEHC, FOHCA
params = struct();
params.areaSize = 1000; % Area size (square field) [meters]
params.numNodes = 100;  % Number of sensor nodes
params.E0 = 0.5;        % Initial energy of each node [Joules]
params.sinkx = 500;     % Sink x-coordinate (center of area)
params.sinky = 500;     % Sink y-coordinate (center of area)
params.packetSize = 4000; % Data packet size [bits]
params.ctrlPacketSize = 80; % Control packet size [bits]
params.Eelec = 50e-9;   % Energy to run the transmitter/receiver circuitry [J/bit]
params.Eda = 5e-9;      % Data aggregation energy [J/bit]
params.Efs = 10e-12;    % Free-space model amplifier energy [J/bit/m^2]
params.Emp = 1.3e-15;   % Multipath model amplifier energy [J/bit/m^4]
params.Tx_range = 100;  % Max transmission range (assumed) [meters]
params.alpha = 2;       % Path loss exponent (2 for free-space, 4 for multipath)
params.beta = 1;        % If any other energy model needs beta
params.w1 = 0.5;        % FOHCA: weight for average distance
params.w2 = 0.5;        % FOHCA: weight for energy
params.FO_iter = 20;    % FOHCA: firefly optimization iterations
params.P_CH = 0.05;     % Probability of node becoming CH
params.maxRounds = 3000;% Maximum simulation rounds
params.maxGen = 100;     % Maximum number of generations where the DDMPEA Algorithms runs

% Common network parameters
params.areaSize  = 100;
params.numNodes  = 100;
params.numRounds = 150;
params.E0        = 0.5;
params.m         = 0.1;
params.m0        = 0.2;
params.alpha     = 2;
params.beta      = 1;
params.sink      = [50,50];
% Energy model
params.Eelec     = 50e-9;
params.Eda       = 5e-9;
params.Efs       = 10e-12;
params.Emp       = 0.0013e-12;
params.packetSize= 4000;
% DDMPEA-specific
params.NP        = 50;
params.maxGen    = 100;
params.P         = 30;
params.sigma1    = 1;
% DWEHC-specific
params.Einit     = params.E0;
params.R         = 30;
% EDC-specific
params.RFpos     = params.sink;
params.targetD   = 0.2;
params.L         = 8e3;
params.Pi        = 1;
params.sigmaS2   = 1;
params.sigmaN2   = 0.1;
params.sigmaW2   = 0.1;
params.sigma1_EDC= 50;
params.Gt        = 17;
params.Gr        = 9;
params.lambda    = 3e8/950e6;
params.Pt        = 20;
% FOHCA-specific
params.BSpos     = params.sink;
params.P_CH      = 0.05;
params.k         = round(params.P_CH*params.numNodes);
params.FO_iter   = 20;
params.w1        = 0.5;
params.w2        = 0.5;

%% DBSCAN ALGO %%
% Step 1: SETUP %
%%%%%%%%%%%%%%%%%%%%% Network Establishment Parameters %%%%%%%%%%%%%%%%%%%%
%%% Plot of Operation %%%
%rng('default');
% Field Dimensions in meters %
% Define the grid size
x_max = 1000;
y_max = 1000;
x_min = 10;
y_min = 10;
step = 100;
% Generate the grid
x_cord = x_min:step:(x_min + (x_max - 1) * step);
y_cord = y_min:step:(y_min + (y_max - 1) * step);
x = 0; % added for better display results of the plot
y = 0; % added for better display results of the plot
% Coordinates of the Sink (location is predetermined in this simulation) %
sinkx = 990;
sinky = 990;
% No. of nodes
n = 100;

%%% Energy Values %%%
% Initial Energy of a Node (in Joules) %
Eo = 0.1; % units in Joules
% Energy required to run circuity (both for transmitter and receiver) %
Eelec = 15 * 10 ^ (-9); % units in Joules/bit
% Transmit Amplifier Types %
Eamp = 50 * 10 ^ (-12); % units in Joules/bit/m^2 (amount of energy spent by the amplifier to transmit the bits)
% Data Aggregation Energy %
EDA = 5 * 10 ^ (-9); % units in Joules/bit

% Size of data package %
pkt_size = 20; % units in bits
% Transmission range
Tx_range = 50; % same as Eps for now
% energy threshold perc
E_thresh = 0.2;

%%% Creation of the Wireless Sensor Network %%%
% preallocating pos for speed%
pos(n) = struct('x', [], 'y', []);  % Preallocate structure array

for i = 1:n
    % pos(i).x = x_min + (x_max - x_min) * rand(); % X-axis coordinates of sensor node
    % pos(i).y = y_min + (y_max - y_min) * rand(); % Y-axis coordinates of sensor node
    % Assign positions in the randomised WSN %
    positions = zeros(n, 2); % Preallocate for performance
    while true
        % Generate random x and y coordinates within the field dimensions
        new_x = x_min + (x_max - x_min) * rand; % Random x-coordinate
        new_y = y_min + (y_max - y_min) * rand; % Random y-coordinate
    
        % Check for uniqueness - to avoid ovaerlapping nodes 
        if i == 1 || all(positions(1:i-1, 1) ~= new_x | positions(1:i-1, 2) ~= new_y)
            positions(i, :) = [new_x, new_y]; % Store the unique position
            break; % Exit the loop if the position is unique
        end
    end
    
    % Assign the unique coordinates to the sensor node
    pos(i).x = new_x;
    pos(i).y = new_y;
end

SN(n) = struct('x', [], 'y', [], 'id', []);
for i = 1:n
    SN(i).x = pos(i).x;
    SN(i).y = pos(i).y;

    % Plotting the randomised WSN % 
    hold on;
    figure(1);
    plot(x, y, x_max, y_max, SN(i).x, SN(i).y, 'ob', sinkx, sinky, '*r');
    title 'Wireless Sensor Network';
    xlabel 'X-coordinate (Field size in Meters)';
    ylabel 'Y-coordinate (Field size in Meters)';

end

% Calculate the pairwise distance matrix
DistMat = zeros(n, n);
for i = 1:n
    for j = 1:n
        DistMat(i, j) = sqrt((pos(i).x - pos(j).x)^2 + (pos(i).y - pos(j).y)^2);
    end
end



%% Step 2: Apply DBSCAN %%
Eps = 110;    % Epsilon neighborhood radius
MinPts = 3;  % Minimum number of points to form a cluster

% Initialising SN
SN = resetNodes(n, Eo, sinkx, sinky, pos, DistMat, Eps);

%Clust:  A N*1 vector describes the cluster membership for each point. 0 is
%reserved for NOISE.
[Clust, SN] = DBSCAN(DistMat, Eps, MinPts, SN); % Applying DBSCAN 

% Number of noise points are ones unassigned to clusters
noise_points_count = sum(Clust == 0);
fprintf("Number of Unusable or Unassigned Nodes (Noise Nodes): %d/%d\n", noise_points_count, n);
fprintf("Number of Usable or Assigned Nodes: %d/%d\n", n - noise_points_count, n);

% running the DBSCAN simulation with the very basic CH election algo
fprintf("Starting Simulation for DBSCAN \n");
[opNodes_db, dNodes_db, cNodes_db, remainingEnergy_db, abpl_db, lsp_db, nrg_db, threshData_db, firstNodeDead_db, quarterNodesDead_db, halfNodesDead_db, allNodesDead_db] = runDbscanSimulation(SN, Clust, DistMat, Eo, Eps, MinPts, n, noise_points_count, Eelec, Eamp, EDA, pkt_size, Tx_range, E_thresh);

%%% Visualize the Clusters %%%
figure(2);
hold on;
title '1st Clustering Based on DBSCAN';
xlabel 'X-coordinate (Field Size in Meters)';
ylabel 'Y-coordinate (Field Size in Meters)';
% Define colors for different clusters
colors = lines(max(Clust)+1); % Lines generate different colors
plot(sinkx, sinky, '*r', 'MarkerSize', 12, 'LineWidth', 3); % mark the sink node
for i = 1:n
    if Clust(i) == 0
        % Plot noise points
        plot(pos(i).x, pos(i).y, 'kx', 'MarkerSize', 8, 'LineWidth', 3);
    else
        % Plot clustered points
        plot(pos(i).x, pos(i).y, 'o', 'Color', colors(Clust(i), :), 'MarkerSize', 8, 'LineWidth', 2);
    end
end

% parameters: weights(i) - correspond to the ith parameter
% 1. energy left
% 2. Distance from sink node
% 3. average distance from all cluster members
% 4. How many times node has become cluster head

n_parameters = 4;

%%  Step 3: Simulate all algos %%

%% Step 3a: Label the graphs that will do the comparative analysis
% Plotting Number of Operating Nodes per Round
figure(3);
hold on;
title({'COMPARISON'; 'Number of Operating Nodes Per Round'});
xlabel '# Rounds';
ylabel '# Operational Nodes';

% Plotting Number of Dead Nodes Per Round
figure(4);
hold on;
title({'COMPARISON'; 'Number of Dead Nodes Per Round'});
xlabel '# Rounds';
ylabel '# Dead Nodes';

% Plotting Number of Clusters Per Round
figure(5);
hold on;
title({'COMPARISON'; 'Number of Clusters Per Round'});
xlabel '# Rounds';
ylabel '# Clusters';

% Plotting number of transmissions occuring in every round of the simulation
figure(6);
hold on;
title({'COMPARISON'; 'Number of Transmissions Occurring Per Round'});
xlabel '# Rounds';
ylabel '# Transmissions Occurring';

% Plotting Energy Consumption Per Transmission
figure(7);
hold on;
title({'COMPARISON'; 'Energy Consumption Per Round'});
xlabel '# Round';
ylabel 'Energy (Joule)';

% Plotting Remaining Energy Per Round
figure(8);
hold on;
title({'COMPARISON'; 'Remaining Energy Per Round'});
xlabel '# Rounds';
ylabel 'Remaining Energy (Joule)';

% Plotting Average Backbone Path Length Per Round
figure(9);
hold on;
title({'COMPARISON'; 'Average Backbone Path Length Per Round'});
xlabel '# Rounds';
ylabel 'Average Backbone Path Length';

% Plotting Longest Shortest Path Length Per Round
figure(10);
hold on;
title({'COMPARISON'; 'Longest Shortest Path Length Per Round'});
xlabel '# Rounds';
ylabel 'Longest Shortest Path Length';

% Define a number for the figure that will be updated with each figure made
% when you update thsi also update ' figIndex'  
FigNo = 11; % since the last figure was numbered 10, next one will be 10
% lastFigNo = 11 - 1; % since the last figure currently assigned FigNo -1

%% Step 3b: Actually simulating the algos
%% Now simulating RCA - Ranked Choice Algorithm
ranks_roc = [1, 2, 3, 4];
% Array that'll store teh final RCA weights
roc_weights = zeros(1, n_parameters);
% Provides a balanced weighting by ensuring higher-ranked parameters carry progressively less influence than the previous one.

% what the code below does is - 
% For i = 1 (highest-ranked parameter):
% ranks_roc(1:end) = [1, 2, 3, 4].
% 1 ./ ranks_roc(1:end) = [1/1, 1/2, 1/3, 1/4].
% Sum = 1 + 0.5 + 0.333 + 0.25 = 2.083.
% Weight = 2.083 / 4 = 0.52075.

% What it does - 
% Lower-ranked parameters still contribute to the weights of higher-ranked  
% ones through cumulative summation, creating a cumulative ranking effect.
for i = 1:n_parameters
    roc_weights(i) = sum(1 ./ ranks_roc(i:end)) / n_parameters;
end
% Reset function that sets the node back to initial format of randomly unclustered nodes
SN = resetNodes(n, Eo, sinkx, sinky, pos, DistMat, Eps);
fprintf("Starting Simulation for RCA\n");
[FigNo, opNodes_roc, dNodes_roc, cNodes_roc, remainingEnergy_roc, abpl_roc, lsp_roc, nrg_roc, threshData_roc, firstNodeDead_roc, quarterNodesDead_roc, halfNodesDead_roc, allNodesDead_roc] = runSimulation(Eps, MinPts, FigNo, roc_weights, DistMat, SN, Clust, Eo, n, noise_points_count, Eelec, Eamp, EDA, pkt_size, Tx_range, E_thresh);


%% Now simulating SRA - Score-based Ranking Algorithm
ranks_rs = [1, 2, 3, 4];
% What is happening - 
% Suppose n = 4 and ranks_rs = [1, 2, 3, 4].

% Reversed Rank Scale:
% n + 1 - ranks_rs = [4, 3, 2, 1].

% Normalization Factor: ensure that the sum of all weights equals 1
% 2 / (n * (n + 1)) = 2 / (4 * 5) = 2 / 20 = 0.1.

% Weights Calculation: 
% rs_weights = 0.1 * [4, 3, 2, 1] = [0.4, 0.3, 0.2, 0.1].

% Result: 
% The weights are [0.4, 0.3, 0.2, 0.1], where the highest-ranked parameter gets the largest weight.

rs_weights = 2 * (n + 1 - ranks_rs) ./ (n * (n + 1));
% Reset function that sets the node back to initial format of randomly unclustered nodes
SN = resetNodes(n, Eo, sinkx, sinky, pos, DistMat, Eps);
fprintf("Starting Simulation for SRA\n");
[FigNo, opNodes_rs, dNodes_rs, cNodes_rs, remainingEnergy_rs, abpl_rs, lsp_rs, nrg_rs, threshData_rs, firstNodeDead_rs, quarterNodesDead_rs, halfNodesDead_rs, allNodesDead_rs] = runSimulation(Eps, MinPts, FigNo, rs_weights, DistMat, SN, Clust, Eo, n, noise_points_count, Eelec, Eamp, EDA, pkt_size, Tx_range, E_thresh);

%% Now simulating RRA - Rank Reciprocal Algo
ranks_rr = [1, 2, 3, 4];
% Array that'll store teh final RRA weights
rr_weights = zeros(1, n_parameters);
% find the reciprocal sum of the rank - according to the algo
sum_inverse_r = sum(1 ./ ranks_rr);

for j = 1:n_parameters
    % weights normalized to ensure the total weight sums up to 1.
    rr_weights(j) = (1 / ranks_rr(j)) / sum_inverse_r;
end
% Reset function that sets the node back to initial format of randomly unclustered nodes
SN = resetNodes(n, Eo, sinkx, sinky, pos, DistMat, Eps);
fprintf("Starting Simulation for RRA\n");
[FigNo, opNodes_rr, dNodes_rr, cNodes_rr, remainingEnergy_rr, abpl_rr, lsp_rr, nrg_rr, threshData_rr, firstNodeDead_rr, quarterNodesDead_rr, halfNodesDead_rr, allNodesDead_rr] = runSimulation(Eps, MinPts, FigNo, rr_weights, DistMat, SN, Clust, Eo, n, noise_points_count, Eelec, Eamp, EDA, pkt_size, Tx_range, E_thresh);

%%  Step 4:  Plotting the various comparative graphs %%
% defining colours for the plots
colour_RCA = '#A2142F';
colour_SRA = '#EDB120';
colour_RRA = '#7E2F8E';
colour_DB  = '#77AC30';

% Plotting Number of Operating Nodes per Round
figure(3);
hold on;
plot(1:length(opNodes_roc), opNodes_roc(1:length(opNodes_roc)), '-', 'Color', colour_RCA, 'Linewidth', 2); % RCA method
plot(1:length(opNodes_rs), opNodes_rs(1:length(opNodes_rs)), '-', 'Color', colour_SRA, 'Linewidth', 2); % SRA method
plot(1:length(opNodes_rr), opNodes_rr(1:length(opNodes_rr)), '-', 'Color', colour_RRA, 'Linewidth', 2); % RRA method
plot(1:length(opNodes_db), opNodes_db(1:length(opNodes_db)), '-', 'Color', colour_DB, 'Linewidth', 2); % Plain DBSCAN


% Plotting Number of Dead Nodes Per Round
figure(4);
hold on;
plot(1:length(dNodes_roc), dNodes_roc(1:length(dNodes_roc)), '-', 'Color', colour_RCA, 'Linewidth', 2); % RCA method
plot(1:length(dNodes_rs), dNodes_rs(1:length(dNodes_rs)), '-', 'Color', colour_SRA, 'Linewidth', 2); % SRA method
plot(1:length(dNodes_rr), dNodes_rr(1:length(dNodes_rr)), '-', 'Color', colour_RRA, 'Linewidth', 2); % RRA method
plot(1:length(dNodes_db), dNodes_db(1:length(dNodes_db)), '-', 'Color', colour_DB, 'Linewidth', 2); % Plain DBSCAN


% Plotting Number of Clusters Per Round
figure(5);
hold on;
plot(1:length(cNodes_roc), cNodes_roc(1:length(cNodes_roc)), '-', 'Color', colour_RCA, 'Linewidth', 2); % RCA method
plot(1:length(cNodes_rs), cNodes_rs(1:length(cNodes_rs)), '-', 'Color', colour_SRA, 'Linewidth', 2); % SRA method
plot(1:length(cNodes_rr), cNodes_rr(1:length(cNodes_rr)), '-', 'Color', colour_RRA, 'Linewidth', 2); % RRA method
plot(1:length(cNodes_db), cNodes_db(1:length(cNodes_db)), '-', 'Color', colour_DB, 'Linewidth', 2); % Plain DBSCAN


% Plotting number of transmissions occuring in every round of the simulation
figure(6);
hold on;
plot(1:length(threshData_roc), threshData_roc(1:length(threshData_roc)), '-', 'Color', colour_RCA, 'Linewidth', 2); % RCA method
plot(1:length(threshData_rs), threshData_rs(1:length(threshData_rs)), '-', 'Color', colour_SRA, 'Linewidth', 2); % SRA method
plot(1:length(threshData_rr), threshData_rr(1:length(threshData_rr)), '-', 'Color', colour_RRA, 'Linewidth', 2); % RRA method
plot(1:length(threshData_db), threshData_db(1:length(threshData_db)), '-', 'Color', colour_DB, 'Linewidth', 2); % Plain DBSCAN


% Plotting Energy Consumption Per Transmission
figure(7);
hold on;
plot(1:length(nrg_roc), nrg_roc(1:length(nrg_roc)), '-', 'Color', colour_RCA, 'Linewidth', 2); % RCA method
plot(1:length(nrg_rs), nrg_rs(1:length(nrg_rs)), '-', 'Color', colour_SRA, 'Linewidth', 2); % SRA method
plot(1:length(nrg_rr), nrg_rr(1:length(nrg_rr)), '-', 'Color', colour_RRA, 'Linewidth', 2); % SRA method
plot(1:length(nrg_db), nrg_db(1:length(nrg_db)), '-', 'Color', colour_DB, 'Linewidth', 2); % Plain DBSCAN


% Plotting Remaining Energy Per Round
figure(8);
hold on;
area(1:length(remainingEnergy_roc), remainingEnergy_roc(1:length(remainingEnergy_roc)), 'FaceColor', colour_RCA, 'FaceAlpha', 0.5); % RCA method
area(1:length(remainingEnergy_rs), remainingEnergy_rs(1:length(remainingEnergy_rs)), 'FaceColor', colour_SRA, 'FaceAlpha', 0.5); % SRA method
area(1:length(remainingEnergy_rr), remainingEnergy_rr(1:length(remainingEnergy_rr)), 'FaceColor', colour_RRA, 'FaceAlpha', 0.5); % RRA method
area(1:length(remainingEnergy_db), remainingEnergy_db(1:length(remainingEnergy_db)), 'FaceColor', colour_DB, 'FaceAlpha', 0.5); % Plain DBSCAN


% Plotting Average Backbone Path Length Per Round
figure(9);
hold on;
plot(1:length(abpl_roc), abpl_roc(1:length(abpl_roc)), '-', 'Color', colour_RCA, 'Linewidth', 2); % RCA method
plot(1:length(abpl_rs), abpl_rs(1:length(abpl_rs)), '-', 'Color', colour_SRA, 'Linewidth', 2); % SRA method
plot(1:length(abpl_rr), abpl_rr(1:length(abpl_rr)), '-', 'Color', colour_RRA, 'Linewidth', 2); % RRA method
plot(1:length(abpl_db), abpl_db(1:length(abpl_db)), '-', 'Color', colour_DB, 'Linewidth', 2); % Plain DBSCAN


% Plotting Longest Shortest Path Length Per Round
figure(10);
hold on;
plot(1:length(lsp_roc), lsp_roc(1:length(lsp_roc)), '-', 'Color', colour_RCA, 'Linewidth', 2); % RCA method
plot(1:length(lsp_rs), lsp_rs(1:length(lsp_rs)), '-', 'Color', colour_SRA, 'Linewidth', 2); % SRA method
plot(1:length(lsp_rr), lsp_rr(1:length(lsp_rr)), '-', 'Color', colour_RRA, 'Linewidth', 2); % RRA method
plot(1:length(abpl_db), abpl_db(1:length(abpl_db)), '-', 'Color', colour_DB, 'Linewidth', 2); % Plain DBSCAN

% figure(23); - done later after the 5 algos are also implemnted
% data = [firstNodeDead_roc, firstNodeDead_rs, firstNodeDead_rr;
%     halfNodesDead_roc, halfNodesDead_rs, halfNodesDead_rr;
%     allNodesDead_roc, allNodesDead_rs, allNodesDead_rr];
% 
% 
% bar(data);
% 
% set(gca, 'XTickLabel', {'First Node Dead', 'Half Nodes Dead', 'All Nodes Dead'});
% 
% legend({'RCA Method', 'SRA Method', 'RRA Method'}, 'Location', 'northwest');
% 
% title({'COMPARISON'; 'Network Status'});
% xlabel('Network Dead');
% ylabel('# Rounds');


networkLiveData_RCA = [firstNodeDead_roc, allNodesDead_roc];
networkLiveData_SRA = [firstNodeDead_rs, allNodesDead_rs];
networkLiveData_RRA = [firstNodeDead_rr, allNodesDead_rr];
networkLiveData_DB = [firstNodeDead_db, allNodesDead_db];


% networkLiveData_RCA = [firstNodeDead_roc, quarterNodesDead_roc, halfNodesDead_roc, allNodesDead_roc];
% networkLiveData_SRA = [firstNodeDead_rs, quarterNodesDead_rs, halfNodesDead_rs, allNodesDead_rs];
% networkLiveData_RRA = [firstNodeDead_rr, quarterNodesDead_rr, halfNodesDead_rr, allNodesDead_rr];
% networkLiveData_DB = [firstNodeDead_db, quarterNodesDead_db, halfNodesDead_db, allNodesDead_db];

% figure(10);
% x = categorical({'First Dead Node', 'Half Nodes Dead', 'All Nodes Dead'});
% x = reordercats(x, {'First Dead Node', 'Half Nodes Dead', 'All Nodes Dead'});
% y = [networkLiveData_RCA; networkLiveData_SRA; networkLiveData_RRA;];
% g = bar(x, y, 'grouped');
% 
% % RCA : -b
% % SRA : -r
% % RRA : -g
% 
% set(g(1), 'FaceColor', 'b');
% set(g(2), 'FaceColor', 'r');
% set(g(3), 'FaceColor', 'g');
% 
% l = {'RCA Method', 'SRA Method', 'RRA Method', };
% legend(l, 'Location', 'NorthWest');
% 
% title ({'COMPARISON', 'Network Status'; })
% xlabel 'Network Dead';
% ylabel '# Rounds';



%% Function Implementations for RCA, SRA, RRA - MCDA
function SN = resetNodes(n, Eo, sinkx, sinky, pos, DistMat, Eps)
% RESETNODES Initializes or resets the properties of sensor nodes
% INPUTS:
%   n - Number of sensor nodes
%   Eo - Initial energy for each node
%   sinkx - x-coordinate of the sink
%   sinky - y-coordinate of the sink
%   eps - the epsilon neighbourhood accpring to DBSCAN
% OUTPUT:
%   SN - Array of sensor nodes with initialized properties

% Initialize the array of sensor nodes
SN(n) = struct('id', [], 'Energy', [], 'role', [], 'condition', [], 'dtch', [], 'dts', [], 'chid', [], 'ch_count', [], 'neighbours', []);

for i = 1:n
    % Initialize or reset node properties
    SN(i).x = pos(i).x;
    SN(i).y = pos(i).y;
    SN(i).id = i; % Sensor's ID number
    SN(i).Energy = Eo; % Initial energy
    SN(i).role = 0; % Node role (0: normal, 1: cluster head)
    SN(i).condition = 1; % Operational status (1: alive, 0: dead)
    SN(i).dtch = 0; % Distance to cluster head
    SN(i).dts = sqrt((sinkx - SN(i).x) ^ 2 + (sinky - SN(i).y) ^ 2); % Distance to sink (assuming SN(i).x and SN(i).y are initialized elsewhere)
    SN(i).chid = 0; % Node ID of the cluster head which the "i" normal node belongs to
    SN(i).ch_count = 0; % Number of times the node has become a cluster head
    SN(i).neighbours = find(DistMat(:,i)<=Eps);
end
end

function [FigNo, opNodes, dNodes, cNodes, remainingEnergy, abpl, lsp, nrg, threshData, firstNodeDead, quarterNodesDead, halfNodesDead, allNodesDead] = runSimulation(Eps, MinPts, FigNo, weights, DistMat, SN, Clust, Eo, n, noise_points_count, Eelec, Eamp, EDA, pkt_size, Tx_range, E_thresh)
opNodes = [];
dNodes = [];
cNodes = [];
threshData = [];
remainingEnergy = [];
% Energy transmitted per round
nrg = [];
% average backbone path length per round
abpl = [];
% longest shortest path length per round
lsp = [];
% count of the number of roudns that have taken place
rounds = 0;
% Starting total energy of number of grouped nodes, excluding the unclustered nodes
totalEnergy = (n - noise_points_count)* Eo;
% Number nodes we are starting with
operating_nodes = n;

stop_flag = 0;

% flags to note the rounds in which the action takes place
firstNodeDead = -1;
halfNodesDead = -1;
quarterNodesDead = -1;
allNodesDead = -1;

prevEnergy = totalEnergy;
remainingEnergy = [remainingEnergy, totalEnergy];

numClusters = max(Clust);
clusterStatus = true(1, numClusters);
while (operating_nodes > 0 && stop_flag == 0)
    if rounds ~= 1
        % Reapplying DBSCAN -  for next set of clustering
        [Clust, SN] = DBSCAN(DistMat, Eps, MinPts, SN); 
    end
    fprintf("round: %d Number of clusters: %d Number of alive nodes: %d Number of noise nodes: %d\n", rounds, max(Clust), operating_nodes, noise_points_count);
    % If number of derived clusters from DBSCAN clustering is 0, assume networ is dead & terminate loop
    if(max(Clust) == 0)
        % error("Number of clusters is 0");
        allNodesDead = rounds;
        break;
    end

    % Assigning Cluster Heads every round purely on the basis of number of neighbours 
    SN = electDbscanHeads(SN, Clust, DistMat);

    % Increment the round
    rounds = rounds + 1;

    % disp('RCA-SRA-RRA: ');
    % disp(rounds);


    % Normalize the parameters for each node
    for i = 1:n
        SN(i).role = 0; % reset the roles before doing the weighted score sum
        if SN(i).condition == 1  % Check if the node is alive
            % Normalize energy left
            normalized_energy = SN(i).Energy / Eo;

            % Normalize distance to sink
            normalized_dist_sink = 1 - (SN(i).dts / max([SN.dts]));

            % Calculate and normalize the average distance from all cluster members
            if SN(i).role == 1  % If the node is a cluster head
                cluster_members = [SN.chid] == i;
                avg_dist_cluster = mean(DistMat(i, cluster_members));
                normalized_avg_dist_cluster = 1 - (avg_dist_cluster / max(DistMat(:)));
            else
                normalized_avg_dist_cluster = 0;
            end

            % Normalize the number of times the node has become a cluster head
            normalized_ch_count = 1 - (SN(i).ch_count / rounds);

            % Score is calucated for alive nodes - which is later used to
            % elect CHs

            % Calculate the score for each node
            SN(i).score =   weights(1) * normalized_energy + ...
                weights(2) * normalized_dist_sink + ...
                weights(3) * normalized_avg_dist_cluster + ...
                weights(4) * normalized_ch_count;
        else
            SN(i).score = -1;  % Node is dead
        end
    end

    % Select cluster heads based on scores
    for cluster_id = 1:max(Clust)
        % clustering has been done - and the memebrs of a particular cluster are extracted
        members = find(Clust == cluster_id);
        % The alive members from that cluster are extracted
        alive_members = members([SN(members).score] > -1); % Filter out dead nodes

        % Checking if at least 1 member alive and max energy memeber is elected CH
        if ~isempty(alive_members)
            % get node with maximum score
            [~, max_idx] = max([SN(alive_members).score]);
            % get index of maximum score node
            cluster_head_id = alive_members(max_idx);

            % Assign the role to the cluster head
            SN(cluster_head_id).role = 1; % Cluster head - role = 1 -> CH, role = 0 -> Normal
            SN(cluster_head_id).chid = -1; % For cluster heads, the chid is set as -1
            SN(cluster_head_id).ch_count = SN(cluster_head_id).ch_count + 1; % Increment the CH count

            for idx = 1:length(members)
                member = members(idx);
                if member ~= cluster_head_id
                    SN(member).role = 0; % Normal node -> role 0
                    SN(member).chid = cluster_head_id; % Assign cluster head ID
                end
            end
            % if no alive members in that cluster - proclaim it dead
        else
            clusterStatus(cluster_id) = false; % Mark cluster as dead
        end
    end


    %%% Identify the Closest Cluster Head to the Sink %%%

    %%% Identify if closer to the sink or find the clostest cluster head
    cluster_head_ids = find([SN.role] == 1); % extract IDs of all cluster heads
    % This step will be executed for each cluster head
    for cluster_id = 1:max(Clust)
        ch_id = find(Clust == cluster_id, 1); % Find the cluster head for the current cluster
        if isempty(ch_id)
            % If no ch_id is found continue to the next iteration
            % because the cluster is now completely dead
            continue;
        end

        % Calculate the distance from the current CH to the sink
        d_to_sink = SN(ch_id).dts;

        if d_to_sink <= Tx_range  % If the CH is within range of the sink
            SN(ch_id).next_hop = -1; % Directly communicates with the sink
        else
            % Identify the closest CH to the sink within range
            possible_hops_init = cluster_head_ids(cluster_head_ids ~= ch_id);
            min_dist = inf;
            next_hop_id = -1;

            for i = 1:length(possible_hops_init)
                potential_hop_id = possible_hops_init(i);
                d_ch_to_sink = SN(potential_hop_id).dts; % Distance from potential hop CH to the sink
                d_ch_to_ch = DistMat(ch_id, potential_hop_id); % Distance between CHs
                % condition only fullfilled if CH at a distance smaller
                % than tranmission range and less than a perviously found
                % CH is discovered
                if d_ch_to_sink < min_dist && d_ch_to_ch <= Tx_range
                    min_dist = d_ch_to_sink;
                    next_hop_id = potential_hop_id;
                end
            end

            SN(ch_id).next_hop = next_hop_id; % Set the next hop CH
        end
    end

    totalTransmissions = 0;

    %%% Multi-Hop Transmission with Dynamic Next Hop Selection %%%
    for i = 1:n
        if SN(i).condition == 1
            if SN(i).role == 0 && SN(i).chid > 0  % Non-cluster head node
                ch_id = SN(i).chid;
                d_to_ch = DistMat(i, ch_id);
                ETx = Eelec * pkt_size + Eamp * pkt_size * d_to_ch^2; % Energy to transmit to the cluster head
                SN(i).Energy = SN(i).Energy - ETx;

                if SN(i).Energy < Eo * E_thresh
                    SN(i).condition = 0;
                end

                if firstNodeDead == -1 && SN(i).condition == 0
                    firstNodeDead = rounds;
                end
                totalEnergy = totalEnergy - ETx;
                % fprintf("totalEnergy: %f, Etx: %f\n", totalEnergy, ETx);
                totalTransmissions = totalTransmissions + 1;

            elseif SN(i).role == 1 % Cluster head node
                current_ch_id = i;

                % Aggregate data from cluster members
                cluster_members = find([SN.chid] == current_ch_id);
                num_cluster_members = length(cluster_members);
                total_pkt_size = pkt_size*num_cluster_members;
                ERx_energy = Eelec * total_pkt_size; % recieving from all cluster members
                EDA_energy = EDA * pkt_size;
                SN(i).Energy = SN(i).Energy -  ERx_energy - EDA_energy;
                if SN(i).Energy <= Eo*E_thresh
                    SN(i).condition = 0;
                end
                visited_nodes = [];

                reached_sink = 0;
                % Multi-hop transmission to the sink with dynamic next hop selection
                while reached_sink ~= 1
                    if SN(current_ch_id).condition == 0 % Check if the current CH is dead
                        break;
                    end

                    visited_nodes = [visited_nodes, current_ch_id];
                    d_to_next_hop = SN(current_ch_id).dts; % Initially distance to the sink
                    next_hop_id = SN(current_ch_id).next_hop;

                    if next_hop_id ~= -1 & ~ismember(next_hop_id, visited_nodes)
                        % Check if the next hop is alive
                        if SN(next_hop_id).condition == 1
                            d_to_next_hop = DistMat(current_ch_id, next_hop_id);
                        else
                            % Next hop is dead, find a new next hop
                            possible_hops = find([SN.role] == 1 & [SN.condition] == 1 & (1:n) ~= current_ch_id);
                            min_dist = inf;
                            new_next_hop_id = -1;

                            for j = 1:length(possible_hops)
                                potential_hop_id = possible_hops(j);
                                d_ch_to_sink = SN(potential_hop_id).dts;
                                d_ch_to_ch = DistMat(current_ch_id, potential_hop_id);

                                if d_ch_to_sink < min_dist && d_ch_to_ch <= Eps
                                    min_dist = d_ch_to_sink;
                                    new_next_hop_id = potential_hop_id;
                                end
                            end

                            SN(current_ch_id).next_hop = new_next_hop_id;
                            next_hop_id = new_next_hop_id;

                            if next_hop_id == -1
                                % No valid next hop found
                                if SN(current_ch_id).dts <= Tx_range
                                    % Sink is within range, transmit directly to sink
                                    d_to_next_hop = SN(current_ch_id).dts;
                                    reached_sink = 1;

                                else
                                    % Sink is too far away, transmission fails (drop the packet)
                                    break;
                                end

                            else
                                d_to_next_hop = DistMat(current_ch_id, next_hop_id);
                            end
                        end
                        % if at any point next_hop_id = -1 then assume it will reach sink somehow
                        % or if it's a cycle of reachable nodes then assume the same as above
                    else
                        reached_sink = 1; % Reached the sink
                    end

                    ETx_to_next_hop = Eelec * total_pkt_size + Eamp * total_pkt_size * d_to_next_hop^2;
                    SN(current_ch_id).Energy = SN(current_ch_id).Energy - ETx_to_next_hop;
                    if SN(current_ch_id).Energy < Eo*E_thresh
                        SN(current_ch_id).condition = 0;
                    end
                    totalTransmissions = totalTransmissions + 1; % Increment transmission counter

                    if reached_sink ~= 1
                        current_ch_id = next_hop_id; % Move to the next hop

                        % Consume the receiving energy
                        SN(current_ch_id).Energy = SN(current_ch_id).Energy - Eelec * total_pkt_size;
                        if SN(current_ch_id).Energy <= Eo*E_thresh
                            SN(current_ch_id).condition = 0;
                        end
                    end
                end
                % when firstNodeDies(==-1, means no node has died before) make a note of teh round it dies in
                if firstNodeDead == -1 && SN(i).condition == 0
                    firstNodeDead = rounds;
                end

            end
        end

        % if SN(i).Energy < 0
        %     fprintf('Negative %d with %f\n', i, SN(i).Energy);
        % end
    end

    % Track the remaining total energy (include only alive nodes to avoid negative energies)
    % Not the best way to do this again
    total_remaining_energy = sum([SN([SN(:).condition] == 1 & [SN(:).chid] ~= 0).Energy]);
    remainingEnergy = [remainingEnergy, total_remaining_energy];

    nrg = [nrg, prevEnergy - total_remaining_energy];

    prevEnergy = total_remaining_energy;

    % Store average backbone path length per round
    avg_bpl = mean([SN([SN.role] == 1).dts]);
    abpl = [abpl, avg_bpl];

    % Store longest shortest path length per round
    lsp_round = max([SN([SN.role] == 1).dts]);
    lsp = [lsp, lsp_round];

    % Update the number of operating nodes
    operating_nodes = sum([SN(:).condition] == 1 & [SN(:).chid] ~= 0);
    opNodes = [opNodes, operating_nodes]; % Track operational nodes

    % Track count of dead nodes
    dead_nodes = sum([SN(:).condition] == 0 & [SN(:).chid] ~= 0);
    dNodes = [dNodes, dead_nodes];

    % Track the number of clusters
    numClustersAlive = max(Clust);
    cNodes = [cNodes, numClustersAlive];

    % Track the number of transmissions to the sink
    transmissions = totalTransmissions;
    threshData = [threshData, transmissions];

    % List of titles for the figure headings
    titleList = ["RRA ", "RCA ", "SRA "];

    % plotting the first clustering
    if rounds == 1
        % Sink nodes definition
        sinkx = 990;
        sinky = 990;
        figure(FigNo);
        hold on;
        % Define colors for different clusters
        colors = lines(max(Clust)+1); % Lines generate different colors
        htmlGray = [0.35 0.35 0.35];
        for i = 1:n
            if SN(i).condition == 1 % Alive node
                if Clust(i) == 0
                    % Gray cross for noise points
                    plot(SN(i).x, SN(i).y, 'x', 'Color', htmlGray,  'MarkerSize', 8, 'LineWidth', 3);
                else
                    % Plot clustered points
                    if SN(i).role == 1 % Cluster Head - trianagle with the cluster's colour
                        plot(SN(i).x, SN(i).y, '^', 'Color', colors(Clust(i), :), 'MarkerSize', 10, 'LineWidth', 2);
                    else % Normal node (Cluster member) - circle with cluster's colour
                        plot(SN(i).x, SN(i).y, 'o', 'Color', colors(Clust(i), :), 'MarkerSize', 8, 'LineWidth', 2);
                        if SN(i).chid > 0 % Ensure that this node has a valid cluster head ID
                            chIndex = SN(i).chid; % Get the index of the cluster head
                            plot([SN(i).x, SN(chIndex).x], [SN(i).y, SN(chIndex).y], 'm--'); % Magenta dashed line
                        end
                    end
                end
            else % Dead nodes
                % Black cross for dead nodes
                plot(SN(i).x, SN(i).y, 'kx', 'MarkerSize', 6, 'LineWidth', 2);
            end
        end

        % Plot the sink location
        plot(sinkx, sinky, '*k', 'MarkerSize', 10); % Black star for sink
      
        % index calculation to access Title list 
        % since figure number of type 11,13,15 - then (11-9)/2, (13-9)/2...
        % onwards will give us 1, 2, 3

        figIndex = (FigNo-9)/2;

        % Add titles and labels
        title(strcat(titleList(figIndex), 'Network Status After 1st Cluster Head Election'));
        xlabel('X-coordinate (Meters)');
        ylabel('Y-coordinate (Meters)');

        % Initialize handles for legend
        hClusterHead = plot(nan, nan, 'k^', 'MarkerSize', 10, 'LineWidth', 2); % Triangle for Cluster Head
        hClusterMember = plot(nan, nan, 'ko', 'MarkerSize', 8, 'LineWidth', 2); % Circle for Cluster Member
        hUnreachableNodes = plot(nan, nan, 'x', 'Color', htmlGray,  'MarkerSize', 8, 'LineWidth', 3); % Gray cross for unreachable nodes
        hDeadNode = plot(nan, nan, 'kx', 'MarkerSize', 6, 'LineWidth', 2); % Black cross for dead nodes
        hSink = plot(nan, nan, '*k', 'MarkerSize', 10); % Black star for Sink

        % Create custom legend using handles
        legend([hClusterHead, hClusterMember,hUnreachableNodes, hDeadNode, hSink], {'Cluster Heads', 'Cluster Members', 'Unreachable Nodes', 'Dead Nodes', 'Sink'}, ...
            'Location', 'Best');

        grid on; % Adding grid for better visibility
        hold off; % Release the hold on current figure
        
        % Updating figure number
        FigNo = FigNo+1;
        
    end

    % For when half of the network dies
    if halfNodesDead == -1 && operating_nodes <= (n - noise_points_count)/2
        % fprintf("%d, %d, %d \n", rounds, n - noise_points_count, operating_nodes);
        halfNodesDead = rounds;
    end
    
    % For when quarter of the network dies
    if quarterNodesDead == -1 && operating_nodes <= (n - noise_points_count)*3/4
        % fprintf("%d, %d, %d \n", rounds, n - noise_points_count, operating_nodes);
        quarterNodesDead = rounds;
        
        % Sink nodes definition
        sinkx = 990;
        sinky = 990;

        % Plot all nodes at half nodes alive mark
        figure(FigNo);
        hold on;
        % Define colors for different clusters
        colors = lines(max(Clust)+1); % Lines generate different colors
        for i = 1:n
            if SN(i).condition == 1 % Alive node
                if Clust(i) == 0
                    % Gray cross for noise points
                    htmlGray = [0.35 0.35 0.35];
                    plot(SN(i).x, SN(i).y, 'x', 'Color', htmlGray,  'MarkerSize', 8, 'LineWidth', 3);
                else
                    % Plot clustered points
                    if SN(i).role == 1 % Cluster Head - trianagle with the cluster's colour
                        plot(SN(i).x, SN(i).y, '^', 'Color', colors(Clust(i), :), 'MarkerSize', 10, 'LineWidth', 2); % Red circle for Cluster Heads
                    else % Normal node (Cluster member) - circle with cluster's colour
                        plot(SN(i).x, SN(i).y, 'o', 'Color', colors(Clust(i), :), 'MarkerSize', 8, 'LineWidth', 2);
                        if SN(i).chid > 0 % Ensure that this node has a valid cluster head ID
                            chIndex = SN(i).chid; % Get the index of the cluster head
                            plot([SN(i).x, SN(chIndex).x], [SN(i).y, SN(chIndex).y], 'm--'); % Magenta dashed line
                        end
                    end
                end
            else % Dead nodes
                % Black cross for dead nodes
                plot(SN(i).x, SN(i).y, 'kx', 'MarkerSize', 6, 'LineWidth', 2);
            end
        end

        % Plot the sink location
        plot(sinkx, sinky, '*k', 'MarkerSize', 10); % Black star for sink

        % index calculation to access Title list 
        % since figure number of type 12,14,16 - then (12-10)/2, (14-10)/2...
        % onwards will give us 1, 2, 3

        figIndex = (FigNo - 10)/2;

        % Add titles and labels
        title(strcat(titleList(figIndex), 'Network Status When >= 1/4th Nodes aAre Dead'));  
        xlabel('X-coordinate (Meters)');
        ylabel('Y-coordinate (Meters)');

        % Initialize handles for legend
        hClusterHead = plot(nan, nan, 'k^', 'MarkerSize', 10, 'LineWidth', 2); % Triangle for Cluster Head
        hClusterMember = plot(nan, nan, 'ko', 'MarkerSize', 8, 'LineWidth', 2); % Circle for Cluster Member
        hUnreachableNodes = plot(nan, nan, 'x', 'Color', htmlGray,  'MarkerSize', 8, 'LineWidth', 3); % Gray cross for unreachable nodes
        hDeadNode = plot(nan, nan, 'kx', 'MarkerSize', 6, 'LineWidth', 2); % Black cross for dead nodes
        hSink = plot(nan, nan, '*k', 'MarkerSize', 10); % Black star for Sink

        % Create custom legend using handles
        legend([hClusterHead, hClusterMember,hUnreachableNodes, hDeadNode, hSink], {'Cluster Heads', 'Cluster Members', 'Unreachable Nodes', 'Dead Nodes', 'Sink'}, ...
            'Location', 'Best');

        grid on; % Adding grid for better visibility
        hold off; % Release the hold on current figure
        
        % Updating figure number
        FigNo = FigNo+1;
        
    end

    

    % Stop the simulation if all nodes are dead or certain condition is met
    if operating_nodes == 0
        allNodesDead = rounds;
        stop_flag = 1;
    end
end
end

function [Clust, SN] = DBSCAN(DistMat,Eps,MinPts, SN)

% Input: DistMat, Eps, MinPts
% DistMat: A N*N distance matrix, the (i,j) element contains the distance
% from point-i to point-j.
% Eps:     A scalar value for Epsilon-neighborhood threshold.
% MinPts:  A scalar value for minimum points in Eps-neighborhood that holds
% the core-point condition. - core point - cluster memebers
% SN - Status of various parameters of the nodes 

% Output: Clust
% Clust:  A N*1 vector describes the cluster membership for each point. 0 is
% reserved for NOISE.
% SN - Status of various parameters of the nodes 


% what is done by code below
% size(DistMat, 1):
% This function call retrieves the number of rows in the matrix DistMat.
% The size function returns a vector containing the dimensions of the array, 
% and the second argument 1 specifies that we want the size of the first dimension (the number of rows).

% zeros(size(DistMat, 1), 1):
% This part creates a column vector of zeros with a length equal to the number of rows in DistMat. 
% The zeros function generates an array filled with zeros, and here it is specified to be a column vector (with one column).

% - 1:
% After creating the column vector of zeros, this operation subtracts 1 from each element of that vector.
% Since the vector was initially filled with zeros, subtracting 1 will result in a column vector where all elements are now -1.
Clust = zeros(size(DistMat,1),1)-1;
% ^^^For code above - intiialy set to -1 - unclassified. Other points mean 0 - noise, >=1 - cluster allotted


ClusterId=1;

%randomly choose the visiting order
VisitSequence=randperm(length(Clust));

for i=1:length(Clust)
    % For each point, check if it is not visited yet (unclassified)
    pt=VisitSequence(i);
    if Clust(pt) == -1
        %Iteratively expand the cluster through density-reachability
        [Clust,isnoise]=ExpandCluster(DistMat,pt,ClusterId,Eps,MinPts,Clust, SN);
        if ~isnoise % as classified by the expand cluster algo
            % m-th cluster id allotted, so move to (m+1)-th cluster
            ClusterId=ClusterId+1;
        end
    end
end

end

function [Clust, isnoise, SN]=ExpandCluster(DistMat, pt, ClusterId, Eps, MinPts, Clust, SN)

% Initial seeds extracted from neighbors of the point 
extracted_seeds = SN(pt).neighbours;

% Filter seeds based on condition of being alive
valid_indices = arrayfun(@(p) SN(p).condition == 1, extracted_seeds);
seeds = extracted_seeds(valid_indices);

% % Renove from here since it was also taking dead nodes as seeds
% %region query - finding all possible points within epsilon range for a particular point
% seeds = SN(pt).neighbours;

% SN(k).neighbours is find(DistMat(:,k)<=Eps)

% if minpts =3, then it looks if it has 2 nearby points since - the
% dist(i,i) is always = 0, so it will always be counted
if length(seeds)<MinPts
    Clust(pt) = 0; % 0 reserved for noise
    SN(pt).chid = 0;
    isnoise=true;
    return
else
    for i = 1:length(seeds)
        Clust(seeds(i)) = ClusterId;
        SN(seeds(i)).chid = ClusterId;
    end
    %delete the core point
    seeds=setxor(seeds,pt);
    while ~isempty(seeds)
        currentP=seeds(1);
        % region query for cluster's other nodes - looking for other nodes in epsilon neighborhood
        result=find(DistMat(:,currentP)<=Eps);
        if length(result) >= MinPts
            for i=1:length(result)
                resultP=result(i);
                if Clust(resultP)==-1||Clust(resultP)==0 % unclassified or noise
                    if Clust(resultP)==-1 %unclassified
                        % if unclassfied, add to seeds to visit that node
                        % as well
                        seeds=[seeds(:);resultP]; 
                    end
                    % if eitehr unclassified or noise - allotted to cluster
                    Clust(resultP)=ClusterId;
                    SN(resultP).chid = ClusterId;
                end 
            end
        end
        seeds=setxor(seeds,currentP);
    end
    isnoise=false;
    return 
end
end

function SN = electDbscanHeads(SN, Clust, DistMat)
% Function to elect cluster heads based on the number of neighbors.
% In case of a tie, the node with the smaller ID is chosen.

uniqueClusters = unique(Clust);
uniqueClusters(uniqueClusters == 0) = []; % Remove noise cluster (0)

for idx = 1:length(uniqueClusters)
    cluster_id = uniqueClusters(idx);
    members = find(Clust == cluster_id); % Get all nodes in that cluster

    if isempty(members)
        continue; % Skip if no members found
    end

    % Get the number of neighbors for each member
    num_neighbors = arrayfun(@(i) length(SN(i).neighbours), members);

    % Find the node(s) with the maximum number of neighbors
    max_neighbors = max(num_neighbors);
    candidate_ids = members(num_neighbors == max_neighbors);

    % If multiple candidates, choose the one with the smallest node ID
    CH_id = min(candidate_ids);

    % Assign roles: 1 for cluster head, 0 for normal nodes
    for i = 1:length(members)
        if members(i) == CH_id
            SN(members(i)).role = 1; % Cluster Head
            SN(members(i)).chid = CH_id; % Assign it's own ID as CH ID
            SN(members(i)).ch_count = SN(members(i)).ch_count + 1; % Number of times node becomes CH
            SN(members(i)).dtch = 0; % Distance from CH(itself) is 0
        else
            SN(members(i)).role = 0; % Normal Node
            SN(members(i)).chid = CH_id; % Assign CH ID
            SN(members(i)).dtch = DistMat(i,CH_id); % Distance from CH
        end
    end
end
end

function [opNodes, dNodes, cNodes, remainingEnergy, abpl, lsp, nrg, threshData, firstNodeDead, quarterNodesDead, halfNodesDead, allNodesDead] = runDbscanSimulation(SN, Clust, DistMat, Eo, Eps, MinPts, n, noise_points_count, Eelec, Eamp, EDA, pkt_size, Tx_range, E_thresh)
opNodes = [];
dNodes = [];
cNodes = [];
threshData = [];
remainingEnergy = [];
% Energy transmitted per round
nrg = [];
% average backbone path length per round
abpl = [];
% longest shortest path length per round
lsp = [];
% count of the number of roudns that have taken place
rounds = 0;
% Starting total energy of number of grouped nodes, excluding the unclustered nodes
totalEnergy = (n - noise_points_count)* Eo;
% Number nodes we are starting with - assuming all can be classified into clusters
operating_nodes = n;

stop_flag = 0;

% flags to note the rounds in which the death event takes place
firstNodeDead = -1;
halfNodesDead = -1;
quarterNodesDead = -1;
allNodesDead = -1;

prevEnergy = totalEnergy;
remainingEnergy = [remainingEnergy, totalEnergy];


%  Simulation loop until all nodes are dead
while (operating_nodes > 0 && stop_flag == 0)
    if rounds ~= 1
        % Reapplying DBSCAN -  for next set of clustering
        [Clust, SN] = DBSCAN(DistMat, Eps, MinPts, SN); 
    end
    fprintf("round: %d Number of clusters: %d Number of alive nodes: %d Number of noise nodes: %d\n", rounds, max(Clust), operating_nodes, noise_points_count);
    % If number of derived clusters from DBSCAN clustering is 0, terminate loop
    if(max(Clust) == 0)
        % error("Number of clusters is 0");
        allNodesDead = rounds; 
        break;
    end

    % Assigning Cluster Heads every round purely on the basis of number of neighbours 
    SN = electDbscanHeads(SN, Clust, DistMat);

    rounds = rounds + 1;

    %%% Identify if closer to the sink or find the clostest cluster head
    cluster_head_ids = find([SN.role] == 1); % extract IDs of all cluster heads
    % This step will be executed for each cluster head
    for cluster_id = 1:max(Clust)
        ch_id = find(Clust == cluster_id, 1); % Find the cluster head for the current cluster
        if isempty(ch_id)
            % If no ch_id is found continue to the next iteration
            % because the cluster is now completely dead
            continue;
        end

        % Calculate the distance from the current CH to the sink
        d_to_sink = SN(ch_id).dts;

        if d_to_sink <= Tx_range  % If the CH is within range of the sink
            SN(ch_id).next_hop = -1; % Directly communicates with the sink
        else
            % Identify the closest CH to the sink within range
            possible_hops_init = cluster_head_ids(cluster_head_ids ~= ch_id);
            min_dist = inf;
            next_hop_id = -1;

            for i = 1:length(possible_hops_init)
                potential_hop_id = possible_hops_init(i);
                d_ch_to_sink = SN(potential_hop_id).dts; % Distance from potential hop CH to the sink
                d_ch_to_ch = DistMat(ch_id, potential_hop_id); % Distance between CHs
                % condition only fullfilled if CH at a distance smaller
                % than tranmission range and less than a perviously found
                % CH is discovered
                if d_ch_to_sink < min_dist && d_ch_to_ch <= Tx_range
                    min_dist = d_ch_to_sink;
                    next_hop_id = potential_hop_id;
                end
            end

            SN(ch_id).next_hop = next_hop_id; % Store the next hop CH
        end
    end

    totalTransmissions = 0;
    
    % % To stop the code when it runs for too long
    % if(rounds > 25000)
    %     operating_nodes
    %     prevEnergy
    %     error("too many iterations");
    % end

    % Energy consumption and transmission tracking
    for i = 1:n
        if SN(i).condition == 1 % Node is alive

            if SN(i).role == 0 && SN(i).chid ~= 0  % Normal node (Non-CH)
                ch_id = SN(i).chid;
                d_to_ch = DistMat(i, ch_id);
                ETx = Eelec * pkt_size + Eamp * pkt_size * d_to_ch^2;
                SN(i).Energy = SN(i).Energy - ETx;
                
                % Networks energy and transmissions
                totalEnergy = totalEnergy - ETx;
                totalTransmissions = totalTransmissions + 1;

                % if energy falls below threshold - procalim dead
                if SN(i).Energy < Eo * E_thresh
                    SN(i).condition = 0;
                    % Not removing the energy of "dead" node from the system since it still had that much energy left
                end

            elseif SN(i).role == 1  % Cluster Head
                % 
                % % Aggregate data from cluster members
                % cluster_members = find([SN.chid] == current_ch_id;
                % num_cluster_members = length(cluster_members);
                % total_pkt_size = pkt_size * num_cluster_members; % receiving from all cluster members
                % ERx_energy = Eelec * total_pkt_size;
                % EDA_energy = EDA * total_pkt_size;
                % 
                % SN(i).Energy = SN(i).Energy - ERx_energy - EDA_energy;
                % 
                % if SN(i).Energy <= Eo*E_thresh
                %     SN(i).condition = 0;
                % end
                % visited_nodes = [];
                % 
                % % Transmit aggregated data to sink or next-hop CH
                % if SN(i).dts <= Tx_range
                %     % Direct transmission to sink
                %     ETx_to_sink = Eelec * total_pkt_size + Eamp * total_pkt_size * (SN(i).dts)^2;
                %     SN(i).Energy = SN(i).Energy - ETx_to_sink;
                % else
                %     % Multi-hop transmission to the closest CH
                %     cluster_head_ids = find([SN.role] == 1 & [SN.condition] == 1);
                %     possible_hops = cluster_head_ids(cluster_head_ids ~= i);
                % 
                %     min_dist = inf;
                %     next_hop_id = -1;
                %     for j = 1:length(possible_hops)
                %         potential_hop_id = possible_hops(j);
                %         d_ch_to_sink = SN(potential_hop_id).dts;
                %         d_ch_to_ch = DistMat(i, potential_hop_id);
                % 
                %         if d_ch_to_sink < min_dist && d_ch_to_ch <= Tx_range
                %             min_dist = d_ch_to_sink;
                %             next_hop_id = potential_hop_id;
                %         end
                %     end
                % 
                %     if next_hop_id ~= -1
                %         % Multi-hop transmission
                %         d_to_next_hop = DistMat(i, next_hop_id);
                %         ETx_to_next_hop = Eelec * total_pkt_size + Eamp * total_pkt_size * d_to_next_hop^2;
                %         SN(i).Energy = SN(i).Energy - ETx_to_next_hop;
                %     end
                % end

                     current_ch_id = i;

                % Aggregate data from cluster members
                cluster_members = find([SN.chid] == current_ch_id);
                num_cluster_members = length(cluster_members);
                total_pkt_size = pkt_size*num_cluster_members;
                ERx_energy = Eelec * total_pkt_size; % recieving from all cluster members
                EDA_energy = EDA * pkt_size;
                SN(i).Energy = SN(i).Energy -  ERx_energy - EDA_energy;
                if SN(i).Energy <= Eo*E_thresh
                    SN(i).condition = 0;
                end
                visited_nodes = [];

                reached_sink = 0;
                % Multi-hop transmission to the sink with dynamic next hop selection
                while reached_sink ~= 1
                    if SN(current_ch_id).condition == 0 % Check if the current CH is dead
                        break;
                    end

                    visited_nodes = [visited_nodes, current_ch_id];
                    d_to_next_hop = SN(current_ch_id).dts; % Initially distance to the sink
                    next_hop_id = SN(current_ch_id).next_hop;

                    if next_hop_id ~= -1 & ~ismember(next_hop_id, visited_nodes)
                        % Check if the next hop is alive and not previously visited
                        if SN(next_hop_id).condition == 1
                            d_to_next_hop = DistMat(current_ch_id, next_hop_id);
                        else
                            % Next hop is dead, find a new next hop
                            possible_hops = find([SN.role] == 1 & [SN.condition] == 1 & (1:n) ~= current_ch_id);
                            min_dist = inf;
                            new_next_hop_id = -1;

                            for j = 1:length(possible_hops)
                                potential_hop_id = possible_hops(j);
                                d_ch_to_sink = SN(potential_hop_id).dts;
                                d_ch_to_ch = DistMat(current_ch_id, potential_hop_id);

                                if d_ch_to_sink < min_dist && d_ch_to_ch <= Tx_range
                                    min_dist = d_ch_to_sink;
                                    new_next_hop_id = potential_hop_id;
                                end
                            end

                            SN(current_ch_id).next_hop = new_next_hop_id;
                            next_hop_id = new_next_hop_id;

                            if next_hop_id == -1
                                % No valid next hop found
                                if SN(current_ch_id).dts <= Tx_range
                                    % Sink is within range, transmit directly to sink
                                    d_to_next_hop = SN(current_ch_id).dts;
                                    reached_sink = 1;

                                else
                                    % Sink is too far away, transmission fails (drop the packet)
                                    break;
                                end

                            else
                                d_to_next_hop = DistMat(current_ch_id, next_hop_id);
                            end
                        end
                        % if at any point next_hop_id = -1 then assume it will reach sink somehow
                        % or if it's a cycle of reachable nodes then assume the same as above
                    else
                        reached_sink = 1; % Reached the sink
                    end

                    ETx_to_next_hop = Eelec * total_pkt_size + Eamp * total_pkt_size * d_to_next_hop^2;
                    SN(current_ch_id).Energy = SN(current_ch_id).Energy - ETx_to_next_hop;
                    if SN(current_ch_id).Energy < Eo*E_thresh
                        SN(current_ch_id).condition = 0;
                    end
                    totalTransmissions = totalTransmissions + 1; % Increment transmission counter

                    if reached_sink ~= 1
                        current_ch_id = next_hop_id; % Move to the next hop

                        % Consume the receiving energy
                        SN(current_ch_id).Energy = SN(current_ch_id).Energy - Eelec * total_pkt_size;
                        if SN(current_ch_id).Energy <= Eo*E_thresh
                            SN(current_ch_id).condition = 0;
                        end
                    end
                end

                % if energy falls below threshold - consider dead
                if SN(i).Energy <= Eo * E_thresh
                    SN(i).condition = 0;
                end

                totalTransmissions = totalTransmissions + 1;
            end
            % if node proclaimed dead during it's transmission
            if SN(i).condition == 0
                % Mark the death of the 1st node
                if firstNodeDead == -1
                    firstNodeDead = rounds;
                end
                % remove all Cluster affiliation
                SN(i).cluster = 0;
                Clust(i) = 0;
                SN(i).dtch = 0;
                % Loop through each of i's neighbours and remove node i from it
                for index = 1:length(SN(i).neighbours)
                    node = SN(i).neighbours(index);
                    % if teh nide discover itself as teh neighbour, skip it 
                    % since that will change the indexing for the array of 
                    % SN(i).neighbours leading to elements access issues
                    % and anyways at the end neighbours of i are nullified
                    if(node == i) 
                        continue;
                    end
                    SN(node).neighbours(SN(node).neighbours == i) = [];
                end
                % Nullify all neighbours
                SN(i).neighbours = [];
            end
        end
    end

    % Track the remaining total energy (include only alive nodes to avoid negative energies)
    % Not the best way to do this again
    total_remaining_energy = sum([SN([SN(:).condition] == 1 & [SN(:).chid] ~= 0).Energy]);
    remainingEnergy = [remainingEnergy, total_remaining_energy];

    % Energy consumed
    nrg = [nrg, prevEnergy - total_remaining_energy];
    % energy of current round will become that of prev round when we move to next round
    prevEnergy = total_remaining_energy;

    % Store average backbone path length per round
    avg_bpl = mean([SN([SN.role] == 1).dts]);
    abpl = [abpl, avg_bpl];

    % Store longest shortest path length per round
    lsp_round = max([SN([SN.role] == 1).dts]);
    lsp = [lsp, lsp_round];

    % Update the number of operating nodes
    operating_nodes = sum([SN(:).condition] == 1 & [SN(:).chid] ~= 0);
    opNodes = [opNodes, operating_nodes]; % Track operational nodes

    % Track count of dead nodes
    dead_nodes = sum([SN(:).condition] == 0 & [SN(:).chid] ~= 0);
    dNodes = [dNodes, dead_nodes];

    % Track the number of clusters
    numClustersAlive = max(Clust);
    cNodes = [cNodes, numClustersAlive];

    % Track the number of transmissions to the sink
    transmissions = totalTransmissions;
    threshData = [threshData, transmissions];

    % For when half of the network dies
    if halfNodesDead == -1 && operating_nodes <= (n - noise_points_count)/2
        % fprintf("%d, %d, %d \n", rounds, n - noise_points_count, operating_nodes);
        halfNodesDead = rounds;
    end

    % Record when quarter of the nodes are dead
    if quarterNodesDead == -1 && operating_nodes <= (n - noise_points_count)*3/4
        quarterNodesDead = rounds;
    end

    % % Stop simulation if all nodes are dead
    % if operating_nodes == 0
    %     allNodesDead = rounds;
    %     stop_flag = 1;
    % end
end
end


%% 3 Algos (HEED, LEACH-C, LEACH) setup %%

% Establish the maximum communication range
maxCommRange = 100;

x = 0; % added for better display results of the plot
y = 0; % added for better display results of the plot
% Number of Nodes in the field %
n = 100;
% Number of Dead Nodes in the beggining %
dead_nodes = 0;
% Coordinates of the Sink (location is predetermined in this simulation) %
sinkx = 990;
sinky = 990;
%%% Energy Values %%%
% Initial Energy of a Node (in Joules) %
Eo = 0.1; % units in Joules
% Energy required to run circuity (both for transmitter and receiver) %
Eelec = 15 * 10 ^ (-9); % units in Joules/bit
ETx = 15 * 10 ^ (-9); % units in Joules/bit
ERx = 15 * 10 ^ (-9); % units in Joules/bit
% Transmit Amplifier Types %
Eamp = 50 * 10 ^ (-12); % units in Joules/bit/m^2 (amount of energy spent by the amplifier to transmit the bits)
% Data Aggregation Energy %
EDA = 5 * 10 ^ (-9); % units in Joules/bit
% Size of data package %
packet_size = pkt_size; % units in bits
% Suggested percentage of cluster head %
p = 0.1; % a 1 percent of the total amount of nodes used in the network is proposed to give good results
% Number of Clusters %
Ci = p * n;
% Round of Operation %
rounds = 0;
% Current Number of operating Nodes %
totalEnergy = n * Eo;
operating_nodes = n;
transmissions = 0;
temp_val = 0;
flagFirstDead = 0;
stop_flag = 0;

%%% Creation of the Wireless Sensor Network %%%
% % Plotting the uniform WSN %
% i = 1;
% 
% while (i <= n)
%     for j = 1:(x_max / step)
%         for k = 1:(y_max / step)
%             SN(i).x = x_cord(j); % X-axis coordinates of sensor node
%             SN(i).y = y_cord(k); % Y-axis coordinates of sensor node
%             i = i + 1;
%         end
%     end
% end



% Node properties assignment
for i = 1:n 
    SN(i).id = i; % sensor's ID number
    SN(i).Energy = Eo; % nodes energy levels (initially set to be equal to "Eo"
    SN(i).role = 0; % node acts as normal if the value is '0', if elected as a cluster head it gets the value '1' (initially all nodes are normal)
    SN(i).cluster = 0; % the cluster which a node belongs to
    SN(i).condition = 1; % States the current condition of the node. when the node is operational its value is =1 and when dead =0
    SN(i).rop = 0; % number of rounds node was operational
    SN(i).rleft = 0; % rounds left for node to become available for Cluster Head election
    SN(i).dtch = 0; % nodes distance from the cluster head of the cluster in which he belongs
    SN(i).dts = sqrt((sinkx - SN(i).x) ^ 2 + (sinky - SN(i).y) ^ 2); % nodes distance from the sink
    SN(i).tel = 0; % Tines elected - states how many times the node was elected as a Cluster Head
    SN(i).rn = 0; % round node got elected as cluster head
    SN(i).chid = 0; % node ID of the cluster head which the "i" normal node belongs to
    SN(i).prob = p; % probability with which a node gets to be cluster head
end



%% HEED %%
%-----------Re-initializing values-----------%
dead_nodes = 0;
%%% Energy Values %%%
% Initial Energy of a Node (in Joules) %
Eo = 0.1; % units in Joules
% Energy required to run circuity (both for transmitter and receiver) %
Eelec = 15 * 10 ^ (-9); % units in Joules/bit
ETx = 15 * 10 ^ (-9); % units in Joules/bit
ERx = 15 * 10 ^ (-9); % units in Joules/bit
% Transmit Amplifier Types %
Eamp = 50 * 10 ^ (-12); % units in Joules/bit/m^2 (amount of energy spent by the amplifier to transmit the bits)
% Data Aggregation Energy %
EDA = 5 * 10 ^ (-9); % units in Joules/bit

for i = 1:n

    SN(i).id = i; % sensor's ID number
    SN(i).Energy = Eo; % nodes energy levels (initially set to be equal to "Eo"
    SN(i).role = 0; % node acts as normal if the value is '0', if elected as a cluster head it gets the value '1' (initially all nodes are normal)
    SN(i).cluster = 0; % the cluster which a node belongs to
    SN(i).condition = 1; % States the current condition of the node. when the node is operational its value is =1 and when dead =0
    SN(i).rop = 0; % number of rounds node was operational
    SN(i).rleft = 0; % rounds left for node to become available for Cluster Head election
    SN(i).dtch = 0; % nodes distance from the cluster head of the cluster in which he belongs
    SN(i).tel = 0; % states how many times the node was elected as a Cluster Head
    SN(i).rn = 0; % round node got elected as cluster head
    SN(i).chid = 0; % node ID of the cluster head which the "i" normal node belongs to
    SN(i).prob = p; % probability with which a node gets to be cluster head

end

CHeads = 0;
CH_list = [];
firstRound = 1;
totalData = 0;
networkStatus = 1;
rad = maxCommRange;
dead_nodes = 0;
rounds = 0;
totalEnergy = n * Eo;
rounds = 0;
operating_nodes = n;
transmissions = 0;
temp_val = 0;
flagFirstDead = 0;
stop_flag = 0;

opNodes = [];
dNodes = [];
cNodes = [];
threshData = [];
remainingEnergy = [];
nrg = [];
flagFirstDead = 0;
networkLiveData_3 = [];
abpl_3 = [];
lsp_3 = [];

%-----------Re-initializing values done-----------%

%%%%%% Set-Up Phase %%%%%%
fprintf("Starting HEED Clustering \n");
while (operating_nodes > 0 && stop_flag == 0)

    % Displays Current Round %
    rounds = rounds + 1
    remainingEnergy(rounds) = totalEnergy;
    disp(totalEnergy)

    % Reseting Previous Amount Of Energy Consumed In the Network on the Previous Round %
    energy = 0;

    % Cluster Heads Election %
    [SN, CH_list, CHeads] = CH_election_HEED(SN, n, p, rounds, CHeads, Eo, CH_list);
    
    % % to check if CH_list was receiving properly
    % for i = 1:length(CH_list)
    %     disp(['Cluster Head ID: ', num2str(CH_list(i).id)]);
    % end

    if (CHeads ~= 0)
        % Fixing the size of "CH" array %
        CH_list = CH_list(1:CHeads);
        
        % Set the degree to 0
        CH_list = arrayfun(@(x) setfield(x, 'degree', 0), CH_list);

        % Debugging for checking if length of CH_list is more than CHeads
        % disp('Size of CH_list:');
        % disp(size(CH_list));
        % disp('Index array:');
        % disp((1:length(CH_list))');

        % Store the index of each node in the CH_list
        CH_list = arrayfun(@(x) setfield(x, 'index', 0), CH_list);

        for i= 1:length(CH_list)
            CH_list(i).index = i;
        end

        % Calculating node degree of cluster head based on Distance to cluster members
        for i =1:n
            % if node is normal i.e. not a CH
            if ((SN(i).role == 0) && (SN(i).Energy > 0)) 
                % % debugging to see of the iteration variable is being
                % % updated corectly as that's being used an index for the
                % % nodes array
                % fprintf("i = %d ",i);

                % Initialize validCH_list as 0 for cluster heads within maxCommRange
                validCH= 0;
                for m = 1:10
                    if(m<=CHeads)
                        d(m) = sqrt((CH_list(m).x - SN(i).x) ^ 2 + (CH_list(m).y - SN(i).y) ^ 2);
                        % we calculate the distance 'd' between the sensor node that is
                        % transmitting and the cluster head that is receiving with the following equation +
                        % d=sqrt((x2-x1)^2 + (y2-y1)^2) where x2 and y2 the coordinates of
                        % the cluster head and x1 and y1 the coordinates of the transmitting node
                        % Check if the distance is within the maximum communication range
                        if d(m) <= maxCommRange
                            validCH= validCH + 1;
                        end
                    else
                        d(m) = inf;
                    end
                end
                
                % Sort CH_list based on distances d
                [~, sortedIndices] = sort(d); % Get sorted indices based on distances
                %fixing the size of sortedCH_list
                sortedIndices = sortedIndices(1:CHeads);
                % Create a sorted version of CH_list
                
                try
                    sortedCH_list = CH_list(sortedIndices);
                catch
                    fprintf("ch - %d, si- %d, chl - %d", CHeads, length(sortedIndices), length(CH_list));
                    disp(sortedIndices);
                    fprintf("\n");
                    validCH
                    fprintf("\n");
                    % CH_list.index
                    d
                    error("Index exceeds the number of array elements.");
                end
                
                % To debug the code to see the state of the variables at this stage
                % d
                % sortedCH_list.index

                %fixing the size of sortedCH_list
                sortedCH_list = sortedCH_list(1:CHeads);
                % seeing if number of cluster heads in range are 1 or none
                % then select the nearest CH
                % if none in range it chooses the closest one
                if (validCH==1 || validCH==0)
                    % Above calculates distances of node from all the cluster heads and find the one with the minimum distance
                    d = d(1:CHeads); % fixing the size of "d" array
                    [M, I] = min(d(:)); % finds the minimum distance of node to CH
                    [Row, Col] = ind2sub(size(d), I); % displays the Cluster Number in which this node belongs too
                    SN(i).cluster = Col; % assigns node to the cluster
                    SN(i).dtch = d(Col); % assigns the distance of node to CH
                    SN(i).chid = CH_list(Col).id;
                    CH_list(Col).degree = CH_list(Col).degree + 1;

                elseif (validCH>1)
                    % adding new field as Cost as a function of node degree to CH_list %
                    sortedCH_list = arrayfun(@(x) setfield(x, 'cost', 0), CH_list);
                    for idx = 1:validCH
                        CH_ID = sortedCH_list(idx).index;
                        if (CH_list(CH_ID).degree ~= 0)
                            CH_list(CH_ID).cost = CH_list(CH_ID).degree;
                        else
                            CH_list(CH_ID).cost = 100;
                        end

                        CH_list(CH_ID).degree = 0;

                    end


                    % Assigning cost to each node of the cluster
                    for m = 1:validCH
                        c(m) = CH_list(sortedCH_list(m).index).cost;
                        % we add in a list the 'cost' of connecting to the cluster
                    end
                    % c = c(1:validCH); % fixing the size of "c" array

                    [M, I] = min(c(:)); % finds the minimum cost of CH
                    [Row, Column] = ind2sub(size(c), I); % displays the Cluster Number in which this node belongs too
                    Col = sortedCH_list(Column).index;
                    SN(i).cluster = Col; % assigns node to the cluster
                    SN(i).dtch = d(Col); % assigns the distance of node to CH
                    SN(i).chid = CH_list(Col).id;
                    CH_list(Col).degree = CH_list(Col).degree + 1;

                end

                % % to see which nodes are mot being assigned a cluster head
                % fprintf("Node number is %d and cluster head id is %d\n", i, SN(i).chid);

            % To assign the cluster Heads their own cluster 
            elseif (SN(i).role==1)
                SN(i).cluster = i; % assigns node to the cluster
                SN(i).dtch = 0; % assigns the distance of node to CH
                SN(i).chid = i;
            end
        end

        % After the first clustering happens (inside the while loop for HEED)
        if rounds == firstRound % Check if it's the first round of clustering
            % Create a new figure
            figure(17); 
            hold on;

            % Plot each node based on its role
            for i = 1:n
                if SN(i).role == 1 % Cluster Head
                    plot(SN(i).x, SN(i).y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for CHs
                else % Normal node (Cluster member)
                    plot(SN(i).x, SN(i).y, 'bo', 'MarkerSize', 6); % Blue circle for normal nodes
                    % Draw line to the corresponding cluster head
                    if SN(i).chid > 0 % Ensure that this node has a valid cluster head ID
                        chIndex = SN(i).chid; % Get the index of the cluster head
                        plot([SN(i).x, SN(chIndex).x], [SN(i).y, SN(chIndex).y], 'g--'); % Green dashed line
                    end
                end 
            end

            % Plot the sink location
            plot(sinkx, sinky, '*k', 'MarkerSize', 10, 'LineWidth', 3); % Black star for sink

            % Add titles and labels
            title('First HEED Clustering Event');
            xlabel('X-coordinate (Meters)');
            ylabel('Y-coordinate (Meters)');

            % Initialize handles for legend
            hClusterHead = plot(nan, nan, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for Cluster Head
            hClusterMember = plot(nan, nan, 'bo', 'MarkerSize', 6); % Blue circle for Cluster Member
            hSink = plot(nan, nan, '*k', 'MarkerSize', 10); % Black star for Sink

            % Create custom legend using handles
            legend([hClusterHead, hClusterMember, hSink], {'Cluster Heads', 'Cluster Members', 'Sink'}, ...
                'Location', 'Best');
            grid on; % Add grid for better visibility
            hold off; % releasing the hold
        end
        
        % % debugging to see which and how many nodes don't have CHs
        % noCH = 0;
        % disp("Nodes with no CH");
        % for i = 1:n
        %     if SN(i).chid==0
        %         fprintf("%d ", i);
        %         noCH = noCH+1;
        %     end
        % end

        % display(noCH); % to see how many nodes don't have a cluster head

        % printing the degree of each CH %

        % calculating HOPS and Proximity %
        [CH_list, ABPL] = CH_list_with_HOPS(CH_list, CHeads, rad, rounds);
        Network_Longest_Shortest_Path = calculating_lsp(CH_list, CHeads);

        abpl_3(rounds) = ABPL;
        lsp_3(rounds) = Network_Longest_Shortest_Path;

        %%%%%% Steady-State Phase %%%%%%

        % Consideration to check if the cluster heads don't have enough
        % energy to receive from any of it's cluster members
        % adding 0 means not transmitted to that Cluster 
        % adding 1 means transmitted to a at least 1 cluster memeber
        % CH_list(1:length(CH_list)) = struct('receiving_status', []);
        for i = 1:length(CH_list)
            CH_list(i).receiving_status = 0;
        end

        % Energy Dissipation for alive nodes %
        for i = 1:n
            % energy transmission for a normal (non-CH) node
            if (SN(i).condition == 1) && (SN(i).role == 0)
                ETx = Eelec * packet_size + Eamp * packet_size * SN(i).dtch ^ 2;% transmssion energy of node to CH
                ERx = (Eelec + EDA) * packet_size;% energy taken to receive signal by CH 
                % % Used to debug to see if any node's CH was still unassigned
                % if (SN(i).chid < 1)
                %    display(SN(i).chid)
                %    display(SN(i).id)
                %    display(SN(i).x)
                %    display(SN(i).y)
                % end
                ETx_to_sink = (Eelec + EDA) * packet_size + Eamp * packet_size * SN(SN(i).chid).dts ^ 2;% transmssion energy of CH to sink
                
                % % debugguing to see if any value went unassigned
                % fprintf("id = %d, CH = %d, ETx = %d, ERx = %d, ETx_to_sink = %d, CHDist = %d, SinkDist = %d\n", SN(i).id, SN(i).chid, ETx , ERx , ETx_to_sink, SN(i).dtch, SN(SN(i).chid).dts);

                % to make cahnges to the receiving status we can't directly
                % use SN(i).chid in CH_list - that's we extract the
                % position of the CH in CH_list
                CHindexInCHList = findCHIndex(CH_list, SN(i).chid);
                if(CHindexInCHList == -1)
                    error('CH id not found');
                end

                % if node's energy is not sufficient for transmission
                if SN(i).Energy < ETx 
                    dead_nodes = dead_nodes + 1;
                    totalEnergy = totalEnergy - SN(i).Energy;
                    SN(i).Energy = 0;
                    operating_nodes = operating_nodes - 1
                    SN(i).condition = 0;
                    SN(i).chid = 0;
                    SN(i).rop = rounds;
                % if receiving node's energy is not suffiecient for
                % receiving & also transmitting to the sink - then just
                % nodes don't transmit energy back to the CH
                elseif SN(SN(i).chid).Energy < ERx + ETx_to_sink && SN(SN(i).chid).condition == 1 && SN(SN(i).chid).role == 1
                    CH_list(CHindexInCHList).receiving_status = CH_list(CHindexInCHList).receiving_status + 0; 

                elseif SN(SN(i).chid).Energy > ERx + ETx_to_sink && SN(SN(i).chid).condition == 1 && SN(SN(i).chid).role == 1
                    % Dissipation for node during reception   
                    SN(i).Energy = SN(i).Energy - ETx;
                    energy = energy + ETx;
                    totalEnergy = totalEnergy - ETx;
                    totalData = totalData + packet_size;
                    
                    % Dissipation for cluster head during reception                
                    energy = energy + ERx;
                    totalEnergy = totalEnergy - ERx;
                    CH_list(CHindexInCHList).receiving_status = CH_list(CHindexInCHList).receiving_status+ 1; % resetting the receive status of the CH back to 1
                    SN(SN(i).chid).Energy = SN(SN(i).chid).Energy - ERx;
                end
            end
        end

        % to debug and see if the size of the list if more than the number
        % of cluster that exist
        % disp(['Size of arrays structure', num2str(length(CH_list)), ' Cluster head size', num2str(CHeads)]);

        % if the size of the list has increased then adjust it back to the
        % number of cluster necessary/ it is resized back to the size defined using number of nodes and
        % probability of become cluster head = CHeads, which stores the size of list after the election algois performed
        CH_list = resize(CH_list, CHeads);

        % % to check if CH_list was receiving properly
        % for i = 1:length(CH_list)
        %     disp(['Cluster Head ID: ', num2str(CH_list(i).id)]);
        % end
        

        % Looping through all cluster heads to see which ones had eneough
        % energy to receive even 1 signal
        for i = 1:length(CH_list)
            % if cluster heads energy not sufficient to support any reception
            if CH_list(i).receiving_status == 0
                CH_idx = CH_list(i).id;
                SN(CH_idx).Energy
                totalEnergy = totalEnergy - SN(CH_idx).Energy;
                SN(CH_idx).Energy = 0;
                SN(CH_idx).condition = 0;
                SN(CH_idx).rop = rounds;
                dead_nodes = dead_nodes + 1;
                operating_nodes = operating_nodes - 1
            end
        end

        % Energy Dissipation for cluster head nodes %
        for i = 1:n

            if (SN(i).condition == 1) && (SN(i).role == 1)
                ETx = (Eelec + EDA) * packet_size + Eamp * packet_size * SN(i).dts ^ 2;
                if SN(i).Energy >= ETx
                    SN(i).Energy = SN(i).Energy - ETx;
                    energy = energy + ETx;
                    totalEnergy = totalEnergy - ETx;
                % if cluster heads energy depletes with transmission and
                % won't be enough to transmit again
                elseif SN(i).Energy < ETx
                    dead_nodes = dead_nodes + 1;
                    operating_nodes = operating_nodes - 1
                    SN(i).condition = 0;
                    SN(i).rop = rounds;
                    totalEnergy = totalEnergy - SN(i).Energy;
                end
            end
        end
     end

    if operating_nodes < n && temp_val == 0
        temp_val = 1;
        flagFirstDead = rounds;
        networkLiveData_3(networkStatus) = rounds;
        networkStatus = networkStatus + 1;
    end

    if operating_nodes <= n * 0.75 && temp_val == 1
        temp_val = 2;
        % networkLiveData_3(networkStatus) = rounds;
        % networkStatus = networkStatus + 1;

        % Create a figure for visualization of nodes at this stage
        figure(18);
        hold on;

        % Plot all alive nodes
        for i = 1:n
            if SN(i).condition == 1 % Alive node
                if SN(i).role == 1 % Cluster Head
                    plot(SN(i).x, SN(i).y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for Cluster Heads
                else % Normal node (Cluster member)
                    plot(SN(i).x, SN(i).y, 'bo', 'MarkerSize', 8); % Blue circle for normal nodes
                    if SN(i).chid > 0 % Ensure that this node has a valid cluster head ID
                        chIndex = SN(i).chid; % Get the index of the cluster head
                        plot([SN(i).x, SN(chIndex).x], [SN(i).y, SN(chIndex).y], 'g--'); % Green dashed line
                    end
                end
            else % Dead node
                plot(SN(i).x, SN(i).y, 'kx', 'MarkerSize', 6, 'LineWidth', 2); % Black cross for dead nodes
            end
        end

        % Plot the sink location
        plot(sinkx, sinky, '*k', 'MarkerSize', 10); % Black star for sink

        % Add titles and labels
        title('HEED Network Status When >= 1/4th Nodes Are Dead');
        xlabel('X-coordinate (Meters)');
        ylabel('Y-coordinate (Meters)');

        % Initialize handles for legend
        hClusterHead = plot(nan, nan, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for Cluster Head
        hClusterMember = plot(nan, nan, 'bo', 'MarkerSize', 6); % Blue circle for Cluster Member
        hDeadNode = plot(nan, nan, 'kx', 'MarkerSize', 6, 'LineWidth', 2); % Black cross for dead nodes
        hSink = plot(nan, nan, '*k', 'MarkerSize', 10); % Black star for Sink
        
        % Create custom legend using handles
        legend([hClusterHead, hClusterMember, hDeadNode, hSink], {'Cluster Heads', 'Cluster Members','Dead Nodes', 'Sink'}, ...
            'Location', 'Best');
    
        grid on; % Adding grid for better visibility
        hold off; % Release the hold on current figure
    end

    % if operating_nodes <= n * 0.5 && temp_val == 2
    %     temp_val = 3;
    %     networkLiveData_3(networkStatus) = rounds;
    %     networkStatus = networkStatus + 1;
    % end

    transmissions = transmissions + 1;
    nrg(transmissions) = energy;

    if CHeads == 0 || operating_nodes < 3
        stop_flag = 1;
        CHeads = 0;
        networkLiveData_3(networkStatus) = rounds;
    end

    opNodes(rounds) = operating_nodes;
    dNodes(rounds) = dead_nodes;
    cNodes(rounds) = CHeads;
    threshData(rounds) = totalData;

end



if networkStatus == 1
    networkStatus = networkStatus + 1;
    networkLiveData_3(networkStatus) = rounds;
    % networkStatus = networkStatus + 1;
    % networkLiveData_3(networkStatus) = rounds;
% elseif networkStatus == 2
%     networkStatus = networkStatus + 1;
%     networkLiveData_3(networkStatus) = rounds;
% elseif networkStatus == 3
%     networkLiveData_3(networkStatus) = rounds;
% elseif networkStatus == 4
%     networkLiveData_3(networkStatus) = rounds;
end

% Plotting Simulation Results "Operating Nodes per Round" %
figure(3)
plot(1:length(opNodes), opNodes(1:length(opNodes)), '-g', 'Linewidth', 2);
hold on;

figure(4)
plot(1:length(dNodes), dNodes(1:length(dNodes)), '-g', 'Linewidth', 2);
hold on;

figure(5)
plot(1:length(cNodes), cNodes(1:length(cNodes)), '-g', 'Linewidth', 2);
hold on;

figure(6)
plot(1:length(threshData), threshData(1:length(threshData)), '-g', 'Linewidth', 2);
hold on;

figure(7)
plot(1:length(nrg), nrg(1:length(nrg)), '-g', 'Linewidth', 2);
hold on;

figure(8)
area(1:length(remainingEnergy), remainingEnergy(1:length(remainingEnergy)), 'FaceColor', 'g', 'FaceAlpha', 0.5);
hold on;

figure(9)
plot(1:length(abpl_3), abpl_3(1:length(abpl_3)), '-g', 'Linewidth', 2);
hold on;

figure(10)
plot(1:length(lsp_3), lsp_3(1:length(lsp_3)), '-g', 'Linewidth', 2);
hold on;

%% LEACH-C %%
%-----------Re-initializing values-----------%
dead_nodes = 0;
%%% Energy Values %%%
% Initial Energy of a Node (in Joules) %
Eo = 0.1; % units in Joules
% Energy required to run circuity (both for transmitter and receiver) %
Eelec = 15 * 10 ^ (-9); % units in Joules/bit
ETx = 15 * 10 ^ (-9); % units in Joules/bit
ERx = 15 * 10 ^ (-9); % units in Joules/bit
% Transmit Amplifier Types %
Eamp = 50 * 10 ^ (-12); % units in Joules/bit/m^2 (amount of energy spent by the amplifier to transmit the bits)
% Data Aggregation Energy %
EDA = 5 * 10 ^ (-9); % units in Joules/bit

for i = 1:n

    SN(i).id = i; % sensor's ID number
    SN(i).Energy = Eo; % nodes energy levels (initially set to be equal to "Eo"
    SN(i).role = 0; % node acts as normal if the value is '0', if elected as a cluster head it gets the value '1' (initially all nodes are normal)
    SN(i).cluster = 0; % the cluster which a node belongs to
    SN(i).condition = 1; % States the current condition of the node. when the node is operational its value is =1 and when dead =0
    SN(i).rop = 0; % number of rounds node was operational
    SN(i).rleft = 0; % rounds left for node to become available for Cluster Head election
    SN(i).dtch = 0; % nodes distance from the cluster head of the cluster in which he belongs
    SN(i).tel = 0; % states how many times the node was elected as a Cluster Head
    SN(i).rn = 0; % round node got elected as cluster head
    SN(i).chid = 0; % node ID of the cluster head which the "i" normal node belongs to
    SN(i).prob = p; % probability with which a node gets to be cluster head

end

CHeads = 0;
CLheads = 0;
CH_list = [];
firstRound = 1;
totalData = 0;
networkStatus = 1;
rad = maxCommRange;

rounds = 0;
totalEnergy = n * Eo;
operating_nodes = n;
transmissions = 0;
temp_val = 0;
flagFirstDead = 0;
stop_flag = 0;

opNodes = [];
dNodes = [];
cNodes = [];
threshData = [];
remainingEnergy = [];
nrg = [];
flagFirstDead = 0;
networkLiveData_4 = [];
abpl_4 = [];
lsp_4 = [];

%-----------Re-initializing values done-----------%
%%%%%% Set-Up Phase %%%%%%
fprintf("Starting LEACH-C Clustering, Ended HEED Clustering \n");
while (operating_nodes > 0 && stop_flag == 0)

    % Displays Current Round %
    rounds = rounds + 1
    remainingEnergy(rounds) = totalEnergy;

    % Reseting Previous Amount Of Cluster Heads In the Network %

    CLheads = 0;

    % Threshold Value %
    t = (p / (1 - p * (mod(rounds, 1 / p))));

    % Re-election Value %
    tleft = mod(rounds, 1 / p);

    % Reseting Previous Amount Of Energy Consumed In the Network on the Previous Round %
    energy = 0;
    Ecen = 0;

    % average energy calculation %
    for i = 1:n

        if (SN(i).condition == 1)
            Ecen = Ecen + SN(i).Energy;
        end

    end

    Ecen = Ecen / operating_nodes;

    % Cluster Heads Election %
    [SN, CL, CLheads] = CH_election_centralized(SN, n, t, tleft, p, rounds, sinkx, sinky, CLheads, Eo, Ecen);

    % if no nodes can become CHeads anymore - break out of the loop
    if(CLheads == 0)
        break;
    end

    % Fixing the size of "CL" array %
    CL = CL(1:CLheads);
    CL = arrayfun(@(x) setfield(x, 'degree', 0), CL);

    % Grouping the Nodes into Clusters & caclulating the distance between node and cluster head %

    for i = 1:n

        if (SN(i).role == 0) && (SN(i).Energy > 0) && (CLheads > 0) % if node is normal

            for m = 1:CLheads
                d(m) = sqrt((CL(m).x - SN(i).x) ^ 2 + (CL(m).y - SN(i).y) ^ 2) * 2;
                % we calculate the distance 'd' between the sensor node that is
                % transmitting and the cluster head that is receiving with the following equation+
                % d=sqrt((x2-x1)^2 + (y2-y1)^2) where x2 and y2 the coordinates of
                % the cluster head and x1 and y1 the coordinates of the transmitting node
            end

            d = d(1:CLheads); % fixing the size of "d" array
            [M, I] = min(d(:)); % finds the minimum distance of node to CH
            [Row, Col] = ind2sub(size(d), I); % displays the Cluster Number in which this node belongs too
            SN(i).cluster = Col; % assigns node to the cluster
            SN(i).dtch = d(Col); % assigns the distance of node to CH
            SN(i).chid = CL(Col).id;
            CL(Col).degree = CL(Col).degree + 1; % increase the degree of the cluster head
        end

    end

     % After the first clustering happens (inside the while loop for LEACH-C)
        if rounds == firstRound % Check if it's the first round of clustering
            % Create a new figure
            figure(19); 
            hold on;

            % Plot each node based on its role
            for i = 1:n
                if SN(i).role == 1 % Cluster Head
                    plot(SN(i).x, SN(i).y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for CHs
                else % Normal node (Cluster member)
                    plot(SN(i).x, SN(i).y, 'bo', 'MarkerSize', 6); % Blue circle for normal nodes
                    % Draw line to the corresponding cluster head
                    if SN(i).chid > 0 % Ensure that this node has a valid cluster head ID
                        chIndex = SN(i).chid; % Get the index of the cluster head
                        plot([SN(i).x, SN(chIndex).x], [SN(i).y, SN(chIndex).y], 'g--'); % Green dashed line
                    end
                end
            end

            % Plot the sink location
            plot(sinkx, sinky, '*k', 'MarkerSize', 10, 'LineWidth', 3); % Black star for sink

            % Add titles and labels
            title('First LEACH-C Clustering Event');
            xlabel('X-coordinate (Meters)');
            ylabel('Y-coordinate (Meters)');

            % Initialize handles for legend
            hClusterHead = plot(nan, nan, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for Cluster Head
            hClusterMember = plot(nan, nan, 'bo', 'MarkerSize', 6); % Blue circle for Cluster Member
            hSink = plot(nan, nan, '*k', 'MarkerSize', 10); % Black star for Sink

            % Create custom legend using handles
            legend([hClusterHead, hClusterMember, hSink], {'Cluster Heads', 'Cluster Members', 'Sink'}, ...
                'Location', 'Best');
            grid on; % Add grid for better visibility
            hold off; % releasing the hold
        end

    % calculating only if there are CHs in the network %
    if (CLheads ~= 0)

        % calculating HOPS and Proximity %
        [CL, ABPL] = CH_list_with_HOPS(CL, CLheads, rad, rounds);
        Network_Longest_Shortest_Path = calculating_lsp(CL, CLheads);

        abpl_4(rounds) = ABPL;
        lsp_4(rounds) = Network_Longest_Shortest_Path;

    end

    %%%%%% Steady-State Phase %%%%%%
    
        % Consideration to check if the cluster heads don't have enough
        % energy to receive from any of it's cluster members
        % CH_list(1:length(CH_list)) = struct('receiving_status', []);
        for i = 1:length(CLheads)
            CL(i).receiving_status = 0;
        end
        fprintf("\n");

        % Energy Dissipation for normal nodes %
        for i = 1:n
            
            if (SN(i).condition == 1) && (SN(i).role == 0)
                ETx = Eelec * packet_size + Eamp * packet_size * SN(i).dtch ^ 2;% transmssion energy of node to CH
                ERx = (Eelec + EDA) * packet_size;% energy taken to receive signal by CH 
                try
                    ETx_to_sink = (Eelec + EDA) * packet_size + Eamp * packet_size * SN(SN(i).chid).dts ^ 2;% transmssion energy of CH to sink
                catch
                    % debugguing to see if any value went unassigned
                    fprintf("id = %d, CH = %d, ETx = %d, ERx = %d, ETx_to_sink = %d, CHDist = %d\n", SN(i).id, SN(i).chid, ETx , ERx , ETx_to_sink, SN(i).dtch);
                    error('Array indices must be positive integers or logical values.');
                end

                % to make cahnges to the receiving status we can't directly
                % use SN(i).chid in CH_list - that's we extract the
                % position of the CH in CH_list
                CHindexInCHList = findCHIndex(CL, SN(i).chid);
                if(CHindexInCHList == -1)
                    disp(SN(i).chid);
                    error('CH id not found');
                end

                % if node's energy is not sufficient for transmission
                if SN(i).Energy < ETx 
                    dead_nodes = dead_nodes + 1;
                    totalEnergy = totalEnergy - SN(i).Energy;
                    SN(i).Energy = 0;
                    operating_nodes = operating_nodes - 1
                    SN(i).condition = 0;
                    SN(i).chid = 0;
                    SN(i).rop = rounds;
                % if receiving node's energy is not suffiecient for
                % receiving & also transmitting to the sink - then just
                % nodes don't transmit energy back to the CH
                elseif SN(SN(i).chid).Energy < ERx + ETx_to_sink && SN(SN(i).chid).condition == 1 && SN(SN(i).chid).role == 1
                    try
                        CL(CHindexInCHList).receiving_status = CL(CHindexInCHList).receiving_status + 0; 
                    catch
                        fprintf("id = %d, CH = %d", SN(i).id, SN(i).chid);
                        error('Index exceeds array bounds.');
                    end

                elseif SN(SN(i).chid).Energy > ERx + ETx_to_sink && SN(SN(i).chid).condition == 1 && SN(SN(i).chid).role == 1
                    % Dissipation for node during transmission   
                    SN(i).Energy = SN(i).Energy - ETx;
                    energy = energy + ETx;
                    totalEnergy = totalEnergy - ETx;
                    totalData = totalData + packet_size;
                    
                    % Dissipation for cluster head during reception                
                    energy = energy + ERx;
                    totalEnergy = totalEnergy - ERx;
                    % Adding 1 to the receive status of the CH when it
                    % receievrs from any one of it's cluster memebrs
                    CL(CHindexInCHList).receiving_status = CL(CHindexInCHList).receiving_status + 1; 
                    SN(SN(i).chid).Energy = SN(SN(i).chid).Energy - ERx;
                end
            end
        end

        % % to debug and see if the size of the list if more than the number
        % % of cluster that exist
        % disp(['Size of arrays structure', num2str(length(CL)), ' Cluster head size', num2str(CHeads)]);

        % if the size of the list has increased then adjust it back to the
        % number of cluster necessary/ it is resized back to the size defined using number of nodes and
        % probability of become cluster head = CHeads, which stores the size of list after the election algois performed
        CL = resize(CL, CHeads);

        % to check if CH_list was receiving properly
        for i = 1:length(CL)
            disp(['Cluster Head ID: ', num2str(CL(i).id)]);
        end
        

        % Looping through all cluster heads to see which ones had eneough
        % energy to receive even 1 signal
        for i = 1:length(CL)
            % if cluster heads energy not sufficient to support any reception
            % seen by numebrs of cluster members it receievd energy from
            % being 0 - proclaim it equal to dead
            if CL(i).receiving_status == 0
                CH_idx = CL(i).id;
                totalEnergy = totalEnergy - SN(CH_idx).Energy;
                SN(CH_idx).Energy = 0;
                SN(CH_idx).condition = 0;
                SN(CH_idx).rop = rounds;
                dead_nodes = dead_nodes + 1;
                operating_nodes = operating_nodes - 1
            end
        end

        % Energy Dissipation for cluster head nodes %
        for i = 1:n

            if (SN(i).condition == 1) && (SN(i).role == 1)
                ETx = (Eelec + EDA) * packet_size + Eamp * packet_size * SN(i).dts ^ 2;
                if SN(i).Energy >= ETx
                    SN(i).Energy = SN(i).Energy - ETx;
                    energy = energy + ETx;
                    totalEnergy = totalEnergy - ETx;
                % if cluster heads energy depletes with transmission and
                % won't be enough to transmit again
                elseif SN(i).Energy < ETx
                    dead_nodes = dead_nodes + 1;
                    operating_nodes = operating_nodes - 1
                    SN(i).condition = 0;
                    SN(i).rop = rounds;
                    totalEnergy = totalEnergy - SN(i).Energy;
                end
            end
        end

    if operating_nodes < n && temp_val == 0
        temp_val = 1;
        flagFirstDead = rounds;
        networkLiveData_4(networkStatus) = rounds;
        networkStatus = networkStatus + 1;
    end

    % if operating_nodes <= n * 0.5 && temp_val == 2
    %     temp_val = 3;
    %     networkLiveData_4(networkStatus) = rounds;
    %     networkStatus = networkStatus + 1;
    % end

    if operating_nodes <= n * 0.75 && temp_val == 1
        temp_val = 2;
        % networkLiveData_4(networkStatus) = rounds;
        % networkStatus = networkStatus + 1;

        % Create a figure for visualization of nodes at this stage
        figure(20);
        hold on;

        % Plot all alive nodes
        for i = 1:n
            if SN(i).condition == 1 % Alive node
                if SN(i).role == 1 % Cluster Head
                    plot(SN(i).x, SN(i).y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for Cluster Heads
                else % Normal node (Cluster member)
                    plot(SN(i).x, SN(i).y, 'bo', 'MarkerSize', 8); % Blue circle for normal nodes
                    if SN(i).chid > 0 % Ensure that this node has a valid cluster head ID
                        chIndex = SN(i).chid; % Get the index of the cluster head
                        plot([SN(i).x, SN(chIndex).x], [SN(i).y, SN(chIndex).y], 'g--'); % Green dashed line
                    end
                end
            else % Dead node
                plot(SN(i).x, SN(i).y, 'kx', 'MarkerSize', 6, 'LineWidth', 2); % Black cross for dead nodes
            end
        end

        % Plot the sink location
        plot(sinkx, sinky, '*k', 'MarkerSize', 10); % Black star for sink

        % Add titles and labels
        title('LEACH-C Network Status When >= 1/4th Nodes Are Dead');
        xlabel('X-coordinate (Meters)');
        ylabel('Y-coordinate (Meters)');

        % Initialize handles for legend
        hClusterHead = plot(nan, nan, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for Cluster Head
        hClusterMember = plot(nan, nan, 'bo', 'MarkerSize', 6); % Blue circle for Cluster Member
        hDeadNode = plot(nan, nan, 'kx', 'MarkerSize', 6, 'LineWidth', 2); % Black cross for dead nodes
        hSink = plot(nan, nan, '*k', 'MarkerSize', 10); % Black star for Sink
        
        % Create custom legend using handles
        legend([hClusterHead, hClusterMember, hDeadNode, hSink], {'Cluster Heads', 'Cluster Members','Dead Nodes', 'Sink'}, ...
            'Location', 'Best');
    
        grid on; % Adding grid for better visibility
        hold off; % Release the hold on current figure
    end

    transmissions = transmissions + 1;
    nrg(transmissions) = energy;

    cnt = 0;

    for i = 1:n

        if (SN(i).Energy <= Eo * 0.2)
            cnt = cnt + 1;
        end

    end

    if cnt == n || operating_nodes < 3
        networkLiveData_4(networkStatus) = rounds;
        stop_flag = 1;
    end

    opNodes(rounds) = operating_nodes;
    dNodes(rounds) = dead_nodes;
    cNodes(rounds) = CLheads;
    threshData(rounds) = totalData;

end

if networkStatus == 1
    networkStatus = networkStatus + 1;
    networkLiveData_4(networkStatus) = rounds;
elseif networkStatus == 2
    % networkStatus = networkStatus + 1;
    networkLiveData_4(networkStatus) = rounds;
% elseif networkStatus == 3
%     networkLiveData_4(networkStatus) = rounds;
% elseif networkStatus == 4
%     networkLiveData_4(networkStatus) = rounds;
end

% Plotting Simulation Results "Operating Nodes per Round" %
figure(3)
plot(1:length(opNodes), opNodes(1:length(opNodes)), '-c', 'Linewidth', 2);
hold on;

figure(4)
plot(1:length(dNodes), dNodes(1:length(dNodes)), '-c', 'Linewidth', 2);
hold on;

figure(5)
plot(1:length(cNodes), cNodes(1:length(cNodes)), '-c', 'Linewidth', 2);
hold on;

figure(6)
plot(1:length(threshData), threshData(1:length(threshData)), '-c', 'Linewidth', 2);
hold on;

figure(7)
plot(1:length(nrg), nrg(1:length(nrg)), '-c', 'Linewidth', 1);
hold on;

figure(8)
area(1:length(remainingEnergy), remainingEnergy(1:length(remainingEnergy)), 'FaceColor', 'c', 'FaceAlpha', 0.5);
hold on;

figure(9)
plot(1:length(abpl_4), abpl_4(1:length(abpl_4)), '-c', 'Linewidth', 1);
hold on;

figure(10)
plot(1:length(lsp_4), lsp_4(1:length(lsp_4)), '-c', 'Linewidth', 1);
hold on;

%% LEACH %%
%-----------Re-initializing values-----------%
dead_nodes = 0;
%%% Energy Values %%%
% Initial Energy of a Node (in Joules) %
Eo = 0.1; % units in Joules
% Energy required to run circuity (both for transmitter and receiver) %
Eelec = 15 * 10 ^ (-9); % units in Joules/bit
ETx = 15 * 10 ^ (-9); % units in Joules/bit
ERx = 15 * 10 ^ (-9); % units in Joules/bit
% Transmit Amplifier Types %
Eamp = 50 * 10 ^ (-12); % units in Joules/bit/m^2 (amount of energy spent by the amplifier to transmit the bits)
% Data Aggregation Energy %
EDA = 5 * 10 ^ (-9); % units in Joules/bit

for i = 1:n

    SN(i).id = i; % sensor's ID number
    SN(i).Energy = Eo; % nodes energy levels (initially set to be equal to "Eo"
    SN(i).role = 0; % node acts as normal if the value is '0', if elected as a cluster head it gets the value '1' (initially all nodes are normal)
    SN(i).cluster = 0; % the cluster which a node belongs to
    SN(i).condition = 1; % States the current condition of the node. when the node is operational its value is =1 and when dead =0
    SN(i).rop = 0; % number of rounds node was operational
    SN(i).rleft = 0; % rounds left for node to become available for Cluster Head election
    SN(i).dtch = 0; % nodes distance from the cluster head of the cluster in which he belongs
    SN(i).tel = 0; % states how many times the node was elected as a Cluster Head
    SN(i).rn = 0; % round node got elected as cluster head
    SN(i).chid = 0; % node ID of the cluster head which the "i" normal node belongs to
    SN(i).prob = p; % probability with which a node gets to be cluster head

end

CHeads = 0;
CLheads = 0;
CL = [];
firstRound = 1;
totalData = 0;
networkStatus = 1;
rad = maxCommRange;

rounds = 0;
totalEnergy = n * Eo;
operating_nodes = n;
transmissions = 0;
temp_val = 0;
flagFirstDead = 0;
stop_flag = 0;

opNodes = [];
dNodes = [];
cNodes = [];
threshData = [];
remainingEnergy = [];
nrg = [];
flagFirstDead = 0;
networkLiveData_5 = [];
abpl_5 = [];
lsp_5 = [];

%-----------Re-initializing values done-----------%

%%%%%% Set-Up Phase %%%%%%
fprintf("Starting LEACH Clustering, Ended LEACH-C Clustering \n");
while (operating_nodes > 0 && stop_flag == 0)

    % Displays Current Round %
    rounds = rounds + 1
    remainingEnergy(rounds) = totalEnergy;

    % Threshold Value %
    t = (p / (1 - p * (mod(rounds, 1 / p))));

    % Re-election Value %
    tleft = mod(rounds, 1 / p);

    % Reseting Previous Amount Of Cluster Heads In the Network %
    CLheads = 0;

    % Reseting Previous Amount Of Energy Consumed In the Network on the Previous Round %
    energy = 0;

    % Cluster Heads Election %
    [SN, CL, CLheads] = CH_election(SN, n, t, tleft, p, rounds, sinkx, sinky, CLheads, Eo);

    % if no nodes can become CHeads anymore - break out of the loop
    if(CLheads == 0)
        break;
    end

    % Fixing the size of "CL" array %
    CL = CL(1:CLheads);
    CL = arrayfun(@(x) setfield(x, 'degree', 0), CL);

    % Grouping the Nodes into Clusters & caclulating the distance between node and cluster head %

    for i = 1:n

        if (SN(i).role == 0) && (SN(i).Energy > 0) && (CLheads > 0) % if node is normal

            for m = 1:CLheads
                d(m) = sqrt((CL(m).x - SN(i).x) ^ 2 + (CL(m).y - SN(i).y) ^ 2) * 2;
                % we calculate the distance 'd' between the sensor node that is
                % transmitting and the cluster head that is receiving with the following equation+
                % d=sqrt((x2-x1)^2 + (y2-y1)^2) where x2 and y2 the coordinates of
                % the cluster head and x1 and y1 the coordinates of the transmitting node
            end

            d = d(1:CLheads); % fixing the size of "d" array
            [M, I] = min(d(:)); % finds the minimum distance of node to CH
            [Row, Col] = ind2sub(size(d), I); % displays the Cluster Number in which this node belongs too
            SN(i).cluster = Col; % assigns node to the cluster
            SN(i).dtch = d(Col); % assigns the distance of node to CH
            SN(i).chid = CL(Col).id;
            CL(Col).degree = CL(Col).degree + 1; % increase the degree of the cluster head
        end

    end


    if (CLheads ~= 0)
        % printing the degree of each CH %

        % calculating HOPS and Proximity %
        [CL, ABPL] = CH_list_with_HOPS(CL, CLheads, rad, rounds);
        Network_Longest_Shortest_Path = calculating_lsp(CL, CLheads);

        abpl_5(rounds) = ABPL;
        lsp_5(rounds) = Network_Longest_Shortest_Path;

    end

    % After the first clustering happens (inside the while loop for LEACH)
        if rounds == firstRound % Check if it's the first round of clustering
            % Create a new figure
            figure(21); 
            hold on;

            % Plot each node based on its role
            for i = 1:n
                if SN(i).role == 1 % Cluster Head
                    plot(SN(i).x, SN(i).y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for CHs
                else % Normal node (Cluster member)
                    plot(SN(i).x, SN(i).y, 'bo', 'MarkerSize', 6); % Blue circle for normal nodes
                    % Draw line to the corresponding cluster head
                    if SN(i).chid > 0 % Ensure that this node has a valid cluster head ID
                        chIndex = SN(i).chid; % Get the index of the cluster head
                        plot([SN(i).x, SN(chIndex).x], [SN(i).y, SN(chIndex).y], 'g--'); % Green dashed line
                    end
                end
            end

            % Plot the sink location
            plot(sinkx, sinky, '*k', 'MarkerSize', 10, 'LineWidth', 3); % Black star for sink

            % Add titles and labels
            title('First LEACH Clustering Event');
            xlabel('X-coordinate (Meters)');
            ylabel('Y-coordinate (Meters)');

            % Initialize handles for legend
            hClusterHead = plot(nan, nan, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for Cluster Head
            hClusterMember = plot(nan, nan, 'bo', 'MarkerSize', 6); % Blue circle for Cluster Member
            hSink = plot(nan, nan, '*k', 'MarkerSize', 10); % Black star for Sink

            % Create custom legend using handles
            legend([hClusterHead, hClusterMember, hSink], {'Cluster Heads', 'Cluster Members', 'Sink'}, ...
                'Location', 'Best');
            grid on; % Add grid for better visibility
            hold off; % releasing the hold
        end

    %%%%%% Steady-State Phase %%%%%%

        % Consideration to check if the cluster heads don't have enough
        % energy to receive from any of it's cluster members
        % CH_list(1:length(CH_list)) = struct('receiving_status', []);
        for i = 1:length(CL)
            CL(i).receiving_status = 0;
        end

        % Energy Dissipation for normal nodes %
        for i = 1:n
            
            if (SN(i).condition == 1) && (SN(i).role == 0)
                ETx = Eelec * packet_size + Eamp * packet_size * SN(i).dtch ^ 2;% transmssion energy of node to CH
                ERx = (Eelec + EDA) * packet_size;% energy taken to receive signal by CH 
                ETx_to_sink = (Eelec + EDA) * packet_size + Eamp * packet_size * SN(SN(i).chid).dts ^ 2;% transmssion energy of CH to sink

                % % debugguing to see if any value went unassigned
                % fprintf("id = %d, CH = %d, ETx = %d, ERx = %d, ETx_to_sink = %d, CHDist = %d, SinkDist = %d\n", SN(i).id, SN(i).chid, ETx , ERx , ETx_to_sink, SN(i).dtch, SN(SN(i).chid).dts);

                % to make cahnges to the receiving status we can't directly
                % use SN(i).chid in CH_list - that's we extract the
                % position of the CH in CH_list
                CHindexInCHList = findCHIndex(CL, SN(i).chid);
                if(CHindexInCHList == -1)
                    error('CH id not found');
                end

                % if node's energy is not sufficient for transmission
                if SN(i).Energy < ETx 
                    dead_nodes = dead_nodes + 1;
                    totalEnergy = totalEnergy - SN(i).Energy;
                    SN(i).Energy = 0;
                    operating_nodes = operating_nodes - 1
                    SN(i).condition = 0;
                    SN(i).chid = 0;
                    SN(i).rop = rounds;
                % if receiving node's energy is not suffiecient for
                % receiving & also transmitting to the sink - then just
                % nodes don't transmit energy back to the CH
                elseif SN(SN(i).chid).Energy < ERx + ETx_to_sink && SN(SN(i).chid).condition == 1 && SN(SN(i).chid).role == 1
                    CL(CHindexInCHList).receiving_status = CL(CHindexInCHList).receiving_status + 0; 

                elseif SN(SN(i).chid).Energy > ERx + ETx_to_sink && SN(SN(i).chid).condition == 1 && SN(SN(i).chid).role == 1
                    % Dissipation for node during reception   
                    SN(i).Energy = SN(i).Energy - ETx;
                    energy = energy + ETx;
                    totalEnergy = totalEnergy - ETx;
                    totalData = totalData + packet_size;
                    
                    % Dissipation for cluster head during reception                
                    energy = energy + ERx;
                    totalEnergy = totalEnergy - ERx;
                    CL(CHindexInCHList).receiving_status = CL(CHindexInCHList).receiving_status + 1; % resetting the receive status of the CH back to 1
                    SN(SN(i).chid).Energy = SN(SN(i).chid).Energy - ERx;
                end
            end
        end

        % % to debug and see if the size of the list if more than the number
        % % of cluster that exist
        % disp(['Size of arrays structure', num2str(length(CL)), ' Cluster head size', num2str(CHeads)]);

        % if the size of the list has increased then adjust it back to the
        % number of cluster necessary/ it is resized back to the size defined using number of nodes and
        % probability of become cluster head = CHeads, which stores the size of list after the election algois performed
        CL = resize(CL, CHeads);

        % to check if CH_list was receiving properly
        for i = 1:length(CL)
            disp(['Cluster Head ID: ', num2str(CL(i).id)]);
        end
        

        % Looping through all cluster heads to see which ones had eneough
        % energy to receive even 1 signal
        for i = 1:length(CL)
            % if cluster heads energy not sufficient to support any reception
            if CL(i).receiving_status == 0
                CH_idx = CL(i).id;
                SN(CH_idx).Energy
                totalEnergy = totalEnergy - SN(CH_idx).Energy;
                SN(CH_idx).Energy = 0;
                SN(CH_idx).condition = 0;
                SN(CH_idx).rop = rounds;
                dead_nodes = dead_nodes + 1;
                operating_nodes = operating_nodes - 1
            end
        end

        % Energy Dissipation for cluster head nodes %
        for i = 1:n

            if (SN(i).condition == 1) && (SN(i).role == 1)
                ETx = (Eelec + EDA) * packet_size + Eamp * packet_size * SN(i).dts ^ 2;
                if SN(i).Energy >= ETx
                    SN(i).Energy = SN(i).Energy - ETx;
                    energy = energy + ETx;
                    totalEnergy = totalEnergy - ETx;
                % if cluster heads energy depletes with transmission and
                % won't be enough to transmit again
                elseif SN(i).Energy < ETx
                    dead_nodes = dead_nodes + 1;
                    operating_nodes = operating_nodes - 1
                    SN(i).condition = 0;
                    SN(i).rop = rounds;
                    totalEnergy = totalEnergy - SN(i).Energy;
                end
            end
        end

    if operating_nodes < n && temp_val == 0
        temp_val = 1;
        flagFirstDead = rounds;
        networkLiveData_5(networkStatus) = rounds;
        networkStatus = networkStatus + 1;
    end

    % if operating_nodes <= n * 0.5 && temp_val == 2
    %     temp_val = 3;
    %     networkLiveData_5(networkStatus) = rounds;
    %     networkStatus = networkStatus + 1;
    % end

    if operating_nodes <= n * 0.75 && temp_val == 1
        temp_val = 2;
        % networkLiveData_5(networkStatus) = rounds;
        % networkStatus = networkStatus + 1;

        % Create a figure for visualization of nodes at this stage
        figure(22);
        hold on;

        % Plot all alive nodes
        for i = 1:n
            if SN(i).condition == 1 % Alive node
                if SN(i).role == 1 % Cluster Head
                    plot(SN(i).x, SN(i).y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for Cluster Heads
                else % Normal node (Cluster member)
                    plot(SN(i).x, SN(i).y, 'bo', 'MarkerSize', 8); % Blue circle for normal nodes
                    if SN(i).chid > 0 % Ensure that this node has a valid cluster head ID
                        chIndex = SN(i).chid; % Get the index of the cluster head
                        plot([SN(i).x, SN(chIndex).x], [SN(i).y, SN(chIndex).y], 'g--'); % Green dashed line
                    end
                end
            else % Dead node
                plot(SN(i).x, SN(i).y, 'kx', 'MarkerSize', 6, 'LineWidth', 2); % Black cross for dead nodes
            end
        end

        % Plot the sink location
        plot(sinkx, sinky, '*k', 'MarkerSize', 10); % Black star for sink

        % Add titles and labels
        title('LEACH Network Status When >= 1/4th Nodes Are Dead');
        xlabel('X-coordinate (Meters)');
        ylabel('Y-coordinate (Meters)');

        % Initialize handles for legend
        hClusterHead = plot(nan, nan, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle for Cluster Head
        hClusterMember = plot(nan, nan, 'bo', 'MarkerSize', 6); % Blue circle for Cluster Member
        hDeadNode = plot(nan, nan, 'kx', 'MarkerSize', 6, 'LineWidth', 2); % Black cross for dead nodes
        hSink = plot(nan, nan, '*k', 'MarkerSize', 10); % Black star for Sink
        
        % Create custom legend using handles
        legend([hClusterHead, hClusterMember, hDeadNode, hSink], {'Cluster Heads', 'Cluster Members','Dead Nodes', 'Sink'}, ...
            'Location', 'Best');
    
        grid on; % Adding grid for better visibility
        hold off; % Release the hold on current figure
    end

    transmissions = transmissions + 1;
    nrg(transmissions) = energy;

    cnt = 0;

    for i = 1:n

        if (SN(i).Energy <= Eo * 0.2)
            cnt = cnt + 1;
        end

    end

    if cnt == n || operating_nodes < 3
        networkLiveData_5(networkStatus) = rounds;
        stop_flag = 1;
    end

    opNodes(rounds) = operating_nodes;
    dNodes(rounds) = dead_nodes;
    cNodes(rounds) = CLheads;
    threshData(rounds) = totalData;
end


if networkStatus == 1
    networkStatus = networkStatus + 1;
    networkLiveData_5(networkStatus) = rounds;
    networkStatus = networkStatus + 1;
    % networkLiveData_5(networkStatus) = rounds;
elseif networkStatus == 2
    % networkStatus = networkStatus + 1;
    networkLiveData_5(networkStatus) = rounds;
% elseif networkStatus == 3
%     networkLiveData_5(networkStatus) = rounds;
% elseif networkStatus == 4
%     networkLiveData_5(networkStatus) = rounds;
end

% Plotting Simulation Results "Operating Nodes per Round" %
figure(3)
plot(1:length(opNodes), opNodes(1:length(opNodes)), '-c', 'Linewidth', 2);
hold on;

figure(4)
plot(1:length(dNodes), dNodes(1:length(dNodes)), '-c', 'Linewidth', 2);
hold on;

figure(5)
plot(1:length(cNodes), cNodes(1:length(cNodes)), '-c', 'Linewidth', 2);
hold on;

figure(6)
plot(1:length(threshData), threshData(1:length(threshData)), '-c', 'Linewidth', 2);
hold on;

figure(7)
plot(1:length(nrg), nrg(1:length(nrg)), '-c', 'Linewidth', 1);
hold on;

figure(8)
area(1:length(remainingEnergy), remainingEnergy(1:length(remainingEnergy)), 'FaceColor', 'c', 'FaceAlpha', 0.5);
hold on;

figure(9)
plot(1:length(abpl_5), abpl_5(1:length(abpl_5)), '-c', 'Linewidth', 1);
hold on;

figure(10)
plot(1:length(lsp_5), lsp_5(1:length(lsp_5)), '-c', 'Linewidth', 1);
hold on;



%% DDMPEA
fprintf("Starting Simulation for DDMPEA\n");

params_ddmpea = params; % reuse main params
params_ddmpea.NP = 50;
params_ddmpea.maxGen = 100;
params_ddmpea.P = 30;
params_ddmpea.sigma1 = 1;
params_ddmpea.sinkx = sinkx;
params_ddmpea.sinky = sinky;

SN_reset = resetNodes(n, Eo, sinkx, sinky, pos, DistMat, Eps);
[opNodes_ddmpea, dNodes_ddmpea, cNodes_ddmpea, remainingEnergy_ddmpea, abpl_ddmpea, lsp_ddmpea, nrg_ddmpea, threshData_ddmpea, firstNodeDead_ddmpea, quarterNodesDead_ddmpea, halfNodesDead_ddmpea, allNodesDead_ddmpea] = runDDMPEA_Simulation(SN_reset, DistMat, params_ddmpea);

%% DWEHC
fprintf("Starting Simulation for DWEHC\n");

params_dwehc = params;
params_dwehc.Einit = Eo;
params_dwehc.R = 30;
params_dwehc.alpha = 2;
params_dwehc.sinkx = sinkx;
params_dwehc.sinky = sinky;

SN_reset = resetNodes(n, Eo, sinkx, sinky, pos, DistMat, Eps);
[opNodes_dwehc, dNodes_dwehc, cNodes_dwehc, remainingEnergy_dwehc, abpl_dwehc, lsp_dwehc, nrg_dwehc, threshData_dwehc, firstNodeDead_dwehc, quarterNodesDead_dwehc, halfNodesDead_dwehc, allNodesDead_dwehc] = runDWEHC_Simulation(SN_reset, DistMat, params_dwehc);

%% FOHCA
fprintf("Starting Simulation for FOHCA\n");

params_fohca = params;
params_fohca.k = round(0.05*n);
params_fohca.BSpos = [sinkx, sinky];
params_fohca.FO_iter = 20;
params_fohca.w1 = 0.5;
params_fohca.w2 = 0.5;
params_fohca.sinkx = sinkx;
params_fohca.sinky = sinky;

SN_reset = resetNodes(n, Eo, sinkx, sinky, pos, DistMat, Eps);
[opNodes_fohca, dNodes_fohca, cNodes_fohca, remainingEnergy_fohca, abpl_fohca, lsp_fohca, nrg_fohca, threshData_fohca, firstNodeDead_fohca, quarterNodesDead_fohca, halfNodesDead_fohca, allNodesDead_fohca] = runFOHCA_Simulation(SN_reset, DistMat, params_fohca);

%% Figure plotting for DDMPEA, DWEHC & FOHCA
figure(3)
hold on;
plot(1:length(opNodes_ddmpea), opNodes_ddmpea, '-', 'LineWidth', 2);
plot(1:length(opNodes_dwehc), opNodes_dwehc, '-', 'LineWidth', 2);
plot(1:length(opNodes_fohca), opNodes_fohca, '-', 'LineWidth', 2);
legend({'RCA Method', 'SRA Method', 'RRA Method', 'DBSCAN', 'HEED', 'LEACH-C', 'LEACH', 'DDMPEA', 'DWEHC', 'FOHCA'}, 'Location', 'Best');
hold off;

figure(4)
hold on;
plot(1:length(dNodes_ddmpea), dNodes_ddmpea(1:length(dNodes_ddmpea)), '-', 'Linewidth', 2);
plot(1:length(dNodes_dwehc), dNodes_dwehc(1:length(dNodes_dwehc)), '-', 'Linewidth', 2);
plot(1:length(dNodes_fohca), dNodes_fohca(1:length(dNodes_fohca)), '-', 'Linewidth', 2);
legend({'RCA Method', 'SRA Method', 'RRA Method', 'DBSCAN', 'HEED', 'LEACH-C', 'LEACH', 'DDMPEA', 'DWEHC', 'FOHCA'}, 'Location', 'Best');
hold off;

figure(5)
hold on;
plot(1:length(cNodes_ddmpea), cNodes_ddmpea(1:length(cNodes_ddmpea)), '-', 'Linewidth', 2);
plot(1:length(cNodes_dwehc), cNodes_dwehc(1:length(cNodes_dwehc)), '-', 'Linewidth', 2);
plot(1:length(cNodes_fohca), cNodes_fohca(1:length(cNodes_fohca)), '-', 'Linewidth', 2);
legend({'RCA Method', 'SRA Method', 'RRA Method', 'DBSCAN', 'HEED', 'LEACH-C', 'LEACH', 'DDMPEA', 'DWEHC', 'FOHCA'}, 'Location', 'Best');
hold off;

figure(6)
hold on;
plot(1:length(threshData_ddmpea), threshData_ddmpea(1:length(threshData_ddmpea)), '-', 'Linewidth', 2);
plot(1:length(threshData_dwehc), threshData_dwehc(1:length(threshData_dwehc)), '-', 'Linewidth', 2);
plot(1:length(threshData_fohca), threshData_fohca(1:length(threshData_fohca)), '-', 'Linewidth', 2);
legend({'RCA Method', 'SRA Method', 'RRA Method', 'DBSCAN', 'HEED', 'LEACH-C', 'LEACH', 'DDMPEA', 'DWEHC', 'FOHCA'}, 'Location', 'Best');
hold off;

figure(7)
hold on;
plot(1:length(nrg_ddmpea), nrg_ddmpea(1:length(nrg_ddmpea)), '-', 'Linewidth', 2);
plot(1:length(nrg_dwehc), nrg_dwehc(1:length(nrg_dwehc)), '-', 'Linewidth', 2);
plot(1:length(nrg_fohca), nrg_fohca(1:length(nrg_fohca)), '-', 'Linewidth', 2);
legend({'RCA Method', 'SRA Method', 'RRA Method', 'DBSCAN', 'HEED', 'LEACH-C', 'LEACH', 'DDMPEA', 'DWEHC', 'FOHCA'}, 'Location', 'Best');
hold off;

figure(8)
hold on;
area(1:length(remainingEnergy_ddmpea), remainingEnergy_ddmpea(1:length(remainingEnergy_ddmpea)), 'FaceAlpha', 0.5);
area(1:length(remainingEnergy_dwehc), remainingEnergy_dwehc(1:length(remainingEnergy_dwehc)), 'FaceAlpha', 0.5);
area(1:length(remainingEnergy_fohca), remainingEnergy_fohca(1:length(remainingEnergy_fohca)), 'FaceAlpha', 0.5);
legend(flip({'RCA Method', 'SRA Method', 'RRA Method', 'DBSCAN', 'HEED', 'LEACH-C', 'LEACH', 'DDMPEA', 'DWEHC', 'FOHCA'}), 'Location', 'Best');
hold off;

figure(9)
hold on;
plot(1:length(abpl_ddmpea), abpl_ddmpea(1:length(abpl_ddmpea)), '-', 'Linewidth', 2);
plot(1:length(abpl_dwehc), abpl_dwehc(1:length(abpl_dwehc)), '-', 'Linewidth', 2);
plot(1:length(abpl_fohca), abpl_fohca(1:length(abpl_fohca)), '-', 'Linewidth', 2);
legend({'RCA Method', 'SRA Method', 'RRA Method', 'DBSCAN', 'HEED', 'LEACH-C', 'LEACH', 'DDMPEA', 'DWEHC', 'FOHCA'}, 'Location', 'Best');
hold off;

figure(10)
hold on;
plot(1:length(lsp_ddmpea), lsp_ddmpea(1:length(lsp_ddmpea)), '-', 'Linewidth', 2);
plot(1:length(lsp_dwehc), lsp_dwehc(1:length(lsp_dwehc)), '-', 'Linewidth', 2);
plot(1:length(lsp_fohca), lsp_fohca(1:length(lsp_fohca)), '-', 'Linewidth', 2);
legend({'RCA Method', 'SRA Method', 'RRA Method', 'DBSCAN', 'HEED', 'LEACH-C', 'LEACH', 'DDMPEA', 'DWEHC', 'FOHCA'}, 'Location', 'Best');
hold off;



fprintf("All Clustering Ended");

% fid = fopen('debug.txt', 'w');
% fprintf(fid, 'Length of networkLiveData_1: %d\n', length(networkLiveData_1));
% fprintf(fid, 'Length of networkLiveData_2: %d\n', length(networkLiveData_2));
% fprintf(fid, 'Length of networkLiveData_3: %d\n', length(networkLiveData_3));
% fprintf(fid, 'Length of networkLiveData_4: %d\n', length(networkLiveData_4));
% fprintf(fid, 'Length of networkLiveData_5: %d\n', length(networkLiveData_5));


figure(23)
% for all 5 algos from AllAlgos
% x = categorical({'RCA Method', 'SRA Method', 'RRA Method','PROPOSED WITH DEGREE', 'PROPOSED W/O DEGREE', 'HEED', 'LEACH-C', 'LEACH'});
% x = reordercats(x, {'RCA Method', 'SRA Method', 'RRA Method','PROPOSED WITH DEGREE', 'PROPOSED W/O DEGREE', 'HEED', 'LEACH-C', 'LEACH'});
% y = [networkLiveData_RCA; networkLiveData_SRA; networkLiveData_RRA; networkLiveData_1; networkLiveData_2; networkLiveData_3; networkLiveData_4; networkLiveData_5];

% For just 3 Algos of all Algos
x = categorical({'RCA Method', 'SRA Method', 'RRA Method', 'DBSCAN', 'HEED', 'LEACH-C', 'LEACH', 'DDMPEA', 'DWEHC', 'FOHCA'});
x = reordercats(x, {'RCA Method', 'SRA Method', 'RRA Method', 'DBSCAN', 'HEED', 'LEACH-C', 'LEACH', 'DDMPEA', 'DWEHC', 'FOHCA'});
% y = [networkLiveData_RCA; networkLiveData_SRA; networkLiveData_RRA; networkLiveData_DB; networkLiveData_3; networkLiveData_4; networkLiveData_5];
y = [networkLiveData_RCA;
     networkLiveData_SRA;
     networkLiveData_RRA;
     networkLiveData_DB;
     networkLiveData_3;
     networkLiveData_4;
     networkLiveData_5;
     [firstNodeDead_ddmpea, allNodesDead_ddmpea];
     [firstNodeDead_dwehc, allNodesDead_dwehc];
     [firstNodeDead_fohca, allNodesDead_fohca]];
g = bar(x, y, 'grouped');

% Each bar represent which round in which the first node, half N/W, full n/w dies
set(g(1), 'FaceColor', 'r')
set(g(2), 'FaceColor', 'b')
% set(g(3), 'FaceColor', 'g')
% set(g(4), 'FaceColor', 'm')

% l = {'First Dead Node', '1/4th Network Dead', 'Half Network Dead', 'Full Network Dead'};
l = {'First Dead Node', 'Full Network Dead'};
legend(l, 'Location', 'NorthWest');

title ({'COMPARISON', 'Network Status'; })
xlabel 'Network';
ylabel '# Rounds';

%% ALL FUNCTIONS %%
% sorting nodes based on energy
function S = sortNodes_energy(S, Ni)

    for i = 1:Ni

        S(i).role = 0;

        for j = 1:Ni

            if (S(j).condition == 0)
                break;
            end

            if S(i).Energy > S(j).Energy
                temp = S(i);
                S(i) = S(j);
                S(j) = temp;
            end

        end

    end

end

% sorting nodes based on probability
function S = sortNodes_prob(S, Ni)

    for i = 1:Ni

        S(i).role = 0;

        for j = 1:Ni

            if (S(j).condition == 0)
                break;
            end

            if S(i).prob > S(j).prob
                temp = S(i);
                S(i) = S(j);
                S(j) = temp;
            end

        end

    end

end

%% algorithm for PROPOSED WITH DEGREE
function [S, CH_list, CHeads, firstRound] = maxE_minD_selection_new(S, Ni, Ci, Eo, CH_list, CHeads, firstRound, operating_nodes)

    if (firstRound == 1)
        CH_list = [];
        CHeads = 0;

        for k = 1:Ci
            S(k).cluster = 0;
            S(k).role = 0;
            S(k).chid = 0;
            index = -1;
            count = 0;
            minD = 10 ^ 10;
            maxE = -1;

            % selecting cluster heads based on max energy and min distance
            for i = 1:Ni

                if (S(i).role == 1 || S(i).condition == 0)
                    continue;
                end

                distance = 0;

                for j = 1:Ni

                    if (S(j).condition == 0)
                        continue;
                    end

                    if (i ~= j)
                        distance = distance + sqrt((S(i).x - S(j).x) ^ 2 + (S(i).y - S(j).y) ^ 2);
                        count = count + 1;
                    end

                end

                if ((distance / count) <= minD && (S(i).Energy >= maxE) && (S(i).Energy >= Eo * 0.2))
                    minD = distance;
                    maxE = S(i).Energy;
                    index = i;
                end

            end

            if (index ~= -1)
                S(index).role = 1; % 1 = cluster head
                S(index).tel = S(index).tel + 1; % total number of times it became cluster head
                CHeads = CHeads + 1;
                S(index).cluster = CHeads; % cluster number this node belongs to
                CH_list(CHeads).id = S(index).id;
                CH_list(CHeads).x = S(index).x;
                CH_list(CHeads).y = S(index).y;
                CH_list(CHeads).dts = S(index).dts;
            end

        end

        firstRound
        firstRound = firstRound + 1;

    else
        temp_CH_list = [];
        temp_CHeads = 0;

        for k = 1:CHeads

            if (S(CH_list(k).id).Energy < Eo * 0.2 || CH_list(k).degree < operating_nodes * 0.03)

                S(CH_list(k).id).role = 0;
                index = -1;
                count = 0;
                minD = 10 ^ 10;
                maxE = -1;

                for i = 1:Ni

                    if (S(i).role == 1 || S(i).condition == 0 || CH_list(k).id == i)
                        continue;
                    end

                    distance = 0;

                    for j = 1:Ni

                        if (S(j).condition == 0)
                            continue;
                        end

                        if (i ~= j)
                            distance = distance + sqrt((S(i).x - S(j).x) ^ 2 + (S(i).y - S(j).y) ^ 2);
                            count = count + 1;
                        end

                    end

                    if ((distance / count) <= minD && (S(i).Energy >= maxE) && (S(i).Energy >= Eo * 0.2))
                        minD = distance;
                        maxE = S(i).Energy;
                        index = i;
                    end

                end

                if (index ~= -1)
                    S(index).role = 1; % 1 = cluster head
                    S(index).tel = S(index).tel + 1; % total number of times it became cluster head
                    S(index).cluster = k; % cluster number this node belongs to
                    CH_list(k).id = S(index).id;
                    CH_list(k).x = S(index).x;
                    CH_list(k).y = S(index).y;
                    CH_list(k).dts = S(index).dts;

                    temp_CHeads = temp_CHeads + 1;
                    temp_CH_list(temp_CHeads).id = CH_list(k).id;
                    temp_CH_list(temp_CHeads).x = CH_list(k).x;
                    temp_CH_list(temp_CHeads).y = CH_list(k).y;
                    temp_CH_list(temp_CHeads).dts = CH_list(k).dts;
                end

            else
                temp_CHeads = temp_CHeads + 1;
                temp_CH_list(temp_CHeads).id = CH_list(k).id;
                temp_CH_list(temp_CHeads).x = CH_list(k).x;
                temp_CH_list(temp_CHeads).y = CH_list(k).y;
                temp_CH_list(temp_CHeads).dts = CH_list(k).dts;
            end

        end

        CH_list = temp_CH_list;
        CHeads = temp_CHeads;
    end

end

%% algorithm for PROPOSED W/O DEGREE
function [S, CH_list, CHeads] = maxE_minD_selection(S, Ni, Ci, Eo)
    CH_list = [];
    CHeads = 0;

    for k = 1:Ci
        S(k).cluster = 0;
        S(k).role = 0;
        S(k).chid = 0;
        index = -1;
        count = 0;
        minD = 10 ^ 10;
        maxE = -1;

        % selecting cluster heads based on max energy and min distance
        for i = 1:Ni

            if (S(i).role == 1 || S(i).condition == 0)
                continue;
            end

            distance = 0;

            for j = 1:Ni

                if (S(j).condition == 0)
                    continue;
                end

                if (i ~= j)
                    distance = distance + sqrt((S(i).x - S(j).x) ^ 2 + (S(i).y - S(j).y) ^ 2);
                    count = count + 1;
                end

            end

            if ((distance / count) <= minD && (S(i).Energy >= maxE) && (S(i).Energy >= Eo * 0.2))
                minD = distance;
                maxE = S(i).Energy;
                index = i;
            end

        end

        if (index ~= -1)
            S(index).role = 1; % 1 = cluster head
            S(i).tel = S(i).tel + 1; % total number of times it became cluster head
            CHeads = CHeads + 1;
            S(i).cluster = CHeads; % cluster number this node belongs to
            CH_list(CHeads).id = S(index).id;
            CH_list(CHeads).x = S(index).x;
            CH_list(CHeads).y = S(index).y;
            CH_list(CHeads).dts = S(index).dts;
        end

    end

end

%% algorithm for HEED
function [SN, CH_list, CHeads] = CH_election_HEED(SN, n, p, rounds, CHeads, Eo, CH_list)

    CHeads = 0;

    for i = 1:n
        mult_factor = SN(i).Energy / Eo;
        SN(i).prob = SN(i).prob * mult_factor;
    end

    SN = sortNodes_prob(SN, n);

    for i = 1:n
        SN(i).cluster = 0; % reseting cluster in which the node belongs to
        SN(i).role = 0; % reseting node role
        SN(i).chid = 0; % reseting cluster head id

        if (SN(i).condition == 1 ) % if node is alive and operational

            if (SN(i).prob == 1) % case when its sure to become a cluster head
                SN(i).role = 1; % assigns the node role of a cluster head
                SN(i).rn = rounds; % Assigns the round that the cluster head was elected to the data table
                SN(i).tel = SN(i).tel + 1; % Assigns the number of times the cluster head was elected to the data table
                CHeads = CHeads + 1; % sum of cluster heads that have been elected
                SN(i).cluster = CHeads; % cluster of which the node got elected to be cluster head
                CH_list(CHeads).x = SN(i).x; % X-axis coordinates of elected cluster head
                CH_list(CHeads).y = SN(i).y; % Y-axis coordinates of elected cluster head
                CH_list(CHeads).id = i; % Assigns the node ID of the newly elected cluster head to an array
                CH_list(CHeads).dts = SN(i).dts;

            else
                rand = randi([0, 1], 1, 1); % generates a random number between 0 and 1

                if (rand < SN(i).prob) % if the random number is less than the probability of becoming a cluster head
                    SN(i).role = 1; % assigns the node role of acluster head
                    SN(i).rn = rounds; % Assigns the round that the cluster head was elected to the data table
                    SN(i).tel = SN(i).tel + 1; % Assigns the number of times the cluster head was elected to the data table
                    SN(i).prob = min(SN(i).prob * 2, 1); % Assigns the probability of becoming a cluster head to the data table
                    CHeads = CHeads + 1; % sum of cluster heads that have been elected
                    SN(i).cluster = CHeads; % cluster of which the node got elected to be cluster head
                    CH_list(CHeads).x = SN(i).x; % X-axis coordinates of elected cluster head
                    CH_list(CHeads).y = SN(i).y; % Y-axis coordinates of elected cluster head
                    CH_list(CHeads).id = i; % Assigns the node ID of the newly elected cluster head to an array
                    CH_list(CHeads).dts = SN(i).dts;
                end

            end

        end

        if (CHeads == n * p)
            break;
        end

    end

end

%% algorithm for LEACH-C
function [SN, CL, CLheads] = CH_election_centralized(SN, n, t, tleft, p, rounds, sinkx, sinky, CLheads, Eo, Ecen)
    CL = [];

    for i = 1:n
        SN(i).cluster = 0; % reseting cluster in which the node belongs to
        SN(i).role = 0; % reseting node role
        SN(i).chid = 0; % reseting cluster head id

        if SN(i).rleft > 0
            SN(i).rleft = SN(i).rleft - 1;
        end

        if (SN(i).Energy > 0) && (SN(i).rleft == 0)
            generate = rand;

            if (generate < t  && SN(i).Energy >= Ecen)
                SN(i).role = 1; % assigns the node role of acluster head
                SN(i).rn = rounds; % Assigns the round that the cluster head was elected to the data table
                SN(i).tel = SN(i).tel + 1;
                SN(i).rleft = 1 / p - tleft; % rounds for which the node will be unable to become a CH
                SN(i).dts = sqrt((sinkx - SN(i).x) ^ 2 + (sinky - SN(i).y) ^ 2); % calculates the distance between the sink and the cluster hea
                CLheads = CLheads + 1; % sum of cluster heads that have been elected
                SN(i).cluster = CLheads; % cluster of which the node got elected to be cluster head
                CL(CLheads).x = SN(i).x; % X-axis coordinates of elected cluster head
                CL(CLheads).y = SN(i).y; % Y-axis coordinates of elected cluster head
                CL(CLheads).id = i; % Assigns the node ID of the newly elected cluster head to an array
                CL(CLheads).dts = SN(i).dts; % Assigns the distance between the sink and the cluster head to an array
            end

        end

        if CLheads == n * p
            break;
        end

    end

end

%% algorithm for LEACH
function [SN, CL, CLheads] = CH_election(SN, n, t, tleft, p, rounds, sinkx, sinky, CLheads, Eo)
    CL = [];

    for i = 1:n
        SN(i).cluster = 0; % reseting cluster in which the node belongs to
        SN(i).role = 0; % reseting node role
        SN(i).chid = 0; % reseting cluster head id

        if SN(i).rleft > 0
            SN(i).rleft = SN(i).rleft - 1;
        end

        if (SN(i).Energy > 0) && (SN(i).rleft == 0)
            generate = rand;

            if (generate < t )
                SN(i).role = 1; % assigns the node role of a cluster head
                SN(i).rn = rounds; % Assigns the round that the cluster head was elected to the data table
                SN(i).tel = SN(i).tel + 1;
                SN(i).rleft = 1 / p - tleft; % rounds for which the node will be unable to become a CH
                SN(i).dts = sqrt((sinkx - SN(i).x) ^ 2 + (sinky - SN(i).y) ^ 2); % calculates the distance between the sink and the cluster hea
                CLheads = CLheads + 1; % sum of cluster heads that have been elected
                SN(i).cluster = CLheads; % cluster of which the node got elected to be cluster head
                CL(CLheads).x = SN(i).x; % X-axis coordinates of elected cluster head
                CL(CLheads).y = SN(i).y; % Y-axis coordinates of elected cluster head
                CL(CLheads).id = i; % Assigns the node ID of the newly elected cluster head to an array
                CL(CLheads).dts = SN(i).dts; % Assigns the distance between the sink and the cluster head to an array
            end

        end

        if CLheads == n * p
            break;
        end

    end

end


%% DDMPEA_ANUM_Function
function [CH, clusters] = DDMPEA_ANUM_Function(positions, energy, NP, maxGen, P, sigma1, Eelec, Efs, Emp, packetSize, sink)
    n = size(positions,1);
    pop = rand(NP, n);
    fit = zeros(NP,1);

    % Evaluate initial population
    for i = 1:NP
        fit(i) = fitness_DDMPEA(pop(i,:), positions, energy, sink);
    end

    % Main optimization loop
    for gen = 1:maxGen
        for i = 1:NP
            A = randperm(NP, P);
            weights = exp(-((fit(A) - min(fit(A))) ./ (max(fit(A)) - min(fit(A)) + eps)).^2 / sigma1^2);
            weights = weights ./ sum(weights);
            if all(isnan(weights))
                warning('All weights became NaN at generation %d. Terminating optimization early.', gen);
                break; % Terminate the current optimization loop
            end
            try
                idx = randsample(A, 1, true, weights);
            catch ME
                warning('Error during randsample at generation %d: %s', gen, ME.message);
                disp('Weights at error time:');
                disp(weights);
                idx = A(randi(length(A))); % fallback: pick random A if weights fail
            end
            pop(i,:) = (pop(i,:) + pop(idx,:)) / 2;
            fit(i) = fitness_DDMPEA(pop(i,:), positions, energy, sink);
        end
    end

    % Best solution
    [~, bestIdx] = min(fit);
    selected = pop(bestIdx,:) > 0.5;
    CH = find(selected);

    % Assign nodes to closest CH
    clusters = cell(length(CH), 1);
    for i = 1:n
        if ~selected(i)
            dists = vecnorm(positions(CH,:) - positions(i,:), 2, 2);
            [~, idx] = min(dists);
            clusters{idx} = [clusters{idx}; i];
        end
    end
end

function f = fitness_DDMPEA(sol, positions, energy, sink)
    selected = sol > 0.5;
    if sum(selected) == 0
        f = inf;
        return;
    end
    CH = find(selected);
    f = 0;
    for i = 1:size(positions,1)
        if selected(i)
            d = norm(positions(i,:) - sink);
        else
            dists = vecnorm(positions(CH,:) - positions(i,:), 2, 2);
            d = min(dists);
        end
        f = f + d / energy(i);
    end
end


%% New Simulation Driver for DDMPEA
function [opNodes_ddmpea, dNodes_ddmpea, cNodes_ddmpea, remainingEnergy_ddmpea, abpl_ddmpea, lsp_ddmpea, nrg_ddmpea, threshData_ddmpea, firstNodeDead_ddmpea, quarterNodesDead_ddmpea, halfNodesDead_ddmpea, allNodesDead_ddmpea] = runDDMPEA_Simulation(SN, DistMat, params)
    n = params.numNodes;
    noise_points_count = 0; % DDMPEA does not use noise
    rounds = 0;
    totalEnergy = n * params.E0;
    opNodes_ddmpea = [];
    dNodes_ddmpea = [];
    cNodes_ddmpea = [];
    remainingEnergy_ddmpea = totalEnergy;
    nrg_ddmpea = [];
    threshData_ddmpea = [];
    abpl_ddmpea = [];
    lsp_ddmpea = [];

    firstNodeDead_ddmpea = -1;
    quarterNodesDead_ddmpea = -1;
    halfNodesDead_ddmpea = -1;
    allNodesDead_ddmpea = -1;

    energy = [SN(:).Energy];
    positions = [[SN(:).x]' [SN(:).y]'];
    
    while sum(energy > 0) > 0
        rounds = rounds + 1;
        [CH, clusters] = DDMPEA_ANUM_Function(positions, energy, params.NP, params.maxGen, params.P, params.sigma1, params.Eelec, params.Efs, params.Emp, params.packetSize, [params.sinkx, params.sinky]);
        [energy, dataSent] = calculateEnergy_generic(positions, energy, CH, clusters, params);

        aliveNodes = sum(energy > 0);
        deadNodes = n - aliveNodes;
        fprintf('DDMPEA - Round %d: Alive Nodes = %d, Total Energy = %.4f J\n', rounds, aliveNodes, sum(energy));

        if firstNodeDead_ddmpea == -1 && deadNodes > 0
            firstNodeDead_ddmpea = rounds;
        end
        if quarterNodesDead_ddmpea == -1 && deadNodes >= 0.25 * (n - noise_points_count)
            quarterNodesDead_ddmpea = rounds;
        end
        if halfNodesDead_ddmpea == -1 && deadNodes >= 0.5 * (n - noise_points_count)
            halfNodesDead_ddmpea = rounds;
        end
        if aliveNodes == 0
            allNodesDead_ddmpea = rounds;
            break;
        end

        opNodes_ddmpea = [opNodes_ddmpea, aliveNodes];
        dNodes_ddmpea = [dNodes_ddmpea, deadNodes];
        cNodes_ddmpea = [cNodes_ddmpea, length(CH)];
        threshData_ddmpea = [threshData_ddmpea, dataSent];
        remainingEnergy_ddmpea = [remainingEnergy_ddmpea, sum(energy)];
        nrg_ddmpea = [nrg_ddmpea, totalEnergy - sum(energy)];
        abpl_ddmpea = [abpl_ddmpea, mean(sqrt(sum((positions(CH,:) - [params.sinkx, params.sinky]).^2,2)))];
        lsp_ddmpea = [lsp_ddmpea, max(sqrt(sum((positions(CH,:) - [params.sinkx, params.sinky]).^2,2)))];

        totalEnergy = sum(energy);
    end
end

%% DWEHC_Function
function result = DWEHC_Function(positions, energy, Einit, R)
    n = size(positions,1);
    result.head_id = [];
    result.neighbors = {};

    my_level = zeros(n,1);
    head_id = zeros(n,1);
    my_dis = inf(n,1);

    % Elect cluster heads initially based on energy
    for s = 1:n
        if energy(s) > 0
            head_id(s) = s;
            my_level(s) = 0;
            my_dis(s) = 0;
        end
    end

    % Build hierarchy
    for s = 1:n
        if my_level(s) ~= 0
            continue;
        end
        for v = 1:n
            if s == v || energy(v) <= 0
                continue;
            end
            dx = positions(v,1) - positions(s,1);
            dy = positions(v,2) - positions(s,2);
            dist = sqrt(dx^2 + dy^2);
            if dist <= R
                dnew = my_dis(v) + dist;
                if my_level(s) > 0
                    if dnew < my_dis(s)
                        my_dis(s) = dnew;
                        head_id(s) = head_id(v);
                        my_level(s) = my_level(v) + 1;
                    end
                else
                    my_dis(s) = dnew;
                    head_id(s) = head_id(v);
                    my_level(s) = my_level(v) + 1;
                end
            end
        end
    end

    % Extract unique cluster heads
    unique_heads = unique(head_id(head_id > 0));
    result.head_id = unique_heads;

    % Build clusters
    for i = 1:length(unique_heads)
        members = find(head_id == unique_heads(i));
        result.neighbors{i} = members;
    end
end

%% New Simulation Driver for DWEHC
function [opNodes_dwehc, dNodes_dwehc, cNodes_dwehc, remainingEnergy_dwehc, abpl_dwehc, lsp_dwehc, nrg_dwehc, threshData_dwehc, firstNodeDead_dwehc, quarterNodesDead_dwehc, halfNodesDead_dwehc, allNodesDead_dwehc] = runDWEHC_Simulation(SN, DistMat, params)
    n = params.numNodes;
    noise_points_count = 0;
    rounds = 0;
    totalEnergy = n * params.E0;
    opNodes_dwehc = [];
    dNodes_dwehc = [];
    cNodes_dwehc = [];
    remainingEnergy_dwehc = totalEnergy;
    nrg_dwehc = [];
    threshData_dwehc = [];
    abpl_dwehc = [];
    lsp_dwehc = [];

    firstNodeDead_dwehc = -1;
    quarterNodesDead_dwehc = -1;
    halfNodesDead_dwehc = -1;
    allNodesDead_dwehc = -1;

    energy = [SN(:).Energy];
    positions = [[SN(:).x]' [SN(:).y]'];

    while sum(energy > 0) > 0
        rounds = rounds + 1;
        result = DWEHC_Function(positions, energy, params.Einit, params.R);
        CH = result.head_id;
        clusters = result.neighbors;
        [energy, dataSent] = calculateEnergy_generic(positions, energy, CH, clusters, params);

        aliveNodes = sum(energy > 0);
        deadNodes = n - aliveNodes;
        fprintf('DWEHC - Round %d: Alive Nodes = %d, Total Energy = %.4f J\n', rounds, aliveNodes, sum(energy));

        if firstNodeDead_dwehc == -1 && deadNodes > 0
            firstNodeDead_dwehc = rounds;
        end
        if quarterNodesDead_dwehc == -1 && deadNodes >= 0.25 * (n - noise_points_count)
            quarterNodesDead_dwehc = rounds;
        end
        if halfNodesDead_dwehc == -1 && deadNodes >= 0.5 * (n - noise_points_count)
            halfNodesDead_dwehc = rounds;
        end
        if aliveNodes == 0
            allNodesDead_dwehc = rounds;
            break;
        end

        opNodes_dwehc = [opNodes_dwehc, aliveNodes];
        dNodes_dwehc = [dNodes_dwehc, deadNodes];
        cNodes_dwehc = [cNodes_dwehc, length(unique(CH))];
        threshData_dwehc = [threshData_dwehc, dataSent];
        remainingEnergy_dwehc = [remainingEnergy_dwehc, sum(energy)];
        nrg_dwehc = [nrg_dwehc, totalEnergy - sum(energy)];
        abpl_dwehc = [abpl_dwehc, mean(sqrt(sum((positions(CH,:) - [params.sinkx, params.sinky]).^2,2)))];
        lsp_dwehc = [lsp_dwehc, max(sqrt(sum((positions(CH,:) - [params.sinkx, params.sinky]).^2,2)))];

        totalEnergy = sum(energy);
    end
end

%% FOHCA_Function
function [CH, clusters] = FOHCA_Function(nodePos, energy, k, FO_iter, w1, w2)
    N = size(nodePos,1);

    if N < k
        warning("Only %d alive nodes but %d CHs requested — using all nodes as heads.", N, k);
        CH     = 1:N;
        clusters = assignClusters(nodePos, CH);
        return;
    end

    CH = randperm(N, k);

    for iter = 1:FO_iter
        clusters = assignClusters(nodePos, CH);

        newCHs = zeros(1,k);
        for c = 1:k
            members = clusters{c};
            numMembers = numel(members);
            bestFit = inf;
            bestNode = CH(c);
            for m = members'
                dists = sqrt(sum((nodePos(members,:) - nodePos(m,:)).^2, 2));
                avgDist = mean(dists);
                avgEnergy = mean(energy(members));
                fit = w1*avgDist - w2*avgEnergy;
                if fit < bestFit
                    bestFit = fit;
                    bestNode = m;
                end
            end
            newCHs(c) = bestNode;
        end

        if isequal(sort(newCHs), sort(CH))
            break;
        end
        CH = newCHs;
    end

    clusters = assignClusters(nodePos, CH);
end

function clusters = assignClusters(nodePos, CHs)
    k = numel(CHs);
    N = size(nodePos,1);
    clusters = cell(1,k);
    D = pdist2(nodePos, nodePos(CHs,:));
    [~, idx] = min(D,[],2);
    for i = 1:k
        clusters{i} = find(idx==i);
    end
end

%% New Simulation Driver for FOHCA
function [opNodes_fohca, dNodes_fohca, cNodes_fohca, remainingEnergy_fohca, abpl_fohca, lsp_fohca, nrg_fohca, threshData_fohca, firstNodeDead_fohca, quarterNodesDead_fohca, halfNodesDead_fohca, allNodesDead_fohca] = runFOHCA_Simulation(SN, DistMat, params)
    n = params.numNodes;
    noise_points_count = 0;
    rounds = 0;
    totalEnergy = n * params.E0;
    opNodes_fohca = [];
    dNodes_fohca = [];
    cNodes_fohca = [];
    remainingEnergy_fohca = totalEnergy;
    nrg_fohca = [];
    threshData_fohca = [];
    abpl_fohca = [];
    lsp_fohca = [];

    firstNodeDead_fohca = -1;
    quarterNodesDead_fohca = -1;
    halfNodesDead_fohca = -1;
    allNodesDead_fohca = -1;

    energy = [SN(:).Energy];
    positions = [[SN(:).x]' [SN(:).y]'];

    while sum(energy > 0) > 0
        rounds = rounds + 1;
        [CH, clusters] = FOHCA_Function(positions, energy, params.k, params.FO_iter, params.w1, params.w2);
        [energy, dataSent] = calculateEnergy_generic(positions, energy, CH, clusters, params);

        aliveNodes = sum(energy > 0);
        deadNodes = n - aliveNodes;
        fprintf('FOHCA - Round %d: Alive Nodes = %d, Total Energy = %.4f J\n', rounds, aliveNodes, sum(energy));

        if firstNodeDead_fohca == -1 && deadNodes > 0
            firstNodeDead_fohca = rounds;
        end
        if quarterNodesDead_fohca == -1 && deadNodes >= 0.25 * (n - noise_points_count)
            quarterNodesDead_fohca = rounds;
        end
        if halfNodesDead_fohca == -1 && deadNodes >= 0.5 * (n - noise_points_count)
            halfNodesDead_fohca = rounds;
        end
        if aliveNodes == 0
            allNodesDead_fohca = rounds;
            break;
        end

        opNodes_fohca = [opNodes_fohca, aliveNodes];
        dNodes_fohca = [dNodes_fohca, deadNodes];
        cNodes_fohca = [cNodes_fohca, length(CH)];
        threshData_fohca = [threshData_fohca, dataSent];
        remainingEnergy_fohca = [remainingEnergy_fohca, sum(energy)];
        nrg_fohca = [nrg_fohca, totalEnergy - sum(energy)];
        abpl_fohca = [abpl_fohca, mean(sqrt(sum((positions(CH,:) - [params.sinkx, params.sinky]).^2,2)))];
        lsp_fohca = [lsp_fohca, max(sqrt(sum((positions(CH,:) - [params.sinkx, params.sinky]).^2,2)))];

        totalEnergy = sum(energy);
    end
end

%% calculates energy for the DDMPEA, DWEHC & FOHCA
function [energyUpdated, dataSent] = calculateEnergy_generic(positions, energy, CHs, clusters, params)
    dataSent = 0;
    for i = 1:numel(CHs)
        head = CHs(i);
        members = clusters{i};
        % Member transmissions
        for m = members(:)'
            if m==head, continue; end
            d = norm(positions(m,:)-positions(head,:));
            % Etx = params.Eelec*params.packetSize + params.Efs*d^2*params.packetSize;
            if d <= params.Tx_range
                Etx = params.Eelec * params.packetSize + params.Efs * d^params.alpha * params.packetSize;
            else
                Etx = params.Eelec * params.packetSize + params.Emp * d^params.alpha * params.packetSize;
            end
            energy(m)   = energy(m) - Etx;
            energy(head) = energy(head) - params.Eelec*params.packetSize;
        end
        % Aggregation
        energy(head) = energy(head) - params.Eda*params.packetSize*numel(members);
        % Head to sink
        dBS = norm(positions(head,:)- [params.sinkx, params.sinky]);
        EtxBS = params.Eelec*params.packetSize + params.Emp*dBS^4*params.packetSize;
        energy(head) = energy(head) - EtxBS;
        dataSent = dataSent + params.packetSize;
    end
    energyUpdated = max(energy,0);
end

%% GENERAL ALGORITHMS FOR ALL PROTOCOLS %%
% sorting nodes based on proximity
function proximity_list = sortNodes_dts(CH_list, proximity_list)

    if length(proximity_list) == 1
        return;
    end

    for i = 1:length(proximity_list)

        if proximity_list(i) == 0
            continue;
        end

        for j = 1:length(proximity_list)

            if proximity_list(j) == 0
                continue;
            end

            if CH_list(proximity_list(i)).dts > CH_list(proximity_list(j)).dts
                temp = proximity_list(i);
                proximity_list(i) = proximity_list(j);
                proximity_list(j) = temp;
            end

        end

    end

end

% index finding function
function bool = is_found(proximity, index)

    bool = 0;

    for i = 1:length(proximity)

        if (proximity(i) == index)
            bool = 1;
            break;
        end

    end

end

% function to calculate proximity for CHs
function CH_list = CH_list_with_proximity(CH_list, CHeads, rad, rounds)

    CH_list = arrayfun(@(x) setfield(x, 'proximity', []), CH_list);

    % assinging the index of sink as 0 to the proximity list of each CH if it is within the communication range
    for i = 1:CHeads

        if (CH_list(i).dts <= rad)
            CH_list(i).proximity = [CH_list(i).proximity, 0];
        end

    end

    % assinging the index of CHs as their proximity list if they are within the communication range
    for i = 1:CHeads

        for j = 1:CHeads

            if (i ~= j)

                if (sqrt((CH_list(i).x - CH_list(j).x) ^ 2 + (CH_list(i).y - CH_list(j).y) ^ 2) <= rad)
                    CH_list(i).proximity = [CH_list(i).proximity, j];
                end

            end

        end

    end

    for i = 1:CHeads
        CH_list(i).proximity = sortNodes_dts(CH_list, CH_list(i).proximity);
    end

end

% function to calculate the number of hops for each CH
function [hops, indices] = calculate_hops(CH_list, index, indices, hops, rounds)

    if (length(CH_list(index).proximity) ~= 0 && CH_list(index).proximity(1) == 0)
        hops = 1;
    else
        nextIndex = 0;

        for i = 1:length(CH_list(index).proximity)

            for j = 1:length(indices)

                if CH_list(index).proximity(i) == indices(j)
                    nextIndex = 0;
                    break;
                else
                    nextIndex = CH_list(index).proximity(i);
                end

            end

            if nextIndex ~= 0
                break;
            end

        end

        if (nextIndex == 0)
        else
            indices = [indices, nextIndex];
            [hops, indices] = calculate_hops(CH_list, nextIndex, indices, hops, rounds);
            hops = hops + 1;
        end

    end

end

% driver function to calculate the number of hops for each CH
function [CH_list, ABPL] = CH_list_with_HOPS(CH_list, CHeads, rad, rounds)

    CH_list = CH_list_with_proximity(CH_list, CHeads, rad, rounds);
    CH_list = arrayfun(@(x) setfield(x, 'hops', 0), CH_list);

    totalHops = 0;

    % calculating the hops of each CH from the sink
    for i = 1:CHeads

        % if the CH is directly within the communication range of the sink
        if (is_found(CH_list(i).proximity, 0) == 1)
            CH_list(i).hops = 1;
            CH_list(i).lsp_path = [0];

        else
            indices = [];
            indices = [indices, i];
            hops = 0;
            [hops, indices] = calculate_hops(CH_list, i, indices, hops, rounds);

            CH_list(i).hops = hops;
            CH_list(i).lsp_path = indices;
        end

        totalHops = totalHops + CH_list(i).hops;

    end

    ABPL = totalHops / (CHeads * (CHeads + 1) / 2);

end

% calculating the Longest Shortest Path for each CH
function lsp = calculating_lsp(CH_list, CHeads)
    lsp = -1;

    for i = 1:CHeads
        CH_list(i).lsp = 0;

        if CH_list(i).lsp_path(1) == 0
            CH_list(i).lsp = CH_list(i).dts;
        else

            for j = 1:length(CH_list(i).lsp_path)

                if CH_list(i).lsp_path(j) == 0
                    continue;
                else
                    CH_list(i).lsp = CH_list(i).lsp + (sqrt((CH_list(i).x - CH_list(CH_list(i).lsp_path(j)).x) ^ 2 + (CH_list(i).y - CH_list(CH_list(i).lsp_path(j)).y) ^ 2));

                end

            end

        end

    end

    for i = 1:CHeads
        lsp = max(lsp, CH_list(i).lsp);
    end
end

function index = findCHIndex(CH_list, target_id)
    % Initialize index to -1 (indicating not found)
    index = -1;
    % Loop through the array CH_list to find the target id
    for i = 1:length(CH_list)
        if CH_list(i).id == target_id
            index = i; 
            break; % Exit loop once found
        end
    end
end