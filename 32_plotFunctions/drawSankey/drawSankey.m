function drawSankey(inputs, losses, unit, labels, varargin)

% drawSankey(inputs, losses, unit, labels, sep)
%
% drawSankey is a matlab function that draws single-direction Sankey
% diagrams (i.e no feedback loops), however, multiple inputs can be
% specified.
%
% inputs: a vector containing the  flow inputs, the first of which will be
%         considered the main input and drawn centrally, other inputs will
%         be shown below this.
%
% losses: a vector containing all of the losses from the system, which will 
%         be displayed along the top of the Sankey diagram
%
% unit:   a string indicating the unit in which the flows are expressed
%
% labels: a cell list of the labels for the different flows, starting with 
%         the labels for the inputs, then the losses and finally the output
%
% sep:    an (optional) list of position for separating lines, placed after
%         the loss corresponding to the indexes provided
%
% For an example, copy and paste the lines below to the command line:
%
%   inputs = [75 32]; losses = [10 5 2.8]; unit = 'MW'; sep = [1,3];
%   labels = {'Main Input','Aux Input','Losses I','Losses II','Losses III','Output'};
%
%   drawSankey(inputs, losses, unit, labels, sep);
%
% Current Version:  02.11.2009
% Developped by:    James SPELLING, KTH-EGI-EKV
%                   spelling@kth.se
%
% Distributed under Creative Commons Attribution + NonCommerical (by-nc)
% Licensees may copy, distribute, display, and perform the work and make
% derivative works based on it only for noncommercial purposes

%check parameter values%
if sum(losses) >= sum(inputs)
    
    %report unbalanced inputs and losses%
    error('drawSankey: losses exceed inputs, unable to draw diagram');
    
elseif any(losses < 0) || any(inputs < 0)
    
    %report negative inputs and/or losses%
    error('drawSankey: negative inputs or losses encountered');
    
else
    
    %check for the existance of separating lines%
    if nargin > 4; sep = varargin{1}; end
    
    %create plotting window%
    figure('color','white','tag','sankeyDiagram');
    
    %if possible, maximise figure%
    if exist('maximize','file')
        maximize(gcf);
    end
    
    %create plotting axis then hide it%
    axes('position',[0.1 0 0.8 0.85]); axis off;
    
    %calculate fractional losses and inputs%
    frLosses = losses/sum(inputs);
    frInputs = inputs/sum(inputs);
    
    if length(inputs(inputs > eps)) == 1
        
        %assemble first input label if only one input%
        inputLabel = sprintf('%s\n%.1f [%s]', labels{1}, inputs(1), unit);
    
    else
        
        %assemble first input label if only several inputs%
        inputLabel = sprintf('%s\n%.1f [%s] %.1f [%%]', labels{1}, inputs(1), unit, 100*frInputs(1));
    
    end
    
    %determine first input label font size%
    fontsize = min(16, 10 + ceil((frInputs(1)-0.05)/0.025));
    
    %draw first input label to plotting window%
    text(0, frInputs(1)/2, inputLabel, 'FontSize', fontsize,'HorizontalAlignment','right','Rotation',0);
    
    %draw back edge of first input arrow%
    line([0.1 0 0.05 0 0.4], [0 0 frInputs(1)/2 frInputs(1) frInputs(1)], 'Color', 'black', 'LineWidth', 2.5);
    
    %set inital position for the top of the arrows%
    limTop = frInputs(1); posTop = 0.4;
    
    %set inital position for the bottom of the arrows%
    limBot = 0; posBot = 0.1;
    
    %draw arrows for additional inputs%
    for j = 2 : length(inputs)
        
        %don't draw negligable inputs%
        if frInputs(j) > eps
            
            %determine inner and outer arrow radii%
            rI = max(0.07, abs(frInputs(j)/2));
            rE = rI + abs(frInputs(j));
            
            %push separation point forwards%
            newPosB = posBot + rE*sin(pi/4) + 0.01;
            line([posBot newPosB], [limBot limBot], 'Color', 'black', 'LineWidth', 2.5);
            posBot = newPosB;
            
            %determine points on the external arc%
            arcEx = posBot - rE*sin(linspace(0,pi/4));
            arcEy = limBot - rE*(1 - cos(linspace(0,pi/4)));
            
            %determine points on the internal arc%
            arcIx = posBot - rI*sin(linspace(0,pi/4));
            arcIy = limBot - rE + rI*cos(linspace(0,pi/4));
            
            %draw internal and external arcs%
            line(arcIx, arcIy, 'Color', 'black', 'LineWidth', 2.5);
            line(arcEx, arcEy, 'Color', 'black', 'LineWidth', 2.5);
            
            %determine arrow point tip%
            phiTip = pi/4 - 2*min(0.05, 0.8*abs(frInputs(j)))/(rI + rE);
            xTip = posBot - (rE+rI)*sin(phiTip)/2;
            yTip = limBot - rE + (rE+rI)*cos(phiTip)/2;
            
            %draw back edge of additional input arrows%
            line([min(arcEx) xTip min(arcIx)], [min(arcEy) yTip min(arcIy)], 'Color', 'black', 'LineWidth', 2.5);
            
            %determine text edge location%
            phiText = pi/2 - 2*min(0.05, 0.8*abs(frInputs(j)))/(rI + rE);
            xText = posBot - (rE+rI)*sin(phiText)/2;
            yText = limBot - rE + (rE+rI)*cos(phiText)/2;
            
            %determine label size based on importance%
            if frInputs(j) > 0.1
                
                %large inputs text size scales slower%
                fullLabel = sprintf('%s\n%.1f [%s] %.1f [%%]', labels{j}, inputs(j), unit, 100*frInputs(j));
                fontsize = 12 + round((frInputs(j)-0.01)/0.05);
            
            elseif frInputs(j) > 0.05
            
                %smaller but more rapidly scaling losses%
                fullLabel = sprintf('%s: %.1f [%s] %.1f [%%]', labels{j}, inputs(j), unit, 100*frInputs(j));
                fontsize = 10 + ceil((frInputs(j)-0.05)/0.025);
            
            else
            
                %minimum text size for input label%
                fullLabel = sprintf('%s: %.1f [%s] %.1f [%%]',labels{j}, inputs(j), unit, 100*frInputs(j));
                fontsize = 10;
            
            end
            
            %draw input label%
            text(xText, yText, fullLabel, 'FontSize', min(16, fontsize),'HorizontalAlignment','right');
            
            %save new bottom end of arrow%
            limBot = limBot - frInputs(j);
            
        end
        
    end
    
    %draw arrows of losses%
    for i = 1 : length(losses)
        
        %don't draw negligable losses%
        if frLosses(i) > eps
            
            %determine inner and outer arrow radii%
            rI = max(0.07, abs(frLosses(i)/2));
            rE = rI + abs(frLosses(i));
            
            %determine points on the internal arc%
            arcIx = posTop + rI*sin(linspace(0,pi/2));
            arcIy = limTop + rI*(1 - cos(linspace(0,pi/2)));
            
            %determine points on the external arc%
            arcEx = posTop + rE*sin(linspace(0,pi/2));
            arcEy = (limTop + rI) - rE*cos(linspace(0,pi/2));
            
            %draw internal and external arcs%
            line(arcIx, arcIy, 'Color', 'black', 'LineWidth', 2.5);
            line(arcEx, arcEy, 'Color', 'black', 'LineWidth', 2.5);
            
            %determine arrow tip dimensions%
            arEdge = max(0.015, rI/3);
            arTop  = max(0.04, 0.8*frLosses(i));
            
            %determine points on arrow tip%
            arX = posTop + rI + [0 -arEdge frLosses(i)/2 frLosses(i)+ arEdge frLosses(i)];
            arY = limTop + rI + [0 0 arTop 0 0];
            
            %draw tip of losses arrow%
            line(arX, arY, 'Color', 'black', 'LineWidth', 2.5);
            
            %determine text edge location%
            txtX = posTop + rI + frLosses(i)/2;
            txtY = limTop + rI + arTop + 0.05;
            
            %determine label size based on importance%
            if frLosses(i) > 0.1
                
                %large losses have the space for a two line label%
                fullLabel = sprintf('%s\n%.1f [%%]',labels{i+length(inputs)}, 100*frLosses(i));
                fontsize = 12 + round((frLosses(i)-0.01)/0.05);
                
            elseif frLosses(i) > 0.05
            
                %single line, but still scaling label%
                fullLabel = sprintf('%s: %.1f [%%]',labels{i+length(inputs)}, 100*frLosses(i));
                fontsize = 10 + ceil((frLosses(i)-0.05)/0.025);
            
            else
            
                %minimum siye single line label%
                fullLabel = sprintf('%s: %.1f [%%]',labels{i+length(inputs)}, 100*frLosses(i));
                fontsize = 10;
            
            end
            
            %draw losses label%
            text(txtX, txtY, fullLabel, 'Rotation', 90, 'FontSize', fontsize);
            
            %save new position of arrow top%
            limTop = limTop - frLosses(i);
            
            %advance to new separation point%
            newPos = posTop + rE + 0.01;
            
            %draw top line to new separation point%
            line([posTop newPos], [limTop limTop], 'Color', 'black', 'LineWidth', 2.5);
            
            %save new advancement point%
            posTop = newPos;
            
        end
        
        %separation lines%
        if any(i == sep)
            
            if length(inputs) > 1 && any(inputs(2 : length(inputs)) > eps)
                
                %if there are additional inputs, determine approx. sep. line%
                xLeft = 0.1*posTop;
            
            else
            
                %otherwise determine exact sep. line%
                xLeft = 0.05 * (1 - 2*abs(limTop - 0.5));
            
            end
            
            %draw the line%
            line([xLeft posTop], [limTop limTop], 'Color', 'black', 'LineWidth', 2, 'LineStyle','--');
            
        end
        
    end
    
    %push the arrow forwards a little after all side-arrows drawn%
    newPos = max(posTop, posBot) + max(0.05*limTop, 0.05);
    
    %draw lines to this new position%
    line([posTop, newPos],[limTop limTop], 'Color', 'black', 'LineWidth', 2.5);
    line([posBot, newPos],[limBot limBot], 'Color', 'black', 'LineWidth', 2.5);
    
    %draw final arrowhead for the output%
    line([newPos newPos newPos+max(0.04, 0.8*(limTop-limBot)) newPos newPos], [limBot, limBot - max(0.015, (limTop+limBot)/3), (limTop+limBot)/2, limTop + max(0.015, (limTop+limBot)/3), limTop], 'Color', 'black', 'LineWidth', 2.5);
    
    %save final tip position%
    newPos = newPos + 0.8*(limTop - limBot);
    
    %determine overall ins and outs%
    outputFinal = sum(inputs) - sum(losses);
    inputFinal = sum(inputs);

    %create the label for the overall output arrow%
%     endText = sprintf('%s\n%.0f [%s] %.1f [%%]',labels{length(losses)+length(inputs)+1}, outputFinal, unit,100*outputFinal/inputFinal);
%     endText = sprintf('%s\n%.0f [%s] %.1f [%%]',labels{length(losses)+length(inputs)+1}, outputFinal, unit,100*outputFinal/inputFinal);
    endText = sprintf('%s\n%.1f [%s] %.1f [%%]',labels{length(losses)+length(inputs)+1}, 100*outputFinal/inputFinal, unit);
    fontsize = min(16, 10 + ceil((1-sum(frLosses)-0.1)/0.05));
    
    %draw text for the overall output arrow%
    text(newPos + 0.05, (limTop+limBot)/2, endText, 'FontSize', fontsize);
    
    %set correct aspect ratio%
    axis equal;
    
    %set correct axis limits%
    set(gca,'YLim',[frInputs(1)-sum(frInputs)-0.4, frInputs(1)+frLosses(1)+0.4]);
    set(gca,'XLim',[-0.15, newPos + 0.1]);
       
end

