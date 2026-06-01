function MIDORI()
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
disp('Memory Available for MIDORI (After Execution Finished): ');
disp(user2.MemAvailableAllArrays);
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
disp('Total Memory Used by MIDORI: ');
disp(memory_used_in_bytes);

end

%readfile function which calls encryption and decryption functions
function [tencr,tdecr,tend,tappend,ciphertext]= readfile(filePath,binKey)

%key division
K= cell(2,1);
for m =1:2
    K{m}=binKey((m-1)*64 + 1 : m*64);
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
     ciphertext{i}= midoriEncrypt(plaintext{i},RK,WK);

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
      ciphertext{i} = midoriEncrypt(strings{j},RK,WK);

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
      midoriDecrypt(ciphertext{i},RK,WK);      
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
      decryptedtext = midoriDecrypt(cipher{k},RK,WK);

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
        t4 = mixColumns(t3);
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
function state = mixColumns(state)
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
                temp = bitxor(temp, gfmult(M(i,k), state(k,j)));
            end
            result(i,j) = temp; 
        end
    end

    % Convert state back to binary strings
    state = arrayfun(@(x) dec2bin(x,4), result, 'UniformOutput', false);
end

function result = gfmult(a, b)
   
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
   temp = mixColumns(RK(:,:,i));
   RK(:,:,i) = invshuffleCell(temp);
end
    St = keyAdd(S,WK);
    for n = 15:-1:1
        t2 = subCell(St);
        t3 = mixColumns(t2);
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