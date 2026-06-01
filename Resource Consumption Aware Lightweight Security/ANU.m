function ANU()
[user,~] = memory;
disp('Memory Available for ANU (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
    %key
    key = '1101010010111010101100110010110110101010010111010010110101010010110101001011101010110011001011011010101001011101001011010101001';
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
disp('Memory Available for ANU (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by ANU: ');
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
    error('File Not Found');
end

% count the number of lines in the file
numLines=0;
while ~feof(fileID)
   line= fgetl(fileID);  % Read and discard the line
    if ~isempty(line)  % Only count the line if it's not empty
        numLines = numLines + 1;  % Increment the line count
    end
end
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
     tappend = toc(tapp);

     %call encrption function
     [ciphertext{i}, roundKeys] = ANU_encrypt(plaintext{i}, key, roundKeys);
 
 else
    %form blocks if length of binary string is greater than 64
    numBLocks = length(plaintext{i})/64;
    %preallocate array to hold the block strings
    strings = cell(numBLocks,1);
    tappend =0;
    output2 = '';
 for j = 1:numBLocks
     %store the 64-bit size strings in strings array
      strings{j} = plaintext{i}((j-1)*64 + 1 : j*64);
      %append zeroes if required
       if length(strings{j}) < 64
        strings{j} = [repmat('0', 1, 64 - length(strings{j})),strings{j}];
       end
      %call encryption function
      [ciphertext{i}, roundKeys] = ANU_encrypt(strings{j}, key, roundKeys);

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
% disp('Encryption Time (Seconds):');
% disp(tencr);
frewind(fileID); % Reset the file pointer to the beginning of the file

tDecrypt = tic;

while ~feof(fileID) && i <= numLines
    plaintext{i} = fgetl(fileID);
    
 if length(plaintext{i}) <= 64
    % if length(plaintext{i}) < 64
    %    plaintext{i} = [repmat('0', 1, 64 - length(plaintext{i})),plaintext{i}];
    % end

    %call decryption function
    ANU_decrypt(ciphertext{i}, roundKeys);
          
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
      %  if length(strings{j}) < 64
      %   strings{j} = [repmat('0', 1, 64 - length(strings{j})),strings{j}];
      % end

      %call decryption function
      decryptedtext = ANU_decrypt(cipher{k}, roundKeys);

      % concatenate decrypted text for each block
      output1 = strcat(output1,decryptedtext);
      k=k+1;
  end
                
end
    i = i + 1;
    
end

%end decryption timer
tdecr = toc(tDecrypt);
% disp('Decryption Time (Seconds):');
% disp(tdecr);

% Close the file
fclose(fileID);

% end total execution timer
tend = toc(tstart);
% disp('Total Time (Seconds):');
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
        key(1:4) = SBoxSegment(key(1:4));
        key(5:8) = SBoxSegment(key(5:8));
        key(end-4:end) = dec2bin(bitxor(bin2dec(key(end-4:end)), round-1), 5);
        %call function for encryption of one round
        [L, R] = ANURound(L, R, roundKeys{round});
        plaintext = [L, R];
    end
    ciphertext = plaintext;
end

%s-box function with 32-bit input/output
function output = SBox(input)
    output = '';
    %divide 32-bit input into eight 4-bit segments and apply s-box
    for i = 1:8
        segment = input((i-1)*4 + 1 : i*4);
        output = strcat(output, SBoxSegment(segment));
    end
end

%s-box function with 4-bit input/output
function output = SBoxSegment(segment)
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
    F1 = SBox(F1);
    F2 = SBox(F2);
    %apply x-or operations
    FX = dec2bin(bitxor(bin2dec(F1), bin2dec(R)), 32);
    Pt = dec2bin(bitxor(bitxor(bin2dec(FX), bin2dec(F2)), bin2dec(roundKey)), 32);
    %apply bit permutation and swap the bit strings
    R = bitPermutation(L);
    L = bitPermutation(Pt);
end

%function for bit permutation(used in encryption)
function output = bitPermutation(input)
    BP = [20 16 28 24 17 21 25 29 22 18 30 26 19 23 27 31 11 15 3 7 14 10 6 2 9 13 1 5 12 8 4 0] + 1;
    output = input;
    for i = 1:length(BP)
        output(i) = input(BP(i));
    end
end

%function for reverse bit permutation(used in decryption)
function output = reversebitPermutation(input)
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
    L = reversebitPermutation(L);
    R = reversebitPermutation(R);
    %apply circular shifts
    F1 = circshift(L, [0, -3]);
    F2 = circshift(L, [0, 8]);
    %apply s-box substitution
    F1 = SBox(F1);
    F2 = SBox(F2);
    %apply x-or operations
    Pt = dec2bin(bitxor(bitxor(bin2dec(R), bin2dec(F2)), bin2dec(roundKeys)), 32);
    FX = dec2bin(bitxor(bin2dec(F1), bin2dec(Pt)), 32);
   
    R = FX;
end