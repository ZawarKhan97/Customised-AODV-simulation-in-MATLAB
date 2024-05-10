classdef RoutingTable
    properties
        import GlobalVariablesClass
        node_TTL=GlobalVariablesClass.get_Node_TTL_Value;
    end
    
    
    methods (Static)
        function [nodes] = updateTableData(nodes, currentNode, sourceNodeID, broadcastMsg)
            % Check if the current node has an existing entry for the destination ID
            found = false;
            for i = 1:numel(nodes(currentNode).RoutingTable)
                
                if nodes(currentNode).RoutingTable{i}.Destination == sourceNodeID
                    % Update the existing entry
                    nodes(currentNode).RoutingTable{i}.Destination = sourceNodeID;
                    nodes(currentNode).RoutingTable{i}.HopCount = broadcastMsg.HopCount;
                    nodes(currentNode).RoutingTable{i}.NextHop = 0;
                    nodes(currentNode).RoutingTable{i}.SeqNumber = 0;
                    found = true;
                    break;
                end
            end
            
            if ~found
                % Create a new entry
                newEntry = struct('Destination', sourceNodeID, ...
                                  'HopCount', broadcastMsg.HopCount, ...
                                  'NextHop', 0, ...
                                  'Lifetime', broadcastMsg.TTL, ...
                                  'SeqNumber', 0);
               nodes(currentNode).RoutingTable{end+1} = newEntry;
               % displayRoutingTable(nodes, currentNode)
            end
            
        end
        
        function [updated_nodes] = updateTableData_helloPacket(nodes,currentNode,DestID, NextHop, HopCount,TTL)
            % Check if the current node has an existing entry for the destination ID
            % found = false;
            % for i = 1:numel(nodes(currentNode).RoutingTable)
            %     nodes(currentNode).RoutingTable{i}.Destination
            %     if nodes(currentNode).RoutingTable{i}.Destination == sourceNodeID
            %         % Update the existing entry
            %         nodes(currentNode).RoutingTable{i}.Destination = sourceNodeID;
            %         nodes(currentNode).RoutingTable{i}.HopCount = broadcastMsg.HopCount;
            %         nodes(currentNode).RoutingTable{i}.NextHop = 0;
            %         nodes(currentNode).RoutingTable{i}.SeqNumber = 0;
            %         found = true;
            %         break;
            %     end
            % end
            % 
            % if ~found
                % Create a new entry
                newEntry = struct('Destination', DestID, ...
                                  'HopCount', HopCount, ...
                                  'NextHop', NextHop, ...
                                  'Lifetime', TTL, ...
                                  'SeqNumber', 0);
               nodes(currentNode).RoutingTable{end+1} = newEntry;
               % displayRoutingTable(nodes, currentNode)
            % end
              updated_nodes=nodes;
        end
    end
    
end
