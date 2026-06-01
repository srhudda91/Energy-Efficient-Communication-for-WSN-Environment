function RECTANGLE()
[user,~] = memory;
disp('Memory Available for RECTANGLE (Before Execution Started): ');
disp(user.MemAvailableAllArrays);
    %key
    key = '11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
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
title({'COMPARISION'; 'Encryption Time + Key Scheduling Time';});
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
disp('Memory Available for RECTANGLE (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by RECTANGLE: ');
disp(memory_used_in_bytes);
end

% function to read file, encryption and decryption 
function [tencr,tdecr,tend,tappend]= readfile(filePath,key)
roundKeys =cell(4,16,26);
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
while ~feof(fileID) && i <=numLines

    % store the binary strings into plaintext array
    plaintext{i} = fgetl(fileID);

    % append zeroes if required
 if length(plaintext{i}) < 64

     %start time counter to calculate time to append zeroes
     tapp = tic;
     plaintext{i} = [repmat('0', 1, 64 - length(plaintext{i})),plaintext{i}];
     tappend = toc(tapp); % end append time counter
     %call encrption function
     [ciphertext{i}, roundKeys] = rectangleEncrypt(key,plaintext{i});

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
      [ciphertext{i}, roundKeys] = rectangleEncrypt(key,plaintext{i});

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
while ~feof(fileID) && i <=numLines
    plaintext{i} = fgetl(fileID);
    
 if length(plaintext{i}) <= 64
     %call decryption function
      rectangleDecrypt(roundKeys,ciphertext{i});       
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
      decryptedtext =  rectangleDecrypt(roundKeys,cipher{k});  

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