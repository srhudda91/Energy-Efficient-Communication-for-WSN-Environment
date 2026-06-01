function LED()
[user,~] = memory;
disp('Memory Available for LED (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
%key
binKey = '0000000100100011010001010110011110001001101010111100110111101111';
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
disp('Memory Available for LED (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by LED: ');
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
rc = cell(numLines,1);
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
     [ciphertext{i},rc{i}]= LED_enc(plaintext{i},binKey);

 else 

    %form blocks if length of binary string is greater than 64
    numBLocks = length(plaintext{i})/64;
    %preallocate array to hold the block strings
    strings = cell(numBLocks,1);
    tappend =0;% make append time zero for this case
    output2 = '';
  outrc = '';
 for j = 1:numBLocks
     %store the 64-bit size strings in strings array
      strings{j} = plaintext{i}((j-1)*64 + 1 : j*64);

      %append zeroes if required
       if length(strings{j}) < 64
        strings{j} = [repmat('0', 1, 64 - length(strings{j})),strings{j}];
       end

      %call encryption function
      [ciphertext{i},temp] = LED_enc(strings{j},binKey);

      % concatenate all ciphertext formed in every round from j=1 to j=numBlocks 
        output2 = strcat(output2,ciphertext{i});
        outrc = strcat(outrc,temp);
 end
 %store all the ciphertext formed in this array
 ciphertext{i}=output2;   
 rc{i} = outrc;
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
      LED_dec(ciphertext{i}, binKey,rc{i});      
else
    numBLocks = length(plaintext{i})/64;
    %preallocate array to hold the block strings
    strings = cell(numBLocks,1);
    cipher = cell(numBLocks,1);
    rc_temp = cell(numBLocks,1);
    output1 = '';
    k=1;
     for t = 1:numBLocks
        startIdx = (t-1)*6 + 1;
        endIdx = startIdx + 5;
        rc_temp{t} = rc{i}(startIdx:endIdx);
    end
 for j = 1:numBLocks 
      strings{j} = plaintext{i}((j-1)*64 + 1 : j*64);

      %divide ciphertext greater than 64-bit size and store in cipher array
      cipher{k} = ciphertext{i}((k-1)*64 + 1 : k*64);

      %call decryption function
      decryptedtext = LED_dec(cipher{k},binKey,rc_temp{k});

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
function s=create_state(X)
%% Transform an hexadecimal message X in a state to be processed
  for i=1:4
    for j=1:4
      s(i,j)=hex2dec(X((i-1)*4+j));
    end
  end
end

%%%%
%%  Chiffrement
%% The name of each function indicates which function of the algorithm it performs
%%%%
function ks=key_size(K)
  t=dec2bin(length(K)*4, 8);
  for i=0:7
    ks(i+1)=bin2dec(t(8-i));
  end
end

function s=addroundKey(X, K)
  s=bitxor(X, K);
end

function rc=generate_constant(c)
  rc(1:5)=c(2:6);
  rc(6)=dec2bin(bitxor(bin2dec(c(1)), bitxor(bin2dec(c(2)), 1)));
end

function s=addconstant(X, rc, ks)
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

function s=shiftrow(X)
    s(1,:)=X(1,:);
    s(2,:)=[X(2,2:4) X(2,1)];
    s(3,:)=[X(3,3:4) X(3,1:2)];
    s(4,:)=[X(4,4) X(4,1:3)];
end

function n=xtimes(a, c)
  bin=dec2bin(a, 4);
  n=bin2dec([bin(2:4) '0']);
  if bin(1)=='1'
    n=bitxor(n, c);
  end
end

function s=mixcolumns(X)
  tmp=X;
  for k=1:4
    s(1:3,:)=tmp(2:4,:);
    for i=1:4
      s(4,i)=bitxor(xtimes(xtimes(tmp(1,i),3),3), bitxor(tmp(2,i), xtimes(bitxor(tmp(3,i), tmp(4,i)),3)));
    end
    tmp=s;
  end
end


function [s ,rc]=Round(X, c, ks)
  sbox=[12 5 6 11 9 0 10 13 3 14 15 8 4 7 1 2];
  rc=generate_constant(c);
  s=addconstant(X, rc, ks);
  s=sbox(s+1);
  s=shiftrow(s);
  s=mixcolumns(s);
end

%%%%
%%  Dechiffrement
%% The name of each function indicates which function of the algorithm it performs
%%%%
function s=mixcolumns_d(X)
  tmp=X;
  for k=1:4
    s(2:4,:)=tmp(1:3,:);
    for i=1:4
      var1=bitxor(tmp(1,i), tmp(4,i));
      var2=bitxor(tmp(2,i), tmp(3,i));
      a=bitxor(xtimes(xtimes(bitxor(xtimes(var1,3), var1), 3), 3), var1);
      b=bitxor(xtimes(xtimes(xtimes(var2,3),3),3), var2);
 
      s(1,i)=bitxor(a, b);
    end
    tmp=s;
  end
end

function s=shiftrow_d(X)
    s(1,:)=X(1,:);
    s(2,:)=[X(2,4) X(2,1:3)];
    s(3,:)=[X(3,3:4) X(3,1:2)];
    s(4,:)=[X(4,2:4) X(4,1)];
end

function rc=generate_constant_d(c)
  rc(2:6)=c(1:5);
  rc(1)=dec2bin(bitxor(bin2dec(c(6)), bitxor(bin2dec(c(1)), 1)));
end

function [s ,rc]=Round_d(X, c, ks)
  sbox_d=[5 14 15 8 12 1 2 13 11 4 6 3 0 7 9 10];
  s=mixcolumns_d(X);
  s=shiftrow_d(s);
  s=sbox_d(s+1);
  s=addconstant(s, c, ks);
  rc=generate_constant_d(c);
end
%%
%% encryption function
%%
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
S=create_state(m);
k=create_state(Key);
rc='000000';

for i=1:8
  S=addroundKey(S, k);
  for m=0:3
    [S, rc]=Round(S, rc, ks);
  end
end
C=addroundKey(S, k);
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

%%%%
%% Decryption function
%%%%
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
k=create_state(key);
S=C;
for i=8:-1:1
  S=addroundKey(S, k);
  for m=3:-1:0
    [S ,rc]=Round_d(S, rc, ks);
  end
end
M=addroundKey(S, k);
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
