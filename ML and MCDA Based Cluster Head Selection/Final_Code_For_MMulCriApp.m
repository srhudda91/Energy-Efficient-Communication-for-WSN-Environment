close all;
clear;
clc;

% COLORS

% RCA : -b
% RRA : -r
% SRA : -g
% With degree : -c
% W/O degree : -m
% HEED : -y
% LEACH-C: -orange
% LEACH : -k


%%%%%%%%%%%%%%%%%%%% Network Establishment Parameters %%%%%%%%%%%%%%%%%%%%
%%% plot of Operation %%%
% rng('default');
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
Eelec = 50 * 10 ^ (-9); % units in Joules/bit
% Transmit Amplifier Types %
Eamp = 100 * 10 ^ (-12); % units in Joules/bit/m^2 (amount of energy spent by the amplifier to transmit the bits)
% Data Aggregation Energy %
EDA = 5 * 10 ^ (-9); % units in Joules/bit
% Size of data package %
pkt_size = 10; % units in bits
% Transmission range
Tx_range = 50; % can be kept same as Eps
% energy threshold perc
E_thresh = 0.2;

% Round of Operation %
%%% Creation of the Wireless Sensor Network %%%
for i = 1:n
    pos(i).x = x_min + (x_max - x_min) * rand(); % X-axis coordinates of sensor node
    pos(i).y = y_min + (y_max - y_min) * rand(); % Y-axis coordinates of sensor node
end
% Plotting the WSN
% for i = 1:n
%     figure(1)
%     plot(x, y, x_max, y_max, SN(i).x, SN(i).y, 'ob', sinkx, sinky, '*r');
%     title 'Wireless Sensor Network';
%     xlabel 'X-coordinate';
%     ylabel 'Y-coordinate';
%     hold on;
% end
% Calculate the pairwise distance matrix
DistMat = zeros(n, n);
for i = 1:n
    for j = 1:n
        DistMat(i, j) = sqrt((pos(i).x - pos(j).x)^2 + (pos(i).y - pos(j).y)^2);
    end
end
%%% Step 2: Apply DBSCAN %%%
Eps = 110;    % Epsilon neighborhood radius
MinPts = 3;  % Minimum number of points to form a cluster
% Apply DBSCAN
Clust = DBSCAN(DistMat, Eps, MinPts);
noise_points_count = sum(Clust == 0);
fprintf("Number of Unusable/Unassigned Nodes (NOISE): %d/%d\n", noise_points_count, n);
fprintf("Number of Usable/Assigned Nodes: %d/%d\n", n - noise_points_count, n);
%%% Step 3: Visualize the Clusters %%%
figure;
hold on;
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
% title('DBSCAN Clustering of WSN');
% xlabel('X Coordinate');
% ylabel('Y Coordinate');
% hold off;
% Doing RRA
% parameters:
% 1. energy left
% 2. Distance from sink node
% 3. average distance from all cluster members
% 4. How many times node has become cluster head

n_parameters = 4;


% Now simulating RRA
ranks_rr = [1, 2, 3, 4];
rr_weights = zeros(1, n);
sum_inverse_r = sum(1 ./ ranks_rr);
for j = 1:n_parameters
    rr_weights(j) = (1 / ranks_rr(j)) / sum_inverse_r;
end
SN = resetNodes(n, Eo, sinkx, sinky, pos);
[opNodes_rr, dNodes_rr, cNodes_rr, remainingEnergy_rr, abpl_rr, lsp_rr, nrg_rr, threshData_rr, firstNodeDead_rr, halfNodesDead_rr, allNodesDead_rr] = runSimulation(rr_weights, DistMat, SN, Clust, Eo, Eps, n, noise_points_count, Eelec, Eamp, EDA, pkt_size, Tx_range, E_thresh);


% Now simulating RCA
ranks_roc = [1, 2, 3, 4];
roc_weights = zeros(1, n_parameters);
for i = 1:n_parameters
    roc_weights(i) = sum(1 ./ ranks_roc(i:end)) / n_parameters;
end
SN = resetNodes(n, Eo, sinkx, sinky, pos);
[opNodes_roc, dNodes_roc, cNodes_roc, remainingEnergy_roc, abpl_roc, lsp_roc, nrg_roc, threshData_roc, firstNodeDead_roc, halfNodesDead_roc, allNodesDead_roc] = runSimulation(roc_weights, DistMat, SN, Clust, Eo, Eps, n, noise_points_count, Eelec, Eamp, EDA, pkt_size, Tx_range, E_thresh);


% Now simulating SRA
ranks_rs = [1, 2, 3, 4];
rs_weights = 2 * (n + 1 - ranks_rs) ./ (n * (n + 1));
SN = resetNodes(n, Eo, sinkx, sinky, pos);
[opNodes_rs, dNodes_rs, cNodes_rs, remainingEnergy_rs, abpl_rs, lsp_rs, nrg_rs, threshData_rs, firstNodeDead_rs, halfNodesDead_rs, allNodesDead_rs] = runSimulation(rs_weights, DistMat, SN, Clust, Eo, Eps, n, noise_points_count, Eelec, Eamp, EDA, pkt_size, Tx_range, E_thresh);



% hold off;

% data = [firstNodeDead_roc, firstNodeDead_rr, firstNodeDead_rs;
%     halfNodesDead_roc, halfNodesDead_rr, halfNodesDead_rs;
%     allNodesDead_roc, allNodesDead_rr, allNodesDead_rs];

% figure;
% bar(data);

% set(gca, 'XTickLabel', {'First Node Dead', 'Half Nodes Dead', 'All Nodes Dead'});

% legend({'RCA', 'RRA', 'SRA'}, 'Location', 'northwest');

% title('Comparison of Node Death Metrics for RCA, RRA, and SRA');
% xlabel('Metrics');
% ylabel('Number of Rounds');

% grid on;



p = 0.1; % a 1 percent of the total amount of nodes used in the network is proposed to give good results
Ci = p * n;
rounds = 0;
totalEnergy = n * Eo;
operating_nodes = n;
temp_val = 0;
flagFirstDead = 0;
stop_flag = 0;

% ---------------------------- Heed --------------------------
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
% firstRound = 1;
totalData = 0;
networkStatus = 1;
rad = 200;
dead_nodes = 0;
totalEnergy = n * Eo;
rounds = 0;
operating_nodes = n;

temp_val = 0;
stop_flag = 0;

opNodes = [];
dNodes = [];
cNodes = [];
threshData = [];
remainingEnergy = [];
nrg = [];
flagFirstDead = 0;
networkLiveData_Heed = [];
abpl_3 = [];
lsp_3 = [];

prevEnergy = totalEnergy;

while (operating_nodes > 0 && stop_flag == 0)
    
    % Displays Current Round %
    disp('Heed: ');
    disp(rounds);
    rounds = rounds + 1;
    
    % Reseting Previous Amount Of Energy Consumed In the Network on the Previous Round %
    
    totalTransmissionsPerRound = 0;
    
    % Cluster Heads Election %
    [SN, CH_list, CHeads] = CH_election_HEED(SN, n, p, rounds, CHeads, Eo, CH_list);
    
    if (CHeads ~= 0)
        % Fixing the size of "CL" array %
        CH_list = CH_list(1:CHeads);
        CH_list = arrayfun(@(x) setfield(x, 'degree', 0), CH_list);
        
        % Calculating node degree of cluster head based on Distance to cluster members %
        for i = 1:n
            
            if ((SN(i).role == 0) && (SN(i).condition == 1)) % if node is normal
                
                for m = 1:CHeads
                    d(m) = sqrt((CH_list(m).x - SN(i).x) ^ 2 + (CH_list(m).y - SN(i).y) ^ 2);
                    % we calculate the distance 'd' between the sensor node that is
                    % transmitting and the cluster head that is receiving with the following equation+
                    % d=sqrt((x2-x1)^2 + (y2-y1)^2) where x2 and y2 the coordinates of
                    % the cluster head and x1 and y1 the coordinates of the transmitting node
                end
                
                d = d(1:CHeads); % fixing the size of "d" array
                [M, I] = min(d(:)); % finds the minimum distance of node to CH
                [Row, Col] = ind2sub(size(d), I); % displays the Cluster Number in which this node belongs too
                CH_list(Col).degree = CH_list(Col).degree + 1;
                
            end
            
        end
        
        % adding new field as Cost as a function of node degree to CH_list %
        CH_list = arrayfun(@(x) setfield(x, 'cost', 0), CH_list);
        
        for i = 1:CHeads
            
            if (CH_list(i).degree ~= 0)
                CH_list(i).cost = 1 / CH_list(i).degree;
            else
                CH_list(i).cost = 100;
            end
            
            CH_list(i).degree = 0;
            
        end
        
        for i = 1:n
            
            if ((SN(i).role == 0) && (SN(i).condition == 1)) % if node is normal
                
                for m = 1:CHeads
                    c(m) = CH_list(m).cost;
                    % we calculate the distance 'd' between the sensor node that is
                    % transmitting and the cluster head that is receiving with the following equation+
                    % d=sqrt((x2-x1)^2 + (y2-y1)^2) where x2 and y2 the coordinates of
                    % the cluster head and x1 and y1 the coordinates of the transmitting node
                end
                
                c = c(1:CHeads); % fixing the size of "d" array
                [M, I] = min(c(:)); % finds the minimum distance of node to CH
                [Row, Col] = ind2sub(size(c), I); % displays the Cluster Number in which this node belongs too
                SN(i).cluster = Col; % assigns node to the cluster
                SN(i).dtch = d(Col); % assigns the distance of node to CH
                SN(i).chid = CH_list(Col).id;
                CH_list(Col).degree = CH_list(Col).degree + 1;
                
            end
            
        end
        
        % printing the degree of each CH %
        
        % calculating HOPS and Proximity %
        [CH_list, ABPL] = CH_list_with_HOPS(CH_list, CHeads, rad, rounds);
        Network_Longest_Shortest_Path = calculating_lsp(CH_list, CHeads);
        
        abpl_3(rounds) = ABPL;
        lsp_3(rounds) = Network_Longest_Shortest_Path;
        
        %%%%%% Steady-State Phase %%%%%%
        % Energy Dissipation for normal nodes %
        
        for i = 1:n
            
            if (SN(i).condition == 1) && (SN(i).role == 0)
                
                ETx = Eelec * pkt_size + Eamp * pkt_size * SN(i).dtch ^ 2;
                SN(i).Energy = SN(i).Energy - ETx;
                if SN(i).Energy < Eo * E_thresh
                    dead_nodes = dead_nodes + 1;
                    operating_nodes = operating_nodes - 1;
                    SN(i).condition = 0;
                    SN(i).chid = 0;
                    SN(i).rop = rounds;
                    continue;
                end
                totalTransmissionsPerRound = totalTransmissionsPerRound + 1;
                
                totalData = totalData + pkt_size;
                
                % Dissipation for cluster head during reception
                if SN(SN(i).chid).Energy > 0 && SN(SN(i).chid).condition == 1 && SN(SN(i).chid).role == 1
                    ERx = (Eelec + EDA) * pkt_size;
                    
                    
                    SN(SN(i).chid).Energy = SN(SN(i).chid).Energy - ERx;
                    
                    if SN(SN(i).chid).Energy <= Eo * E_thresh % if cluster heads energy depletes with reception
                        SN(SN(i).chid).condition = 0;
                        SN(SN(i).chid).rop = rounds;
                        dead_nodes = dead_nodes + 1;
                        operating_nodes = operating_nodes - 1;
                    end
                    
                end
                
            end
            
        end
        
        % Energy Dissipation for cluster head nodes %
        
        [SN, dead_nodes, operating_nodes, energy_consumed_ch, totalTransmissionsPerRound] = multi_hop_transmission(SN, n, Tx_range, pkt_size, Eelec, EDA, Eamp, Eo, E_thresh, rounds, dead_nodes, operating_nodes, totalTransmissionsPerRound);
        
        
        
    end
    
    if operating_nodes < n && temp_val == 0
        temp_val = 1;
        flagFirstDead = rounds;
        networkLiveData_Heed(networkStatus) = rounds;
        networkStatus = networkStatus + 1;
    end
    
    if operating_nodes <= n * 0.5 && temp_val == 1
        temp_val = 2;
        networkLiveData_Heed(networkStatus) = rounds;
        networkStatus = networkStatus + 1;
    end
    
    
    
    if CHeads == 0 || operating_nodes < 3
        stop_flag = 1;
        CHeads = 0;
        networkLiveData_Heed(networkStatus) = rounds;
    end
    
    % Track the remaining total energy (include only alive nodes to avoid negative energies)
    % Not the best way to do this again
    total_remaining_energy = sum([SN([SN(:).condition] == 1).Energy]);
    remainingEnergy = [remainingEnergy, total_remaining_energy];
    
    nrg = [nrg, prevEnergy - total_remaining_energy];
    prevEnergy = total_remaining_energy;
    
    opNodes(rounds) = operating_nodes;
    dNodes(rounds) = dead_nodes;
    cNodes(rounds) = CHeads;
    threshData(rounds) = totalTransmissionsPerRound;
    
end

if networkStatus == 1
    networkStatus = networkStatus + 1;
    networkLiveData_Heed(networkStatus) = rounds;
    networkStatus = networkStatus + 1;
    networkLiveData_Heed(networkStatus) = rounds;
elseif networkStatus == 2
    networkStatus = networkStatus + 1;
    networkLiveData_Heed(networkStatus) = rounds;
elseif networkStatus == 3
    networkLiveData_Heed(networkStatus) = rounds;
end

% Plotting Simulation Results "Operating Nodes Per Round" %
figure(2)
plot(1:length(opNodes), opNodes(1:length(opNodes)), '-y', 'Linewidth', 2);
hold on;

figure(3)
plot(1:length(dNodes), dNodes(1:length(dNodes)), '-y', 'Linewidth', 2);
hold on;

figure(4)
plot(1:length(cNodes), cNodes(1:length(cNodes)), '-y', 'Linewidth', 2);
hold on;

figure(5)
plot(1:length(threshData), threshData(1:length(threshData)), '-y', 'Linewidth', 2);
hold on;

figure(6)

plot(1:length(nrg), nrg(1:length(nrg)), '-y', 'Linewidth', 2);
hold on;

figure(7)
area_h_heed = area(1:length(remainingEnergy), remainingEnergy(1:length(remainingEnergy)), 'FaceAlpha', 0.1, 'FaceColor', 'y');
hold on;

figure(8)
plot(1:length(abpl_3), abpl_3(1:length(abpl_3)), '-y', 'Linewidth', 2);
hold on;

figure(9)
plot(1:length(lsp_3), lsp_3(1:length(lsp_3)), '-y', 'Linewidth', 2);
hold on;

% -------------------------- Leach-C -------------------------

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

dead_nodes = 0;
totalData = 0;
networkStatus = 1;
rad = 200;
rounds = 0;
totalEnergy = n * Eo;
operating_nodes = n;

temp_val = 0;
stop_flag = 0;
opNodes = [];
dNodes = [];
cNodes = [];
threshData = [];
remainingEnergy = [];
nrg = [];
flagFirstDead = 0;
networkLiveData_LeechC = [];
abpl_4 = [];
lsp_4 = [];

prevEnergy = totalEnergy;

while (operating_nodes > 0 && stop_flag == 0)
    
    % Displays Current Round %
    disp('Leach-C: ');
    disp(rounds);
    rounds = rounds + 1;
    
    % Reseting Previous Amount Of Cluster Heads In the Network %
    
    CLheads = 0;
    
    % Threshold Value %
    t = (p / (1 - p * (mod(rounds, 1 / p))));
    
    % Re-election Value %
    tleft = mod(rounds, 1 / p);
    
    
    
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
    
    % Fixing the size of "CL" array %
    CL = CL(1:CLheads);
    CL = arrayfun(@(x) setfield(x, 'degree', 0), CL);
    
    % Grouping the Nodes into Clusters & caclulating the distance between node and cluster head %
    
    for i = 1:n
        
        if (SN(i).role == 0) && (SN(i).condition == 1) && (CLheads > 0) % if node is normal
            
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
    
    % calculating only if there are CHs in the network %
    if (CLheads ~= 0)
        
        % calculating HOPS and Proximity %
        [CL, ABPL] = CH_list_with_HOPS(CL, CLheads, rad, rounds);
        Network_Longest_Shortest_Path = calculating_lsp(CL, CLheads);
        
        abpl_4(rounds) = ABPL;
        lsp_4(rounds) = Network_Longest_Shortest_Path;
        
    end
    
    %%%%%% Steady-State Phase %%%%%%
    % Energy Dissipation for normal nodes %
    
    totalTransmissionsPerRound = 0;
    for i = 1:n
        
        if (SN(i).condition == 1) && (SN(i).role == 0) && (CLheads > 0)
            ETx = Eelec * pkt_size + Eamp * pkt_size * SN(i).dtch ^ 2;
            SN(i).Energy = SN(i).Energy - ETx;
            if SN(i).Energy < Eo * E_thresh
                dead_nodes = dead_nodes + 1;
                operating_nodes = operating_nodes - 1;
                SN(i).condition = 0;
                SN(i).chid = 0;
                SN(i).rop = rounds;
                continue;
            end
            totalTransmissionsPerRound = totalTransmissionsPerRound + 1;
            totalData = totalData + pkt_size;
            % Dissipation for cluster head during reception
            if SN(SN(i).chid).condition == 1 && SN(SN(i).chid).role == 1
                ERx = (Eelec + EDA) * pkt_size;
                
                
                SN(SN(i).chid).Energy = SN(SN(i).chid).Energy - ERx;
                
                if SN(SN(i).chid).Energy <= Eo * 0.2 % if cluster heads energy depletes with reception
                    SN(SN(i).chid).condition = 0;
                    SN(SN(i).chid).rop = rounds;
                    dead_nodes = dead_nodes +1;
                    operating_nodes = operating_nodes - 1;
                end
                
            end
            
        end
        
    end
    
    % Energy Dissipation for cluster head nodes %
    
    [SN, dead_nodes, operating_nodes, energy_consumed_ch, totalTransmissionsPerRound] = multi_hop_transmission(SN, n, Tx_range, pkt_size, Eelec, EDA, Eamp, Eo, E_thresh, rounds, dead_nodes, operating_nodes, totalTransmissionsPerRound);
    
    
    
    
    if operating_nodes < n && temp_val == 0
        temp_val = 1;
        flagFirstDead = rounds;
        networkLiveData_LeechC(networkStatus) = rounds;
        networkStatus = networkStatus + 1;
    end
    
    if operating_nodes <= n * 0.5 && temp_val == 1
        temp_val = 2;
        networkLiveData_LeechC(networkStatus) = rounds;
        networkStatus = networkStatus + 1;
    end
    
    
    cnt = 0;
    
    for i = 1:n
        
        if (SN(i).condition == 0)
            cnt = cnt + 1;
        end
        
    end
    
    if cnt == n || operating_nodes < 3
        networkLiveData_LeechC(networkStatus) = rounds;
        stop_flag = 1;
    end
    
    % Track the remaining total energy (include only alive nodes to avoid negative energies)
    % Not the best way to do this again
    total_remaining_energy = sum([SN([SN(:).condition] == 1).Energy]);
    remainingEnergy = [remainingEnergy, total_remaining_energy];
    
    nrg = [nrg, prevEnergy - total_remaining_energy];
    prevEnergy = total_remaining_energy;
    
    opNodes(rounds) = operating_nodes;
    dNodes(rounds) = dead_nodes;
    cNodes(rounds) = CLheads;
    threshData(rounds) = totalTransmissionsPerRound;
    
end

if networkStatus == 1
    networkStatus = networkStatus + 1;
    networkLiveData_LeechC(networkStatus) = rounds;
    networkStatus = networkStatus + 1;
    networkLiveData_LeechC(networkStatus) = rounds;
elseif networkStatus == 2
    networkStatus = networkStatus + 1;
    networkLiveData_LeechC(networkStatus) = rounds;
elseif networkStatus == 3
    networkLiveData_LeechC(networkStatus) = rounds;
end

% Plotting Simulation Results "Operating Nodes Per Round" %
figure(2)
plot(1:length(opNodes), opNodes(1:length(opNodes)), '-', 'Linewidth', 2, 'Color', [1, 0.5, 0]);
hold on;

figure(3)
plot(1:length(dNodes), dNodes(1:length(dNodes)), '-', 'Linewidth', 2, 'Color', [1, 0.5, 0]);
hold on;

figure(4)
plot(1:length(cNodes), cNodes(1:length(cNodes)), '-', 'Linewidth', 2, 'Color', [1, 0.5, 0]);
hold on;

figure(5)
plot(1:length(threshData), threshData(1:length(threshData)), '-', 'Linewidth', 2, 'Color', [1, 0.5, 0]);
hold on;

figure(6)
plot(1:length(nrg), nrg(1:length(nrg)), '-', 'Linewidth', 2, 'Color', [1, 0.5, 0]);
hold on;

figure(7)
area_h_leechc = area(1:length(remainingEnergy), remainingEnergy(1:length(remainingEnergy)), 'FaceAlpha', 0.3, 'FaceColor', [1, 0.5, 0]);
hold on;

figure(8)
plot(1:length(abpl_4), abpl_4(1:length(abpl_4)), '-', 'Linewidth', 2, 'Color', [1, 0.5, 0]);
hold on;

figure(9)
plot(1:length(lsp_4), lsp_4(1:length(lsp_4)), '-', 'Linewidth', 2, 'Color', [1, 0.5, 0]);
hold on;


% --------------------------Leach------------------------------
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

dead_nodes = 0;
CHeads = 0;
CLheads = 0;
CH_list = [];
firstRound = 1;
totalData = 0;
networkStatus = 1;
rad = 200;

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
networkLiveData_Leech = [];
abpl_5 = [];
lsp_5 = [];

prevEnergy = totalEnergy;

while (operating_nodes > 0 && stop_flag == 0)
    
    % Displays Current Round %
    disp('Leach: ');
    disp(rounds);
    rounds = rounds + 1;
    totalTransmissionsPerRound = 0;
    
    % Threshold Value %
    t = (p / (1 - p * (mod(rounds, 1 / p))));
    
    % Re-election Value %
    tleft = mod(rounds, 1 / p);
    
    % Reseting Previous Amount Of Cluster Heads In the Network %
    CLheads = 0;
    
    
    
    
    % Cluster Heads Election %
    [SN, CL, CLheads] = CH_election(SN, n, t, tleft, p, rounds, sinkx, sinky, CLheads, Eo);
    
    % Fixing the size of "CL" array %
    CL = CL(1:CLheads);
    CL = arrayfun(@(x) setfield(x, 'degree', 0), CL);
    
    % Grouping the Nodes into Clusters & caclulating the distance between node and cluster head %
    
    for i = 1:n
        
        if (SN(i).role == 0) && (SN(i).condition == 1) && (CLheads > 0) % if node is normal
            
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
    
    %%%%%% Steady-State Phase %%%%%%
    
    % Energy Dissipation for normal nodes %
    
    for i = 1:n
        
        if (SN(i).condition == 1) && (SN(i).role == 0) && (CLheads > 0)
            
            if SN(i).Energy > 0
                ETx = Eelec * pkt_size + Eamp * pkt_size * SN(i).dtch ^ 2;
                SN(i).Energy = SN(i).Energy - ETx;
                if SN(i).Energy < Eo * E_thresh
                    dead_nodes = dead_nodes + 1;
                    operating_nodes = operating_nodes - 1;
                    SN(i).condition = 0;
                    SN(i).chid = 0;
                    SN(i).rop = rounds;
                    continue;
                end
                
                totalTransmissionsPerRound = totalTransmissionsPerRound + 1;
                totalData = totalData + pkt_size;
                
                % Dissipation for cluster head during reception
                if SN(SN(i).chid).Energy > 0 && SN(SN(i).chid).condition == 1 && SN(SN(i).chid).role == 1
                    ERx = (Eelec + EDA) * pkt_size;
                    
                    SN(SN(i).chid).Energy = SN(SN(i).chid).Energy - ERx;
                    
                    if SN(SN(i).chid).Energy <= Eo * 0.2 % if cluster heads energy depletes with reception
                        SN(SN(i).chid).condition = 0;
                        SN(SN(i).chid).rop = rounds;
                        dead_nodes = dead_nodes + 1;
                        operating_nodes = operating_nodes - 1;
                    end
                    
                end
                
            end
            
            if SN(i).Energy <= Eo * 0.2 % if nodes energy depletes with transmission
                dead_nodes = dead_nodes + 1;
                operating_nodes = operating_nodes - 1;
                SN(i).condition = 0;
                SN(i).chid = 0;
                SN(i).rop = rounds;
            end
            
        end
        
    end
    
    % Energy Dissipation for cluster head nodes %
    
    [SN, dead_nodes, operating_nodes, energy_consumed_ch, totalTransmissionsPerRound] = multi_hop_transmission(SN, n, Tx_range, pkt_size, Eelec, EDA, Eamp, Eo, E_thresh, rounds, dead_nodes, operating_nodes, totalTransmissionsPerRound);
    
    
    if operating_nodes < n && temp_val == 0
        temp_val = 1;
        flagFirstDead = rounds;
        networkLiveData_Leech(networkStatus) = rounds;
        networkStatus = networkStatus + 1;
    end
    
    if operating_nodes <= n * 0.5 && temp_val == 1
        temp_val = 2;
        networkLiveData_Leech(networkStatus) = rounds;
        networkStatus = networkStatus + 1;
    end
    
    
    cnt = 0;
    
    for i = 1:n
        
        if (SN(i).condition == 0)
            cnt = cnt + 1;
        end
        
    end
    
    if cnt == n || operating_nodes < 3
        networkLiveData_Leech(networkStatus) = rounds;
        stop_flag = 1;
    end
    
    % Track the remaining total energy (include only alive nodes to avoid negative energies)
    % Not the best way to do this again
    total_remaining_energy = sum([SN([SN(:).condition] == 1).Energy]);
    remainingEnergy = [remainingEnergy, total_remaining_energy];
    nrg = [nrg, prevEnergy - total_remaining_energy];
    prevEnergy = total_remaining_energy;
    
    opNodes(rounds) = operating_nodes;
    dNodes(rounds) = dead_nodes;
    cNodes(rounds) = CLheads;
    threshData(rounds) = totalTransmissionsPerRound;
    
end

if networkStatus == 1
    networkStatus = networkStatus + 1;
    networkLiveData_Leech(networkStatus) = rounds;
    networkStatus = networkStatus + 1;
    networkLiveData_Leech(networkStatus) = rounds;
elseif networkStatus == 2
    networkStatus = networkStatus + 1;
    networkLiveData_Leech(networkStatus) = rounds;
elseif networkStatus == 3
    networkLiveData_Leech(networkStatus) = rounds;
end

% Plotting Simulation Results "Operating Nodes Per Round" %
figure(2)
plot(1:length(opNodes), opNodes(1:length(opNodes)), '-k', 'Linewidth', 2);

figure(3)
plot(1:length(dNodes), dNodes(1:length(dNodes)), '-k', 'Linewidth', 2);


figure(4)
plot(1:length(cNodes), cNodes(1:length(cNodes)), '-k', 'Linewidth', 2);


figure(5)
plot(1:length(threshData), threshData(1:length(threshData)), '-k', 'Linewidth', 2);


figure(6)
plot(1:length(nrg), nrg(1:length(nrg)), '-k', 'Linewidth', 2);


figure(7)
area_h_leech = area(1:length(remainingEnergy), remainingEnergy(1:length(remainingEnergy)), 'FaceColor', 'k', 'FaceAlpha', 0.7);

figure(8)
plot(1:length(abpl_5), abpl_5(1:length(abpl_5)), '-k', 'Linewidth', 2);

figure(9)
plot(1:length(lsp_5), lsp_5(1:length(lsp_5)), '-k', 'Linewidth', 2);


% Plotting Number of Operating Nodes per Round
figure(2);
plot(1:length(opNodes_roc), opNodes_roc(1:length(opNodes_roc)), '-b', 'Linewidth', 2); % RCA method
hold on;
plot(1:length(opNodes_rs), opNodes_rs(1:length(opNodes_rs)), '-g', 'Linewidth', 2); % SRA method
plot(1:length(opNodes_rr), opNodes_rr(1:length(opNodes_rr)), '-r', 'Linewidth', 2); % RRA method
title({'COMPARISON'; 'Number of Operating Nodes Per Round'});
xlabel '# Rounds';
ylabel '# Operational Nodes';
legend('HEED', 'LEACH-C', 'LEACH', 'RCA', 'SRA', 'RRA');

% Plotting Number of Dead Nodes Per Round
figure(3);
plot(1:length(dNodes_roc), dNodes_roc(1:length(dNodes_roc)), '-b', 'Linewidth', 2); % RCA method
hold on;
plot(1:length(dNodes_rs), dNodes_rs(1:length(dNodes_rs)), '-g', 'Linewidth', 2); % SRA method
plot(1:length(dNodes_rr), dNodes_rr(1:length(dNodes_rr)), '-r', 'Linewidth', 2); % RRA method
title({'COMPARISON'; 'Number of Dead Nodes Per Round'});
xlabel '# Rounds';
ylabel '# Dead Nodes';
legend('HEED', 'LEACH-C', 'LEACH', 'RCA', 'SRA', 'RRA');

% Plotting Number of Clusters Per Round
figure(4);
plot(1:length(cNodes_roc), cNodes_roc(1:length(cNodes_roc)), '-b', 'Linewidth', 2); % RCA method
hold on;
plot(1:length(cNodes_rs), cNodes_rs(1:length(cNodes_rs)), '-g', 'Linewidth', 2); % SRA method
plot(1:length(cNodes_rr), cNodes_rr(1:length(cNodes_rr)), '-r', 'Linewidth', 2); % RRA method
title({'COMPARISON'; 'Number of Clusters Per Round'});
xlabel '# Rounds';
ylabel '# Clusters';
legend('HEED', 'LEACH-C', 'LEACH', 'RCA', 'SRA', 'RRA');

% Plotting number of transmissions occuring in every round of the
% simulation
figure(5);
plot(1:length(threshData_roc), threshData_roc(1:length(threshData_roc)), '-b', 'Linewidth', 2); % RCA method
hold on;
plot(1:length(threshData_rs), threshData_rs(1:length(threshData_rs)), '-g', 'Linewidth', 2); % SRA method
plot(1:length(threshData_rr), threshData_rr(1:length(threshData_rr)), '-r', 'Linewidth', 2); % RRA method
title({'COMPARISON'; 'Number of Transmissions Occurring Per Round'});
xlabel '# Rounds';
ylabel '# Transmissions Occurring';
legend('HEED', 'LEACH-C', 'LEACH', 'RCA', 'SRA', 'RRA');

% Plotting Energy Consumption Per Round
figure(6);
plot(1:length(nrg_roc), nrg_roc(1:length(nrg_roc)), '-b', 'Linewidth', 2); % RCA method
hold on;
plot(1:length(nrg_rs), nrg_rs(1:length(nrg_rs)), '-g', 'Linewidth', 2); % SRA method
plot(1:length(nrg_rr), nrg_rr(1:length(nrg_rr)), '-r', 'Linewidth', 2); % RRA method
title({'COMPARISON'; 'Energy Consumption Per Round'});
xlabel '# Rounds';
ylabel 'Energy (Joule)';
legend('HEED', 'LEACH-C', 'LEACH', 'RCA', 'SRA', 'RRA');


% Plotting Remaining Energy Per Round
figure(7);
area_h_roc = area(1:length(remainingEnergy_roc), remainingEnergy_roc(1:length(remainingEnergy_roc)), 'FaceColor', 'b', 'FaceAlpha', 0.5); % RCA method
hold on;
area_h_rs = area(1:length(remainingEnergy_rs), remainingEnergy_rs(1:length(remainingEnergy_rs)), 'FaceColor', 'g', 'FaceAlpha', 0.5); % SRA method
area_h_rr = area(1:length(remainingEnergy_rr), remainingEnergy_rr(1:length(remainingEnergy_rr)), 'FaceColor', 'r', 'FaceAlpha', 0.5); % RRA method
title({'COMPARISON'; 'Remaining Energy Per Round'});
xlabel '# Rounds';
ylabel 'Remaining Energy (Joule)';
legend([area_h_heed, area_h_leechc, area_h_leech, area_h_roc, area_h_rs, area_h_rr], 'HEED', 'LEACH-C', 'LEACH', 'RCA', 'SRA', 'RRA');


% hold off;
% Plotting Average Backbone Path Length Per Round
figure(8);
plot(1:length(abpl_roc), abpl_roc(1:length(abpl_roc)), '-b', 'Linewidth', 2); % RCA method
hold on;
plot(1:length(abpl_rs), abpl_rs(1:length(abpl_rs)), '-g', 'Linewidth', 2); % SRA method
plot(1:length(abpl_rr), abpl_rr(1:length(abpl_rr)), '-r', 'Linewidth', 2); % RRA method
title({'COMPARISON'; 'Average Backbone Path Length Per Round'});
xlabel '# Rounds';
ylabel 'Average Backbone Path Length';
legend('HEED', 'LEACH-C', 'LEACH', 'RCA', 'SRA', 'RRA');

% hold off;
% Plotting Longest Shortest Path Length Per Round
figure(9);
plot(1:length(lsp_roc), lsp_roc(1:length(lsp_roc)), '-b', 'Linewidth', 2); % RCA method
hold on;
plot(1:length(lsp_rs), lsp_rs(1:length(lsp_rs)), '-g', 'Linewidth', 2); % SRA method
plot(1:length(lsp_rr), lsp_rr(1:length(lsp_rr)), '-r', 'Linewidth', 2); % RRA method
title({'COMPARISON'; 'Longest Shortest Path Length Per Round'});
xlabel '# Rounds';
ylabel 'Longest Shortest Path Length';
legend('HEED', 'LEACH-C', 'LEACH', 'RCA', 'SRA', 'RRA');

networkLiveData_ROC = [firstNodeDead_roc, halfNodesDead_roc, allNodesDead_roc];
networkLiveData_RR = [firstNodeDead_rr, halfNodesDead_rr, allNodesDead_rr];
networkLiveData_RS = [firstNodeDead_rs, halfNodesDead_rs, allNodesDead_rs];

figure;
x = categorical({'First Dead Node', 'Half Nodes Dead', 'All Nodes Dead'});
x = reordercats(x, {'First Dead Node', 'Half Nodes Dead', 'All Nodes Dead'});
y = [networkLiveData_Heed; networkLiveData_LeechC; networkLiveData_Leech; networkLiveData_ROC; networkLiveData_RS; networkLiveData_RR;];
g = bar(x, y, 'grouped');

% RCA : -b
% SRA : -g
% RRA : -r
% With degree : -c
% W/O degree : -m
% HEED : -y
% LEACH-C: -orange
% LEACH : -k

set(g(1), 'FaceColor', 'y');
set(g(2), 'FaceColor', [1, 0.5, 0]);
set(g(3), 'FaceColor', 'k');
set(g(4), 'FaceColor', 'b');
set(g(5), 'FaceColor', 'g');
set(g(6), 'FaceColor', 'r');

l = {'HEED', 'LEACH-C', 'LEACH', 'RCA', 'SRA', 'RRA', };
legend(l, 'Location', 'NorthWest');

title ({'COMPARISON', 'Network Status'; })
xlabel 'Network Dead';
ylabel '# Rounds';

% ---------------------- Functions ----------------------------------

function SN = resetNodes(n, Eo, sinkx, sinky, pos)
% RESETNODES Initializes or resets the properties of sensor nodes
% INPUTS:
%   n - Number of sensor nodes
%   Eo - Initial energy for each node
%   sinkx - x-coordinate of the sink
%   sinky - y-coordinate of the sink
% OUTPUT:
%   SN - Array of sensor nodes with initialized properties

% Initialize the array of sensor nodes
SN(n) = struct('id', [], 'Energy', [], 'role', [], 'condition', [], 'dtch', [], 'dts', [], 'chid', [], 'ch_count', []);

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
end
end


%% This function exclusively runs simulation for RCA, SRA, RRA in its entirety %%
function [opNodes, dNodes, cNodes, remainingEnergy, abpl, lsp, nrg, threshData, firstNodeDead, halfNodesDead, allNodesDead] = runSimulation(weights, DistMat, SN, Clust, Eo, Eps, n, noise_points_count, Eelec, Eamp, EDA, pkt_size, Tx_range, E_thresh);
opNodes = [];
dNodes = [];
cNodes = [];
threshData = [];
remainingEnergy = [];
nrg = [];
abpl = [];
lsp = [];
rounds = 0;
totalEnergy = (n - noise_points_count)* Eo;
operating_nodes = n;
stop_flag = 0;

firstNodeDead = -1;
halfNodesDead = -1;
allNodesDead = -1;

prevEnergy = totalEnergy;
remainingEnergy = [remainingEnergy, totalEnergy];

numClusters = max(Clust);
clusterStatus = true(1, numClusters);
while (operating_nodes > 0 && stop_flag == 0)
    
    % Increment the round
    rounds = rounds + 1;
    
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
                cluster_members = find([SN.chid] == i);
                avg_dist_cluster = mean(DistMat(i, cluster_members));
                normalized_avg_dist_cluster = 1 - (avg_dist_cluster / max(DistMat(:)));
            else
                normalized_avg_dist_cluster = 0;
            end
            
            % Normalize the number of times the node has become a cluster head
            normalized_ch_count = 1 - (SN(i).ch_count / rounds);
            
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
        members = find(Clust == cluster_id);
        alive_members = members([SN(members).score] > -1); % Filter out dead nodes
        
        % this logic allows entire clusters to die
        if ~isempty(alive_members)
            [~, max_idx] = max([SN(alive_members).score]);
            cluster_head_id = alive_members(max_idx);
            
            % Assign the role to the cluster head
            SN(cluster_head_id).role = 1; % Cluster head
            SN(cluster_head_id).chid = -1; % For cluster heads, the chid is set as -1
            SN(cluster_head_id).ch_count = SN(cluster_head_id).ch_count + 1; % Increment the CH count
            
            for idx = 1:length(members)
                member = members(idx);
                if member ~= cluster_head_id
                    SN(member).role = 0; % Normal node
                    SN(member).chid = cluster_head_id; % Assign cluster head ID
                end
            end
        else
            clusterStatus(cluster_id) = false; % Mark cluster as dead
        end
    end
    
    
    %%% Identify the Closest Cluster Head to the Sink %%%
    % This step will be executed for each cluster head
    
    for cluster_id = 1:max(Clust)
        cluster_head_ids = find([SN.role] == 1); % IDs of all cluster heads
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
                
                if d_ch_to_sink < min_dist && d_ch_to_ch <= Tx_range
                    min_dist = d_ch_to_sink;
                    next_hop_id = potential_hop_id;
                end
            end
            
            SN(ch_id).next_hop = next_hop_id; % Set the next hop CH
        end
    end
    
    totalTransmissions = 0;
    lsp_round = -1;
    %%% Multi-Hop Transmission with Dynamic Next Hop Selection %%%
    for i = 1:n
        if SN(i).condition == 1
            if SN(i).role == 0 && SN(i).chid ~= 0  % Non-cluster head node
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
                n_members = length(cluster_members);
                total_pkt_size = pkt_size*n_members;
                ERx_energy = Eelec * total_pkt_size; % recieving from all cluster members
                EDA_energy = EDA * pkt_size;
                SN(i).Energy = SN(i).Energy -  ERx_energy - EDA_energy;
                if SN(i).Energy <= Eo*E_thresh
                    SN(i).condition = 0;
                end
                visited_nodes = [];
                path_dist = 0;
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
                    else
                        reached_sink = 1; % Reached the sink
                    end
                    
                    ETx_to_next_hop = Eelec * total_pkt_size + Eamp * total_pkt_size * d_to_next_hop^2;
                    path_dist = path_dist + d_to_next_hop;
                    SN(current_ch_id).Energy = SN(current_ch_id).Energy - ETx_to_next_hop;
                    if SN(current_ch_id).Energy < Eo*E_thresh
                        SN(current_ch_id).condition = 0;
                    end
                    totalTransmissions = totalTransmissions + 1; % Increment transmission counter
                    
                    if reached_sink ~= 1
                        current_ch_id = next_hop_id; % Move to the next hop
                        
                        % Consume the recieving energy
                        SN(current_ch_id).Energy = SN(current_ch_id).Energy - Eelec * total_pkt_size;
                        if SN(current_ch_id).Energy <= Eo*E_thresh
                            SN(current_ch_id).condition = 0;
                        end
                    end
                end
                % path_dist
                lsp_round = max(lsp_round, path_dist);
                
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
    
    % energy consumption per round
    nrg = [nrg, prevEnergy - total_remaining_energy];
    
    prevEnergy = total_remaining_energy;
    
    avg_bpl = mean([SN([SN.role] == 1).dts]);
    abpl = [abpl, avg_bpl];  % Store average backbone path length per round
    
    % lsp_round
    lsp = [lsp, lsp_round];  % Store longest shortest path length per round
    
    % Update the number of operating nodes
    operating_nodes = sum([SN(:).condition] == 1 & [SN(:).chid] ~= 0);
    opNodes = [opNodes, operating_nodes]; % Track operational nodes
    
    % Track count of dead nodes
    dead_nodes = sum([SN(:).condition] == 0 & [SN(:).chid] ~= 0);
    dNodes = [dNodes, dead_nodes];
    
    % Track the number of clusters
    numClustersAlive = sum(clusterStatus);
    cNodes = [cNodes, numClustersAlive];
    
    % Track the number of transmissions to the sink
    transmissions = totalTransmissions;
    threshData = [threshData, transmissions];
    
    if halfNodesDead == -1 && operating_nodes <= (n - noise_points_count)/2
        % fprintf("%d, %d, %d \n", rounds, n - noise_points_count, operating_nodes);
        halfNodesDead = rounds;
    end
    
    % Stop the simulation if all nodes are dead or certain condition is met
    if operating_nodes == 0
        allNodesDead = rounds;
        stop_flag = 1;
    end
end
end

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



% algorithm for HEED
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
    
    if (SN(i).condition == 1) % if node is alive and operational
        
        if (SN(i).prob == 1) % case when its sure to become a cluster head
            SN(i).role = 1; % assigns the node role of acluster head
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

% algorithm for LEACH-C
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
        
        if (generate < t && SN(i).condition == 1 && SN(i).Energy >= (Ecen - 1e-6))
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

% algorithm for LEACH
function [SN, CL, CLheads] = CH_election(SN, n, t, tleft, p, rounds, sinkx, sinky, CLheads, Eo)
CL = [];

for i = 1:n
    SN(i).cluster = 0; % reseting cluster in which the node belongs to
    SN(i).role = 0; % reseting node role
    SN(i).chid = 0; % reseting cluster head id
    
    if SN(i).rleft > 0
        SN(i).rleft = SN(i).rleft - 1;
    end
    
    if (SN(i).condition == 1) && (SN(i).rleft == 0)
        generate = rand;
        
        if (generate < t && SN(i).condition == 1)
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

%% FUNCTION FOR MULTIHOP TRANSMISSION %%
function [SN, dead_nodes, operating_nodes, energy_consumed, totalTransmissionsPerRound] = multi_hop_transmission(SN, n, Tx_range, pkt_size, Eelec, EDA, Eamp, Eo, E_thresh, rounds, dead_nodes, operating_nodes, totalTransmissionsPerRound)
% Initialize energy consumed in the round
energy_consumed = 0;

% Loop through each node
for i = 1:n
    if (SN(i).condition == 1) && (SN(i).role == 1) % Check if node is a CH and alive
        if SN(i).Energy > 0
            % Check if multi-hop transmission is needed
            if SN(i).dts > Tx_range
                currentNode = i;
                
                while (SN(currentNode).dts > Tx_range)
                    % Find the next closest node to the sink
                    nextNode = -1;
                    minDistanceToSink = inf;
                    
                    for j = 1:n
                        if (j ~= currentNode) && (SN(j).condition == 1) && (SN(j).role == 1) && (SN(j).dts < minDistanceToSink)
                            minDistanceToSink = SN(j).dts;
                            nextNode = j;
                        end
                    end
                    
                    if nextNode == -1
                        break; % No suitable next node found
                    end
                    
                    % Transmit to the next node
                    ETx = (Eelec + EDA) * pkt_size + Eamp * pkt_size * SN(currentNode).dts ^ 2;
                    SN(currentNode).Energy = SN(currentNode).Energy - ETx;
                    energy_consumed = energy_consumed + ETx;
                    totalTransmissionsPerRound = totalTransmissionsPerRound + 1;
                    
                    if SN(currentNode).Energy <= Eo * E_thresh
                        dead_nodes = dead_nodes + 1;
                        operating_nodes = operating_nodes - 1;
                        SN(currentNode).condition = 0;
                        SN(currentNode).rop = rounds;
                        break;
                    end
                    
                    % Energy consumption for receiving data at the next node
                    ERx = (Eelec + EDA) * pkt_size;
                    SN(nextNode).Energy = SN(nextNode).Energy - ERx;
                    energy_consumed = energy_consumed + ERx;
                    
                    % Handle case where the next node's energy depletes
                    if SN(nextNode).Energy <= Eo * E_thresh
                        
                        dead_nodes = dead_nodes + 1;
                        operating_nodes = operating_nodes - 1;
                        SN(nextNode).condition = 0;
                        SN(nextNode).rop = rounds;
                        break;
                    end
                    % Move to the next node
                    currentNode = nextNode;
                    
                end
                
                % Check if the final node is close to the sink
                if SN(currentNode).dts <= Tx_range && SN(currentNode).Energy >= Eo * E_thresh
                    % Transmit to the sink
                    ETx = (Eelec + EDA) * pkt_size + Eamp * pkt_size * SN(currentNode).dts ^ 2;
                    SN(currentNode).Energy = SN(currentNode).Energy - ETx;
                    energy_consumed = energy_consumed + ETx;
                    totalTransmissionsPerRound = totalTransmissionsPerRound + 1;
                    
                    % Handle case where the final node's energy depletes
                    if SN(currentNode).Energy <= Eo * E_thresh
                        dead_nodes = dead_nodes + 1;
                        operating_nodes = operating_nodes - 1;
                        SN(currentNode).condition = 0;
                        SN(currentNode).rop = rounds;
                    end
                end
            else
                % Direct transmission to the sink
                ETx = (Eelec + EDA) * pkt_size + Eamp * pkt_size * SN(i).dts ^ 2;
                SN(i).Energy = SN(i).Energy - ETx;
                energy_consumed = energy_consumed + ETx;
                
                if SN(i).Energy <= Eo * E_thresh
                    % Handle case where the node's energy depletes
                    dead_nodes = dead_nodes + 1;
                    operating_nodes = operating_nodes - 1;
                    SN(i).condition = 0;
                    SN(i).rop = rounds;
                    continue;
                end
                totalTransmissionsPerRound = totalTransmissionsPerRound + 1;
            end
        end
    end
end
end

function Clust = DBSCAN(DistMat,Eps,MinPts)

%Input: DistMat, Eps, MinPts
%DistMat: A N*N distance matrix, the (i,j) element contains the distance
%from point-i to point-j.

%Eps:     A scalar value for Epsilon-neighborhood threshold.
%MinPts:  A scalar value for minimum points in Eps-neighborhood that holds
%the core-point condition.

%Output: Clust
%Clust:  A N*1 vector describes the cluster membership for each point. 0 is
%reserved for NOISE.

Clust=zeros(size(DistMat,1),1)-1;
ClusterId=1;

%randomly choose the visiting order
VisitSequence=randperm(length(Clust));

for i=1:length(Clust)
    % For each point, check if it is not visited yet (unclassified)
    pt=VisitSequence(i);
    if Clust(pt)==-1
        %Iteratively expand the cluster through density-reachability
        [Clust,isnoise]=ExpandCluster(DistMat,pt,ClusterId,Eps,MinPts,Clust);
        if ~isnoise
            ClusterId=ClusterId+1;
        end
    end
end

end

function [Clust,isnoise]=ExpandCluster(DistMat,pt,ClusterId,Eps,MinPts,Clust)

%region query
seeds=find(DistMat(:,pt)<=Eps);

if length(seeds)<MinPts
    Clust(pt)=0; % 0 reserved for noise
    isnoise=true;
    return
else
    Clust(seeds)=ClusterId;
    %delete the core point
    seeds=setxor(seeds,pt);
    while ~isempty(seeds)
        currentP=seeds(1);
        %region query
        result=find(DistMat(:,currentP)<=Eps);
        if length(result)>=MinPts
            for i=1:length(result)
                resultP=result(i);
                if Clust(resultP)==-1||Clust(resultP)==0 % unclassified or noise
                    if Clust(resultP)==-1 %unclassified
                        seeds=[seeds(:);resultP];
                    end
                    Clust(resultP)=ClusterId;
                end
                
            end
        end
        seeds=setxor(seeds,currentP);
    end
    isnoise=false;
    return
end
end
