function [loglike_max] = getLogLikelihood(params)

% TODO: how to take parameters that should not be fitted? Workaround:
% global variable...
global subjectNo;
global model;


% the single-cue standard deviations
sigma_m = params(1);
sigma_f = params(2);
sigma_f_old = params(3);
% the mean over all combined conditions
b = params(4);
% lapse rate
lapseRate = params(5);

% the "old" variable
c = 0.35;
 
% load the subject's behavioral results
load(sprintf('behavioral_data/FaceCueInt_%.2d.mat',subjectNo));


% subject's choices (1 = Laura, 2 = Susan)
resp = results.resp;
% the conditions
% 1 = form-only, 2 = motion-only
% 3 = combined, delta 0
% 4 = combined, delta -0.15
% 5 = combined, delta +0.15
cond = results.cond;
nCond = 5;
% old on (1) or off (0)
old = results.old;
% the morph level from 1:11
morphlevel = results.morphlevel;

% morphlevels differ for congruent and incongruent conditions
% incongruent:
morphlevels_incong = [0.1 0.2 0.3 0.4 0.45 0.5 0.55 0.6 0.7 0.8 0.9];
% congruent:
morphlevels_cong = [0 0.2 0.3 0.4 0.45 0.5 0.55 0.6 0.7 0.8 1.0];
% the conflict size
delta = 0.15;
% old factor is either 0 or the "old" variable
condOld = [0 c];


loglike = zeros(1,2);

for iCond = 1:nCond
    % for single-cues and combined-congruent, set the morph levels of the
    % congruent condition
    if (iCond < 4)
        morphlevels = morphlevels_cong;
    % combined-incongruent conditions
    else
        morphlevels = morphlevels_incong;
    end
    
    % old off and on
    for oldOn = 0:1
        
        skipFit = 0;
        
        sigm = sigma_m;
        
        if (oldOn == 0)
            sigf = sigma_f;
        else
            sigf = sigma_f_old;
        end
        
        % motion-only and old off
        if (iCond == 2 && oldOn == 0)
            % set sigf to 0
            sigf = 0;
        % motion-only and old on, skip (already included in motion-only)
        elseif (iCond == 2 && oldOn == 1)
            skipFit = 1;
        else
            % form-only: set sigm to 0
            if (iCond == 1)
                sigm = 0;
            end
        end
            
        % all morph levels
        for iMorphlevel = 1:length(morphlevels)
            % motion-only, fit across old on and off
            if (iCond == 2 && oldOn == 0)
                indx = find((cond == iCond) & (morphlevel == iMorphlevel));
            else
                indx = find((old == oldOn) & (cond == iCond) & (morphlevel == iMorphlevel));
            end
            if (~skipFit)
                nRespSusan = length(find(resp(indx)==2));
                nRespLaura = length(find(resp(indx)==1));
                % delta = 0
                if (iCond < 4)
                    s_m = morphlevels(iMorphlevel);
                    s_f = morphlevels(iMorphlevel);
                % - delta (motion > form)
                elseif (iCond == 4)
                    s_m = morphlevels(iMorphlevel)+delta/2;
                    s_f = morphlevels(iMorphlevel)-delta/2;
                % + delta (form > motion)
                else
                    s_m = morphlevels(iMorphlevel)-delta/2;
                    s_f = morphlevels(iMorphlevel)+delta/2;
                end

                p = getProbReportSusan([s_m s_f], condOld(oldOn+1), [sigm sigf], b, model);
                
                % introduce lapse rate
                pSusan = 0.5*lapseRate+p*(1-lapseRate);
                pLaura = 0.5*lapseRate+(1-p)*(1-lapseRate);

                loglike(1) = loglike(1) + log(pSusan)*nRespSusan;
                loglike(2) = loglike(2) + log(pLaura)*nRespLaura;
            end
        end
    end
end

% for fmincon return the negative log likelihood
loglike_max = -sum(loglike);

end


