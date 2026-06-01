function KLEIN()
[user,~] = memory;
disp('Memory Available for KLIEN (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
    %key
    key = '0000000000000000000000000000000000000000000000000000000000000000';
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
disp('Memory Available for KLIEN (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by KLIEN: ');
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
     ciphertext{i} = Klein_enc(plaintext{i}, key);

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
      ciphertext{i} = Klein_enc(strings{j}, key);

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
      Klein_dec(ciphertext{i}, key);       
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
      decryptedtext = Klein_dec(cipher{k}, key);  

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

function state=create_state(X)
%% Transform an hexadecimal message X into a state
    for i=1:length(X)
      state(i)=hex2dec(X(i));
    end
end

function s=subnibble(X) %% Sbox
  sbox=[7 4 10 9 1 15 11 0 12 3 2 6 8 14 13 5];
  for i=1:length(X)
    s(i)=sbox(X(i)+1);
  end
end

function s=rotate_nibble(X) %% Encryption Rotation
  s=[X(5:16) X(1:4)];
end

function s=rotate_nibble_d(X) %% Decryption Rotation
  s=[X(13:16) X(1:12)];
end

function s=f(x) %% xtimes
   bin=dec2bin(x, 8);
   le=bin2dec([bin(2:8) '0']);
   if bin(1)=='1'
    ri=hex2dec('1B');
   else
    ri=0;
   end
   s=bitxor(le,ri);
%   L(x) ( ((x) << 1) ^ (0x1B & (u8)((s8)(x) >> 7)) )
end

function s=mixnibble(X) %% Encryption MixColumn
  for i=1:8
    oct(i)=bin2dec([dec2bin(X(2*(i-1)+1),4) dec2bin(X(2*i),4)]);
  end
  tmp(1) = bitxor(bitxor(bitxor(f(bitxor(oct(1),oct(2))),oct(2)),oct(3)),oct(4));
  tmp(2) = bitxor(bitxor(bitxor(f(bitxor(oct(2),oct(3))),oct(1)),oct(3)),oct(4));
  tmp(3) = bitxor(bitxor(bitxor(f(bitxor(oct(3),oct(4))),oct(1)),oct(2)),oct(4));
  tmp(4) = bitxor(bitxor(bitxor(f(bitxor(oct(4),oct(1))),oct(1)),oct(2)),oct(3));
  tmp(5) = bitxor(bitxor(bitxor(f(bitxor(oct(5),oct(6))),oct(6)),oct(7)),oct(8));
  tmp(6) = bitxor(bitxor(bitxor(f(bitxor(oct(6),oct(7))),oct(5)),oct(7)),oct(8));
  tmp(7) = bitxor(bitxor(bitxor(f(bitxor(oct(7),oct(8))),oct(5)),oct(6)),oct(8));
  tmp(8) = bitxor(bitxor(bitxor(f(bitxor(oct(8),oct(5))),oct(5)),oct(6)),oct(7));
  for i=1:8
   bin=dec2bin(tmp(i), 8);
   s(2*(i-1)+1)=bin2dec(bin(1:4));
   s(2*i)=bin2dec(bin(5:8));
  end
end

function s=mixnibble_d(X) %% Decryption MixColumn
  for i=1:8
    oct(i)=bin2dec([dec2bin(X(2*(i-1)+1),4) dec2bin(X(2*i),4)]);
  end
  var1 = bitxor(oct(4), bitxor(oct(2), bitxor(oct(3), oct(1))));
  var2 = bitxor(oct(8), bitxor(oct(7), bitxor(oct(6), oct(5))));
  
  tmp(1) = bitxor(f(bitxor(f(bitxor(f(var1), bitxor(oct(3), oct(1)))),  bitxor(oct(2), oct(1)))), bitxor(oct(4), bitxor(oct(2), oct(3))));
  tmp(2) = bitxor(f(bitxor(f(bitxor(f(var1), bitxor(oct(4), oct(2)))),  bitxor(oct(3), oct(2)))), bitxor(oct(1), bitxor(oct(3), oct(4))));
  tmp(3) = bitxor(f(bitxor(f(bitxor(f(var1), bitxor(oct(1), oct(3)))),  bitxor(oct(4), oct(3)))), bitxor(oct(2), bitxor(oct(4), oct(1))));
  tmp(4) = bitxor(f(bitxor(f(bitxor(f(var1), bitxor(oct(2), oct(4)))),  bitxor(oct(1), oct(4)))), bitxor(oct(3), bitxor(oct(1), oct(2))));
  tmp(5) = bitxor(f(bitxor(f(bitxor(f(var2), bitxor(oct(7), oct(5)))),  bitxor(oct(6), oct(5)))), bitxor(oct(8), bitxor(oct(6), oct(7))));
  tmp(6) = bitxor(f(bitxor(f(bitxor(f(var2), bitxor(oct(8), oct(6)))),  bitxor(oct(7), oct(6)))), bitxor(oct(5), bitxor(oct(7), oct(8))));
  tmp(7) = bitxor(f(bitxor(f(bitxor(f(var2), bitxor(oct(5), oct(7)))),  bitxor(oct(8), oct(7)))), bitxor(oct(6), bitxor(oct(8), oct(5))));
  tmp(8) = bitxor(f(bitxor(f(bitxor(f(var2), bitxor(oct(6), oct(8)))),  bitxor(oct(5), oct(8)))), bitxor(oct(7), bitxor(oct(5), oct(6))));
  tmp;
  for i=1:8
   bin=dec2bin(tmp(i), 8);
   s(2*(i-1)+1)=bin2dec(bin(1:4));
   s(2*i)=bin2dec(bin(5:8));
  end
end
%%%%
%%  Keyschedule
%%%%

function s=keyschedule(K, i)
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

function s=keyschedule_d(K, i)
  sbox=[7 4 10 9 1 15 11 0 12 3 2 6 8 14 13 5];
  a=[K(7:8) K(1:5) bitxor(K(6), i)];
  b=[K(15:16) K(9:10) sbox(K(11)+1) sbox(K(12)+1) sbox(K(13)+1) sbox(K(14)+1)];
  s(1:8)=bitxor(a,b);
  s(9:16)=a;
end

%%%%
%% Klein
%%%%
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
  %% Initialization
  S=create_state(m);
  K=create_state(k);
  %% Rounds
  for i=1:12
    S=bitxor(S, K);
    S=subnibble(S);
    S=rotate_nibble(S);
    S=mixnibble(S);
    K=keyschedule(K, i);
  end
  C_tmp=bitxor(S, K);
  %% Reformat Cipher
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

function M=Klein_dec(C_b, key) %% Decryption
k = '';

for i = 1:4:length(key)
    bin = key(i:i+3);  % Extract 4 bits
    dec = bin2dec(bin);  % Convert to decimal
    hex = dec2hex(dec);  % Convert to hexadecimal
    k = [k hex];  % Append to the hexadecimal string
end
  %% Initialization
  binStr = C_b;
 C = '';

for i = 1:4:length(binStr)
    bin = binStr(i:i+3);  % Extract 4 bits
    dec = bin2dec(bin);  % Convert to decimal
    hex = dec2hex(dec);  % Convert to hexadecimal
    C = [C hex];  % Append to the hexadecimal string
end
  %% Initialization
  S=create_state(C);
  K=create_state(k);
  %% Computation of encryption Keys
  for i=1:12
    i;
    K=keyschedule(K, i);
  end
  %% Rounds
  S=bitxor(S, K);
  for i=12:-1:1
    i;
    S=mixnibble_d(S);
    S=rotate_nibble_d(S);
    S=subnibble(S);
    K=keyschedule_d(K, i);
    S=bitxor(S, K);
  end
  %% Reformat Message
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
