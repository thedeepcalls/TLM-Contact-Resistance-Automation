clear;
clc;
close all;

spacing = [25 50 75 100 125];   % microns

% Insert CSV File
[file, path] = uigetfile('*.csv','Select TLM CSV File');
if file == 0
    return;
end
filename = fullfile(path,file);

data = readlines(filename);
V = {};
I = {};
sweep = 0;

% Analyze Data
for n = 1:length(data)
    line = strtrim(data(n));
    if startsWith(line,"DataName")
        names = strtrim(split(line,","));
        vCol = find(strcmp(names,"V1")) - 1;
        iCol = find(strcmp(names,"I1")) - 1;
        
        if isempty(vCol) || isempty(iCol)
            continue;
        end
        
        sweep = sweep + 1;
        voltage = [];
        current = [];
        j = n + 1;
        
        while j <= length(data) && startsWith(strtrim(data(j)),"DataValue")
            values = split(strtrim(data(j)),",");
            numbers = str2double(values(2:end));
            voltage(end+1,1) = numbers(vCol);
            current(end+1,1) = numbers(iCol);
            j = j + 1;
        end
        V{sweep} = voltage;
        I{sweep} = current;
    end
end

% 4155C stores sweeps backwards
V = flip(V);
I = flip(I);

R = zeros(1,length(V));
IV_R2 = zeros(1,length(V));

figure;
hold on;
grid on;

for n = 1:length(V)
    voltage = V{n};
    current = I{n};
    
    use = abs(voltage) <= 0.5;
    voltageFit = voltage(use);
    currentFit = current(use);
    
    p = polyfit(voltageFit,currentFit,1);
    R(n) = 1 / abs(p(1));
    
    currentLine = polyval(p,voltageFit);
    SSres_IV = sum((currentFit - currentLine).^2);
    SStot_IV = sum((currentFit - mean(currentFit)).^2);
    IV_R2(n) = 1 - SSres_IV/SStot_IV;
    
    plot(voltage,current*1000,'LineWidth',1.5);
end

% TLM Plot
xlabel('Voltage (V)');
ylabel('Current (mA)');
title('TLM I-V Curves');
legend('25 um','50 um','75 um','100 um','125 um','Location','best');
hold off;

figure;
scatter(spacing,R,70,'filled');
hold on;
grid on;

pTLM = polyfit(spacing,R,1);
x = linspace(0,130,100);
y = polyval(pTLM,x);
plot(x,y,'LineWidth',1.5);

xlabel('Contact Spacing (\mum)');
ylabel('Resistance (\Omega)');
title('TLM Resistance vs Contact Spacing');

slope = pTLM(1);
intercept = pTLM(2);
Rc = intercept / 2;

Rfit = polyval(pTLM,spacing);
SSres = sum((R - Rfit).^2);
SStot = sum((R - mean(R)).^2);
R2 = 1 - SSres/SStot;

% Detect Ohmic/Shottkey-Like Contact
average_IV_R2 = mean(IV_R2);
if average_IV_R2 >= 0.98
    contactType = 'Likely Ohmic';
else
    contactType = 'Likely Schottky-like / Non-Ohmic';
end

% Results
fprintf('\nResistance Results\n');
fprintf('-------------------------\n');

for n = 1:length(spacing)
    fprintf('%3.0f um   = %.2f ohms\n', spacing(n), R(n));
end

fprintf('\nTLM Fit\n');
fprintf('R = %.4fL + %.4f\n', slope, intercept);
fprintf('TLM R^2 = %.4f\n', R2);

fprintf('\nContact Resistance\n');
fprintf('Rc = %.2f ohms/contact\n', Rc);

fprintf('\nContact Behavior\n');
fprintf('%s\n', contactType);