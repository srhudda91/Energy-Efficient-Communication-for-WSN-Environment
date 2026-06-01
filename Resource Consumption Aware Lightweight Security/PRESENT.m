function PRESENT()
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

% encryption time(in seconds) vs binary string size
figure(1);
bar(bitsize,encryptionTime);
title({'COMPARISION'; 'Encryption Time';});
ylabel('Time (seconds)');
xlabel('Payload (Data Size in bits)');

% decryption time(in seconds) vs binary string size
figure(2);
bar(bitsize,decryptionTime);
title({'COMPARISION'; 'Decryption Time';});
ylabel('Time (seconds)');
xlabel('Payload (Data Size in bits)');


% total execution time(in seconds) vs binary string size
figure(3);
bar(bitsize,timeTotal);
title({'COMPARISION'; 'Total Time (Sum of Encryption Time and Decryption Time)';});
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

[user2,~] = memory;
disp('Memory Available for PRESENT (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by PRESENT: ');
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
     ciphertext{i} = Present_enc(plaintext{i}, key);

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
      ciphertext{i} = Present_enc(strings{j}, key);

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
while ~feof(fileID) && i <=3%numLines
    plaintext{i} = fgetl(fileID);
    
 if length(plaintext{i}) <= 64
     %call decryption function
      Present_dec(ciphertext{i}, key);       
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
      decryptedtext = Present_dec(cipher{k}, key);  

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
