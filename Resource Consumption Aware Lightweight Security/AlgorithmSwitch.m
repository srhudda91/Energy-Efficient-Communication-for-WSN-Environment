AlgorithmSwitcher(AlgoManager());
function AlgorithmSwitcher(algoSwitcher)
%{
    The input to this function is an AlgoManager object. This serves as the main function where the entire simulation is executed.
%}


mqttBrokerAddress = "tcp://127.0.0.1:1883"; % MQTT broker address
% Plot BER for each message
%{
Shows the BER for each message induced by deriving the SNR from Ec/No parameter and passing the waveform through a AWGN channel with the derived SNR. 
This visualizes the network status during the time of simulation. 
X axis has the sequence numbers of messages  and Y axis has the BER value.
%}

% figure('Name', 'BER Plot', 'NumberTitle', 'off');
% xlabel('Message Sequence Number');
% ylabel('Bit Error Rate (BER)');
% title({'COMPARISON','BER vs Message'});
% grid on;
% hold on;
% 
% % Plot Number of times algorithm is used
% %{
% This visualizes how the algorithms are being used. By visualizing the
% number of times each algorithm is used. We can analyze if the algorithm is
% choosing the best algorithm at each step.
% %}
% 
% figure('Name', 'Algorithms Used', 'NumberTitle', 'off');
% xlabel('Algorithms');
% ylabel('Number of times used');
% title({'COMPARISON','Algorithm vs Use'});
% grid on;
% hold on;
% 
% % Plot the current algorithm being used
% %{
% This shows the current algorithm being used. Helps in debugging when the
% program is running.
% %}
% figure('Name', 'Current Algorithm', 'NumberTitle', 'off');
% xlabel('Algorithms');
% ylabel('Current');
% title({'Measure','Current Algorithm'});
% grid on;
% hold off;
% 
% %{
% This visualizes the time taken for switching from one algorithm to another. Helps in analysing the impact of the switching algorithm.
% %}
% figure('Name', 'Time Taken for switching', 'NumberTitle', 'off');
% title({'Measure','Time Taken for switching'});
% ylabel('Time(seconds)');
% xlabel('No of Switches');
% hold on;
% %{
% This visualizes how messages are spread out in terms of BER . Gives  a
% summary of how many messages are in a particular range of ber(0,0 -0.1,0.1-0.2,0.2-Threshold,>Threshold)
% %}
% % Plot the BER Ranges
% figure('Name', 'Messages Count vs BER Ranges', 'NumberTitle', 'off');
% xlabel('BER Range');
% ylabel('Number of Messages');
% title({'COMPARISON'; 'Messages at different BER ranges';});
% grid on;
% hold on;



startSimulation(algoSwitcher);


% function to read file, encryption and decryption
    function [isCompromised,isComplete]= readfile(filePath,key,algoSwitcher,reset,mqttNode,n,f)
        %{
            Input : 
                filePath -> Path to the file to be read.
                key -> secret key for the algorithm being run
                algoSwitcher --> AlgoManager Object
                reset --> flag to be true when new file is to be opened
                msgType --> Length of the message (1 to 7 mapped to 8,16,32,64,128,256,512)
                mqttNode --> Mqtt object
            Output :
                isCompromised -> If state changes set to true
                isComplete -> When reading the file is complete set to true
            This function takes several inputs: 
            filePath, which specifies the path to the file being read;
            key, the secret key for the algorithm in use; 
            algoSwitcher, an AlgoManager object; 
            reset,a flag that should be set to true when a new file needs to be opened; 
            msgType, which determines the message length based on predefined mappings; and 
            mqttNode, an MQTT object. 
            The function produces two outputs: isCompromised, which is set to true if there is a state change, and 
            isComplete, which is set to true once the file has been fully read. 
            The function follows a series of steps, starting with preparing the necessary data structures for encryption.
            It then reads the file line by line and encrypts each message using the current algorithm. The network and device status are continuously
            monitored, and if any changes occur, the state is updated accordingly. If a state change is detected, isCompromised is set to true.
            Once the file reading is complete, isComplete is set to true. If no state changes occur,
            the message is sent to the destination using MQTT.
        %}
        algonum = algoSwitcher.getCurrentAlgo();
        isCompromised = false;
        isComplete = false;
        nodeTopic = sprintf("mqtt/Node%d", bin2dec('0010'));
        roundKeys = cell(25, 1);
        for i= 1:25
            roundKeys{i} = '00000000000000000000000000000000';
        end
        if algonum==3
            %key division
            K= cell(2,1);
            for m =1:2
                K{m}=key((m-1)*64 + 1 : m*64);
            end
            k1 = cell(4,4);
            k2 = cell(4,4);
            c3 = 1;
            for j = 1:4
                for i = 1:4
                    k1{i, j} = K{1}(c3:c3+3);
                    c3 = c3 + 4;
                end
            end
            c3 = 1;
            for j = 1:4
                for i = 1:4
                    k2{i, j} = K{2}(c3:c3+3);
                    c3 = c3 + 4;
                end
            end
            %making WK
            m1= cell(2,1);
            m2= cell(2,1);
            for m =1:2
                m1{m}=K{1}((m-1)*32 + 1 : m*32);
            end
            for m =1:2
                m2{m}=K{2}((m-1)*32 + 1 : m*32);
            end
            w = cell(2,1);
            for m =1:2
                w{m}=dec2bin(bitxor(bin2dec(m2{m}),bin2dec(m1{m})),32);
            end
            Wks = [w{1} w{2}];
            WK = cell(4,4);
            c3 = 1;
            for j = 1:4
                for i = 1:4
                    WK{i, j} = Wks(c3:c3+3);
                    c3 = c3 + 4;
                end
            end
            %making WK
            RK = cell(4,4,15);
            %alpha constants
            A=zeros(4,4,15);
            A(:,:,1) = [0 0 1 0;
                0 1 0 0;
                0 0 1 1;
                1 1 1 1];
            A(:,:,2) = [0 1 1 0;
                1 0 1 0;
                1 0 0 0;
                1 0 0 0];
            A(:,:,3) = [1 0 0 0;
                0 1 0 1;
                1 0 1 0;
                0 0 1 1];
            A(:,:,4) = [0 0 0 0;
                1 0 0 0;
                1 1 0 1;
                0 0 1 1];
            A(:,:,5) = [0 0 0 1;
                0 0 1 1;
                0 0 0 1;
                1 0 0 1];
            A(:,:,6) = [1 0 0 0;
                1 0 1 0;
                0 0 1 0;
                1 1 1 0];
            A(:,:,7) = [0 0 0 0;
                0 0 1 1;
                0 1 1 1;
                0 0 0 0];
            A(:,:,8) = [0 1 1 1;
                0 0 1 1;
                0 1 0 0;
                0 1 0 0];
            A(:,:,9) = [1 0 1 0;
                0 1 0 0;
                0 0 0 0;
                1 0 0 1];
            A(:,:,10) = [0 0 1 1;
                1 0 0 0;
                0 0 1 0;
                0 0 1 0];
            A(:,:,11) = [0 0 1 0;
                1 0 0 1;
                1 0 0 1;
                1 1 1 1];
            A(:,:,12) = [0 0 1 1;
                0 0 0 1;
                1 1 0 1;
                0 0 0 0];
            A(:,:,13) = [0 0 0 0;
                1 0 0 0;
                0 0 1 0;
                1 1 1 0];
            A(:,:,14) = [1 1 1 1;
                1 0 1 0;
                1 0 0 1;
                1 0 0 0];
            A(:,:,15) = [1 1 1 0;
                1 1 0 0;
                0 1 0 0;
                1 1 1 0];
            for i = 1:15
                if mod(i,2)==1
                    for n1=1:4
                        for n2=1:4
                            % Extract the LSB of k1{n1,n2}
                            lsb_k1 = k1{n1,n2}(end);
                            % if i==1 && n1==3 && n2==3
                            % disp(lsb_k1);
                            % end
                            result = dec2bin(bitxor(bin2dec(lsb_k1), A(n1,n2,i)), 1);

                            RK{n1,n2,i} = [k1{n1,n2}(1:end-1), result];
                        end
                    end
                else
                    for n1=1:4
                        for n2=1:4
                            % Extract the LSB of k2{n1,n2}
                            lsb_k2 = k2{n1,n2}(end);

                            result = dec2bin(bitxor(bin2dec(lsb_k2), A(n1,n2,i)), 1);

                            RK{n1,n2,i} = [k2{n1,n2}(1:end-1), result];
                        end
                    end
                end
            end
        end

        persistent fileID filePos;
        if isempty(fileID) || reset
            fileID = fopen(filePath, 'r');
            filePos = 0;
        end
        % Check if file exists
        if fileID == -1
            error('File Not Found');
        end
        fseek(fileID, filePos, 'bof');
        % count the number of lines in the file
        % numLines=0;
        % while ~feof(fileID)
        %     line= fgetl(fileID);  % Read and discard the line
        %     if ~isempty(line)  % Only count the line if it's not empty
        %         numLines = numLines + 1;  % Increment the line count
        %     end
        % end
        numLines = 3000;
        % disp('Number of Records in This Input File: ');
        % disp(numLines);
        fseek(fileID, filePos, 'bof'); % Reset the file pointer to the last position
        % Preallocate a cell array to hold the binary strings
        % plaintext = cell(numLines, 1);
        % ciphertext = cell(numLines, 1);

        persistent lc;
        if isempty(lc)
            lc=1;
        end



        %loop to call encryption function
        while ~feof(fileID) && lc <=numLines
            filePos = ftell(fileID);
            % store the binary strings into plaintext array
            plaintext = fgetl(fileID);
            % append zeroes if required
            if length(plaintext) < 64

                plaintext = [repmat('0', 1, 64 - length(plaintext)),plaintext];
                %call encrption function
                if algonum ==1
                    [ciphertext, roundKeys] = ANU_encrypt(plaintext, key, roundKeys);
                end
                if algonum ==2
                    ciphertext= qtl_encrypt(key,plaintext);
                end
                if algonum ==3
                    ciphertext= midoriEncrypt(plaintext,RK,WK);
                end
                if algonum ==4
                    [ciphertext, roundKeys] = rectangleEncrypt(key,plaintext);
                end
                if algonum ==5
                    ciphertext = Present_enc(plaintext, key);
                end
                if algonum ==6
                    ciphertext= Hight_enc(plaintext,key);
                end
                if algonum ==7
                    ciphertext = Klein_enc(plaintext, key);
                end
                if algonum ==8
                    [ciphertext,res_X,K] = LBlock_enc(plaintext, key);
                end
                if algonum ==9
                    ciphertext= Lilliput_enc(plaintext,key);
                end
                if algonum ==10
                    [ciphertext,outrc]= LED_enc(plaintext,key);
                end
            else

                %form blocks if length of binary string is greater than 64
                numBLocks = length(plaintext)/64;
                %preallocate array to hold the block strings
                strings = cell(numBLocks,1);
                output2 = '';
                outrc ='';

                for j = 1:numBLocks
                    %store the 64-bit size strings in strings array
                    strings{j} = plaintext((j-1)*64 + 1 : j*64);

                    %append zeroes if required
                    if length(strings{j}) < 64
                        strings{j} = [repmat('0', 1, 64 - length(strings{j})),strings{j}];
                    end

                    %call encryption function
                    if algonum == 1
                        [ciphertext, roundKeys] = ANU_encrypt(strings{j}, key, roundKeys);
                    end
                    if algonum ==2
                        ciphertext = qtl_encrypt(key,strings{j});
                    end
                    if algonum ==3
                        ciphertext = midoriEncrypt(strings{j},RK,WK);
                    end
                    if algonum ==4
                        [ciphertext, roundKeys] = rectangleEncrypt(key,plaintext);
                    end
                    if algonum ==5
                        ciphertext = Present_enc(strings{j}, key);
                    end
                    if algonum ==6
                        ciphertext = Hight_enc(strings{j},key);
                    end
                    if algonum ==7
                        ciphertext = Klein_enc(strings{j}, key);
                    end
                    if algonum ==8
                        [ciphertext,X_temp,K] = LBlock_enc(strings{j}, key);
                        if j == 1
                            res_X = X_temp;
                        else
                            res_X = [res_X; X_temp];
                        end
                    end
                    if algonum ==9
                        ciphertext = Lilliput_enc(strings{j},key);
                    end
                    if algonum ==10
                        [ciphertext,temp] = LED_enc(strings{j},key);
                        outrc = strcat(outrc,temp);

                    end
                    % concatenate all ciphertext formed in every round from j=1 to j=numBlocks
                    output2 = strcat(output2,ciphertext);

                end
                %store all the ciphertext formed in this array

                ciphertext=output2;


            end
            % disp(ciphertext{lc});
            x = algoSwitcher.state;
            isCompromised  = evaluateMessageWithAWGN(double(ciphertext) - '0',f,n);
            if isCompromised
                x(1) = 0;
            end
            if (getEnergyConsumption() == 1);
                x(2) = 0;
                isCompromised = true;
                lc = lc+1;
            end
            if isCompromised
                ttotal = tic;
                algoSwitcher.state = x;
                ttotal = toc(ttotal);
                plotTimeTaken(ttotal,f);
                return
            end
            if algonum ==8
                ciphertext = sprintf('%s|%s|%s',num2str(ciphertext),matrixToString(res_X),num2str(K));
            end
            if algonum ==10
                ciphertext = sprintf('%s|%s',num2str(ciphertext),num2str(outrc));
            end
            sendToDestination(mqttNode,nodeTopic,ciphertext,algoSwitcher.getCurrentAlgo());
            lc = lc + 1;
        end

        lc=1;

        frewind(fileID); % Reset the file pointer to the beginning of the file

        isComplete = true;
        % Close the file
        fclose(fileID);


    end


    function startSimulation(algoSwitcher)
        %{
            Input : 
                algoSwitcher -> AlgoManager object
               
            
            This function takes algoSwitcher, which is an AlgoManager object, as input.
            The first step in the function is to initialize MQTT and set up all the necessary configurations required for the process.
            After that, it registers itself as a client with the destination to establish proper communication. Once the registration is complete, 
            the function proceeds to define and set up different types of graphs that will be plotted during execution. 
            These graphs include BER vs. Message, which represents the Bit Error Rate against the message length; Algorithm vs. Number of Times Used, 
            which tracks how frequently each algorithm is selected; and the Current Algorithm..
            After defining the graphs, the function moves on to reading data files.
            It calls the readfile function in an order to process these files sequentially (8,16,32,64,128,256,512). 
            While doing so, it constantly monitors the state and updates the graphs accordingly based on any changes that occur. 
            Throughout this process, it ensures that all files are read completely before the function concludes. 

                
        %}
        disp("Starting");
        nodeID = '0010';  % Unique Node ID
        nodeTopic = sprintf("mqtt/Node%d", bin2dec(nodeID));
        mqttNode = mqttclient(mqttBrokerAddress, "ClientID", sprintf("Node_%d", bin2dec(nodeID)));
        % Register with the coordinator
        registrationMessage = sprintf('%s', nodeID);
        write(mqttNode, "mqtt/Register", registrationMessage);
        disp(['Node ', num2str(bin2dec(nodeID)), ': Registration Request Sent.']);
        algos = {'ANU', 'QTL', 'Midori', 'Rectangle', 'Present', 'HIGHT', 'KLEIN', 'LBlock', 'Lilliput', 'LED'};
        data_files = ["8-Bits","16-Bits","32-Bits","64-Bits","128-Bits","256-Bits","512-Bits"];
        algoUseCount = zeros(1,10);
        currentAlgo = zeros(1,10);
        resetRequired = true;

        algoNum = algoSwitcher.getCurrentAlgo();
        disp(algoNum);
        isComplete=false;
        isCompromised=false;
        n=1;
        currentFolder = pwd;
        algoUseCount(algoNum) = 1;
        currentAlgo(algoNum) = 1;
        f = figure("Name",data_files(n));
        figure(f);
        subplot(2,2,1);
        bar(categorical(algos), algoUseCount, 'g');
        xlabel('Algorithms');
        ylabel('Number of Times Used');
        title({'COMPARISON','Algorithm v/s Use'});
        grid on;
        hold on;
        drawnow;
        figure(f);
        subplot(2,2,2);
        
        hold off;
        legend off;
        bar(categorical(algos), currentAlgo, 'b');
        xlabel('Algorithms');
        ylabel('Current');
        title({'INDICATOR','Current Algorithm'});
        yticks([0,1]);
        grid on;
        hold off;
        drawnow;

        while true

            if n == 7 && isComplete == true
                disp("Sending Message Complete")
                break
            end
            if isCompromised == true
                
                    disp("Changing Algorithm");
                    currentAlgo = zeros(1,10);
                    algoNum = algoSwitcher.getCurrentAlgo();
                    algoUseCount(algoNum) = algoUseCount(algoNum) + 1;
                    currentAlgo(algoNum) = 1;
                    figure(f);
                    subplot(2,2,1);
                    xlabel('Algorithms');
                    ylabel('Number of Times Used');
                    title({'COMPARISON','Algorithm v/s Use'});
                    bar(categorical(algos), algoUseCount, 'g');
                    grid on;
                    hold on;
                    drawnow;
                    figure(f);
                    subplot(2,2,2);
                    
                    hold off;
                    legend off;
                    bar(categorical(algos), currentAlgo, 'b');
                    xlabel('Algorithms');
                    title({'INDICATOR','Current Algorithm'});
                    yticks([0,1]);
                    grid on;
                    hold off;
                    drawnow;
            end
            if isComplete && n < 7
                n = n+1;
                f = figure("Name",data_files(n));
                resetRequired= true;
                algoUseCount = zeros(1,10);
                algoUseCount(algoNum) = 1;
                figure(f);
                    subplot(2,2,1);
                    
                    bar(categorical(algos), algoUseCount, 'g');
                    xlabel('Algorithms');
                    ylabel('Number of Times Used');
                    title({'COMPARISON','Algorithm v/s Use'});
                    grid on;
                    hold on;
                    drawnow;
                    figure(f);
                    subplot(2,2,2);
                    
                    hold off;
                    legend off;
                    bar(categorical(algos), currentAlgo, 'b');
                    xlabel('Algorithms');
                    title({'INDICATOR','Current Algorithm'});
                    yticks([0,1]);
                    grid on;
                    hold off;
                    drawnow;

            end


            switch n
                case 1
                    
                    disp('8-bit Message');
                    filePath = fullfile(currentFolder, 'Bits 8 Number Of Record 100000');
                    [isCompromised,isComplete] = readfile(filePath,getKey(algoSwitcher.getCurrentAlgo()),algoSwitcher,resetRequired,mqttNode,n,f);
                case 2
                    % f = figure("Name",'16 Bits');
                    disp('16-bit Message');
                    filePath = fullfile(currentFolder, 'Bits 16 Number Of Record 100000');
                    [isCompromised,isComplete] = readfile(filePath,getKey(algoSwitcher.getCurrentAlgo()),algoSwitcher,resetRequired,mqttNode,n,f);

                case 3
                     % f = figure("Name",'32-bit Messages');
                    disp('32-bit Message');
                    filePath = fullfile(currentFolder, 'Bits 32 Number Of Record 100000');
                    [isCompromised,isComplete] = readfile(filePath,getKey(algoSwitcher.getCurrentAlgo()),algoSwitcher,resetRequired,mqttNode,n,f);

                case 4
                    % f = figure("Name",'64-bit Messages');
                    disp('64-bit Message');
                    filePath = fullfile(currentFolder, 'Bits 64 Number Of Record 100000');
                    [isCompromised,isComplete] = readfile(filePath,getKey(algoSwitcher.getCurrentAlgo()),algoSwitcher,resetRequired,mqttNode,n,f);

                case 5
                    % f = figure("Name",'128-bit Messages');
                    disp('128-bit Message');
                    filePath = fullfile(currentFolder, 'Bits 128 Number Of Record 100000');
                    [isCompromised,isComplete] = readfile(filePath,getKey(algoSwitcher.getCurrentAlgo()),algoSwitcher,resetRequired,mqttNode,n,f);

                case 6
                    % f = figure("Name",'256-bit Messages');
                    disp('256-bit Message');
                    filePath = fullfile(currentFolder, 'Bits 256 Number Of Record 100000');
                    [isCompromised,isComplete] = readfile(filePath,getKey(algoSwitcher.getCurrentAlgo()),algoSwitcher,resetRequired,mqttNode,n,f);

                case 7
                    % f = figure("Name",'512-bit Messages');
                    disp('512-bit Message');
                    filePath = fullfile(currentFolder, 'Bits 512 Number Of Record 100000');
                    [isCompromised,isComplete] = readfile(filePath,getKey(algoSwitcher.getCurrentAlgo()),algoSwitcher,resetRequired,mqttNode,n,f);



            end
            if isCompromised
                resetRequired = false;
            end
            % figure(2);
            % bar(categorical(algos), algoUseCount, 'g');
            % hold on;
            % drawnow;

            % figure(3);
            % bar(categorical(algos), currentAlgo, 'b');
            % title({'Measure','Current Algorithm'});
            % hold off;
            % drawnow;

            % figure(4);
            % bar(categorical(algos), algoSwitcher.getVisited(), 'b');
            % hold on;
            % drawnow;
        end
    end



    function [key] = getKey(algo)
        %{
            Input : 
                algo -> ID of the algorithm
            Output :
                key -> Secret Key of the given algorithm
            
        %}
        switch algo
            case 1
                key = '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
            case 2
                key = '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
            case 3
                key = '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
            case 4
                key = '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
            case 5
                key = '00000000000000000000000000000000000000000000000000000000000000000000000000000000';
            case 6
                key  = '11111111111011101101110111001100101110111010101010011001100010000111011101100110010101010100010000110011001000100001000100000000';
            case 7
                key  = '0000000000000000000000000000000000000000000000000000000000000000';
            case 8
                key = '00000000000000000000000000000000000000000000000000000000000000000000000000000000';
            case 9
                key = '00000001001000110100010101100111100010011010101111001101111011110000000100100011';
            case 10
                key = '0000000100100011010001010110011110001001101010111100110111101111';
        end
    end
% ANU Helpers
% function for encryption

    function [ciphertext,roundKeys] = ANU_encrypt(plaintext, key, roundKeys)
        %25 rounds for encryption
        for round = 1:25

            [L, R] = initialPermutation(plaintext);
            %generate round keys(key scheduling)
            key64 = key(end-63:end);
            roundKeys{round} = key64(end-31:end);
            %update key(key scheduling)
            key = circshift(key, [0, -13]);
            key(1:4) = SBoxSegment_ANU(key(1:4));
            key(5:8) = SBoxSegment_ANU(key(5:8));
            key(end-4:end) = dec2bin(bitxor(bin2dec(key(end-4:end)), round-1), 5);
            %call function for encryption of one round
            [L, R] = ANURound(L, R, roundKeys{round});
            plaintext = [L, R];

        end
        ciphertext = plaintext;
    end

%s-box function with 32-bit input/output
    function output = SBox_ANU(input)
        output = '';
        %divide 32-bit input into eight 4-bit segments and apply s-box
        for i = 1:8
            segment = input((i-1)*4 + 1 : i*4);
            output = strcat(output, SBoxSegment_ANU(segment));
        end
    end

%s-box function with 4-bit input/output
    function output = SBoxSegment_ANU(segment)
        sBoxTable = ['2' '9' '7' 'E' '1' 'C' 'A' '0' '4' '3' '8' 'D' 'F' '6' '5' 'B'];
        segmentDecimal = bin2dec(segment) + 1;
        outputDecimal = hex2dec(sBoxTable(segmentDecimal));
        output = dec2bin(outputDecimal, 4);
    end

%function to break plaintext into two 32-bit strings
    function [L, R] = initialPermutation(plaintext)
        L = plaintext(1:32);
        R = plaintext(33:64);
    end

%function for encryption of one round
    function [L, R] = ANURound(L, R, roundKey)
        %aplly circular shifts
        F1 = circshift(L, [0, -3]);
        F2 = circshift(L, [0, 8]);
        %apply s-box
        F1 = SBox_ANU(F1);
        F2 = SBox_ANU(F2);
        %apply x-or operations
        FX = dec2bin(bitxor(bin2dec(F1), bin2dec(R)), 32);
        Pt = dec2bin(bitxor(bitxor(bin2dec(FX), bin2dec(F2)), bin2dec(roundKey)), 32);
        %apply bit permutation and swap the bit strings
        R = bitPermutation_ANU(L);
        L = bitPermutation_ANU(Pt);

    end

%function for bit permutation(used in encryption)
    function output = bitPermutation_ANU(input)
        BP = [20 16 28 24 17 21 25 29 22 18 30 26 19 23 27 31 11 15 3 7 14 10 6 2 9 13 1 5 12 8 4 0] + 1;
        output = input;
        for i = 1:length(BP)
            output(i) = input(BP(i));
        end
    end

%function for reverse bit permutation(used in decryption)
    function output = reversebitPermutation_ANU(input)
        BP = [31 26 23 18 30 27 22 19 29 24 21 16 28 25 20 17 1 4 9 12 0 5 8 13 3 6 11 14 2 7 10 15] + 1;
        output = input;
        for i = 1:length(BP)
            output(i) = input(BP(i));
        end
    end

%function for decryption
    function plaintext = ANU_decrypt(ciphertext, roundKeys)
        for round = 25:-1:1
            %disp(ciphertext);
            [L, R] = initialPermutation(ciphertext);
            %function call for one round of decryption
            [L, R] = ANURoundDecrypt(L, R, roundKeys{round});
            ciphertext = [L, R];
        end
        plaintext = ciphertext;
    end

%function for decryption of one round
    function [L, R] = ANURoundDecrypt(L, R, roundKeys)
        %swap the bit strings L and R
        temp = L;
        L = R;
        R = temp;
        %apply reverse bit permutation
        L = reversebitPermutation_ANU(L);
        R = reversebitPermutation_ANU(R);
        %apply circular shifts
        F1 = circshift(L, [0, -3]);
        F2 = circshift(L, [0, 8]);
        %apply s-box substitution
        F1 = SBox_ANU(F1);
        F2 = SBox_ANU(F2);
        %apply x-or operations
        Pt = dec2bin(bitxor(bitxor(bin2dec(R), bin2dec(F2)), bin2dec(roundKeys)), 32);
        FX = dec2bin(bitxor(bin2dec(F1), bin2dec(Pt)), 32);

        R = FX;
    end




% QTL Helpers
%The encryption function
    function ciphertext = qtl_encrypt(binKey,plaintextt)
        %generate sub keys
        oddkeys = cell(4, 1);
        evenkeys = cell(4,1);
        plaintext =cell(4,1);
        for i= 1:4
            plaintext{i} = '0000000000000000';
        end
        %divide the plaintextt received into four 16-bit strings
        for i=1:4
            plaintext{i}=plaintextt((i-1)*16 + 1 : i*16);
        end
        %keys for odd number of rounds
        for i = 1:4
            oddkeys{i} = flip(binKey(end-16*i+1:end-(16*i-16)));

        end
        %keys for even number of rounds
        for i = 1:4
            evenkeys{i} = flip(binKey(64-16*i+1:64-(16*(i-1))));
        end
        %loop start for 19 rounds of encryption
        for NR = 1:19

            if mod(NR,2) == 1
                key = evenkeys;
            else
                key = oddkeys;
            end

            for j = 1:2
                if j==1

                    f1out = function1(key{1},plaintext{1},NR);
                    f2out = function2(key{2},plaintext{3},NR);
                    plaintext{2}= dec2bin(bitxor(bin2dec(plaintext{2}),bin2dec(f1out)),16);
                    plaintext{4}= dec2bin(bitxor(bin2dec(plaintext{4}),bin2dec(f2out)),16);
                    %swap the strings in plaintext array as defined
                    plaintext([1,2,3,4]) = plaintext([2,1,4,3]);

                end
                if j==2
                    f1out = function1(key{3},plaintext{1},NR);
                    f2out = function2(key{4},plaintext{3},NR);
                    plaintext{2}= dec2bin(bitxor(bin2dec(plaintext{2}),bin2dec(f1out)),16);
                    plaintext{4}= dec2bin(bitxor(bin2dec(plaintext{4}),bin2dec(f2out)),16);

                end
            end
            %perform round transpose
            inp = [plaintext{1},plaintext{2},plaintext{3},plaintext{4}];
            out1 = roundTranspose_qtl(inp);
            %divide the array back for next round
            for i=1:4
                plaintext{i}=out1((i-1)*16 + 1 : i*16);
            end

        end
        %encryption round 20
        key =evenkeys;
        NR = 20;
        for j = 1:2
            if j ==1

                f1out = function1(key{1},plaintext{1},NR);
                f2out = function2(key{2},plaintext{3},NR);
                plaintext{2}= dec2bin(bitxor(bin2dec(plaintext{2}),bin2dec(f1out)),16);
                plaintext{4}= dec2bin(bitxor(bin2dec(plaintext{4}),bin2dec(f2out)),16);
                %swap the strings in plaintext array as defined
                plaintext([1,2,3,4]) = plaintext([2,1,4,3]);


            end
            if j==2
                f1out = function1(key{3},plaintext{1},NR);
                f2out = function2(key{4},plaintext{3},NR);
                plaintext{2}= dec2bin(bitxor(bin2dec(plaintext{2}),bin2dec(f1out)),16);
                plaintext{4}= dec2bin(bitxor(bin2dec(plaintext{4}),bin2dec(f2out)),16);
            end
        end
        %join the four 16-bit strings of plaintext after 20 rounds
        ciphertext = [plaintext{1} plaintext{2} plaintext{3} plaintext{4}];

    end
%definition for function 1
    function outf1 = function1(key1,pt,NR)

        t1 = addconstants1_qtl(pt,NR);
        t2 = addroundkeys_qtl(key1,t1);
        t3 = SBox1(t2);
        t4 = bitPermutation_qtl(t3);
        outf1 = SBox1(t4);
    end

%definition for function 2
    function outf2= function2(key2,pt,NR)
        t1 = addconstants2_qtl(pt,NR);
        t2 = addroundkeys_qtl(key2,t1);
        t3 = SBox2_qtl(t2);
        t4 = bitPermutation_qtl(t3);
        outf2 = SBox2_qtl(t4);
    end

%function to add constants in function1 of encryption
    function res = addconstants1_qtl(pt,NR)
        %array of constants
        constant1 = ['00' '01' '02' '03' '04' '05' '06' '07' '08' '09' '0A' '0B' '0C' '0D' '0E' '0F' '10' '11' '12' '13'];
        addcons1 = cell(2,1);

        %divide plaintext received into two 8-bit strings to get initial 8 bits
        for n=1:2
            addcons1{n} = pt((n-1)*8 + 1 : n*8);
        end

        %add the respective constant with those initial 8-bits
        temp1 = dec2bin(bitxor(bin2dec(addcons1{1}),hex2dec(constant1(2*NR-1:2*NR))),8);

        %concatenate the added result and last 8-bits back
        res = [temp1 addcons1{2}];

    end

%function to add constants in function2 of encryption
    function res = addconstants2_qtl(pt,NR)

        %array of constants
        constant2 = ['14' '15' '16' '17' '18' '19' '1A' '1B' '1C' '1D' '1E' '1F' '20' '21' '22' '23' '24' '25' '26' '27'];
        addcons2 = cell(2,1);

        %divide plaintext received into two 8-bit strings to get initial 8 bits
        for n=1:2
            addcons2{n} = pt((n-1)*8 + 1 : n*8);
        end

        %add the respective constant with those initial 8-bits
        temp2 = dec2bin(bitxor(bin2dec(addcons2{1}),hex2dec(constant2(2*NR-1:2*NR))),8);

        %concatenate the added result and last 8-bits back
        res = [temp2 addcons2{2}];

    end

%function definition to add roundkey(subkey)
    function result = addroundkeys_qtl(key1,pt)

        %perform bitxor on the plaintext and key received
        result = dec2bin(bitxor(bin2dec(key1),bin2dec(pt)),16);
    end

%function definition for sbox1
    function output = SBox1(input)

        output = '';

        %divide 16-bit input into four 4-bit segments and apply s-box
        for i = 1:4
            segment = input((i-1)*4 + 1 : i*4);
            output = [output, SBoxSegment1_qtl(segment)];
        end
    end

%s-box function with 4-bit input/output
    function output = SBoxSegment1_qtl(segment)

        sBoxTable1 = ['C' '5' '6' 'B' '9' '0' 'A' 'D' '3' 'E' 'F' '8' '4' '7' '1' '2'];

        segmentDecimal = bin2dec(segment) + 1;

        outputHex = sBoxTable1(segmentDecimal);

        output = dec2bin(hex2dec(outputHex), 4);
    end

%function definition for sbox2
    function output = SBox2_qtl(input)
        output = '';

        %divide 16-bit input into four 4-bit segments and apply s-box
        for i = 1:4
            segment = input((i-1)*4 + 1 : i*4);
            output = [output, SBoxSegment2_qtl(segment)];
        end
    end

%s-box function with 4-bit input/output
    function output = SBoxSegment2_qtl(segment)
        sBoxTable2 = ['4' 'F' '3' '8' 'D' 'A' 'C' '0' 'B' '5' '7' 'E' '2' '6' '1' '9'];
        segmentDecimal = bin2dec(segment) + 1;
        outputDecimal = hex2dec(sBoxTable2(segmentDecimal));
        output = dec2bin(outputDecimal, 4);
    end

%function to perform bit permutation
    function output = bitPermutation_qtl(input)
        BP = [0 4 8 12 1 5 9 13 2 6 10 14 3 7 11 15] + 1;
        output = input;
        for i = 1:length(BP)
            output(i) = input(BP(i));
        end
    end

%function to perform round transpose
    function out = roundTranspose_qtl(input)
        inp = cell(4,1);
        for i=1:4
            inp{i}=input((i-1)*16 + 1 : i*16);
        end
        inp([1,2,3,4]) = inp([3,2,1,4]);
        out = [inp{1} inp{2} inp{3} inp{4}];

    end

%the decryption function
    function decryptedtext = qtl_decrypt(binKey,ciphertextt)
        oddkeys = cell(4, 1);
        evenkeys = cell(4,1);
        plaintext =cell(4,1);
        for i= 1:4
            plaintext{i} = '0000000000000000';
        end
        % divide the ciphertextt received into four 16-bit strings
        for i=1:4
            plaintext{i}=ciphertextt((i-1)*16 + 1 : i*16);
        end
        %generate subkeys
        for i = 1:4
            oddkeys{i} = flip(binKey(end-16*i+1:end-(16*i-16)));

        end

        for i = 1:4
            evenkeys{i} = flip(binKey(64-16*i+1:64-(16*(i-1))));
        end

        %loop start for 19 rounds of decryption
        for NR = 1:19

            if mod(NR,2) == 1
                key_decr = evenkeys;

            else
                key_decr = oddkeys;
            end
            %change the subkeys as defined for the decryption
            key{1}=key_decr{3};
            key{2}=key_decr{4};
            key{3}=key_decr{1};
            key{4}=key_decr{2};

            for j = 1:2
                if j==1

                    f1out = function1decr(key{1},plaintext{1},NR);
                    f2out = function2decr(key{2},plaintext{3},NR);
                    plaintext{2}= dec2bin(bitxor(bin2dec(plaintext{2}),bin2dec(f1out)),16);
                    plaintext{4}= dec2bin(bitxor(bin2dec(plaintext{4}),bin2dec(f2out)),16);
                    %swap the strings in plaintext array as defined
                    plaintext([1,2,3,4]) = plaintext([2,1,4,3]);

                end
                if j==2
                    f1out = function1decr(key{3},plaintext{1},NR);
                    f2out = function2decr(key{4},plaintext{3},NR);
                    plaintext{2}= dec2bin(bitxor(bin2dec(plaintext{2}),bin2dec(f1out)),16);
                    plaintext{4}= dec2bin(bitxor(bin2dec(plaintext{4}),bin2dec(f2out)),16);

                end
            end

            inp = [plaintext{1},plaintext{2},plaintext{3},plaintext{4}];

            %perform round transpose
            out1 = roundTranspose_qtl(inp);

            %divide ciphertext back for next round of decryption
            for i=1:4
                plaintext{i}=out1((i-1)*16 + 1 : i*16);
            end

        end
        %decryption round 20
        key_decr =oddkeys;
        key{1}=key_decr{3};
        key{2}=key_decr{4};
        key{3}=key_decr{1};
        key{4}=key_decr{2};
        NR = 20;

        for j = 1:2
            if j ==1

                f1out = function1decr(key{1},plaintext{1},NR);
                f2out = function2decr(key{2},plaintext{3},NR);
                plaintext{2}= dec2bin(bitxor(bin2dec(plaintext{2}),bin2dec(f1out)),16);
                plaintext{4}= dec2bin(bitxor(bin2dec(plaintext{4}),bin2dec(f2out)),16);
                %swap the strings in plaintext array as defined
                plaintext([1,2,3,4]) = plaintext([2,1,4,3]);


            end
            if j==2
                f1out = function1(key{3},plaintext{1},NR);
                f2out = function2(key{4},plaintext{3},NR);
                plaintext{2}= dec2bin(bitxor(bin2dec(plaintext{2}),bin2dec(f1out)),16);
                plaintext{4}= dec2bin(bitxor(bin2dec(plaintext{4}),bin2dec(f2out)),16);
            end
        end
        %concatenate the four 16-bit strings back after 20 rounds of decryption
        decryptedtext = [plaintext{1} plaintext{2} plaintext{3} plaintext{4}];

    end

%function definition for function1 for decryption
    function outf1 = function1decr(key1,pt,NR)

        t1 = addconstants1decr_qtl(pt,NR);
        t2 = addroundkeys_qtl(key1,t1);
        t3 = SBox1(t2);
        t4 = bitPermutation_qtl(t3);
        outf1 = SBox1(t4);
    end

%function definition for function2 for decryption
    function outf2= function2decr(key2,pt,NR)

        t1 = addconstants2decr_qtl(pt,NR);
        t2 = addroundkeys_qtl(key2,t1);
        t3 = SBox2_qtl(t2);
        t4 = bitPermutation_qtl(t3);
        outf2 = SBox2_qtl(t4);
    end

%function definition for adding constants in function1 of decryption
    function res = addconstants1decr_qtl(pt,NR)

        %array of constants
        constant1 =  ['13' '12' '11' '10' '0F' '0E' '0D' '0C' '0B' '0A' '09' '08' '07' '06' '05' '04' '03' '02' '01' '00'];
        addcons1 = cell(2,1);

        %divide the ciphertext received to two 8-bit strings to get initial 8-bits
        for n=1:2
            addcons1{n} = pt((n-1)*8 + 1 : n*8);
        end

        %add constants to those initial 8-bits
        temp1 = dec2bin(bitxor(bin2dec(addcons1{1}),hex2dec(constant1(2*NR-1:2*NR))),8);

        %concatenate added result with last 8-bits
        res = [temp1 addcons1{2}];

    end

%function definition for adding constants in function2 of decryption
    function res = addconstants2decr_qtl(pt,NR)

        %array of constants
        constant2 = ['27' '26' '25' '24' '23' '22' '21' '20' '1F' '1E' '1D' '1C' '1B' '1A' '19' '18' '17' '16' '15' '14'];
        addcons2 = cell(2,1);

        %divide the ciphertext received to two 8-bit strings to get initial 8-bits
        for n=1:2
            addcons2{n} = pt((n-1)*8 + 1 : n*8);
        end

        %add constants to those initial 8-bits
        temp2 = dec2bin(bitxor(bin2dec(addcons2{1}),hex2dec(constant2(2*NR-1:2*NR))),8);

        %concatenate added result with last 8-bits
        res = [temp2 addcons2{2}];
    end





% MIDORI Helpers
%the encryption function
    function ciphertext = midoriEncrypt(plaintext,RK,WK)
        %making 4 by 4 array of plaintext
        S = cell(4,4);
        c3 = 1;
        for j = 1:4
            for i = 1:4
                S{i, j} = plaintext(c3:c3+3);
                c3 = c3 + 4;
            end
        end
        %the function callings
        St = keyAdd(S,WK);
        for n = 1:15
            t2 = subCell(St);
            t3 = shuffleCell(t2);
            t4 = mixColumns_midori(t3);
            St = keyAdd(t4,RK(:,:,n));
        end
        temp = subCell(St);
        cipher = keyAdd(temp,WK);
        %forming a ciphertext out of 4 by 4 array
        ciphertext = [cipher{1,1} cipher{2,1} cipher{3,1} cipher{4,1} cipher{1,2} cipher{2,2} cipher{3,2} cipher{4,2} cipher{1,3} cipher{2,3} cipher{3,3} cipher{4,3} cipher{1,4} cipher{2,4} cipher{3,4} cipher{4,4}];
    end

%the key addition function
    function res = keyAdd(X,WK)
        res = cell(4,4);
        %bitxor the key with plaintext
        for i =1:4
            for j = 1:4
                res{i,j} = dec2bin(bitxor(bin2dec(X{i,j}),bin2dec(WK{i,j})),4);
            end
        end
    end

%the substitution function
    function res = subCell(S)
        res = cell(4,4);
        sb = ['C' 'A' 'D' '3' 'E' 'B' 'F' '7' '8' '9' '1' '5' '0' '2' '4' '6'];
        for i =1:4
            for j=1:4
                stDecimal = bin2dec(S{i,j}) + 1;
                outputDecimal = hex2dec(sb(stDecimal));
                res{i,j} = dec2bin(outputDecimal, 4);
            end
        end
    end

%the permutation function
    function res = shuffleCell(S)
        res = cell(4,4);
        p= [1,1,3,3,2,2,4,4,3,4,1,2,4,3,2,1,2,3,4,1,1,4,3,2,4,2,2,4,3,1,1,3];
        c=1;
        for j=1:4
            for i=1:4
                res{i,j} = S{p(c),p(c+1)};
                c=c+2;
            end
        end
    end

%the mix columns function
    function state = mixColumns_midori(state)
        M = [bin2dec('0') bin2dec('1') bin2dec('1') bin2dec('1');
            bin2dec('1') bin2dec('0') bin2dec('1') bin2dec('1');
            bin2dec('1') bin2dec('1') bin2dec('0') bin2dec('1');
            bin2dec('1') bin2dec('1') bin2dec('1') bin2dec('0')];

        % Convert state from binary strings to decimal
        state = cellfun(@(x) bin2dec(x), state);
        result = zeros(4, 4);
        for i = 1:4
            for j = 1:4
                temp = 0;
                for k = 1:4
                    % Multiply in GF(2^4) and then add (XOR) the results
                    temp = bitxor(temp, gfmult_midori(M(i,k), state(k,j)));
                end
                result(i,j) = temp;
            end
        end

        % Convert state back to binary strings
        state = arrayfun(@(x) dec2bin(x,4), result, 'UniformOutput', false);
    end

    function result = gfmult_midori(a, b)

        p = bin2dec('10011'); % Corresponds to x^4 + x + 1
        result = 0;

        while b > 0
            % If the lsb of b is 1, add (XOR) a to the result
            if bitand(b, 1) == 1
                result = bitxor(result, a);
            end

            % Multiply a by x (left shift) and reduce if necessary
            a = bitshift(a, 1);
            if a >= 16
                a = bitxor(a, p);
            end

            % Divide b by x (right shift)
            b = bitshift(b, -1);
        end
    end

%the decryption function
    function decryptedText = midoriDecrypt(ciphertext,RK,WK)
        S = cell(4,4);
        c3 = 1;
        %forming 4 by 4 array of ciphertext
        for j = 1:4
            for i = 1:4
                S{i, j} = ciphertext(c3:c3+3);
                c3 = c3 + 4;
            end
        end
        %making inverse keys for decryption
        for i = 1:15
            temp = mixColumns_midori(RK(:,:,i));
            RK(:,:,i) = invshuffleCell(temp);
        end
        St = keyAdd(S,WK);
        for n = 15:-1:1
            t2 = subCell(St);
            t3 = mixColumns_midori(t2);
            t4 = invshuffleCell(t3);
            St = keyAdd(t4,RK(:,:,n));
        end
        temp = subCell(St);
        cipher = keyAdd(temp,WK);
        %making a decryptedtext out of 4 by 4 array
        decryptedText = [cipher{1,1} cipher{2,1} cipher{3,1} cipher{4,1} cipher{1,2} cipher{2,2} cipher{3,2} cipher{4,2} cipher{1,3} cipher{2,3} cipher{3,3} cipher{4,3} cipher{1,4} cipher{2,4} cipher{3,4} cipher{4,4}];
    end

%the inverse permutation function for decryption
    function res = invshuffleCell(S)
        res = cell(4,4);
        p= [1,1,4,2,3,4,2,3,2,2,3,1,4,3,1,4,4,4,1,3,2,1,3,2,3,3,2,4,1,2,4,1];
        c=1;
        for j=1:4
            for i=1:4
                res{i,j} = S{p(c),p(c+1)};
                c=c+2;
            end
        end
    end





% RECTANGLE Helpers
%function for key scheduling and making round keys
    function keys = keyScheduling(binKey)
        keys = cell(4,16,26);
        rkeys = cell(4,32,26);
        RK = cell(4,32);
        k = cell(4,1);
        %divide main key into 4 parts
        for i = 1:4
            k{i} = binKey((i-1)*32 + 1 : i*32);
        end
        %divide each part into 32 parts and store in 4 by 32 array
        for i=1:4
            RK(i,:) = num2cell(k{i}(end:-1:1));
        end

        %25 rounds to generate 25 roundkeys
        for n =1:25

            %copy last round key in RK
            for i = 1:4
                for j = 1:32
                    rkeys{i,j,n} = RK{i,j};
                end
            end

            %perform s-box on rightmost 8 columns
            for j = 25:32
                temp = [RK{4,j} RK{3,j} RK{2,j} RK{1,j}];
                result = sbox(temp,1);
                RK{4,j} = result(1);
                RK{3,j} = result(2);
                RK{2,j} = result(3);
                RK{1,j} = result(4);
            end

            %temporarily store row 1
            temp1 = cell(1,32);
            for i = 1:32
                temp1{1,i} = RK{1,i};
            end

            %left shift row 1 by 8 bits
            temp = cell2mat(RK(1,:));
            temp = circshift(temp, [0, -8]);
            RK(1,:) = num2cell(temp);

            %bitxor row 1 with row 2 and store in row1
            for i=1:32
                RK{1,i} = dec2bin(bitxor(bin2dec(RK{1,i}),bin2dec(RK{2,i})),1);
            end

            %copy row 3 into row 2
            for i =1:32
                RK{2,i} = RK{3,i};
            end

            %left shift row 3 by 16 bits
            temp = cell2mat(RK(3,:));
            temp = circshift(temp, [0, -16]);
            RK(3,:) = num2cell(temp);

            %bitxor row 3 with row 4 and store in row 3
            for i=1:32
                RK{3,i} = dec2bin(bitxor(bin2dec(RK{4,i}),bin2dec(RK{3,i})),1);
            end

            %add constants to required bits
            for i =1:32
                RK{4,i} = temp1{1,i};
            end
            temp = [RK{1,28} RK{1,29} RK{1,30} RK{1,31} RK{1,32}];

            temp = addconstants(temp,n);
            RK{1,28} = temp(1);
            RK{1,29} = temp(2);
            RK{1,30} = temp(3);
            RK{1,31} = temp(4);
            RK{1,32} = temp(5);
        end

        %generate last 26th roundkey
        for i = 1:4
            for j = 1:32
                rkeys{i,j,26} = RK{i,j};
            end
        end

        %extract 16 rightmost columns from 4 by 32 array and store in 4 by 16 array
        for k = 1:26
            for i = 1:4
                keys(i, 1:16, k) = rkeys(i, end-15:end, k);
            end
        end
    end

%function for encryption
    function [ciphertext,Rkeys] = rectangleEncrypt(binKey,plaintext)

        %generate round keys
        Rkeys = keyScheduling(binKey);

        %make the plaintext into 4 by 16 array st
        s = cell(4, 1);
        for i = 1:4
            s{i} = plaintext((i-1)*16 + 1 : i*16);
        end
        st = cell(4,16);
        for i=1:4
            st(i,:) = num2cell(s{i}(end:-1:1));
        end

        %perform 25 rounds of encryption
        for n=1:25
            t1 = addroundkey(st,Rkeys(:,:,n));
            t2 = subColumn(t1,1);
            st = shiftRow(t2,1);
        end

        %add 26th round key with st
        cipher = addroundkey(st,Rkeys(:,:,26));

        %add back the st array to 64 bit ciphertext
        temp1 = cell(4,1);
        for n=1:4
            temp1{n} = [cipher{n,:}];
        end
        ciphertext = [temp1{1} temp1{2} temp1{3} temp1{4}];
    end

%function for decryption
    function plaintext = rectangleDecrypt(Rkeys,ciphertext)

        %make the ciphertext into 4 by 16 array st
        s = cell(4, 1);
        for i = 1:4
            s{i} = ciphertext((i-1)*16 + 1 : i*16);
        end
        st = cell(4,16);
        for i=1:4
            st(i,:) = num2cell(s{i}(1:end));
        end

        %reverse the steps followed for encryption
        st = addroundkey(st,Rkeys(:,:,26));
        for n=25:-1:1
            t1 = shiftRow(st,2);
            t2 = subColumn(t1,2);
            st = addroundkey(t2,Rkeys(:,:,n));
        end

        %add 64 bit plaintext back from 4 by 16 array
        plain = st;
        temp1 = cell(4,1);
        for n=1:4
            temp1{n} = [plain{n,:}];
        end
        plaintext = [temp1{1} temp1{2} temp1{3} temp1{4}];
    end

%function for substitution box
    function output = sbox(input,n)

        %substitution table for encryption
        if n==1
            sBoxTable = ['6' '5' 'C' 'A' '1' 'E' '7' '9' 'B' '0' '3' 'D' '8' 'F' '4' '2'];

            %substitution table for decryption
        else
            sBoxTable = ['9' '4' 'F' 'A' 'E' '1' '0' '6' 'C' '7' '3' '8' '2' 'B' '5' 'D'];
        end
        inputDecimal = bin2dec(input) + 1;
        outputDecimal = hex2dec(sBoxTable(inputDecimal));
        output = dec2bin(outputDecimal, 4);
    end

%function to add constants
    function res = addconstants(st,n)

        %constants table
        constants =['01' '02' '04' '09' '12' '05' '0B' '16' '0C' '19' '13' '07' '0F' '1F' '1E' '1C' '18' '11' '03' '06' '0D' '1B' '17' '0E' '1D'];

        %convert constants to 5 bit binary string
        temp = dec2bin(hex2dec(constants(2*n-1:2*n)),5);

        %add the constants with 5 bit input
        res = dec2bin(bitxor(bin2dec(st),bin2dec(temp)),5);
    end

%funcction to add roundkeys
    function res = addroundkey(st,keys)
        res = cell(4,16);
        for i = 1:4
            for j=1:16
                res{i,j} = dec2bin(bitxor(bin2dec(st{i,j}),bin2dec(keys{i,j})),1);
            end
        end
    end

%function to perform parallel substitution box on columns
    function res = subColumn(st,n)
        temp = cell(16,1);

        %store all bits of a column in a string
        %store all those strings in a array
        for i =1:16
            temp{i} = [st{4,i} st{3,i} st{2,i} st{1,i}];
        end

        %perform sbox on those strings
        for i =1:16
            temp{i} = sbox(temp{i},n);
        end
        for i =1:16
            st{4,i} = temp{i}(1);
            st{3,i} = temp{i}(2);
            st{2,i} = temp{i}(3);
            st{1,i} = temp{i}(4);
        end
        res = st;
    end

%function to perform shifts on rows of an array
    function res = shiftRow(st,n)
        offsets = [0, 1, 12, 13];
        for i = 1:4
            temp = cell2mat(st(i,:));

            %perform left shift for encryption
            if n==1
                temp = circshift(temp, [0, -offsets(i)]);

                %perform right shift for decryption
            else
                temp = circshift(temp, [0, offsets(i)]);
            end
            st(i,:) = num2cell(temp);
        end
        res = st;
    end




% PRESENT Helpers
%encryption function
    function C=Present_enc(P_in, K)
        S=P_in;
        K_s=K;
        for i=1:31
            %    i
            S=addRoundKey_present(S, K_s(1:64));
            S=sboxLayer_present(S);
            S=permutation_present(S);
            K_s=updateKey(K_s, i);
        end
        C=addRoundKey_present(S, K_s(1:64));

    end


%Decryption function

    function C=Present_dec(P_in, K)
        S=P_in;
        K_s=K;
        for i=1:31
            K_s=updateKey(K_s, i);
        end
        K_hex="";
        for i=1:4:64
            K_hex(end+1)=dec2hex(bin2dec(K_s(i:i+3)));
        end

        for i=31:-1:1

            S=addRoundKey_present(S, K_s(1:64));
            S=permutation_decr_present(S);
            S=sboxLayer_decr_present(S);
            K_s=updateKey_d(K_s, i);
            S_hex="";
            K_hex="";
            for n=1:4:64
                S_hex(end+1)=dec2hex(bin2dec(S(n:n+3)));
                K_hex(end+1)=dec2hex(bin2dec(K_s(n:n+3)));
            end


        end
        C=addRoundKey_present(S, K_s(1:64));

    end
    function s_out=addRoundKey_present(s_in, key)
        for i=1:4:64
            s_out(i:i+3) = dec2bin(bitxor(bin2dec(s_in(i:i+3)), bin2dec(key(i:i+3))), 4);
        end
    end

    function s_out=sboxLayer_present(s_in) % Encryption
        sbox=[12 5 6 11 9 0 10 13 3 14 15 8 4 7 1 2];
        for i=1:4:64
            s_out(i:i+3) = dec2bin(sbox(bin2dec(s_in(i:i+3))+1), 4);
        end
    end

    function s_out=sboxLayer_decr_present(s_in) % Decryption
        sbox=[5 14 15 8 12 1 2 13 11 4 6 3 0 7 9 10];
        for i=1:4:64
            s_out(i:i+3) = dec2bin(sbox(bin2dec(s_in(i:i+3))+1), 4);
        end
    end

    function s_out=permutation_present(s_in) % Encryption
        Perm=[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 ...
            1 5 9 13 17 21 25 29 33 37 41 45 49 53 57 61 ...
            2 6 10 14 18 22 26 30 34 38 42 46 50 54 58 62 ...
            3 7 11 15 19 23 27 31 35 39 43 47 51 55 59 63];
        for i = 1:64
            s_out(i)=s_in(Perm(i)+1);
        end
    end

    function s_out=permutation_decr_present(s_in) % Decryption
        Perm=[0 16 32 48 1 17 33 49 2 18 34 50 3 19 35 51 ...
            4 20 36 52 5 21 37 53 6 22 38 54 7 23 39 55 ...
            8 24 40 56 9 25 41 57 10 26 42 58 11 27 43 59 ...
            12 28 44 60 13 29 45 61 14 30 46 62 15 31 47 63];
        for i = 1:64
            s_out(i)=s_in(Perm(i)+1);
        end
    end

    function key_out=updateKey(key, i) % Encryption
        sbox=[12 5 6 11 9 0 10 13 3 14 15 8 4 7 1 2];
        key_out=[key(62:80) key(1:61)];
        key_out(1:4)=dec2bin(sbox(bin2dec(key_out(1:4))+1),4);
        key_out(61:65)=dec2bin(bitxor(i, bin2dec(key_out(61:65))), 5);
    end

    function key_out=updateKey_d(key, i) % Decryption
        sbox=[5 14 15 8 12 1 2 13 11 4 6 3 0 7 9 10];
        key_out=key;
        key_out(61:65)=dec2bin(bitxor(i, bin2dec(key_out(61:65))), 5);
        key_out(1:4)=dec2bin(sbox(bin2dec(key_out(1:4))+1),4);
        key_out=[key_out(20:80) key_out(1:19)];
    end





% HIGHT Helpers
    function state=create_state_HIGHT(X, m)
        state=[];
        if m<=0
            for i=1:8:(length(X)-7)
                state=[bin2dec(X(i:i+7)) state];
            end
        else
            j=0;
            for i=1:2:length(X)-1
                state=[hex2dec(X(i:i+1)) state];
            end
        end
    end
% Keyschedule
    function wk=whiteningKey(K)
        % create the whitening key that is used before the first round and after the last round
        for i=1:8
            if i<=4
                wk(i)=K(i+12);
            else
                wk(i)=K(i-4);
            end
        end
    end

    function cst=constantGen()
        % Generate constants used for the round
        cst='0101101';
        for i=1:127
            cst(7+i)=dec2bin(bitxor(bin2dec(cst(i+3)), bin2dec(cst(i))), 1);
        end
    end

    function c=extract_const(cst, i)
        % Extract the correct constant for the round i from the vector cst generated by the function constantGen
        c='';
        for j=i:i+6
            c=[cst(j+1) c];
        end
    end

    function sk=subkey_HIGHT(K, cst)
        % Generated the subkey used during the round
        for i=0:7
            for j=0:7
                c=extract_const(cst, 16*i+j);
                sk(16*i+j+1)=mod(K(mod(j-i, 8)+1)+ bin2dec(c), 256);
                c=extract_const(cst, 16*i+j+8);
                sk(16*i+j+9)=mod(K(mod(j-i, 8)+9)+ bin2dec(c), 256);
            end
        end
    end

% Initial transformations
    function x=initialTransformation_HIGHT(P, wk)
        x(1)=mod(P(1)+wk(1), 256);
        x(2)=P(2);
        x(3)=bitxor(P(3), wk(2));
        x(4)=P(4);
        x(5)=mod(P(5)+wk(3), 256);
        x(6)=P(6);
        x(7)=bitxor(P(7), wk(4));
        x(8)=P(8);
    end

    function x=initialTransformation_d(P, wk)
        x(2)=mod(P(1)-wk(5), 256);
        x(3)=P(2);
        x(4)=bitxor(P(3), wk(6));
        x(5)=P(4);
        x(6)=mod(P(5)-wk(7), 256);
        x(7)=P(6);
        x(8)=bitxor(P(7), wk(8));
        x(1)=P(8);
    end
% round
    function res=rotl(bin, d) %% Left rotation of d bits
        if d>1
            res=rotl([bin(2:end) bin(1)], d-1);
        else
            res=[bin(2:end) bin(1)];
        end
    end

    function x=f0(s) %% Function f0 of the round
        bin=dec2bin(s,8);
        x=bitxor(bitxor(bin2dec(rotl(bin,1)), bin2dec(rotl(bin,2))), bin2dec(rotl(bin,7)));
    end

    function x=f1(s) %% Function f1 of the round
        bin=dec2bin(s,8);
        x=bitxor(bitxor(bin2dec(rotl(bin,3)), bin2dec(rotl(bin,4))), bin2dec(rotl(bin,6)));
    end

    function x=Round_HIGHT(state, sk, i) %% Encryption
        x(1)=bitxor(state(8), mod(f0(state(7))+sk(4*i+4), 256));
        x(2)=state(1);
        x(3)=mod(state(2)+bitxor(f1(state(1)),sk(4*i+1)), 256);
        x(4)=state(3);
        x(5)=bitxor(state(4), mod(f0(state(3))+sk(4*i+2), 256));
        x(6)=state(5);
        x(7)=mod(state(6)+bitxor(f1(state(5)),sk(4*i+3)), 256);
        x(8)=state(7);
    end

    function x=Round_d(state, sk, i) %% Decryption
        sk_3=sk(4*i+4);
        x(8)=bitxor(state(1), mod(f0(state(8))+sk(4*i+4), 256));
        x(1)=state(2);
        sk_0=sk(4*i+1);
        x(2)=mod(state(3)-bitxor(f1(state(2)),sk(4*i+1)), 256);
        x(3)=state(4);
        sk_1=sk(4*i+2);
        x(4)=bitxor(state(5), mod(f0(state(4))+sk(4*i+2), 256));
        x(5)=state(6);
        sk_2=sk(4*i+3);
        x(6)=mod(state(7)-bitxor(f1(state(6)),sk(4*i+3)), 256);
        x(7)=state(8);
    end
%  Final transformation
    function c=FinalTransformation_HIGHT(x, wk) %% Encryption
        c(1)=mod(x(2)+wk(5), 256);
        c(2)=x(3);
        c(3)=bitxor(x(4), wk(6));
        c(4)=x(5);
        c(5)=mod(x(6)+wk(7), 256);
        c(6)=x(7);
        c(7)=bitxor(x(8), wk(8));
        c(8)=x(1);
    end

    function c=FinalTransformation_d(x, wk) %% Decryption
        c(1)=mod(x(1)-wk(1), 256);

        c(2)=x(2);
        c(3)=bitxor(x(3), wk(2));
        c(4)=x(4);
        c(5)=mod(x(5)-wk(3), 256);
        c(6)=x(6);
        c(7)=bitxor(x(7), wk(4));
        c(8)=x(8);
    end

%  Encryption function

    function C=Hight_enc(m_b, key) %% Encryption
        k = '';

        for i = 1:4:length(key)
            bin = key(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            k = [k hex];  % Append to the hexadecimal string
        end
        binStr = m_b;
        m = '';

        for i = 1:4:length(binStr)
            bin = binStr(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            m = [m hex];  % Append to the hexadecimal string
        end
        % Initialization
        state_m=create_state_HIGHT(m, 1);
        state_k=create_state_HIGHT(k, 1);
        wk=whiteningKey(state_k);
        cst=constantGen();
        sk=subkey_HIGHT(state_k, cst);
        state_m=initialTransformation_HIGHT(state_m, wk);
        % Rounds
        for i=0:31
            state_m=Round_HIGHT(state_m, sk, i);
        end
        % Final transformation
        C_tmp=FinalTransformation_HIGHT(state_m, wk);
        % reformat cipher
        C_tmp=dec2hex(C_tmp);
        C='';
        for i=1:length(C_tmp)
            C=[C_tmp(i,:) C];
        end
        binStr = '';

        for i = 1:length(C)
            dec = hex2dec(C(i));
            bin = dec2bin(dec, 4);  % Convert to binary with 4 digits
            binStr = [binStr bin];  % Append to the binary string
        end
        C=binStr;

    end
%Decryption function
    function M=Hight_dec(C_b, key) %% Decryption
        k = '';

        for i = 1:4:length(key)
            bin = key(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            k = [k hex];  % Append to the hexadecimal string
        end
        % Initialization
        binStr = C_b;
        C = '';

        for i = 1:4:length(binStr)
            bin = binStr(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            C = [C hex];  % Append to the hexadecimal string
        end

        state_m=create_state_HIGHT(C, 1);
        state_k=create_state_HIGHT(k, 1);
        wk=whiteningKey(state_k);
        cst=constantGen();
        sk=subkey_HIGHT(state_k, cst);
        state_m=initialTransformation_d(state_m, wk);
        % Rounds
        for i=0:31
            31-i;
            state_m=Round_d(state_m, sk, 31-i);
        end
        % Final transformation
        M_tmp=FinalTransformation_d(state_m, wk);
        % reformat message
        M_tmp=dec2hex(M_tmp);
        M='';
        for i=1:length(M_tmp)
            M=[M_tmp(i,:) M];
        end
        binStr = '';

        for i = 1:length(M)
            dec = hex2dec(M(i));
            bin = dec2bin(dec, 4);  % Convert to binary with 4 digits
            binStr = [binStr bin];  % Append to the binary string
        end
        M=binStr;
    end






% KLEIN Helpers
    function state=create_state_KLIEN(X)
        % Transform an hexadecimal message X into a state
        for i=1:length(X)
            state(i)=hex2dec(X(i));
        end
    end

    function s=subnibble_KLIEN(X) %% Sbox
        sbox=[7 4 10 9 1 15 11 0 12 3 2 6 8 14 13 5];
        for i=1:length(X)
            s(i)=sbox(X(i)+1);
        end
    end

    function s=rotate_nibble_KLIEN(X) %% Encryption Rotation
        s=[X(5:16) X(1:4)];
    end

    function s=rotate_nibble_d_KLIEN(X) %% Decryption Rotation
        s=[X(13:16) X(1:12)];
    end

    function s=f_KLIEN(x) %% xtimes
        bin=dec2bin(x, 8);
        le=bin2dec([bin(2:8) '0']);
        if bin(1)=='1'
            ri=hex2dec('1B');
        else
            ri=0;
        end
        s=bitxor(le,ri);

    end

    function s=mixnibble_KLIEN(X) %% Encryption MixColumn
        for i=1:8
            oct(i)=bin2dec([dec2bin(X(2*(i-1)+1),4) dec2bin(X(2*i),4)]);
        end
        tmp(1) = bitxor(bitxor(bitxor(f_KLIEN(bitxor(oct(1),oct(2))),oct(2)),oct(3)),oct(4));
        tmp(2) = bitxor(bitxor(bitxor(f_KLIEN(bitxor(oct(2),oct(3))),oct(1)),oct(3)),oct(4));
        tmp(3) = bitxor(bitxor(bitxor(f_KLIEN(bitxor(oct(3),oct(4))),oct(1)),oct(2)),oct(4));
        tmp(4) = bitxor(bitxor(bitxor(f_KLIEN(bitxor(oct(4),oct(1))),oct(1)),oct(2)),oct(3));
        tmp(5) = bitxor(bitxor(bitxor(f_KLIEN(bitxor(oct(5),oct(6))),oct(6)),oct(7)),oct(8));
        tmp(6) = bitxor(bitxor(bitxor(f_KLIEN(bitxor(oct(6),oct(7))),oct(5)),oct(7)),oct(8));
        tmp(7) = bitxor(bitxor(bitxor(f_KLIEN(bitxor(oct(7),oct(8))),oct(5)),oct(6)),oct(8));
        tmp(8) = bitxor(bitxor(bitxor(f_KLIEN(bitxor(oct(8),oct(5))),oct(5)),oct(6)),oct(7));
        for i=1:8
            bin=dec2bin(tmp(i), 8);
            s(2*(i-1)+1)=bin2dec(bin(1:4));
            s(2*i)=bin2dec(bin(5:8));
        end
    end

    function s=mixnibble_d_KLIEN(X) %% Decryption MixColumn
        for i=1:8
            oct(i)=bin2dec([dec2bin(X(2*(i-1)+1),4) dec2bin(X(2*i),4)]);
        end
        var1 = bitxor(oct(4), bitxor(oct(2), bitxor(oct(3), oct(1))));
        var2 = bitxor(oct(8), bitxor(oct(7), bitxor(oct(6), oct(5))));

        tmp(1) = bitxor(f_KLIEN(bitxor(f_KLIEN(bitxor(f_KLIEN(var1), bitxor(oct(3), oct(1)))),  bitxor(oct(2), oct(1)))), bitxor(oct(4), bitxor(oct(2), oct(3))));
        tmp(2) = bitxor(f_KLIEN(bitxor(f_KLIEN(bitxor(f_KLIEN(var1), bitxor(oct(4), oct(2)))),  bitxor(oct(3), oct(2)))), bitxor(oct(1), bitxor(oct(3), oct(4))));
        tmp(3) = bitxor(f_KLIEN(bitxor(f_KLIEN(bitxor(f_KLIEN(var1), bitxor(oct(1), oct(3)))),  bitxor(oct(4), oct(3)))), bitxor(oct(2), bitxor(oct(4), oct(1))));
        tmp(4) = bitxor(f_KLIEN(bitxor(f_KLIEN(bitxor(f_KLIEN(var1), bitxor(oct(2), oct(4)))),  bitxor(oct(1), oct(4)))), bitxor(oct(3), bitxor(oct(1), oct(2))));
        tmp(5) = bitxor(f_KLIEN(bitxor(f_KLIEN(bitxor(f_KLIEN(var2), bitxor(oct(7), oct(5)))),  bitxor(oct(6), oct(5)))), bitxor(oct(8), bitxor(oct(6), oct(7))));
        tmp(6) = bitxor(f_KLIEN(bitxor(f_KLIEN(bitxor(f_KLIEN(var2), bitxor(oct(8), oct(6)))),  bitxor(oct(7), oct(6)))), bitxor(oct(5), bitxor(oct(7), oct(8))));
        tmp(7) = bitxor(f_KLIEN(bitxor(f_KLIEN(bitxor(f_KLIEN(var2), bitxor(oct(5), oct(7)))),  bitxor(oct(8), oct(7)))), bitxor(oct(6), bitxor(oct(8), oct(5))));
        tmp(8) = bitxor(f_KLIEN(bitxor(f_KLIEN(bitxor(f_KLIEN(var2), bitxor(oct(6), oct(8)))),  bitxor(oct(5), oct(8)))), bitxor(oct(7), bitxor(oct(5), oct(6))));

        for i=1:8
            bin=dec2bin(tmp(i), 8);
            s(2*(i-1)+1)=bin2dec(bin(1:4));
            s(2*i)=bin2dec(bin(5:8));
        end
    end
% Keyschedule
    function s=keyschedule_KLIEN(K, i)
        sbox=[7 4 10 9 1 15 11 0 12 3 2 6 8 14 13 5];
        a=[K(3:8) K(1) K(2)];
        b=[K(11:16) K(9) K(10)];
        s(1:8)=[b(1:5) bitxor(b(6), i) b(7:8)];
        b=bitxor(a, b);
        s(9:10)=b(1:2);
        s(11)=sbox(b(3)+1);
        s(12)=sbox(b(4)+1);
        s(13)=sbox(b(5)+1);
        s(14)=sbox(b(6)+1);
        s(15)=b(7);
        s(16)=b(8);
    end

    function s=keyschedule_d_KLIEN(K, i)
        sbox=[7 4 10 9 1 15 11 0 12 3 2 6 8 14 13 5];
        a=[K(7:8) K(1:5) bitxor(K(6), i)];
        b=[K(15:16) K(9:10) sbox(K(11)+1) sbox(K(12)+1) sbox(K(13)+1) sbox(K(14)+1)];
        s(1:8)=bitxor(a,b);
        s(9:16)=a;
    end

%encryption function
    function C=Klein_enc(m_b, key) %% Encryption
        k = '';

        for i = 1:4:length(key)
            bin = key(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            k = [k hex];  % Append to the hexadecimal string
        end
        binStr = m_b;
        m = '';

        for i = 1:4:length(binStr)
            bin = binStr(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            m = [m hex];  % Append to the hexadecimal string
        end
        % Initialization
        S=create_state_KLIEN(m);
        K=create_state_KLIEN(k);
        % Rounds
        for i=1:12
            S=bitxor(S, K);
            S=subnibble_KLIEN(S);
            S=rotate_nibble_KLIEN(S);
            S=mixnibble_KLIEN(S);
            K=keyschedule_KLIEN(K, i);
        end
        C_tmp=bitxor(S, K);
        % Reformat Cipher
        C_tmp=dec2hex(C_tmp);
        C='';
        for i=1:length(C_tmp)
            C=[C C_tmp(i,:)];
        end
        binStr = '';

        for i = 1:length(C)
            dec = hex2dec(C(i));
            bin = dec2bin(dec, 4);  % Convert to binary with 4 digits
            binStr = [binStr bin];  % Append to the binary string
        end
        C=binStr;
    end
%decryption function
    function M=Klein_dec(C_b, key) % Decryption
        k = '';

        for i = 1:4:length(key)
            bin = key(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            k = [k hex];  % Append to the hexadecimal string
        end
        % Initialization
        binStr = C_b;
        C = '';

        for i = 1:4:length(binStr)
            bin = binStr(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            C = [C hex];  % Append to the hexadecimal string
        end
        % Initialization
        S=create_state_KLIEN(C);
        K=create_state_KLIEN(k);
        % Computation of encryption Keys
        for i=1:12
            K=keyschedule_KLIEN(K, i);
        end
        % Rounds
        S=bitxor(S, K);
        for i=12:-1:1
            S=mixnibble_d_KLIEN(S);
            S=rotate_nibble_d_KLIEN(S);
            S=subnibble_KLIEN(S);
            K=keyschedule_d_KLIEN(K, i);
            S=bitxor(S, K);
        end
        % Reformat Message
        M_tmp=dec2hex(S);
        M='';
        for i=1:length(M_tmp)
            M=[M M_tmp(i,:)];
        end
        binStr = '';

        for i = 1:length(M)
            dec = hex2dec(M(i));
            bin = dec2bin(dec, 4);  % Convert to binary with 4 digits
            binStr = [binStr bin];  % Append to the binary string
        end
        M=binStr;
    end

% Lblock Helpers
    function s=create_state_LBlock(X)
        % Transform an hexadecimal message X in a state to be processed
        for i=1:length(X)
            s(i)=hex2dec(X(i));
        end
    end

    function s=create_state_bin_LBlock(X)
        % Transform an hexadecimal message X in a binary message.
        % It is used for the key
        for i=1:length(X)
            s(4*(i-1)+1:4*i)=dec2bin(hex2dec(X(i)), 4);
        end
    end

    function s=create_state_k_LBlock(X)
        % Transform an binary state in a state to be processed
        % It is used for the key
        k=1;
        for i=1:4:length(X)-3
            s(k)=bin2dec(X(i:i+3));
            k=k+1;
        end
    end

    function s=f_LBlock(X,K) %% Sboxes
        s0=[14 9 15 0 13 4 10 11 1 2 8 3 7 6 12 5];
        s1=[4 11 14 9 15 13 0 10 7 12 5 6 2 8 1 3];
        s2=[1 14 7 12 15 13 0 6 11 5 9 3 2 4 8 10];
        s3=[7 6 8 11 0 15 3 14 9 10 12 13 5 2 4 1];
        s4=[14 5 15 0 7 2 12 13 1 8 4 9 11 10 6 3];
        s5=[2 13 11 12 15 14 0 9 7 10 6 3 1 8 4 5];
        s6=[11 9 4 14 0 15 10 13 6 12 5 7 3 8 1 2];
        s7=[13 10 15 0 14 4 9 11 2 1 8 3 7 5 12 6];
        t=bitxor(X, K);
        s=[s6(t(2)+1) s4(t(4)+1) s7(t(1)+1) s5(t(3)+1) s2(t(6)+1) s0(t(8)+1) s3(t(5)+1) s1(t(7)+1)];
    end

    function sk=keyschedule_LBlock(K, i) %% Encryption keyschedule
        s8=[8 7 14 5 15 13 0 6 11 12 9 10 2 4 1 3];
        s9=[11 5 15 0 7 2 9 13 4 8 1 12 14 10 3 6];
        sk=[K(30:80) K(1:29)];
        sk(1:4)=dec2bin(s9(bin2dec(sk(1:4))+1),4);
        sk(5:8)=dec2bin(s8(bin2dec(sk(5:8))+1),4);
        sk(30:34)=dec2bin(bitxor(bin2dec(sk(30:34)), i),5);
    end

    function sk=keyschedule_d_LBlock(K, i) %% Decryption keyschedule
        s8_d=[6 14 12 15 13 3 7 1 0 10 11 8 9 5 2 4];
        s9_d=[3 10 5 14 8 1 15 4 9 6 13 0 11 7 12 2];
        sk=K;
        sk(30:34)=dec2bin(bitxor(bin2dec(sk(30:34)), i),5);
        sk(1:4)=dec2bin(s9_d(bin2dec(sk(1:4))+1),4);
        sk(5:8)=dec2bin(s8_d(bin2dec(sk(5:8))+1),4);
        sk=[sk(52:end) sk(1:51)];
    end

%encryption function

    function [C,X,K]=LBlock_enc(MSG,Key)
        k = '';

        for i = 1:4:length(Key)
            bin = Key(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            k = [k hex];  % Append to the hexadecimal string
        end
        binStr = MSG;
        m = '';

        for i = 1:4:length(binStr)
            bin = binStr(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            m = [m hex];  % Append to the hexadecimal string
        end
        s=create_state_LBlock(m);
        K=create_state_bin_LBlock(k);
        X(1,:)=s(9:16);
        X(2,:)=s(1:8);
        for i=3:34
            Ki=create_state_k_LBlock(K(1:32));
            if i<34
                K=keyschedule_LBlock(K, i-2);
            end
            X(i,:)=bitxor(f_LBlock(X(i-1,:), Ki),[X(i-2,3:end) X(i-2,1:2)]);
        end
        C=[X(33,:) X(34,:)];


        clear X;
        X(34,:)=C(9:16);
        X(33,:)=C(1:8);
        C = dec2hex(C);
        C_cell = cellstr(C);
        C = strjoin(C_cell, '');
        binStr = '';

        for i = 1:length(C)
            dec = hex2dec(C(i));
            bin = dec2bin(dec, 4);  % Convert to binary with 4 digits
            binStr = [binStr bin];  % Append to the binary string
        end
        C=binStr;
    end

%Decryption function
    function M = LBlock_dec(X,K)
        for i=32:-1:1
            Ki=create_state_k_LBlock(K(1:32));
            if i>1
                K=keyschedule_d_LBlock(K, i-1);
            end
            t=bitxor(f_LBlock(X(i+1,:), Ki), X(i+2,:));
            X(i,:)=[t(7:8) t(1:6)];
        end
        M=[X(2,:) X(1,:)];
        M =dec2hex(M);
        M_cell = cellstr(M);
        M = strjoin(M_cell, '');
        binStr = '';

        for i = 1:length(M)
            dec = hex2dec(M(i));
            bin = dec2bin(dec, 4);  % Convert to binary with 4 digits
            binStr = [binStr bin];  % Append to the binary string
        end
        M=binStr;
    end



% Lilliput Helpers
% Creation du state
    function state=create_state_Lilliput(X, m)
        %Transform a message X (binaire -> m=0, hexadecimal -> m=1) to a state to be processed
        state=[];
        if m<=0
            for i=1:4:(length(X)-3)
                state=[bin2dec(X(i:i+3)) state];
            end
        else
            for i=1:length(X)
                state(length(X)-(i-1))=hex2dec(X(i));
            end
        end
    end

% Round function
    function state=nonlinear_layer_Lilliput(X,K)
        sbox=[4 8 7 1 9 3 2 14 0 11 6 15 10 5 13 12];
        for i=1:8
            s=sbox(bitxor(X(9-i), K(i))+1);
            X(8+i)=bitxor(X(8+i), s);
        end
        state=X;
    end

    function state=linear_layer_Lilliput(X)
        for i=2:7
            X(16)=bitxor(X(16),X(i));
            X(17-i)=bitxor(X(17-i),X(8));
        end
        X(16)=bitxor(X(16),X(8));
        state=X;
    end

    function state=permutation_Lilliput(X,n)
        if n==1
            perm=[13 9 14 8 10 11 12 15 4 5 3 1 2 6 0 7];
        else
            perm=[14 11 12 10 8 9 13 15 3 1 4 5 6 0 2 7];
        end
        for i=1:16
            state(perm(i)+1)=X(i);
        end
    end

%  Keyschedule
    function RK=exctract_round_key_Lilliput(K, i)
        sbox=[4 8 7 1 9 3 2 14 0 11 6 15 10 5 13 12];
        tmp=[dec2bin(K(19),4) dec2bin(K(17),4) dec2bin(K(14),4) dec2bin(K(11),4) dec2bin(K(10),4) dec2bin(K(7),4) dec2bin(K(4),4) dec2bin(K(2),4)];
        RK='';
        for j=1:8
            RK_tmp(j)=sbox(1+bin2dec([tmp(j) tmp(8+j) tmp(16+j) tmp(24+j)]));
            RK=[RK dec2bin(RK_tmp(j),4)];
        end
        RK(1:5)=dec2bin(bitxor(bin2dec(RK(1:5)), i), 5);
        RK=create_state_Lilliput(RK, 0);
    end

    function res=rotl_Lilliput(bin, d)
        if d>1
            res=rotl_Lilliput([bin(2:end) bin(1)], d-1);
        else
            res=[bin(2:end) bin(1)];
        end
    end

    function res=rotr_Lilliput(bin, d)
        if d>1
            res=rotr_Lilliput([bin(end) bin(1:end-1)], d-1);
        else
            res=[bin(end) bin(1:end-1)];
        end
    end

    function res=shiftl_Lilliput(bin, d)
        if d>1
            res=shiftl_Lilliput([bin(2:end) '0'], d-1);
        else
            res=[bin(2:end) '0'];
        end
    end

    function res=shiftr_Lilliput(bin, d)
        if d>1
            res=shiftr_Lilliput(['0' bin(1:end-1)], d-1);
        else
            res=['0' bin(1:end-1)];
        end
    end

    function state=roundFnLFSM_Lilliput(K, d)
        if d>0
            for i=1:5:16
                K(i:i+4)=[K(i+1:i+4) K(i)];
            end
        end
        % L0
        state(1)=bitxor(K(1), bin2dec(rotr_Lilliput(dec2bin(K(5),4),1)));
        state(2)=bitxor(K(2), bin2dec(shiftr_Lilliput(dec2bin(K(3),4),3)));
        state(3)=K(3);
        state(4)=K(4);
        state(5)=K(5);
        % L1
        state(6)=K(6);
        state(7)=bitxor(K(7), bin2dec(shiftl_Lilliput(dec2bin(K(8),4),3)));
        state(8)=K(8);
        state(9)=K(9);
        state(10)=bitxor(K(10), bin2dec(rotl_Lilliput(dec2bin(K(9),4),1)));
        % L2
        state(11)=K(11);
        state(12)=bitxor(K(12), bin2dec(rotr_Lilliput(dec2bin(K(13),4),1)));
        state(13)=K(13);
        state(14)=bitxor(K(14), bin2dec(shiftr_Lilliput(dec2bin(K(13),4),3)));
        state(15)=K(15);
        % L3
        state(16)=K(16);
        state(17)=bitxor(K(17), bitxor(bin2dec(shiftl_Lilliput(dec2bin(K(16),4),3)), bin2dec(rotl_Lilliput(dec2bin(K(18),4),1))));
        state(18)=K(18);
        state(19)=K(19);
        state(20)=K(20);
        % permutaion
        if (d<=0)
            for i=1:5:16
                state(i:i+4)=[state(i+4) state(i:i+3)];
            end
        end
    end

%encryption function
    function C = Lilliput_enc(MSG,key)
        k = '';

        for i = 1:4:length(key)
            bin = key(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            k = [k hex];  % Append to the hexadecimal string
        end
        binStr = MSG;
        m = '';

        for i = 1:4:length(binStr)
            bin = binStr(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            m = [m hex];  % Append to the hexadecimal string
        end
        state_M=create_state_Lilliput(m, 1);
        state_K=create_state_Lilliput(k, 1);

        for i=0:28
            RK=exctract_round_key_Lilliput(state_K, i);
            state_K=roundFnLFSM_Lilliput(state_K, 0);
            state_M=nonlinear_layer_Lilliput(state_M, RK);
            state_M=linear_layer_Lilliput(state_M);
            state_M=permutation_Lilliput(state_M,1);
        end
        RK=exctract_round_key_Lilliput(state_K, 29);
        state_M=linear_layer_Lilliput(nonlinear_layer_Lilliput(state_M, RK));
        C='';
        for i=1:16
            C=[dec2hex(state_M(i)) C];
        end
        binStr = '';

        for i = 1:length(C)
            dec = hex2dec(C(i));
            bin = dec2bin(dec, 4);  % Convert to binary with 4 digits
            binStr = [binStr bin];  % Append to the binary string
        end
        C=binStr;
    end

%decryption function
    function M = Lilliput_dec(C_b,key)
        k = '';

        for i = 1:4:length(key)
            bin = key(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            k = [k hex];  % Append to the hexadecimal string
        end
        % Initialization
        binStr = C_b;
        C = '';

        for i = 1:4:length(binStr)
            bin = binStr(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            C = [C hex];  % Append to the hexadecimal string
        end
        state_M=create_state_Lilliput(C, 1);
        state_K=create_state_Lilliput(k, 1);
        for i=0:28
            state_K=roundFnLFSM_Lilliput(state_K, 0);
        end
        for i=29:-1:1
            RK=exctract_round_key_Lilliput(state_K, i);
            state_K=roundFnLFSM_Lilliput(state_K, 1);
            state_M=nonlinear_layer_Lilliput(state_M, RK);
            state_M=linear_layer_Lilliput(state_M);
            state_M=permutation_Lilliput(state_M,2);
        end
        RK=exctract_round_key_Lilliput(state_K, 0);
        state_M=linear_layer_Lilliput(nonlinear_layer_Lilliput(state_M, RK));
        M='';
        for i=1:16
            M=[dec2hex(state_M(i)) M];
        end
        binStr = '';

        for i = 1:length(M)
            dec = hex2dec(M(i));
            bin = dec2bin(dec, 4);  % Convert to binary with 4 digits
            binStr = [binStr bin];  % Append to the binary string
        end
        M=binStr;
    end












% LED Algorithm Helpers
    function s=create_state_LED(X)
        %Transform an hexadecimal message X in a state to be processed
        for i=1:4
            for j=1:4
                s(i,j)=hex2dec(X((i-1)*4+j));
            end
        end
    end
%  Chiffrement
% The name of each function indicates which function of the algorithm it performs

    function s=addroundKey_LED(X, K)
        s=bitxor(X, K);
    end

    function rc=generate_constant_LED(c)
        rc(1:5)=c(2:6);
        rc(6)=dec2bin(bitxor(bin2dec(c(1)), bitxor(bin2dec(c(2)), 1)));
    end

    function s=addconstant_LED(X, rc, ks)
        C=zeros(4,4);
        C(1,1)=bitxor(0, bin2dec(ks(1:4)));
        C(2,1)=bitxor(1, bin2dec(ks(1:4)));
        C(3,1)=bitxor(2, bin2dec(ks(5:8)));
        C(4,1)=bitxor(3, bin2dec(ks(5:8)));
        C(1,2)=bin2dec(rc(1:3));
        C(2,2)=bin2dec(rc(4:6));
        C(3,2)=bin2dec(rc(1:3));
        C(4,2)=bin2dec(rc(4:6));
        s=bitxor(X, C);
    end

    function s=shiftrow_LED(X)
        s(1,:)=X(1,:);
        s(2,:)=[X(2,2:4) X(2,1)];
        s(3,:)=[X(3,3:4) X(3,1:2)];
        s(4,:)=[X(4,4) X(4,1:3)];
    end

    function n=xtimes_LED(a, c)
        bin=dec2bin(a, 4);
        n=bin2dec([bin(2:4) '0']);
        if bin(1)=='1'
            n=bitxor(n, c);
        end
    end

    function s=mixcolumns_LED(X)
        tmp=X;
        for k=1:4
            s(1:3,:)=tmp(2:4,:);
            for i=1:4
                s(4,i)=bitxor(xtimes_LED(xtimes_LED(tmp(1,i),3),3), bitxor(tmp(2,i), xtimes_LED(bitxor(tmp(3,i), tmp(4,i)),3)));
            end
            tmp=s;
        end
    end

    function [s ,rc]=Round_LED(X, c, ks)
        sbox=[12 5 6 11 9 0 10 13 3 14 15 8 4 7 1 2];
        rc=generate_constant_LED(c);
        s=addconstant_LED(X, rc, ks);
        s=sbox(s+1);
        s=shiftrow_LED(s);
        s=mixcolumns_LED(s);
    end

% Dechiffrement
% The name of each function indicates which function of the algorithm it performs
    function s=mixcolumns_d_LED(X)
        tmp=X;
        for k=1:4
            s(2:4,:)=tmp(1:3,:);
            for i=1:4
                var1=bitxor(tmp(1,i), tmp(4,i));
                var2=bitxor(tmp(2,i), tmp(3,i));
                a=bitxor(xtimes_LED(xtimes_LED(bitxor(xtimes_LED(var1,3), var1), 3), 3), var1);
                b=bitxor(xtimes_LED(xtimes_LED(xtimes_LED(var2,3),3),3), var2);

                s(1,i)=bitxor(a, b);
            end
            tmp=s;
        end
    end

    function s=shiftrow_d_LED(X)
        s(1,:)=X(1,:);
        s(2,:)=[X(2,4) X(2,1:3)];
        s(3,:)=[X(3,3:4) X(3,1:2)];
        s(4,:)=[X(4,2:4) X(4,1)];
    end

    function rc=generate_constant_d_LED(c)
        rc(2:6)=c(1:5);
        rc(1)=dec2bin(bitxor(bin2dec(c(6)), bitxor(bin2dec(c(1)), 1)));
    end

    function [s ,rc]=Round_d_LED(X, c, ks)
        sbox_d=[5 14 15 8 12 1 2 13 11 4 6 3 0 7 9 10];
        s=mixcolumns_d_LED(X);
        s=shiftrow_d_LED(s);
        s=sbox_d(s+1);
        s=addconstant_LED(s, c, ks);
        rc=generate_constant_d_LED(c);
    end

% encryption function
    function [C,rc] = LED_enc(MSG,key)
        Key = '';

        for i = 1:4:length(key)
            bin = key(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            Key = [Key hex];  % Append to the hexadecimal string
        end
        binStr = MSG;
        m = '';

        for i = 1:4:length(binStr)
            bin = binStr(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            m = [m hex];  % Append to the hexadecimal string
        end
        ks=dec2bin(length(Key)*4, 8);
        S=create_state_LED(m);
        k=create_state_LED(Key);
        rc='000000';

        for i=1:8
            S=addroundKey_LED(S, k);
            for m=0:3
                [S, rc]=Round_LED(S, rc, ks);
            end
        end
        C=addroundKey_LED(S, k);
        C = dec2hex(C');
        C=C';
        binStr = '';
        for i = 1:length(C)
            dec = hex2dec(C(i));
            bin = dec2bin(dec, 4);  % Convert to binary with 4 digits
            binStr = [binStr bin];  % Append to the binary string
        end
        C=binStr;
    end

% Decryption function
    function M = LED_dec(C,keyy,rc)
        key = '';

        for i = 1:4:length(keyy)
            bin = keyy(i:i+3);  % Extract 4 bits
            dec = bin2dec(bin);  % Convert to decimal
            hex = dec2hex(dec);  % Convert to hexadecimal
            key = [key hex];  % Append to the hexadecimal string
        end
        decMatrix = zeros(4, 4); % Initialize the decimal matrix
        for i = 1:4
            for j = 1:4
                % Calculate the start and end indices of the current 4-bit chunk
                startIdx = (i-1)*16 + (j-1)*4 + 1;
                endIdx = startIdx + 3;

                % Extract the current 4-bit chunk from the binary string
                binChunk = C(startIdx:endIdx);

                % Convert the binary chunk to a decimal number and store it in the decimal matrix
                decMatrix(i, j) = bin2dec(binChunk);
            end
        end

        C = decMatrix;
        ks=dec2bin(length(key)*4, 8);
        k=create_state_LED(key);
        S=C;
        for i=8:-1:1
            S=addroundKey_LED(S, k);
            for m=3:-1:0
                [S ,rc]=Round_d_LED(S, rc, ks);
            end
        end
        M=addroundKey_LED(S, k);
        M = dec2hex(M');
        M = M';
        binStr = '';
        for i = 1:length(M)
            dec = hex2dec(M(i));
            bin = dec2bin(dec, 4);  % Convert to binary with 4 digits
            binStr = [binStr bin];  % Append to the binary string
        end
        M=binStr;
    end

end



function isBERHigh = evaluateMessageWithAWGN(message,f,n)
%{
           
            Output :
                isBERHigh --> bool
            This function does the following things :
                1. Simulates network status
                2. Generates a random Ec/No value betweeen -6 to 0
                3. Calculates SNR
                4. Passes the message to a AWGN channel having SNR as
                caclulated.
                5. If the resulting message has BER > Threashold returns
                true else false
               
               
%}
data_files = ["8-Bits","16-Bit","32-Bit","64-Bit","128-Bit","256-Bit","512-Bit"];
persistent BerCount BER old_f BerFigure;
if isempty(BerCount)
    BerCount = zeros(1,5);
    BER = [];
    old_f = f.Number;
    BerFigure = figure('Name','BER v/s Message');
end


if old_f ~= f.Number
    old_f = f.Number;
    BerFigure = figure("Name",sprintf('BER v/s Message for %s',data_files(n)));
    BerCount = zeros(1,5);
    BER = [];

end
% Function to evaluate BER of a message with AWGN and a random Ec/No

if isrow(message)
    message = message';
end

% Generate random Ec/No value in range [-6, 0]
EcNoRange = -6:0;
randomEcNo = EcNoRange(randi(length(EcNoRange)));
BerThresh = 0.23;

ranges = categorical({'0','0-0.1','0.1-0.2',sprintf('0.2 - %s',num2str(round(BerThresh,2))),sprintf('>%s',num2str(round(BerThresh,2)))});
% Parameters
spc = 4; % Samples per chip
cfgOQPSK = lrwpanOQPSKConfig(Band=2450, PSDULength=length(message)/8, SamplesPerChip=spc);
waveform = lrwpanWaveformGenerator(message, cfgOQPSK);

% Calculate SNR for AWGN
SNR = randomEcNo - 10*log10(spc) + 10*log10(2);

% Add noise
receivedWaveform = awgn(waveform, SNR);

% Decode the noisy waveform
receivedMessage = lrwpan.PHYDecoderOQPSKNoSync(receivedWaveform, spc, '2450 MHz');

% Calculate BER
[numErrors, ber] = biterr(message, receivedMessage);
BER(end+1) = ber;
% disp(BER);



figure(BerFigure);

xlabel('Message Sequence Number');
ylabel('Bit Error Rate (BER)');
title({'COMPARISON',sprintf('BER v/s Message (for %s)',data_files(n))});
grid on;
plot(1:length(BER), BER, 'b-o', 'LineWidth', 1);
xticks(0:300:length(BER));
drawnow;
hold on;
BerCount = groupBER(ber,BerThresh,BerCount);

figure(f);
subplot(2,2,4);
xlabel('BER Range');
ylabel('Number of Messages');
title({'COMPARISON'; 'Messages at Different BER Ranges';});
grid on;
hold on;
bg = bar(ranges,BerCount,'FaceColor', 'flat');
bg.CData = [1 0 0;  % Red
          0 1 0;  % Green
          0 0 1;  % Blue
          1 1 0;  % Yellow
          1 0 1]; % Magenta

drawnow;
hold on;


% Return true if BER is above BerThresh, else false
isBERHigh = (ber > BerThresh);
if isBERHigh
    disp("High BER");
end
end
function[UBerC]= groupBER(BER,thresh,BerC)

    if BER== 0
            BerC(1) = BerC(1) +1 ;
    elseif BER > 0 && BER < 0.1
            BerC(2) = BerC(2) +1 ;
    elseif BER >= 0.1 && BER <0.2
            BerC(3) = BerC(3) +1 ;
    elseif BER >=0.2 && BER < thresh
            BerC(4) = BerC(4) +1 ;
    elseif BER > thresh 
            BerC(5) = BerC(5) +1 ;
    end
    UBerC = BerC;


end




function isEnergyHigh = getEnergyConsumption()
%{
           
            Output :
                isEnergyHigh --> bool
            This function does the following things :
                1. Simulates energy consumption
                2. Generates a random number b/w 1 to 500 and if = 90
                returns true else false
               
               
        %}
randInt = randi([1, 500]);
if (randInt == 90)
    isEnergyHigh= true;
    disp("High Energy");
else
    isEnergyHigh = false;
end
end



function plotTimeTaken(timeTaken,f)
%{
            Input : 
                timeTaken -> time value in seconds
               
            
            This function does the following things :
                1. Keeps track of time taken for switching
                2. Plots the average time
               
        %}
persistent numTimes val old_f;


if isempty(numTimes)
    numTimes= 0;
    val = [];
    old_f = f.Number;
end

if old_f ~= f.Number
    old_f = f.Number
    val = [];
    numTimes= 0;

end
numTimes = numTimes + 1;
val(end+1) = timeTaken;


% Avoid division by zero
% avgS = valSum ./ max(numTimes, 1);
figure(f);
subplot(2,2,3);
plot(1:numTimes, val,'g-o','LineWidth',1.5);
title({'MEASURE','Time Taken for Switching'});
ylabel('Time (In Seconds)');
xlabel('Number of Switches');
grid on;
hold on;

end



function sendToDestination(mqttNode,nodeTopic,sequence,currAlgo)
%{
            Input : 
                mqttNode --> Mqtt object
                nodeTopic --> Topic under which the message is to be sent
                sequence --> Payload
                currAlgo --> Alorithm used to encrypt
            
            This function does the following things :
                1. Uses a sample zigbee message ast MAC Layer
                2. Adds the algorithm id in header(7-9 bits)
                3. Attaches payload
                4. Sends the resulting message to the destination.
               
        %}


coordinatorTopic = nodeTopic;
complete_frame = '0011010%s10011000000001000100100011010010101011110011011111000001010001001000110000000001010111100101000101011001111000100110000111010100110100010101001010100000110101101100110101010100000001000000000000000000000001%s';
algoMap = dec2bin(currAlgo, 4);
% Send the sequence to the coordinator
write(mqttNode, coordinatorTopic, sprintf(complete_frame,algoMap,num2str(sequence)));
% disp(['Node ', nodeTopic, ': Sent sequence to coordinator - ', sequence]);
end


function str = matrixToString(matrix)
%{
            Input : 
                matrix -> 2D Double 
               
            Output :
                2D double represented as a string
            This function takes matrix as input, which is a two-dimensional double array. 
            The output is a string representation of this 2D double array. The function processes the matrix by counting each row and 
            column placing it at fierst and separting each bit by a hyphen (-). 
            The transformation has the number of rows and columns appear first, followed by the matrix elements themselves.

            For example, given the matrix:
                            1 1  
                            0 1  
                         2-2-1-1-0-1  
        Here, the first two values represent the number of row and columns, followed by the individual elements of the matrix, all separated by hyphens. 
        This formatted string is then returned as the output.
               
%}
[rows, cols] = size(matrix);
matrixData = strjoin(string(matrix(:))', '-');
str = sprintf('%d-%d-%s', rows, cols, matrixData);
end