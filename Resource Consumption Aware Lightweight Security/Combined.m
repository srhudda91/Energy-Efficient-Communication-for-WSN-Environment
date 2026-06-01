function Combined()
%initialize arrays
timeEncryption = cell(5,1);
timeDecryption = cell(5,1);
totalTime = cell(5,1);
throughputEncryption = cell(5,1);
throughputDecryption = cell(5,1);
throughputTotal = cell(5,1);
mem = zeros(1,5);
encryptionEnergy = cell(5,1);
decryptionEnergy = cell(5,1);
totalEnergy = cell(5,1);
SE = cell(5,1);

%calling the block cipher algorithms
disp('ANU Started');
[timeEncryption{1}, timeDecryption{1}, totalTime{1}, throughputEncryption{1}, throughputDecryption{1}, throughputTotal{1}, mem(1,1), timeAppend, encryptionEnergy{1}, decryptionEnergy{1}, totalEnergy{1}, SE{1}] = ANU();
disp('ANU Completed');

disp('QTL Started');
[timeEncryption{2}, timeDecryption{2}, totalTime{2}, throughputEncryption{2}, throughputDecryption{2}, throughputTotal{2}, mem(1,2), encryptionEnergy{2}, decryptionEnergy{2}, totalEnergy{2}, SE{2}] = QTL();
disp('QTL Completed');

disp('Midori Started');
[timeEncryption{3}, timeDecryption{3}, totalTime{3}, throughputEncryption{3}, throughputDecryption{3}, throughputTotal{3}, mem(1,3), encryptionEnergy{3}, decryptionEnergy{3}, totalEnergy{3}, SE{3}] = MIDORI();
disp('Midori Completed');

disp('Rectangle Started');
[timeEncryption{4}, timeDecryption{4}, totalTime{4}, throughputEncryption{4}, throughputDecryption{4}, throughputTotal{4}, mem(1,4), encryptionEnergy{4}, decryptionEnergy{4}, totalEnergy{4}, SE{4}] = RECTANGLE();
disp('Rectangle Completed');

disp('Present Started');
[timeEncryption{5}, timeDecryption{5}, totalTime{5}, throughputEncryption{5}, throughputDecryption{5}, throughputTotal{5}, mem(1,5), encryptionEnergy{5}, decryptionEnergy{5}, totalEnergy{5}, SE{5}] = PRESENT();
disp('Present Completed');

%creating graphs
bitsize = {'8-bit';'16-bit';'32-bit';'64-bit';'128-bit';'256-bit';'512-bit';'1024-bit';'2048-bit'};


temp1 = vertcat(timeEncryption{:});
temp2 = vertcat(timeDecryption{:}); 
temp3 = vertcat(totalTime{:}); 
temp4 = vertcat(throughputEncryption{:}); 
temp5 = vertcat(throughputDecryption{:}); 
temp6 = vertcat(throughputTotal{:}); 
temp7 = vertcat(encryptionEnergy{:});
temp8 = vertcat(decryptionEnergy{:});
temp9 = vertcat(totalEnergy{:});
temp10 = vertcat(SE{:});

% encryption time(in seconds) vs binary string size
figure(1);
bar(bitsize,temp1');
title({'COMPARISION'; 'Encryption Time';});
ylabel('Time (In Seconds)');
xlabel('Payload (Data Size in Bits)');
legend('ANU', 'QTL', 'Midori', 'Rectangle', 'Present');

% decryption time(in seconds) vs binary string size
figure(2);
bar(bitsize,temp2');
title({'COMPARISION'; 'Decryption Time';});
ylabel('Time (In Seconds)');
xlabel('Payload (Data Size in Bits)');
legend('ANU', 'QTL', 'Midori', 'Rectangle', 'Present');

% total execution time(in seconds) vs binary string size 
figure(3);
bar(bitsize,temp3');
title({'COMPARISION'; 'Total Time';});
ylabel('Time (In Seconds)');
xlabel('Payload (Data Size in Bits)');
legend('ANU', 'QTL', 'Midori', 'Rectangle', 'Present');

% encryption throughput vs payload size
figure(4);
bar(bitsize,temp4');
title({'COMPARISION'; 'Encryption Throughput';});
ylabel('Throughput (Blocks Per Second)');
xlabel('Payload (Data Size in Bits)');
legend('ANU', 'QTL', 'Midori', 'Rectangle', 'Present');

% decryption throughput vs payload size 
figure(5);
bar(bitsize,temp5');
title({'COMPARISION'; 'Dencryption Throughput';});
ylabel('Throughput (Blocks Per Second)');
xlabel('Payload (Data Size in Bits)');
legend('ANU', 'QTL', 'Midori', 'Rectangle', 'Present');

% total throughput vs payload size
figure(6);
bar(bitsize,temp6');
title({'COMPARISION'; 'Total Throughput';});
ylabel('Throughput (Blocks Per Second)');
xlabel('Payload (Data Size in Bits)');
legend('ANU', 'QTL', 'Midori', 'Rectangle', 'Present');

%memory used by each algorithm
algo = {'ANU'; 'QTL'; 'Midori'; 'Rectangle'; 'Present'};
figure(7);
bar(algo,mem);
title({'COMPARISION'; 'Total Memory Used';});
ylabel('Memory (In Bytes)');
xlabel('Algorithms');

%encryption energy used per block vs paylaod size
figure(8);
bar(bitsize,temp7');
title({'COMPARISION'; 'Encryption Energy Per Bit';});
ylabel('Energy Per Bit (In Joules)');
xlabel('Payload (Data Size in Bits)');
legend('ANU', 'QTL', 'Midori', 'Rectangle', 'Present');

%decryption energy used per block vs paylaod size
figure(9);
bar(bitsize,temp8');
title({'COMPARISION'; 'Decryption Energy Per Bit';});
ylabel('Energy Per Bit (In Joules)');
xlabel('Payload (Data Size in Bits)');
legend('ANU', 'QTL', 'Midori', 'Rectangle', 'Present');

%total energy used per block vs paylaod size
figure(10);
bar(bitsize,temp9');
title({'COMPARISION'; 'Total Energy Per Bit';});
ylabel('Energy Per Bit (In Joules)');
xlabel('Payload (Data Size in Bits)');
legend('ANU', 'QTL', 'Midori', 'Rectangle', 'Present');

%software efficiency vs payload
figure(11);
bar(bitsize,temp10');
title({'COMPARISION'; 'Software Efficiency'});
ylabel('Software Efficiency');
xlabel('Payload (Data Size in Bits)');
legend('ANU', 'QTL', 'Midori', 'Rectangle', 'Present');

%time taken to append Zeros(i.e. 0s) in plaintext
figure(12);
bar(bitsize,timeAppend);
title({'COMPARISION'; 'Time Taken to Append Zeros'});
ylabel('Time (seconds)');
xlabel('Payload (Data Size in bits)');

end



%ANU Block Cipher
function [encryptionTime,decryptionTime, timeTotal,THencryptionTime,THdecryptionTime,THtimeTotal, memory_used_in_bytes,tAppend,energyEncryption, energyDecryption, energyTotal,SE]= ANU()
[user,~] = memory;
disp('Memory Available for ANU (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
   %key
   key = '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
   %initialize cell arrays

   %array to store total time taken to append bits
   tAppend=zeros(1,9);

   %array to store total encryption time 
   encryptionTime = zeros(1,9);

   %array to store total decryption time
   decryptionTime = zeros(1,9);

   %array to store total exeution time
   timeTotal = zeros(1,9);
   
   currentFolder = pwd;
for n=1:9  
% Create the full file path
switch n
    case 1
        disp('8-bit Message');
        filePath = fullfile(currentFolder, 'Bits 8 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,key,1);
        tAppend(1,n) = tappend;

    case 2
        
       disp('16-bit Message');
       filePath = fullfile(currentFolder, 'Bits 16 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] =  readfile(filePath,key,1);
       tAppend(1,n) = tappend;
   
    case 3
      
       disp('32-bit Message');
       filePath = fullfile(currentFolder, 'Bits 32 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,1);
       tAppend(1,n) = tappend;
      
    case 4
        
       disp('64-bit Message');
       filePath = fullfile(currentFolder, 'Bits 64 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,key,1);
       tAppend(1,n) = tappend;
       
    case 5
        
       disp('128-bit Message');
       filePath = fullfile(currentFolder, 'Bits 128 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,key,1);
       tAppend(1,n) = tappend;
       
    case 6
       
       disp('256-bit Message');
       filePath = fullfile(currentFolder, 'Bits 256 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,1);
       tAppend(1,n) = tappend;
       
    case 7
        
       disp('512-bit Message');
       filePath = fullfile(currentFolder, 'Bits 512 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,key,1);
       tAppend(1,n) = tappend;
     
    case 8
       
       disp('1024-bit Message');
       filePath = fullfile(currentFolder, 'Bits 1024 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,1);
       tAppend(1,n) = tappend;
    case 9
        
       disp('2048-bit Message');
       filePath = fullfile(currentFolder, 'Bits 2048 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,1);
       tAppend(1,n) = tappend;
        
end

end

%array to store encryption energy per bit
energyEncryption = calcEnergy(encryptionTime);

%array to store encryption energy per bit
energyDecryption = calcEnergy(decryptionTime);

%array to store encryption energy per bit
energyTotal = calcEnergy(timeTotal);

% % initializing throughput arrays
THencryptionTime = zeros(1,9);
THdecryptionTime = zeros(1,9);
THtimeTotal = zeros(1,9);

% calculating throughput
for a = 1:9
    THencryptionTime(1,a)=100000/(encryptionTime(1,a));
    THdecryptionTime(1,a)=100000/(decryptionTime(1,a));
    THtimeTotal(1,a)=100000/(timeTotal(1,a));
end

%array to store software efficiency
SE = calcSE(THtimeTotal,11.8);

[user2,~] = memory;
disp('Memory Available for ANU (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by ANU: ');
disp(memory_used_in_bytes);

end

% function to read file, encryption and decryption 
function [tencr,tdecr,tend,tappend]= readfile(filePath,key,algonum)
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

% Open the file
fileID = fopen(filePath, 'r');

% Check if file exists
if fileID == -1
    error('File not found');
end

% count the number of lines in the file
numLines=0;
while ~feof(fileID)
   line= fgetl(fileID);  % Read and discard the line
    if ~isempty(line)  % Only count the line if it's not empty
        numLines = numLines + 1;  % Increment the line count
    end
end
disp('Number of Records in This Input File: ');
disp(numLines);

frewind(fileID); % Reset the file pointer to the beginning of the file
% Preallocate a cell array to hold the binary strings
plaintext = cell(numLines, 1);
ciphertext = cell(numLines, 1);
i = 1;

% start the time counter for calculating total time
tstart=tic; 

% start the time counter for calculating encryption time
tEncrypt = tic; 

%loop to call encryption function
while ~feof(fileID) && i <= numLines

    % store the binary strings into plaintext array
    plaintext{i} = fgetl(fileID);

    % append zeroes if required
 if length(plaintext{i}) < 64

     %start time counter to calculate time to append zeroes
     tapp = tic;
     plaintext{i} = [repmat('0', 1, 64 - length(plaintext{i})),plaintext{i}];
     tappend = toc(tapp); % end append time counter
     %call encrption function
     if algonum ==1
     [ciphertext{i}, roundKeys] = ANU_encrypt(plaintext{i}, key, roundKeys);
     end
     if algonum ==2
         ciphertext{i}= qtl_encrypt(key,plaintext{i});
     end
     if algonum ==3
         ciphertext{i}= midoriEncrypt(plaintext{i},RK,WK);
     end
     if algonum ==4
         [ciphertext{i}, roundKeys] = rectangleEncrypt(key,plaintext{i});
     end
     if algonum ==5
         ciphertext{i} = Present_enc(plaintext{i}, key);
     end
 else 

    %form blocks if length of binary string is greater than 64
    numBLocks = length(plaintext{i})/64;
    %preallocate array to hold the block strings
    strings = cell(numBLocks,1);
    tappend =0;% make append time zero for this case
    output2 = '';
  
 for j = 1:numBLocks
     %store the 64-bit size strings in strings array
      strings{j} = plaintext{i}((j-1)*64 + 1 : j*64);

      %append zeroes if required
       if length(strings{j}) < 64
           strings{j} = [repmat('0', 1, 64 - length(strings{j})),strings{j}];
       end

      %call encryption function
      if algonum == 1
          [ciphertext{i}, roundKeys] = ANU_encrypt(strings{j}, key, roundKeys);
      end
      if algonum ==2
          ciphertext{i} = qtl_encrypt(key,strings{j});
      end
      if algonum ==3
          ciphertext{i} = midoriEncrypt(strings{j},RK,WK);
      end
      if algonum ==4
          [ciphertext{i}, roundKeys] = rectangleEncrypt(key,plaintext{i});
      end
      if algonum ==5
          ciphertext{i} = Present_enc(strings{j}, key);
      end
      % concatenate all ciphertext formed in every round from j=1 to j=numBlocks 
      output2 = strcat(output2,ciphertext{i});
 end
 %store all the ciphertext formed in this array
 ciphertext{i}=output2;               
end
    i = i + 1; 
end

i=1;
%end the encryption timer
tencr = toc(tEncrypt);
frewind(fileID); % Reset the file pointer to the beginning of the file
tDecrypt = tic;
% loop to call decryption function
while ~feof(fileID) && i <= numLines
    plaintext{i} = fgetl(fileID);
    
 if length(plaintext{i}) <= 64
     %call decryption function
     if algonum==1
        ANU_decrypt(ciphertext{i}, roundKeys); 
     end
     if algonum==2
         qtl_decrypt(key,ciphertext{i}); 
     end
     if algonum ==3
         midoriDecrypt(ciphertext{i},RK,WK);
     end
     if algonum ==4
         rectangleDecrypt(roundKeys,ciphertext{i}); 
     end
     if algonum ==5
         Present_dec(ciphertext{i}, key);
     end
else
    numBLocks = length(plaintext{i})/64;
    %preallocate array to hold the block strings
    strings = cell(numBLocks,1);
    cipher = cell(numBLocks,1);
    output1 = '';
    k=1;
 for j = 1:numBLocks 
      strings{j} = plaintext{i}((j-1)*64 + 1 : j*64);

      %divide ciphertext greater than 64-bit size and store in cipher array
      cipher{k} = ciphertext{i}((k-1)*64 + 1 : k*64);

      %call decryption function
      if algonum==1
          decryptedtext = ANU_decrypt(cipher{k}, roundKeys);
      end
      if algonum==2
          decryptedtext = qtl_decrypt(key,cipher{k});
      end
      if algonum==3
          decryptedtext = midoriDecrypt(cipher{k},RK,WK);
      end
      if algonum ==4
          decryptedtext =  rectangleDecrypt(roundKeys,cipher{k}); 
      end
      if algonum ==5
          decryptedtext = Present_dec(cipher{k}, key);
      end
      % concatenate decrypted text for each block
      output1 = strcat(output1,decryptedtext);
         k=k+1;
  end
                
end
    i = i + 1;
    
end
%end decryption timer
tdecr = toc(tDecrypt);

% Close the file
fclose(fileID);

% end total execution timer
tend = toc(tstart);
end 

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


%QTL Block cipher
function [encryptionTime,decryptionTime, timeTotal,THencryptionTime,THdecryptionTime,THtimeTotal, memory_used_in_bytes, energyEncryption, energyDecryption, energyTotal,SE] = QTL()
[user,~] = memory;
disp('Memory Available for QTL (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
%key
binKey = '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
%initialize cell arrays

   %array to store total time taken to append bits
   tAppend=zeros(1,9);

   %array to store total encryption time 
   encryptionTime = zeros(1,9);

   %array to store total decryption time
   decryptionTime = zeros(1,9);

   %array to store total exeution time
   timeTotal = zeros(1,9);

   currentFolder = pwd;
for n=1:9  
% Create the full file path
switch n
    case 1
        disp('8-bit Message');
        filePath = fullfile(currentFolder, 'Bits 8 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,binKey,2);
        tAppend(1,n) = tappend;

    case 2
        
       disp('16-bit Message');
       filePath = fullfile(currentFolder, 'Bits 16 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] =  readfile(filePath,binKey,2);
       tAppend(1,n) = tappend;
   
    case 3
      
       disp('32-bit Message');
       filePath = fullfile(currentFolder, 'Bits 32 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,binKey,2);
       tAppend(1,n) = tappend;
      
    case 4
        
       disp('64-bit Message');
       filePath = fullfile(currentFolder, 'Bits 64 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,binKey,2);
       tAppend(1,n) = tappend;
       
    case 5
        
       disp('128-bit Message');
       filePath = fullfile(currentFolder, 'Bits 128 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,binKey,2);
       tAppend(1,n) = tappend;
       
    case 6
       
       disp('256-bit Message');
       filePath = fullfile(currentFolder, 'Bits 256 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,binKey,2);
       tAppend(1,n) = tappend;
       
    case 7
        
       disp('512-bit Message');
       filePath = fullfile(currentFolder, 'Bits 512 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,binKey,2);
       tAppend(1,n) = tappend;
     
    case 8
       
       disp('1024-bit Message');
       filePath = fullfile(currentFolder, 'Bits 1024 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,binKey,2);
       tAppend(1,n) = tappend;
    case 9
        
       disp('2048-bit Message');
       filePath = fullfile(currentFolder, 'Bits 2048 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,binKey,2);
       tAppend(1,n) = tappend;
        
end

end
%array to store encryption energy per bit
energyEncryption = calcEnergy(encryptionTime);

%array to store encryption energy per bit
energyDecryption = calcEnergy(decryptionTime);

%array to store encryption energy per bit
energyTotal = calcEnergy(timeTotal);

% initializing throughput arrays
 THencryptionTime = zeros(1,9);
 THdecryptionTime = zeros(1,9);
 THtimeTotal = zeros(1,9);

 % calculating throughput
 for a = 1:9
     THencryptionTime(1,a)=100000/(encryptionTime(1,a));
     THdecryptionTime(1,a)=100000/(decryptionTime(1,a));
     THtimeTotal(1,a)=100000/(timeTotal(1,a));
 end

 %array to store software efficiency
 SE = calcSE(THtimeTotal,18.8);

[user2,~] = memory;
disp('Memory Available for QTL (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by QTL: ');
disp(memory_used_in_bytes);

end


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


%Midori Block Cipher
function [encryptionTime,decryptionTime, timeTotal,THencryptionTime,THdecryptionTime,THtimeTotal, memory_used_in_bytes, energyEncryption, energyDecryption, energyTotal,SE]= MIDORI()
[user,~] = memory;
disp('Memory Available for MIDORI (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
%key
binKey = '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
%initialize cell arrays

   %array to store total time taken to append bits
   tAppend=zeros(1,9);

   %array to store total encryption time 
   encryptionTime = zeros(1,9);

   %array to store total decryption time
   decryptionTime = zeros(1,9);

   %array to store total exeution time
   timeTotal = zeros(1,9);

   currentFolder = pwd;
for n=1:9  
% Create the full file path
switch n
    case 1
        disp('8-bit Message');
        filePath = fullfile(currentFolder, 'Bits 8 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,binKey,3);
        tAppend(1,n) = tappend;

    case 2
        
        disp('16-bit Message');
        filePath = fullfile(currentFolder, 'Bits 16 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] =  readfile(filePath,binKey,3);
        tAppend(1,n) = tappend;
   
    case 3
      
        disp('32-bit Message');
        filePath = fullfile(currentFolder, 'Bits 32 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,binKey,3);
        tAppend(1,n) = tappend;
      
    case 4
        
        disp('64-bit Message');
        filePath = fullfile(currentFolder, 'Bits 64 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,binKey,3);
        tAppend(1,n) = tappend;
       
    case 5
        
        disp('128-bit Message');
        filePath = fullfile(currentFolder, 'Bits 128 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,binKey,3);
        tAppend(1,n) = tappend;
       
    case 6
       
        disp('256-bit Message');
        filePath = fullfile(currentFolder, 'Bits 256 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,binKey,3);
        tAppend(1,n) = tappend;
       
    case 7
        
        disp('512-bit Message');
        filePath = fullfile(currentFolder, 'Bits 512 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,binKey,3);
        tAppend(1,n) = tappend;
     
    case 8
       
        disp('1024-bit Message');
        filePath = fullfile(currentFolder, 'Bits 1024 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,binKey,3);
        tAppend(1,n) = tappend;
    case 9
        
        disp('2048-bit Message');
        filePath = fullfile(currentFolder, 'Bits 2048 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,binKey,3);
        tAppend(1,n) = tappend;
        
end

end
%array to store encryption energy per bit
energyEncryption = calcEnergy(encryptionTime);

%array to store encryption energy per bit
energyDecryption = calcEnergy(decryptionTime);

%array to store encryption energy per bit
energyTotal = calcEnergy(timeTotal);

% initializing throughput arrays
 THencryptionTime = zeros(1,9);
 THdecryptionTime = zeros(1,9);
 THtimeTotal = zeros(1,9);

 % calculating throughput
 for a = 1:9
     THencryptionTime(1,a)=100000/(encryptionTime(1,a));
     THdecryptionTime(1,a)=100000/(decryptionTime(1,a));
     THtimeTotal(1,a)=100000/(timeTotal(1,a));
 end

 %array to store software efficiency
 SE = calcSE(THtimeTotal,15.1);

[user2,~] = memory;
disp('Memory Available for MIDORI (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by MIDORI: ');
disp(memory_used_in_bytes);

end

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

%Rectangle Block Cipher
function [encryptionTime,decryptionTime, timeTotal,THencryptionTime,THdecryptionTime,THtimeTotal, memory_used_in_bytes, energyEncryption, energyDecryption, energyTotal,SE]=RECTANGLE()
[user,~] = memory;
disp('Memory Available for RECTANGLE (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
   %key
   key = '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
   %initialize cell arrays

   %array to store total time taken to append bits
   tAppend=zeros(1,9);

   %array to store total encryption time 
   encryptionTime = zeros(1,9);

   %array to store total decryption time
   decryptionTime = zeros(1,9);

   %array to store total exeution time
   timeTotal = zeros(1,9);

   currentFolder = pwd;
for n=1:9  
% Create the full file path
switch n
    case 1
        disp('8-bit Message');
        filePath = fullfile(currentFolder, 'Bits 8 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,key,4);
        tAppend(1,n) = tappend;

    case 2
        
        disp('16-bit Message');
        filePath = fullfile(currentFolder, 'Bits 16 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] =  readfile(filePath,key,4);
        tAppend(1,n) = tappend;
   
    case 3
      
        disp('32-bit Message');
        filePath = fullfile(currentFolder, 'Bits 32 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,4);
        tAppend(1,n) = tappend;
      
    case 4
        
        disp('64-bit Message');
        filePath = fullfile(currentFolder, 'Bits 64 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,key,4);
        tAppend(1,n) = tappend;
       
    case 5
        
        disp('128-bit Message');
        filePath = fullfile(currentFolder, 'Bits 128 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,key,4);
        tAppend(1,n) = tappend;
       
    case 6
       
        disp('256-bit Message');
        filePath = fullfile(currentFolder, 'Bits 256 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,4);
        tAppend(1,n) = tappend;
       
    case 7
        
        disp('512-bit Message');
        filePath = fullfile(currentFolder, 'Bits 512 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,key,4);
        tAppend(1,n) = tappend;
     
    case 8
       
        disp('1024-bit Message');
        filePath = fullfile(currentFolder, 'Bits 1024 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,4);
        tAppend(1,n) = tappend;
    case 9
        
        disp('2048-bit Message');
        filePath = fullfile(currentFolder, 'Bits 2048 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,4);
        tAppend(1,n) = tappend;
        
end

end
%array to store encryption energy per bit
energyEncryption = calcEnergy(encryptionTime);

%array to store encryption energy per bit
energyDecryption = calcEnergy(decryptionTime);

%array to store encryption energy per bit
energyTotal = calcEnergy(timeTotal);

%array to store total software efficiency
% initializing throughput arrays
 THencryptionTime = zeros(1,9);
 THdecryptionTime = zeros(1,9);
 THtimeTotal = zeros(1,9);

 % calculating throughput
 for a = 1:9
     THencryptionTime(1,a)=100000/(encryptionTime(1,a));
     THdecryptionTime(1,a)=100000/(decryptionTime(1,a));
     THtimeTotal(1,a)=100000/(timeTotal(1,a));
 end

 %array to store software efficiency
 SE = calcSE(THtimeTotal,13.7);

[user2,~] = memory;
disp('Memory Available for RECTANGLE (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by RECTANGLE: ');
disp(memory_used_in_bytes);

end


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

%Present Block Cipher
function [encryptionTime,decryptionTime, timeTotal,THencryptionTime,THdecryptionTime,THtimeTotal, memory_used_in_bytes, energyEncryption, energyDecryption, energyTotal,SE] = PRESENT()
[user,~] = memory;
disp('Memory Available for PRESENT (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
   %key
   key = '00000000000000000000000000000000000000000000000000000000000000000000000000000000';
   %initialize cell arrays

   %array to store total time taken to append bits
   tAppend=zeros(1,9);

   %array to store total encryption time 
   encryptionTime = zeros(1,9);

   %array to store total decryption time
   decryptionTime = zeros(1,9);

   %array to store total exeution time
   timeTotal = zeros(1,9);

   currentFolder = pwd;
for n=1:9  
% Create the full file path
switch n
    case 1
        disp('8-bit Message');
        filePath = fullfile(currentFolder, 'Bits 8 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,key,5);
        tAppend(1,n) = tappend;

    case 2
        
        disp('16-bit Message');
        filePath = fullfile(currentFolder, 'Bits 16 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] =  readfile(filePath,key,5);
        tAppend(1,n) = tappend;
   
    case 3
      
        disp('32-bit Message');
        filePath = fullfile(currentFolder, 'Bits 32 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,5);
        tAppend(1,n) = tappend;
      
    case 4
        
        disp('64-bit Message');
        filePath = fullfile(currentFolder, 'Bits 64 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend] = readfile(filePath,key,5);
        tAppend(1,n) = tappend;
       
    case 5
        
        disp('128-bit Message');
        filePath = fullfile(currentFolder, 'Bits 128 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,key,5);
        tAppend(1,n) = tappend;
       
    case 6
       
        disp('256-bit Message');
        filePath = fullfile(currentFolder, 'Bits 256 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,5);
        tAppend(1,n) = tappend;
       
    case 7
        
        disp('512-bit Message');
        filePath = fullfile(currentFolder, 'Bits 512 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,key,5);
        tAppend(1,n) = tappend;
     
    case 8
       
        disp('1024-bit Message');
        filePath = fullfile(currentFolder, 'Bits 1024 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,5);
        tAppend(1,n) = tappend;
    case 9
        
        disp('2048-bit Message');
        filePath = fullfile(currentFolder, 'Bits 2048 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key,5);
        tAppend(1,n) = tappend;
        
end
end

%array to store encryption energy per bit
energyEncryption = calcEnergy(encryptionTime);

%array to store encryption energy per bit
energyDecryption = calcEnergy(decryptionTime);

%array to store encryption energy per bit
energyTotal = calcEnergy(timeTotal);

% initializing throughput arrays
 THencryptionTime = zeros(1,9);
 THdecryptionTime = zeros(1,9);
 THtimeTotal = zeros(1,9);

 % calculating throughput
 for a = 1:9
     THencryptionTime(1,a)=100000/(encryptionTime(1,a));
     THdecryptionTime(1,a)=100000/(decryptionTime(1,a));
     THtimeTotal(1,a)=100000/(timeTotal(1,a));
 end

%array to store software efficiency
SE = calcSE(THtimeTotal,10.8);
[user2,~] = memory;
disp('Memory Available for PRESENT (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by PRESENT: ');
disp(memory_used_in_bytes);
end

%encryption function
function C=Present_enc(P_in, K)
  S=P_in;
  K_s=K;
  for i=1:31
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
    for i=1:4:64
      S_hex(end+1)=dec2hex(bin2dec(S(i:i+3)));
      K_hex(end+1)=dec2hex(bin2dec(K_s(i:i+3)));
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

%function to calculate energy
function energy = calcEnergy(time)
    energy = zeros(1,9);
    power1 = 41.50;
    temp = zeros(1,9);
    
    for i=1:9
        temp(1,i) = time(1,i)/100000;
        if i<=4
        energy(1,i) = (power1*temp(1,i))/64;
        else
        energy(1,i) = (power1*temp(1,i))/(power(2,2+i));  
        end
    end
end

%function to calculate software efficiency
function eff= calcSE(throughput,filesize)
eff = zeros(1,9);
for i=1:9
    eff(1,i) = throughput(1,i)/filesize;
end
end
