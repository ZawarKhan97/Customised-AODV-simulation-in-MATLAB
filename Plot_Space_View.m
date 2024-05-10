function Plot_Space_View(nodes)
    % Create Nodes_Space_View figure
    Nodes_Space_View = figure;
    hold on;
    axis equal;
    title('Nodes Space View');

    % Plot nodes as black circles with IDs
    for i = 1:numel(nodes)
        plot(nodes(i).X, nodes(i).Y, 'ko', 'MarkerSize', 10);  % Black circle marker
        text(nodes(i).X, nodes(i).Y, num2str(nodes(i).ID), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
    xlabel('X Position');
    ylabel('Y Position');
    xlim([0, 100]);  % Set X-axis limits
    ylim([0, 100]);  % Set Y-axis limits
    grid on;

end