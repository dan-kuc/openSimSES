function [avgCRate, DOC] = calcCRateDOC(ees)
    cycleStart  = unique(ees.agingStress.lastCycle);
    cycleStart  = cycleStart(cycleStart ~= 0);
    cycleEnd	= [cycleStart(2:end), ees.kNow-1];

    avgCRate    = ees.agingStress.avgCRate(cycleEnd);
    DOC         = (ees.agingStress.maxSOC(cycleEnd) - ees.agingStress.minSOC(cycleEnd)) .* sign(avgCRate);
end
