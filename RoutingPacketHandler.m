classdef RoutingPacketHandler
    properties (Access=protected) 
        temp_nodes
        temp_globalVar
        Timer
        numNodes
        temp_nodes_TTL
        avgE2EDelay
        delayFactorE
        transmitPower  % Transmit power in dBm
        frequency  % Frequency in Hz
        antennaGainTx  % Transmit antenna gain in dBi
        antennaGainRx  % Receive antenna gain in dBi
        pathLossExponent  % Path loss exponent
        transmissionDelay  % Transmission delay in seconds
        propagationSpeed % Speed of light in m/s
        processingDelay % Processing delay in seconds
        queuingDelay % Queuing delay in seconds
        % Calculate path loss using Friis transmission equation
        % receivedPower = transmitPower + antennaGainTx + antennaGainRx - (10 * pathLossExponent * log10(distance)) - 20 * log10(frequency);

    end
   methods
       function obj=RoutingPacketHandler(nodes,globalVariable)
           % import GlobalVariablesClass.*;
           % obj.temp_globalVar=GlobalVariablesClass.getThresholdDistanceValue;
           obj.temp_globalVar=globalVariable.threshold_Distance;
           obj.temp_nodes=nodes;
           obj.Timer = timer('ExecutionMode', 'singleShot', 'TimerFcn', @obj.broadcastHelloPacket);
           obj.numNodes=globalVariable.numNodes;
           obj.temp_nodes_TTL=globalVariable.Node_TTL;
           obj.avgE2EDelay=[];
           obj.delayFactorE=0.5;
           obj.transmitPower = uint8(20); % Transmit power in dBm
           obj.frequency = 430e6; % Frequency in Hz
           obj.antennaGainTx = uint8(5); % Transmit antenna gain in dBi
           obj.antennaGainRx = uint8(3); % Receive antenna gain in dBi
           obj.pathLossExponent = uint8(2); % Path loss exponent
           obj.transmissionDelay = 0.0256; % Transmission delay in seconds
           % obj.transmissionDelay = 0.0224; % Transmission delay in seconds
           obj.propagationSpeed = 3e8; % Speed of light in m/s
           obj.processingDelay = 0.01; % Processing delay in seconds
           obj.queuingDelay = 0.01; % Queuing delay in seconds
       end
       function obj = broadcastPacket(obj,sourceNodeID, broadcastMsg)
            % Iterate through all nodes to send the broadcast msg
            for nodeID = 1:numel(obj.temp_nodes)
                if nodeID == sourceNodeID
                    continue; % Skip sending the broadcast message to the source node
                end
                
                % Send the broadcast message to the current node
                 obj=obj.receivePacket(nodeID, sourceNodeID, broadcastMsg);
               
            end
            
        end
        
        function obj = broadcastHelloPacket(obj,~,~)
            
            %hello packet broadcasted by random node
            sourceNodeID=randi(obj.numNodes);
            % RT_Table=obj.temp_nodes(sourceNodeID).RoutingTable;
            % RT_Table=increment_Hop_Count(temp_routing_table_entries);
            helloPacket = struct('MessageType', 'Hello Packet', 'SourceID', sourceNodeID, ...
                 'RoutingTableEntries', {obj.temp_nodes(sourceNodeID).RoutingTable});
            
            for Receiver_nodeID = 1:numel(obj.temp_nodes)
                if Receiver_nodeID == sourceNodeID
                    continue; % Skip sending the broadcast message to the source node
                end
                
                % Send the broadcast message to the radio receiving the
                % hello packet
                 obj=obj.receivePacket(Receiver_nodeID, sourceNodeID, helloPacket);
                 
            end
                % Increment the transmitted hello packets counter in the source node's routing table
            obj.temp_nodes(sourceNodeID).TransmittedHelloPackets = ...
                 obj.temp_nodes(sourceNodeID).TransmittedHelloPackets + 1;
             % Route_Table(obj.get_nodes_entries)           
        end

        
        function obj=DataPacket(obj,~,~)
        % Generate data packet
                sourceNodeID = randi(obj.numNodes);  % Randomly select source node ID
                destinationNodeID = randi(obj.numNodes);  % Randomly select destination node ID
                
                while destinationNodeID == sourceNodeID
                    destinationNodeID = randi(obj.numNodes); % Skip sending the data message to the source node
                end

                
                % Check routing table for destination
                pathFound = false;
                % lowestHopCount = inf;
                % nextHop = 0;
                
                % Check if the destination node has an entry with the same destination ID
                destinationEntryIndex = obj.findDestinationIndex(destinationNodeID, obj.temp_nodes(sourceNodeID).RoutingTable);
                  if ~isempty(destinationEntryIndex)
                      pathFound=true;

                       % Send data packet to destination node
                       fprintf('Sending data packet from Node %d to Node %d\n', sourceNodeID, destinationNodeID);
                       dataPacket = struct('MessageType', 'Data', ...
                       'SourceID', sourceNodeID, ...
                       'DestinationID', destinationNodeID, ...
                       'NextHop',  obj.temp_nodes(sourceNodeID).RoutingTable{1,destinationEntryIndex}.NextHop, ...
                       'HopCount',obj.temp_nodes(sourceNodeID).RoutingTable{1,destinationEntryIndex}.HopCount, ....
                       'SequenceNumber',0, ...
                       'Data', 'Your data here');
                        obj=obj.receivePacket(destinationNodeID, sourceNodeID, dataPacket); 
                        % Increment the transmitted packets counter in the source node's routing table
                        obj.temp_nodes(sourceNodeID).TransmittedPacket = ...
                                 obj.temp_nodes(sourceNodeID).TransmittedPacket + 1;

                  else
                      % If no entry exists, add a new entry to the destination node's routing table
                      disp("Radio Not Found")
                  end
        end
                
        function obj=receivePacket(obj,currentNode, sourceNodeID, Msg)
                  if strcmp(Msg.MessageType, 'Broadcast')

                    %RSI Check
                    distance = sqrt((obj.temp_nodes(currentNode).X - obj.temp_nodes(sourceNodeID).X)^2 + (obj.temp_nodes(currentNode).Y -obj.temp_nodes(sourceNodeID).Y)^2);
                    if distance <= obj.temp_globalVar
                        obj.temp_nodes=RoutingTable.updateTableData(obj.temp_nodes,currentNode,sourceNodeID,Msg);
                    else
                        disp("Packet Lost Due to out detection area")
                    end


                  elseif strcmp(Msg.MessageType, 'Hello Packet')

                                   HelloPKT_RT_Entries = Msg.RoutingTableEntries;
                                   % Check each entry in the recieved hello packet routing table
                                   for i = 1:numel(HelloPKT_RT_Entries)
                                        % Extract entry details
                                        HelloPKT_Entry = HelloPKT_RT_Entries{1,i};
                                        if currentNode == HelloPKT_Entry.Destination
                                             continue; % Skip sending the broadcast message to the source node
                                        else
                                             DestinationID = HelloPKT_Entry.Destination;
                                             HopCount = HelloPKT_Entry.HopCount;
                                         NextHop = sourceNodeID;
                                          % Check if the destination node has an entry with the same destination ID
                                         destinationEntryIndex = obj.findDestinationIndex(DestinationID, obj.temp_nodes(currentNode).RoutingTable);
                                         if ~isempty(destinationEntryIndex)
                                         % If an entry exists, compare hop counts
                                         % Update the destination node's routing table if the source hop count is lower
                                         if HopCount < obj.temp_nodes(currentNode).RoutingTable{1,destinationEntryIndex}.HopCount
                                           % Update the destination node's routing table if the source hop count is lower
                                           destinationEntry{2} = HopCount;  % Update hop count
                                           destinationEntry{3} = sourceNodeID;    % Update next hop
                                           destinationRoutingTable{destinationEntryIndex} = destinationEntry;
                                           disp("Check this code area.........")
                                         end
                                         else
                                            % If no entry exists, add a new entry to the destination node's routing table
                                            newEntry = RoutingTable.updateTableData_helloPacket(obj.temp_nodes,currentNode,DestinationID, NextHop,HopCount+1,obj.temp_nodes_TTL);
                                            % Increment the received hello packets counter in the destination node's routing table
                                            newEntry(DestinationID).ReceivedHelloPackets =newEntry(DestinationID).ReceivedHelloPackets + 1;
                                            obj.temp_nodes = newEntry;
                                         end
                                     end
                                 end


                 elseif strcmp(Msg.MessageType, 'Data')
                    DestinationNodeID = currentNode;

                    if Msg.HopCount == 0
                        % if distance <= obj.temp_globalVar
                                 distance = sqrt((obj.temp_nodes(sourceNodeID).X - obj.temp_nodes(Msg.DestinationID).X)^2 + ...
                                                (obj.temp_nodes(sourceNodeID).Y - obj.temp_nodes(Msg.DestinationID).Y)^2);
                                 propagationDelay = distance / obj.propagationSpeed;
                                 endToEndDelay = obj.transmissionDelay + propagationDelay + obj.processingDelay + obj.queuingDelay;
                                 obj.avgE2EDelay = [obj.avgE2EDelay, endToEndDelay];
                                 obj.temp_nodes(Msg.DestinationID).ReceivedPackets = obj.temp_nodes(Msg.DestinationID).ReceivedPackets + 1;
                        % else
                            % disp("Packet Lost Due to out detection area")
                        % end

                    elseif Msg.HopCount == 1
                         distance = sqrt((obj.temp_nodes(Msg.NextHop).X - obj.temp_nodes(sourceNodeID).X)^2 + (obj.temp_nodes(Msg.NextHop).Y -obj.temp_nodes(sourceNodeID).Y)^2);
                         % if distance <= obj.temp_globalVar
                             % Forward the data packet to the next hop
                             nextHop = Msg.NextHop;
                             fprintf('Forwarding data packet from Node %d to Node %d through Node %d\n', sourceNodeID, Msg.DestinationID, nextHop);
                             % Check if the destination node has an entry with the same destination ID
                             destinationEntryIndex = obj.findDestinationIndex(Msg.DestinationID, obj.temp_nodes(nextHop).RoutingTable);
                             if ~isempty(destinationEntryIndex)
                               % Calculate propagation delay to next hop
                                propagationDelay = distance / obj.propagationSpeed;   
                                % Calculate end-to-end delay
                                endToEndDelay = obj.transmissionDelay + propagationDelay + obj.processingDelay + obj.queuingDelay;
                                obj.avgE2EDelay = [obj.avgE2EDelay, endToEndDelay];
                                % Forward the packet to the next hop
                                dataPacket = struct('MessageType', 'Data', ...
                                                        'SourceID', Msg.SourceID, ...
                                                        'DestinationID', Msg.DestinationID, ...
                                                        'NextHop', nextHop, ...
                                                        'HopCount', Msg.HopCount - 1, ...
                                                        'SequenceNumber', Msg.SequenceNumber, ...
                                                        'Data', Msg.Data);
                                obj = obj.receivePacket(Msg.DestinationID, nextHop, dataPacket);
                            % else
                                    % disp('Routing table entry not found for next hop. Packet dropped.');
                            % end
                         else
                             disp("Packet Lost Due to out detection area")
                         end

                     elseif Msg.HopCount == 2
                       distance = sqrt((obj.temp_nodes(Msg.NextHop).X - obj.temp_nodes(sourceNodeID).X)^2 + (obj.temp_nodes(Msg.NextHop).Y -obj.temp_nodes(sourceNodeID).Y)^2);
                       % if distance <= obj.temp_globalVar
                        % Forward the data packet to the next two hops
                        nextHop1 = Msg.NextHop;
                         fprintf('Forwarding data packet from Node %d to Node %d through Node %d\n', sourceNodeID, Msg.DestinationID, nextHop1);
                         % Check if the destination node has an entry with the same destination ID
                         destinationEntryIndex1 = obj.findDestinationIndex(Msg.DestinationID, obj.temp_nodes(nextHop1).RoutingTable);
                         if ~isempty(destinationEntryIndex1)
                           % Calculate propagation delay to next hop
                           distance1 = sqrt((obj.temp_nodes(sourceNodeID).X - obj.temp_nodes(nextHop1).X)^2 + ...
                                                     (obj.temp_nodes(sourceNodeID).Y - obj.temp_nodes(nextHop1).Y)^2);
                            propagationDelay1 = distance1 / obj.propagationSpeed;
                                    
                            % Calculate end-to-end delay for first hop
                            endToEndDelay1 = obj.transmissionDelay + propagationDelay1 + obj.processingDelay + obj.queuingDelay;
                            obj.avgE2EDelay = [obj.avgE2EDelay, endToEndDelay1];
                            % Forward the packet to the first next hop
                            dataPacket1 = struct('MessageType', 'Data', ...
                                                         'SourceID', Msg.SourceID, ...
                                                         'DestinationID', Msg.DestinationID, ...
                                                         'NextHop', nextHop1, ...
                                                         'HopCount', Msg.HopCount - 1, ...
                                                         'SequenceNumber', Msg.SequenceNumber, ...
                                                         'Data', Msg.Data);
                            obj = obj.receivePacket(nextHop1, sourceNodeID, dataPacket1);
                            % Check if the next hop has an entry with the same destination ID
                            nextHop2 = obj.temp_nodes(nextHop1).RoutingTable{1, obj.findDestinationIndex(Msg.DestinationID, obj.temp_nodes(nextHop1).RoutingTable)}.NextHop;
                            destinationEntryIndex2 = obj.findDestinationIndex(Msg.DestinationID, obj.temp_nodes(nextHop2).RoutingTable);
                            if ~isempty(destinationEntryIndex2)
                                 % Calculate propagation delay to second hop
                                 distance2 = sqrt((obj.temp_nodes(nextHop1).X - obj.temp_nodes(nextHop2).X)^2 + ...
                                                         (obj.temp_nodes(nextHop1).Y - obj.temp_nodes(nextHop2).Y)^2);
                                 propagationDelay2 = distance2 / obj.propagationSpeed;
                                 % Calculate end-to-end delay for second hop
                                 endToEndDelay2 = obj.transmissionDelay + propagationDelay2 + obj.processingDelay + obj.queuingDelay;
                                 obj.avgE2EDelay = [obj.avgE2EDelay, endToEndDelay2];
                                 % Forward the packet to the second next hop
                                dataPacket2 = struct('MessageType', 'Data', ...
                                                             'SourceID', Msg.SourceID, ...
                                                             'DestinationID', Msg.DestinationID, ...
                                                             'NextHop', nextHop2, ...
                                                             'HopCount', Msg.HopCount - 2, ...
                                                             'SequenceNumber', Msg.SequenceNumber, ...
                                                             'Data', Msg.Data);
                                  obj = obj.receivePacket(nextHop2, nextHop1, dataPacket2);
                             else
                                        disp('Routing table entry not found for second hop. Packet dropped.');
                             end
                        else
                                    disp('Routing table entry not found for first hop. Packet dropped.');
                         end
                         % else
                             % disp("Packet Lost Due to out detection area")
                         % end
                    end
                  end

         end

        function entryIndex = findDestinationIndex(~,DestinationID, routingTable)
            % Initialize the entryIndex to store the index of the destination entry
            entryIndex = [];
            
            % Loop through each routing table entry and check for the sourceDestination
            for idx = 1:numel(routingTable)
                if routingTable{idx}.Destination== DestinationID
                    % If the sourceDestination is found, store the index and break the loop
                    entryIndex = idx;
                    break;
                end
            end
        end
                
        function return_Nodes=get_nodes_entries(obj)
            return_Nodes=obj.temp_nodes;
        end
        function ReturnTime=get_E2Edealy(obj)
            ReturnTime=obj.avgE2EDelay;
        end

        
    end
end

