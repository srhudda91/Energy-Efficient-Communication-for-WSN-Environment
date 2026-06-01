function LBlock()
[user,~] = memory;
disp('Memory Available for LBlock (Before Execution Started): ');
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
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key);
        % disp(tappend);
        tAppend(1,n) = tappend;
        % disp(timeTotal(1,n));

    case 2
        disp('16-bit Message');
        filePath = fullfile(currentFolder, 'Bits 16 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] =  readfile(filePath,key);
        tAppend(1,n) = tappend;
  
    case 3
        disp('32-bit Message');
        filePath = fullfile(currentFolder, 'Bits 32 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key);
         tAppend(1,n) = tappend;
        
    case 4
        disp('64-bit Message');
        filePath = fullfile(currentFolder, 'Bits 64 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key);
         tAppend(1,n) = tappend;
     
    case 5
        disp('128-bit Message');
        filePath = fullfile(currentFolder, 'Bits 128 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,key);
         tAppend(1,n) = tappend;
      
    case 6
        disp('256-bit Message');
        filePath = fullfile(currentFolder, 'Bits 256 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key);
         tAppend(1,n) = tappend;
        
    case 7
        disp('512-bit Message');
        filePath = fullfile(currentFolder, 'Bits 512 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n) ,tappend] = readfile(filePath,key);
         tAppend(1,n) = tappend;
       
    case 8
        disp('1024-bit Message');
        filePath = fullfile(currentFolder, 'Bits 1024 Number Of Record 100000');
       [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key);
        tAppend(1,n) = tappend;
       
    case 9
        disp('2048-bit Message');
        filePath = fullfile(currentFolder, 'Bits 2048 Number Of Record 100000');
        [encryptionTime(1,n) ,decryptionTime(1,n), timeTotal(1,n),tappend ] = readfile(filePath,key);
         tAppend(1,n) = tappend;
        
end
end
%creating graphs
bitsize = {'8-bit';'16-bit';'32-bit';'64-bit';'128-bit';'256-bit';'512-bit';'1024-bit';'2048-bit'};

% encryption time and key schedule time (in seconds) vs binary string size
figure(1);
bar(bitsize,encryptionTime);
title({'COMPARISION'; 'Encryption Time and Key Schedule Time';});
ylabel('Time (seconds)');
xlabel('Payload (Data Size in bits)');

% decryption time and key schedule time (in seconds) vs binary string size
figure(2);
bar(bitsize,decryptionTime);
title({'COMPARISION'; 'Decryption Time and Key Schedule Time';});
ylabel('Time (seconds)');
xlabel('Payload (Data Size in bits)');

% total execution time(in seconds) vs binary string size 
figure(3);
bar(bitsize,timeTotal);
title({'COMPARISION'; 'Total Time (Sum of Encryption Time, Decryption Time, and Key Schedule Time)';});
ylabel('Time (seconds)');
xlabel('Payload (Data Size in bits)');

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

% encryption throughput vs payload size
figure(4);
bar(bitsize,THencryptionTime);
title({'COMPARISION'; 'Average Encryption Throughput';});
ylabel('Throughput (Blocks/Seconds)');
xlabel('Payload (Data Size in bits)');

% decryption throughput vs payload size 
figure(5);
bar(bitsize,THdecryptionTime);
title({'COMPARISION'; 'Average Decryption Throughput';});
ylabel('Throughput (Blocks/Seconds)');
xlabel('Payload (Data Size in bits)');

% total throughput vs payload size
figure(6);
bar(bitsize,THtimeTotal);
title({'COMPARISION'; 'Average Total Throughput (Average of Encryption Throughput and Decryption Throughput)';});
ylabel('Throughput (Blocks/Seconds)');
xlabel('Payload (Data Size in bits)');

% time taken to append zeroes(for one string) vs payload size
figure(7);
bar(bitsize,tAppend);
title({'COMPARISION'; 'Time Taken to Append 0s';});
ylabel('Time (seconds)');
xlabel('Payload (Data Size in bits)');

%Used memory calculation
[user2,~] = memory;
disp('Memory Available for LBlock (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by LBlock: ');
disp(memory_used_in_bytes);
end

% function to read file, encryption and decryption 
function [tencr,tdecr,tend,tappend]= readfile(filePath,key)
roundKeys = cell(25, 1);
    for i= 1:25
        roundKeys{i} = '00000000000000000000000000000000';
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

frewind(fileID); % Reset the file pointer to the beginning of the file
% Preallocate a cell array to hold the binary strings
plaintext = cell(numLines, 1);
ciphertext = cell(numLines, 1);
X=cell(numLines,1);
i = 1;

% start the time counter for calculating total time
tstart=tic; 

% start the time counter for calculating encryption time
tEncrypt = tic; 

%loop to call encryption function
while ~feof(fileID) && i <=3%numLines

    % store the binary strings into plaintext array
    plaintext{i} = fgetl(fileID);

    % append zeroes if required
 if length(plaintext{i}) < 64

     %start time counter to calculate time to append zeroes
     tapp = tic;
     plaintext{i} = [repmat('0', 1, 64 - length(plaintext{i})),plaintext{i}];
     tappend = toc(tapp); % end append time counter
     %call encrption function
     [ciphertext{i},X{i},K] = LBlock_enc(plaintext{i}, key);

 else 

    %form blocks if length of binary string is greater than 64
    numBLocks = length(plaintext{i})/64;
    %preallocate array to hold the block strings
    strings = cell(numBLocks,1);
    %X_segments = cell(numBLocks,1);
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
      [ciphertext{i},X_temp,K] = LBlock_enc(strings{j}, key);
      
      % concatenate all ciphertext formed in every round from j=1 to j=numBlocks 
        output2 = strcat(output2,ciphertext{i});
        if j == 1
        res_X = X_temp;
        else
        res_X = [res_X; X_temp]; 
        end
 end
 %store all the ciphertext formed in this array
 ciphertext{i}=output2;
 X{i} = res_X;
end
    i = i + 1; 
end
i=1;
%end the encryption timer
tencr = toc(tEncrypt);
frewind(fileID); % Reset the file pointer to the beginning of the file
tDecrypt = tic;
% loop to call decryption function
while ~feof(fileID) && i <=3%numLines
    plaintext{i} = fgetl(fileID);
    
 if length(plaintext{i}) <= 64
     %call decryption function
      LBlock_dec(X{i}, K);       
else
    numBLocks = length(plaintext{i})/64;
    output1 = '';
    k=1;
    % Initialize cell array to store the split matrices
X_back = cell(numBLocks, 1);
% Split X{i} into matrices with 34 rows each
for t = 1:numBLocks
    start_row = (t - 1) * 34 + 1;
    end_row = min(t * 34, size(X{i}, 1));
    X_back{t} = X{i}(start_row:end_row, :);
end
 for j = 1:numBLocks 
      %call decryption function
      decryptedtext = LBlock_dec(X_back{k},K);  

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

function s=create_state(X)
%% Transform an hexadecimal message X in a state to be processed
  for i=1:length(X)
    s(i)=hex2dec(X(i));
  end
end

function s=create_state_bin(X)
%% Transform an hexadecimal message X in a binary message.
%% It is used for the key
  for i=1:length(X)
    s(4*(i-1)+1:4*i)=dec2bin(hex2dec(X(i)), 4);
  end
end

function s=create_state_k(X)
%% Transform an binary state in a state to be processed
%% It is used for the key
  k=1;
  for i=1:4:length(X)-3
    s(k)=bin2dec(X(i:i+3));
    k=k+1;
  end
end

%% Encryption

function s=f(X,K) %% Sboxes
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

function sk=keyschedule(K, i) %% Encryption keyschedule
  s8=[8 7 14 5 15 13 0 6 11 12 9 10 2 4 1 3];
  s9=[11 5 15 0 7 2 9 13 4 8 1 12 14 10 3 6];
  sk=[K(30:80) K(1:29)];
  sk(1:4)=dec2bin(s9(bin2dec(sk(1:4))+1),4);
  sk(5:8)=dec2bin(s8(bin2dec(sk(5:8))+1),4);
  sk(30:34)=dec2bin(bitxor(bin2dec(sk(30:34)), i),5);
end

function sk=keyschedule_d(K, i) %% Decryption keyschedule
  s8_d=[6 14 12 15 13 3 7 1 0 10 11 8 9 5 2 4];
  s9_d=[3 10 5 14 8 1 15 4 9 6 13 0 11 7 12 2];
  sk=K;
  sk(30:34)=dec2bin(bitxor(bin2dec(sk(30:34)), i),5);
  sk(1:4)=dec2bin(s9_d(bin2dec(sk(1:4))+1),4);
  sk(5:8)=dec2bin(s8_d(bin2dec(sk(5:8))+1),4);
  sk=[sk(52:end) sk(1:51)];
end
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
s=create_state(m);
K=create_state_bin(k);
X(1,:)=s(9:16);
X(2,:)=s(1:8);
for i=3:34
  Ki=create_state_k(K(1:32));
  if i<34
    K=keyschedule(K, i-2);
  end
  X(i,:)=bitxor(f(X(i-1,:), Ki),[X(i-2,3:end) X(i-2,1:2)]);
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
function M = LBlock_dec(X,K)
for i=32:-1:1
  Ki=create_state_k(K(1:32));
  if i>1
    K=keyschedule_d(K, i-1);
  end
  t=bitxor(f(X(i+1,:), Ki), X(i+2,:));
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
