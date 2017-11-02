function [params_max, loglike_max] = runModelFitJoint(modelType, subjectNumber)

% Fits the subject's responses jointly based on all conditions
% (single-cue and combined-cue) using maximum-likelihood estimation
% (MLE) as used in Dobs et al., 2007.
%
% Inputs
% modelType - 1 for optimal, 2 for best-cue, 3 for simple-average, 4 -
% model based on incorrect beliefs
% subjectNumber - the number of the subject to fit 
%
% Outputs
% params_max - the five paramaters obtained from fitting: standard
% deviations sigma_m (motion), sigma_f (form/old off) and sigma_f_old
% (form/old on), category boundary b and lapse rate lambda.
% loglike_max - the log likelihood of the fit
%
% Katharina Dobs - November 2017


% TODO: how to give fmincon parameters that should not be fitted?
% Workaround: global variable...
global subjectNo;
subjectNo = subjectNumber;
global model;
model = modelType;

% parameters for fmincon
opts=optimset('Algorithm','sqp','DerivativeCheck','off','TolX',1e-6,'TolFun',1e-6,...
  'Diagnostics','off','MaxIter', 200, 'LargeScale','off');

% fit MLE 10-times to find the global minimum
nFits = 10;


% choose some plausible start parameters (based on preliminary testing)
startParamsMean = [0.27 0.18 0.25 0.50 0.04]';
startParamsStd = [0.08 0.06 0.07 0.05 0.03]';
constraintsMin = [0 0 0 -10 0];
constraintsMax = [10 10 10 10 1];

nParams = length(startParamsMean);

params = zeros(nFits,nParams);

% draw start parameters
for iParam = 1:nParams
    params(:,iParam) = startParamsStd(iParam).*randn(nFits,1) + startParamsMean(iParam);
    % make sure that no starting param is smaller 0
    while sum(params(:,iParam)<constraintsMin(iParam))>0
        params(:,iParam) = startParamsStd(iParam).*randn(nFits,1) + startParamsMean(iParam);
    end
end

% will be overwritten with the first fit
params_max = zeros(nParams,1);
loglike_max = 0;
    
% fit n-times
for iFit = 1:nFits
    
    % restrict params
    [params_fit,loglike_fit,~]=fmincon('getLogLikelihood',params(iFit,:),[],[],[],[],constraintsMin,constraintsMax,[],opts);
    
    if (iFit == 1)
        params_max = params_fit;
        loglike_max = loglike_fit;
    end
        
    if (loglike_fit < loglike_max)
        fprintf('A new global max found: %.2f, the old one was: %.2f\n',loglike_fit,loglike_max);
        loglike_max = loglike_fit;
        params_max = params_fit;
    end
    
end