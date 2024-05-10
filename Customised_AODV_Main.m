% AODV Routing Protocol Customised Simulation in MATLAB
clear all
% Set Up the Environment:
% Define parameters such as the number of nodes, transmission range, simulation time, etc.
global globalVariable;
globalVariable=GlobalVariablesClass();

Show_Figure=false;
Show_Figure_Last=true;
transmissionRange = 50; % meters
% Initialize Enviornment or nodes container showing its a device
nodes = struct('ID', [], 'X', [], 'Y', [], 'RoutingTable', containers.Map('KeyType', 'int32', 'ValueType', 'int32'), 'SequenceNumber', 0);
for i = 1:globalVariable.numNodes
    nodes(i).ID = uint8(i);
    nodes(i).X = randi([0, 100]);
    nodes(i).Y = randi([0, 100]); 
    nodes(i).RoutingTable = {};
    nodes(i).ReceivedPackets=0;
    nodes(i).TransmittedPacket=0;
    nodes(i).ReceivedHelloPackets=0;
    nodes(i).TransmittedHelloPackets=0;
    nodes(i).SequenceNumber=0;
end

% Setup Phase Fill route tables at start using broadcast feature
selectedNodes ={};
global nodes_container
nodes_container=RoutingPacketHandler(nodes,globalVariable);%create Nodes container class
while numel(selectedNodes) < globalVariable.numNodes
    % Select a random node
    sourceNodeID = randi(globalVariable.numNodes);
    if ~any(cellfun(@(x) x == sourceNodeID, selectedNodes))
        % Add the node to the selectedNodes array
        selectedNodes = [selectedNodes, sourceNodeID];
         
        % Create a broadcast message
        broadcastMsg = struct('MessageType', 'Broadcast', 'SourceID', sourceNodeID, 'HopCount', 0, 'TTL', globalVariable.Node_TTL); 
        % Call the broadcastPacket function from the RoutingPacketHandler class
        
        nodes_container=nodes_container.broadcastPacket(sourceNodeID,broadcastMsg);
    end
end
if Show_Figure==true
    %%Plot Nodes and show route table
    Plot_Space_View(nodes_container.get_nodes_entries)
    Route_Table(nodes_container.get_nodes_entries)
end
% Implement Customised-AODV Protocol:


%%%Run the simulation
% Start real-time clock
RunTime=tic;
HelloPktTimer=tic;
DataPktTimer=tic;
% Main simulation loop
while toc(RunTime) < globalVariable.Simulation_Time
    % Run the appropriate function based on elapsed time
    if toc(HelloPktTimer) >= globalVariable.helloPktInterval
        % start(HelloPktTimer);  % Start hello packet function after 3 seconds
        nodes_container = nodes_container.broadcastHelloPacket();
        HelloPktTimer=tic;
    end
    if toc(DataPktTimer) >= globalVariable.TransmissionTimeInterval
        % start(DataPktTimer);  % Start data packet function after 1 second
        nodes_container = nodes_container.DataPacket();
        DataPktTimer=tic;
    end
   
    % Pause for a short time to avoid excessive CPU usage
    pause(0.1);
end
clear DataPktTimer
clear HelloPktTimer
toc(RunTime)
clear RunTime

if Show_Figure_Last==true
    %%Plot Nodes and show route table
    Plot_nodes_Paths(nodes_container.get_nodes_entries)
    Route_Table(nodes_container.get_nodes_entries)
end



%stats

totalTimeTaken=sum(nodes_container.get_E2Edealy());
nodes=nodes_container.get_nodes_entries;
totalReceivedPackets=0;
totalreceivedHelloPackets =0;
totalTransmittedPacket =0;
totalTransmittedHelloPacket =0;

for i = 1:globalVariable.numNodes
    totalReceivedPackets = totalReceivedPackets + nodes(i).ReceivedPackets;
    totalreceivedHelloPackets = totalReceivedPackets + nodes(i).ReceivedHelloPackets;
    totalTransmittedPacket = totalTransmittedPacket + nodes(i).TransmittedPacket;
    totalTransmittedHelloPacket = totalTransmittedHelloPacket + nodes(i).TransmittedHelloPackets;
end

% Data rate in bits per second
dataRate = 40 * 10^3; % 40 kbps in bps

avgNumOfBits=1024;
avgE2EDelay=totalTimeTaken/numel(nodes_container.get_E2Edealy());
avgThroughput=((totalReceivedPackets*avgNumOfBits)/totalTimeTaken)/1000;
avgPDRPKT=totalReceivedPackets/totalTransmittedPacket;
avgPDRHelloPKT=totalreceivedHelloPackets/totalTransmittedHelloPacket;

msg1 = ['Average End-to-End Delay: ' num2str(avgE2EDelay*1000)];
msg2 = ['Average Throughput: ' num2str(avgThroughput)];
msg3 = ['Average PDR Packets: ' num2str(avgPDRPKT)];
msg4 = ['Average PDR for Hello Packets: ' num2str(avgPDRHelloPKT)];
msg5 = ['Total Transmitted: ' num2str(totalTransmittedPacket) ' and Received Packets: ' num2str(totalReceivedPackets)];
msg6 = ['Total Transmitted hello Packets: ' num2str(totalTransmittedHelloPacket) ' and Received hello Packets: ' num2str(totalreceivedHelloPackets)];
msg7 = ['Total Time Taken: ' num2str(totalTimeTaken*1000)];
msgbox({msg1, msg2,msg3,msg4,msg5,msg6,msg7}, 'Simulation Results');



