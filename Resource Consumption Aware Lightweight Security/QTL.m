function QTL()
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
disp('Memory Available for QTL (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by QTL: ');
disp(memory_used_in_bytes);
end

%readfile function which calls encryption and decryption functions
function [tencr,tdecr,tend,tappend,ciphertext]= readfile(filePath,binKey)

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
     tappend = toc(tapp); % end append time counter
     %call encrption function
     ciphertext{i}= qtl_encrypt(binKey,plaintext{i});

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
      ciphertext{i} = qtl_encrypt(binKey,strings{j});

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
      qtl_decrypt(binKey,ciphertext{i});      
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
      decryptedtext = qtl_decrypt(binKey,cipher{k});

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
    out1 = roundTranspose(inp);
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

t1 = addconstants1(pt,NR);
t2 = addroundkeys(key1,t1);
t3 = SBox1(t2);
t4 = bitPermutation(t3);
outf1 = SBox1(t4);
end

%definition for function 2
function outf2= function2(key2,pt,NR)
t1 = addconstants2(pt,NR);
t2 = addroundkeys(key2,t1);
t3 = SBox2(t2);
t4 = bitPermutation(t3);
outf2 = SBox2(t4);
end

%function to add constants in function1 of encryption
function res = addconstants1(pt,NR)
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
function res = addconstants2(pt,NR)

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
function result = addroundkeys(key1,pt)

%perform bitxor on the plaintext and key received
result = dec2bin(bitxor(bin2dec(key1),bin2dec(pt)),16);
end

%function definition for sbox1
function output = SBox1(input)
    
    output = '';

    %divide 16-bit input into four 4-bit segments and apply s-box
    for i = 1:4
        segment = input((i-1)*4 + 1 : i*4);
        output = [output, SBoxSegment1(segment)];
    end
end

%s-box function with 4-bit input/output
function output = SBoxSegment1(segment)
  
    sBoxTable1 = ['C' '5' '6' 'B' '9' '0' 'A' 'D' '3' 'E' 'F' '8' '4' '7' '1' '2'];

    segmentDecimal = bin2dec(segment) + 1;

    outputHex = sBoxTable1(segmentDecimal);

    output = dec2bin(hex2dec(outputHex), 4);
end

%function definition for sbox2
function output = SBox2(input)
    output = '';

    %divide 16-bit input into four 4-bit segments and apply s-box
    for i = 1:4
        segment = input((i-1)*4 + 1 : i*4);
        output = [output, SBoxSegment2(segment)];
    end
end

%s-box function with 4-bit input/output
function output = SBoxSegment2(segment)
    sBoxTable2 = ['4' 'F' '3' '8' 'D' 'A' 'C' '0' 'B' '5' '7' 'E' '2' '6' '1' '9'];
    segmentDecimal = bin2dec(segment) + 1;
    outputDecimal = hex2dec(sBoxTable2(segmentDecimal));
    output = dec2bin(outputDecimal, 4);
end

%function to perform bit permutation
function output = bitPermutation(input)
    BP = [0 4 8 12 1 5 9 13 2 6 10 14 3 7 11 15] + 1;
    output = input;
    for i = 1:length(BP)
        output(i) = input(BP(i));
    end
end

%function to perform round transpose
function out = roundTranspose(input)
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
    out1 = roundTranspose(inp);

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

t1 = addconstants1decr(pt,NR);
t2 = addroundkeys(key1,t1);
t3 = SBox1(t2);
t4 = bitPermutation(t3);
outf1 = SBox1(t4);
end

%function definition for function2 for decryption
function outf2= function2decr(key2,pt,NR)

t1 = addconstants2decr(pt,NR);
t2 = addroundkeys(key2,t1);
t3 = SBox2(t2);
t4 = bitPermutation(t3);
outf2 = SBox2(t4);
end

%function definition for adding constants in function1 of decryption
function res = addconstants1decr(pt,NR)

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
function res = addconstants2decr(pt,NR)

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
