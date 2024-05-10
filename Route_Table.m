function [] = Route_Table(nodes)
    % Initialize the cell array to store routing table data for each node
    nodesRoutingTables = cell(1, numel(nodes));
    for nodeID = 1:numel(nodes)
        % Initialize the routing table data for the current node
        routingTableData = cell(numel(nodes(nodeID).RoutingTable), 6); % Increased to accommodate node ID
        
        % Populate the routing table data for the current node
        for entryIdx = 1:numel(nodes(nodeID).RoutingTable)
            entry = nodes(nodeID).RoutingTable{entryIdx};
            routingTableData{entryIdx, 1} = nodeID; % Set node ID as Source ID
            routingTableData{entryIdx, 2} = entry.Destination;
            routingTableData{entryIdx, 3} = entry.HopCount;
            routingTableData{entryIdx, 4} = entry.NextHop;
            routingTableData{entryIdx, 5} = entry.Lifetime;
            % routingTableData{entryIdx, 6} = entry.SeqNumber;
        end
        
        % Store the routing table data in the nodesRoutingTables cell array
        nodesRoutingTables{nodeID} = routingTableData;
    end
    
    % Define column names for the routing table
    columnNames = {'Source ID', 'Destination ID', 'Hop Count', 'Next Hop ID', 'Lifetime'};
    
    % Create the routing table log figure
    Routing_Table_Log = figure('NumberTitle', 'off', 'Name', 'Routing Table Log');
    routingTable = uitable('Data', [], 'ColumnName', columnNames, 'Position', [20, 20, 600, 400]);
    set(Routing_Table_Log, 'ResizeFcn', @resizeTable);
    
    % Populate the routing table
    set(routingTable, 'Data', vertcat(nodesRoutingTables{:}));
    
    % Title for the routing table log figure
    title('Routing Table Log for All Nodes');
    
    function [] = resizeTable(~, ~)
        tableWidth = get(Routing_Table_Log, 'Position');
        tableWidth = tableWidth(3) - 50; % Adjust for padding
        set(routingTable, 'Position', [20, 20, tableWidth, 400]);
    end
end
