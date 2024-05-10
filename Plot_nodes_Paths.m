function Plot_nodes_Paths(nodes)
    % Create Nodes_Space_View figure
    Nodes_Space_View = figure;
    hold on;
    axis equal;
    title('Nodes Space View');

    % Plot nodes as black circles with IDs
    for i = 1:numel(nodes)
        plot(nodes(i).X, nodes(i).Y, 'ko', 'MarkerSize', 10);  % Black circle marker
        text(nodes(i).X, nodes(i).Y, num2str(nodes(i).ID), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        
        % Check routing table for direct paths and plot lines
        routingTable = nodes(i).RoutingTable;
        for j = 1:numel(routingTable)
            destinationID = routingTable{j}.Destination;
            if routingTable{j}.NextHop == 0  % Direct path exists
                plot([nodes(i).X, nodes(destinationID).X], [nodes(i).Y, nodes(destinationID).Y], 'b-', 'LineWidth', 0.5);  % Straight line path
            end
        end
    end
    
    xlabel('X Position');
    ylabel('Y Position');
    xlim([0, 100]);  % Set X-axis limits
    ylim([0, 100]);  % Set Y-axis limits
    grid on;

end
