function [g_ave, MR, measurements] = summarizeT1Frequency(settings)

%% Prepare workspace
% clearvars
% settings = prepareWorkspace;
[labels, metadata] = importData(settings);

% settings.firstDivision = 10;
% settings.lastDivision = 300;
% settings.cellRadius = 60;
% settings.minCellsToCount = 1;

%% Load data
flag = zeros(1, length(labels));

for i = 1:length(labels)
    if (exist(['PooledData' filesep labels{i} '_T1.mat'], 'file'))
        disp(['Processing: ' labels{i}])
        data = load(['PooledData' filesep labels{i} '_T1.mat']);
        if data.flag < 1
            if data.flag == -1
                flag(i) = 0;
            else
                flag(i) = -4;
            end
            continue
        elseif ~isfield(data, 'T1_time') || ~isfield(data, 'T1_cells')
            disp('Processing failed flag -3')
            flag(i) = -3;
            continue
        end
        data2 = load(['PooledData' filesep labels{i} '_Raw.mat'], 'cellNumber', 'cellCenters', 'flag');
        if ~isfield(data2, 'cellNumber') || ~isfield(data2, 'cellCenters')
            flag(i) = -3;
            continue
        else
            disp('Processing Successful')
            measurements(i) = compareT1Transitions(data, data2, settings);
            flag(i) = 1;
%             frame{i} = data.frame;
%             T1_count{i} = data.T1_count;
        end
    else
        flag(i) = -1;
    end
end

%% Rearrange data
g_ave = metadata.g_ave;
MR = metadata.MR;

g_ave = g_ave(flag > 0);
MR = MR(flag > 0);
measurements = measurements(flag > 0);

% g_ave(isnan([measurements.R2])) = [];
% MR(isnan([measurements.R2])) = [];
% measurements(isnan([measurements.R2])) = [];