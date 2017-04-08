% This script identifies the occurence of T1 transitions from connectivity
% information in 2D in the detailed output files generated by Epi-Scale.

function [cellx, celly, T1x, T1y, divx, divy] = IdentifyT1Transitions2D( rawDetails )

lagAfterDetection = 0; % How many timesteps after a T1 transition can another be registered?

%% Initialization
timesteps = length(rawDetails);
cellx = cell(1, timesteps);
T1x = cell(1, timesteps);
celly = cell(1, timesteps);
T1y = cell(1, timesteps);
divx = cell(1, timesteps);
divy = cell(1, timesteps);

%% Analysis
cellNumber = 0;
oldGrowthProgress = [];
newCellNumber = 0;
for t = 1:timesteps
    disp(num2str(t))
    cellData = rawDetails{t};
    if newCellNumber < length(cellData)
        break
    end
    newCellNumber = length(cellData);
    
    edgeCell = str2double({cellData.IsBoundrayCell});
    growthProgress = str2double({cellData.GrowthProgress});
    
        
    newAdjacencyMatrix = makeAdjacencyMatrix({cellData.NeighborCells});
    [allxPositions, allyPositions] = parseCellPositionString2D({cellData.CellCenter});
    
    % Find newly divided cells
    oldGrowthProgress(end:newCellNumber) = 1;
    newCells = (growthProgress - oldGrowthProgress) < 0;
    tempNewx = [];
    tempNewy = [];
    
    for newCellIndex = find(newCells)
        tempNewx(end+1) = allxPositions(newCellIndex);
        tempNewy(end+1) = allyPositions(newCellIndex);
    end
    divx = tempNewx;
    divy = tempNewy;
    
    if cellNumber > 0
        
        neighborChanges = newAdjacencyMatrix(1:cellNumber,1:cellNumber) - adjacencyMatrix(1:cellNumber,1:cellNumber);
        % is and js are cells which gained a neighbor
        [is, js] = find(neighborChanges > 0);
        
        T1 = 0;
        
        tempPositionx = [];
        tempPositiony = [];
        for n = 1:length(is)
            x = is(n);
            y = js(n);
            
            if ~isnan(edgeCell(x)) && ~isnan(edgeCell(y)) && ...
                    ~edgeCell(x) && ~edgeCell(y) && x > y && ...
                    growthProgress(x) < 0.91 && growthProgress(y) < 0.91 && ...
                    growthProgress(x) > 0.03 && growthProgress(y) > 0.03 && ...
                    trackedCells(x) <= 0 && trackedCells(y) <= 0
                T1 = T1 + 1;
                tempPositionx = [tempPositionx mean([allxPositions(x); allxPositions(y)], 2)];
                tempPositiony = [tempPositiony mean([allyPositions(x); allyPositions(y)], 2)];
                trackedCells(x) = lagAfterDetection;
                trackedCells(y) = lagAfterDetection;
            end
        end
        T1x{t} = tempPositionx;
        T1y{t} = tempPositiony;
    end
    cellx{t} = allxPositions;
    celly{t} = allyPositions;
    
    trackedCells((cellNumber+1):newCellNumber) = lagAfterDetection;
    trackedCells = trackedCells - 1;
    
    cellNumber = newCellNumber;
    adjacencyMatrix = newAdjacencyMatrix;
    
    oldGrowthProgress = growthProgress;
end