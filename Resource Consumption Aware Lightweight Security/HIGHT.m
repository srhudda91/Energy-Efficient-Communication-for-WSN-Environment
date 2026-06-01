function HIGHT()
[user,~] = memory;
disp('Memory Available for HIGHT (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
%key
binKey = '11111111111011101101110111001100101110111010101010011001100010000111011101100110010101010100010000110011001000100001000100000000';
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
disp('Memory Available for HIGHT (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by HIGHT: ');
disp(memory_used_in_bytes);

end

%readfile function which calls encryption and decryption functions
function [tencr,tdecr,tend,tappend,ciphertext]= readfile(filePath,binKey)

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
     ciphertext{i}= Hight_enc(plaintext{i},binKey);

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
      ciphertext{i} = Hight_enc(strings{j},binKey);

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
      Hight_dec(ciphertext{i}, binKey);      
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
      decryptedtext = Hight_dec(cipher{k},binKey);

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

function state=create_state(X, m)
  state=[];
  if m<=0
    for i=1:8:(length(X)-7)
      state=[bin2dec(X(i:i+7)) state];
    end
  else
    j=0;
    for i=1:2:length(X)-1
      j-j+1;
      state=[hex2dec(X(i:i+1)) state];
    end
  end
end

%%%%
%% Keychedule
%%%%

function wk=whiteningKey(K) 
%% create the whitening key that is used before the first round and after the last round
  for i=1:8
    if i<=4
      wk(i)=K(i+12);
    else
      wk(i)=K(i-4);
    end
  end
end

function cst=constantGen()
%% Generate constants used for the round
  cst='0101101';
  for i=1:127
    cst(7+i)=dec2bin(bitxor(bin2dec(cst(i+3)), bin2dec(cst(i))), 1);
  end
end

function c=extract_const(cst, i)
%% Extract the correct constant for the round i from the vector cst generated by the function constantGen
  c='';
  for j=i:i+6
    c=[cst(j+1) c];
  end
end

function sk=subkey(K, cst)
%% Generated the subkey used during the round
  for i=0:7
    for j=0:7
      c=extract_const(cst, 16*i+j);
      sk(16*i+j+1)=mod(K(mod(j-i, 8)+1)+ bin2dec(c), 256);
      c=extract_const(cst, 16*i+j+8);
      sk(16*i+j+9)=mod(K(mod(j-i, 8)+9)+ bin2dec(c), 256);
    end
  end
end

%%%%
%%  Initial transformations
%%%%
function x=initialTransformation(P, wk)
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

%%%%
%%  round
%%%%

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

function x=Round(state, sk, i) %% Encryption
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

%%%%
%%  Final transformations
%%%%
function c=FinalTransformation(x, wk) %% Encryption
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

%%%%
%%  Cipher algorithm
%%%%

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
  %% Initialization
  state_m=create_state(m, 1);
  state_k=create_state(k, 1);
  wk=whiteningKey(state_k);
  cst=constantGen();
  sk=subkey(state_k, cst);
  state_m=initialTransformation(state_m, wk);
  %% Rounds
  for i=0:31
    state_m=Round(state_m, sk, i);
  end
  %% Final transformation
  C_tmp=FinalTransformation(state_m, wk);
  %% reformat cipher
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
 %C = reshape(dec2bin(hex2dec(reshape(C, 2, [])), 8)', 1, []);
end

function M=Hight_dec(C_b, key) %% Decryption
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

  state_m=create_state(C, 1);
  state_k=create_state(k, 1);
  wk=whiteningKey(state_k);
  cst=constantGen();
  sk=subkey(state_k, cst);
  state_m=initialTransformation_d(state_m, wk);
  %% Rounds
  for i=0:31
    31-i;
    state_m=Round_d(state_m, sk, 31-i);
  end
  %% Final transformation
  M_tmp=FinalTransformation_d(state_m, wk);
  %% reformat message
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
