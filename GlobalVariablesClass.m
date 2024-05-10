classdef GlobalVariablesClass < handle
    properties
        threshold_Distance 
        Node_TTL
        numNodes
        Simulation_Time
        helloPktInterval
        TransmissionTimeInterval
                   
    end
    
    methods
        function obj = GlobalVariablesClass()
            % Ask the user for the number of nodes using an input dialog
            prompt = 'Enter the number of nodes:';
            dlgtitle = 'Number of Nodes';
            num_lines = 1;
            default_input = '5';  % Default value or initial input
            answer = inputdlg(prompt, dlgtitle, num_lines, {default_input});
            
            % Check if the user provided an input
            if ~isempty(answer)
                % Convert the input to uint8 and assign it to numNodes
                obj.numNodes = uint8(str2double(answer{1}));
            else
                % Use the default value if the user didn't provide input
                obj.numNodes = uint8(5);
            end
            
            obj.Node_TTL = uint8(4);  % 4 corresponds to 4 seconds
            obj.threshold_Distance = uint8(50);
            obj.Simulation_Time = uint8(40);
            obj.helloPktInterval = uint8(5);
            obj.TransmissionTimeInterval = uint8(2);
        end
    end
    
    methods (Static)
        function value = getThresholdDistanceValue()
            value = threshold_Distance;
        end
        function value = get_Node_TTL_Value()
            value = Node_TTL;
        end

        % function setValue1(newValue)
        %     global globalVars;
        %     globalVars.Variable1 = newValue;
        % end
    end
end
