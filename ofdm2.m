clc; 
clear;

no_of_data_bits = 64;
M =4; %Number of subcarrier channels

%............................................................
%............................................................
%............................................................
% Transmitter
%.........................................................
%............................................................
%............................................................

%-----Data generation------------------------------------------------------

data = randi([0,1],1, no_of_data_bits);
disp(data);
figure(1),stem(data);
grid on;
xlabel('Data Points');
ylabel('Amplitude')
title('Original Data ')

%-----Modulation-----------------------------------------------------------

qpsk_modulated_data = pskmod(data, M);

%------Serial to parallel conversion of data stream------------------------
SerialToParallel = reshape(qpsk_modulated_data, no_of_data_bits/M, M);
disp(SerialToParallel);

%---------IFFT and Cyclic prefix stage ------------------------------
A=[];
Ncp = 4; %number of symbols to copy an paste for cyclic prefix
for i=1: M
    ifft_per_subcarrier = ifft(SerialToParallel(:,i));
    ifft_per_subcarrier_cp = [ifft_per_subcarrier(end-Ncp+1:end); ifft_per_subcarrier];
    A=[A,ifft_per_subcarrier_cp];
end
disp(A);

%-----Convert to serial stream for transmission----------------------------
% OFDM signal to be transmitted
ofdm_signal = reshape(A, 1, []);
disp(ofdm_signal);
figure(6),plot(real(ofdm_signal)); xlabel('Time'); ylabel('Amplitude');
title('OFDM Signal');grid on;


%------Channel Modeling----------------------------------------------------

awgnchan = comm.AWGNChannel;

%..........................................................................
%..........................................................................
%..........................................................................
% Receiver
%..........................................................................
%..........................................................................
%..........................................................................
recvd_signal = awgnchan(ofdm_signal);

%------Received signal ----------------------------------------------------

figure(7),plot(real(recvd_signal)),xlabel('Time'); ylabel('Amplitude');
title('OFDM Signal after passing through channel');grid on;

%------Received signal paralleled------------------------------------------
recvd_signal_paralleled = reshape(recvd_signal, 20, 4);

%------Removing cyclic prefic and doing fft on received data --------------
B=[];
for i=1: M
    rcvd_signal_component = recvd_signal_paralleled(:,i);
    
    %----Removing cyclic prefix--------------------------------------------
    recvd_signal_minus_cp = rcvd_signal_component(Ncp+1:end,:);
    
    %----Doing fft on received data minus cyclic prefix--------------------
    fft_rcvd_signal = fft(recvd_signal_minus_cp);
    B=[B,fft_rcvd_signal];
end
recvd_serial_data = reshape(B, 1,(16*4));

%----Demodulation of received data signal----------------------------------
qpsk_demodulated_data = pskdemod(recvd_serial_data,4);
disp(qpsk_demodulated_data);
figure(10)
stem(data)
hold on
stem(qpsk_demodulated_data,'rx');
grid on;xlabel('Data Points');ylabel('Amplitude');
title('Recieved Signal with error')
disp(biterr(data ,qpsk_demodulated_data));