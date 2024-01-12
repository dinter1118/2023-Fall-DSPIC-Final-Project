clear; close all;

% Filter specifications
fp = 1.5e3;    % Passband edge frequency in Hz
FS = 8e3;      % Sampling frequency in Hz
def = 0.5e3;   % Transition width in Hz
Ap = 40;        % Passband ripple in dB
As = 40;       % Stopband attenuation in dB
fs=2e3;

% Design the filter using firpm function
[N,FO,AO,W] = firpmord([fp fs], [1 0], [10^(-Ap/20) 10^(-As/20)], FS);
b = firpm(N, FO, AO, W);
b=b';
% Display filter coefficients
disp('Tap Number:');
disp(N);
disp('Filter Coefficients:');
disp(b);
save ('coeff.txt','b','-ascii');
% Plot frequency response
figure;
freqz(b, 1, 1024, FS);
title('Frequency Response of FIR Filter ');
figure;
[H, w] =freqz(b, 1,'whole', FS);
plot(w/pi, abs(H));
xlim([0 1])
grid on;
xlabel('Normalized Frequency');
ylabel('Amplitude (dB)');
title('Amplitude ');
% Overlay target filter specifications
hold on;
plot([0, fp, (fp+def/2),(fp+def/2), fs,FS/2]/(FS/2), [1, 1, 1, 0, 0,0], 'r--');
legend('Filter Response', 'Ideal  Lowpass Filter');
hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%(b) (i)
% Randomly generate test patterns of floating-point signed real-value signals
numberOfTestPatterns = 1000; 
rng(111061642);
inputSignals =(randn(1, numberOfTestPatterns))';% Gaussian noise with mean 0 and variance
avg_power = mean(inputSignals.^2);
scaling_factor = 1 / sqrt(avg_power);
%avg power = 1
inputSignals = scaling_factor * inputSignals;
save ('input.txt',"inputSignals",'-ascii');
outfloat = filter(b, 1, inputSignals);
save('out.txt',"outfloat",'-ascii');
figure;
plot(linspace(1,numberOfTestPatterns,numberOfTestPatterns),inputSignals);
grid on;
title('input signal(original)');
grid off;

% Plot the spectrum of the input signal
figure;
subplot(2, 1, 1);
plot(linspace(0, FS, numberOfTestPatterns), abs(fft(inputSignals)));
title('Input Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

% Plot the spectrum of the output signal
subplot(2, 1, 2);
plot(linspace(0, FS, numberOfTestPatterns), abs(fft(outfloat)));
title('Output Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

% Adjust figure properties
sgtitle('(b)(i) Float-Point FIR Filter Simulation');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%(b) ii 
%add noise snr
snr= 30;
inputSignals_noise = awgn(inputSignals,snr,'measured');
figure;
plot(linspace(1,numberOfTestPatterns,numberOfTestPatterns),inputSignals_noise);
grid on;
title('input signal(original+noise) ');
grid off;

wordLengths = 8; % Word lengths to test
%%(b) ii Output SNR vs Input Word Length
%%fi(data,signed,wordlength)
% Normalize input signals to fixed-point representation
scale = 2.^(wordLengths);
coeffix = round(b*scale);
coeffix = coeffix /scale;
snrResults = [];
sumoutfloat= sum(outfloat.^2);
for wordLength = 2:1:16
    % Quantize input signals and coefficients to fixed-point representation
    scale = 2.^(wordLength);
    inputfix = round(inputSignals_noise*scale);
    inputfix = inputfix/scale;
    % Perform fixed-point FIR filtering
    outfix = filter(coeffix, 1, inputfix);
    % Calculate SNR
    noise = double(outfloat-outfix);
    snr = 10 * log10 (double(sumoutfloat/ sum(noise.^2)));
    snrResults = [snrResults,snr];
end

% Plot output SNR versus input word length
figure;
plot(2:16, snrResults, '-o');
title('(b)(ii)Output SNR vs Input Word Length');
xlabel('Input Word Length');
ylabel('Output SNR (dB)');
grid on;


% Perform similar analysis for the MAC word length
macWordLengths = 8; % Word lengths to test for MAC
macSnrResults = zeros(length(macWordLengths), 1);
scale = 2.^(macWordLengths);
coeffix = round(b*scale);
coeffix = coeffix /scale;
macWordLengths = 2:16;

for i = 1:length(macWordLengths)
    macWordLength = macWordLengths(i);
    inputfix = round(inputSignals*(2.^8));
    inputfix = inputfix/(2.^8);
    scale = 2.^(macWordLength);
    % Quantize coefficients to MAC word length
    inputfix = round(inputfix*scale);
    inputfix = inputfix/scale;
    % Perform fixed-point FIR filtering
    outfix = filter(coeffix, 1, inputfix);
    % Calculate SNR
    noiseMAC = outfloat - outfix;
    macSnrResults(i) = 10 * log10(double(sumoutfloat / sum(noiseMAC.^2)));
end

% Plot output SNR versus MAC word length
figure;
plot(macWordLengths, macSnrResults, '-o');
title('(b)(ii)Output SNR vs MAC Word Length');
xlabel('MAC Word Length');
ylabel('Output SNR (dB)');
grid on; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%output txt to verilog 
%%input bit =8 ,tap bit=8
%%output bit =15
input_fix = round(inputSignals*2.^8);
coef_fix = round(b*2.^8);
out_fix = filter(coef_fix , 1 ,input_fix);
fileID = fopen('../RTL/input_fix.txt','w');
fprintf(fileID,'%d\n',input_fix);
fileID1 = fopen('../RTL/coef_fix.txt','w');
fprintf(fileID1,'%d\n',coef_fix);
fileID2 = fopen('../RTL/out_fix.txt','w');
fprintf(fileID2,'%d\n',out_fix);

fileID3 = fopen('../NETILST/input_fix.txt','w');
fprintf(fileID3,'%d\n',input_fix);
fileID4 = fopen('../NETILST/coef_fix.txt','w');
fprintf(fileID4,'%d\n',coef_fix);
fileID5 = fopen('../NETILST/out_fix.txt','w');
fprintf(fileID5,'%d\n',out_fix);

figure;
plot(linspace(0,31,32),coef_fix,'-o')
title('coefficient');
grid on;
figure;
plot(linspace(1,numberOfTestPatterns,numberOfTestPatterns),input_fix)
title('inputfix');
grid on;
figure;
plot(linspace(1,numberOfTestPatterns,numberOfTestPatterns),out_fix)
title('outputfix');
grid on;

