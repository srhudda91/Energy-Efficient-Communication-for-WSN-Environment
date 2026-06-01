function LILLIPUT()
[user,~] = memory;
disp('Memory Available for LILLIPUT (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
%key
binKey = '00000001001000110100010101100111100010011010101111001101111011110000000100100011';
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
disp('Memory Available for LILLIPUT (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by LILLIPUT: ');
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
     ciphertext{i}= Lilliput_enc(plaintext{i},binKey);

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
      ciphertext{i} = Lilliput_enc(strings{j},binKey);

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
      Lilliput_dec(ciphertext{i}, binKey);      
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
      decryptedtext = Lilliput_dec(cipher{k},binKey);

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
%%%%
%% Creation du state
%%%%

function state=create_state(X, m)
%% Transform a message X (binaire -> m=0, hexadecimal -> m=1) to a state to be processed
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
%%%%
%% Round function
%%%%

function state=nonlinear_layer(X,K)
    sbox=[4 8 7 1 9 3 2 14 0 11 6 15 10 5 13 12];
  for i=1:8
    s=sbox(bitxor(X(9-i), K(i))+1);
    X(8+i)=bitxor(X(8+i), s);
  end
  state=X;
end

function state=linear_layer(X)
  for i=2:7
    X(16)=bitxor(X(16),X(i));
    X(17-i)=bitxor(X(17-i),X(8));
  end
  X(16)=bitxor(X(16),X(8));
  state=X;
end

function state=permutation(X,n)
    if n==1
        perm=[13 9 14 8 10 11 12 15 4 5 3 1 2 6 0 7]; 
    else
        perm=[14 11 12 10 8 9 13 15 3 1 4 5 6 0 2 7];
    end
  for i=1:16
    state(perm(i)+1)=X(i);
  end
end

%%%%
%%  Keyschedule
%%%%

function RK=exctract_round_key(K, i)
    sbox=[4 8 7 1 9 3 2 14 0 11 6 15 10 5 13 12];
  tmp=[dec2bin(K(19),4) dec2bin(K(17),4) dec2bin(K(14),4) dec2bin(K(11),4) dec2bin(K(10),4) dec2bin(K(7),4) dec2bin(K(4),4) dec2bin(K(2),4)];
  RK='';
  for j=1:8
    s=bin2dec([tmp(j) tmp(8+j) tmp(16+j) tmp(24+j)]);
    RK_tmp(j)=sbox(1+bin2dec([tmp(j) tmp(8+j) tmp(16+j) tmp(24+j)]));
    RK=[RK dec2bin(RK_tmp(j),4)];
  end
    RK(1:5)=dec2bin(bitxor(bin2dec(RK(1:5)), i), 5);
    RK=create_state(RK, 0);
end

function res=rotl(bin, d)
  if d>1
    res=rotl([bin(2:end) bin(1)], d-1);
  else
    res=[bin(2:end) bin(1)];
  end
end

function res=rotr(bin, d)
  if d>1
    res=rotr([bin(end) bin(1:end-1)], d-1);
  else
    res=[bin(end) bin(1:end-1)];
  end
end

function res=shiftl(bin, d)
  if d>1
    res=shiftl([bin(2:end) '0'], d-1);
  else
    res=[bin(2:end) '0'];
  end
end

function res=shiftr(bin, d)
  if d>1
    res=shiftr(['0' bin(1:end-1)], d-1);
  else
    res=['0' bin(1:end-1)];
  end
end

function state=roundFnLFSM(K, d)
if d>0
  for i=1:5:16
    K(i:i+4)=[K(i+1:i+4) K(i)];
  end
end
%% L0
  state(1)=bitxor(K(1), bin2dec(rotr(dec2bin(K(5),4),1)));
  state(2)=bitxor(K(2), bin2dec(shiftr(dec2bin(K(3),4),3)));
  state(3)=K(3);
  state(4)=K(4);
  state(5)=K(5);
%% L1
  state(6)=K(6);
  state(7)=bitxor(K(7), bin2dec(shiftl(dec2bin(K(8),4),3)));
  state(8)=K(8);
  state(9)=K(9);
  state(10)=bitxor(K(10), bin2dec(rotl(dec2bin(K(9),4),1)));
%% L2
  state(11)=K(11);
  state(12)=bitxor(K(12), bin2dec(rotr(dec2bin(K(13),4),1)));
  state(13)=K(13);
  state(14)=bitxor(K(14), bin2dec(shiftr(dec2bin(K(13),4),3)));
  state(15)=K(15);
%% L3
  state(16)=K(16);
  state(17)=bitxor(K(17), bitxor(bin2dec(shiftl(dec2bin(K(16),4),3)), bin2dec(rotl(dec2bin(K(18),4),1))));
  state(18)=K(18);
  state(19)=K(19);
  state(20)=K(20);
%%%% permutaion
if (d<=0)
  for i=1:5:16
    state(i:i+4)=[state(i+4) state(i:i+3)];
  end
end
end
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
state_M=create_state(m, 1);
state_K=create_state(k, 1);

for i=0:28
  RK=exctract_round_key(state_K, i);
  state_K=roundFnLFSM(state_K, 0);
  state_M=nonlinear_layer(state_M, RK);
  state_M=linear_layer(state_M);
  state_M=permutation(state_M,1);
end
RK=exctract_round_key(state_K, 29);
state_M=linear_layer(nonlinear_layer(state_M, RK));
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
function M = Lilliput_dec(C_b,key)
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
state_M=create_state(C, 1);
state_K=create_state(k, 1);
for i=0:28
   state_K=roundFnLFSM(state_K, 0);
end
for i=29:-1:1
  RK=exctract_round_key(state_K, i);
  state_K=roundFnLFSM(state_K, 1);
  state_M=nonlinear_layer(state_M, RK);
  state_M=linear_layer(state_M);
  state_M=permutation(state_M,2);
end
RK=exctract_round_key(state_K, 0);
state_M=linear_layer(nonlinear_layer(state_M, RK));
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
