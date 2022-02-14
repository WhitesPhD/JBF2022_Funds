function [mxBSAlpha, mxBSAlphaTstat, mxBSBetas, mxBSBetasTstat] = fnc_bootstrap_independ(vecY,mxX,id,time,b)

% This function implements a bootstrap with independent resampling of residuals and explanatory returns
% vecY is the (N x 1) vector of returns for n cryptocurrency funds
% mxX  is the (N x m) matrix of returns for m passive benchmarks (factors) 
% id   is the (N x 1) vector of individual fund id's
% time is the (N x 1) vector of time index
% b    is the number of bootstrap iterations
% mxBSAlpha      is (b x n) matrix of alphas for n cryptocurrency funds across b bootstrap simulations
% mxBSAlphaTstat is (b x n) matrix of t-statistics for n cryptocurrency funds across b bootstrap simulations
% mxBSBetas      is (b x m) matrix of loadings for m passive benchmarks (factors) across b bootstrap simulations
% mxBSBetasTstat is (b x m) matrix of t-statistics for m passive benchmarks (factors) across b bootstrap simulations

fe_boost                    = panel(id,time,vecY,mxX,'fe');

resY                        = fe_boost.res;
resYResample                = zeros(size(resY));

n                           = size(vecY,1);
mxYNoAlphaResample          = zeros(n,b);
mxXResample                 = zeros(n,size(mxX,2),b);   % three dimensional matrix
mxIndex                     = zeros(n,b);               % store index vector indicating which values have been sampled from data.

% Resample data b times with replacement - sample manager returns and corresponding factor returns

for i = 1:b
    for ifund = 1:1:max(id)
        [resYResample(id==ifund,i),mxIndex(id==ifund,i)]    = datasample(resY(id==ifund),length(resY(id==ifund)));
        
        [mxX_temp,mxIndexNew]           = datasample(mxX(id==ifund,:),max(time));
        mxXResample(id==ifund,:,i)      = mxX_temp(time(id==ifund),:);
        mxYNoAlphaResample(id==ifund,i) = mxXResample(id==ifund,:,i) * fe_boost.coef + resYResample(id==ifund,i);
    end
end

% Compute alpha distribution under assumption of no alpha

mxBSAlpha      = zeros(b,length(unique(id)));       % Alpha estimates
mxBSBetas      = zeros(b,size(mxX,2));              % Beta estimates

mxBSAlphaTstat = zeros(b,length(unique(id)));       % Alpha stat
mxBSBetasTstat = zeros(b,size(mxX,2));              % Beta tsta

for i = 1:b
     
    display(['Iteration number ', num2str(i)])

    fe_boost            = panel(id,time,mxYNoAlphaResample(:,i),squeeze(mxXResample(:,:,i)),'fe');
    [ieff, se, t, p]    = ieffects( fe_boost );

	mxBSAlpha(i,:)      = ieff;
    mxBSAlphaTstat(i,:) = t;
    mxBSBetas(i,:)      = fe_boost.coef';
    mxBSBetasTstat(i,:) = fe_boost.coef'./fe_boost.stderr';

end

end

