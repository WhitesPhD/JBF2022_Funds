function [mxBSAlpha, mxBSAlphaTstat, mxBSBetas, mxBSBetasTstat] = fnc_bootstrap_block(vecY,mxX,id,time,b,block_size)

% This function implements a block bootstrap specification
% vecY is the (N x 1) vector of returns for n cryptocurrency funds
% mxX  is the (N x m) matrix of returns for m passive benchmarks (factors) 
% id   is the (N x 1) vector of individual fund id's
% time is the (N x 1) vector of time index
% b    is the number of bootstrap iterations
% mxBSAlpha      is (b x n) matrix of alphas for n cryptocurrency funds across b bootstrap simulations
% mxBSAlphaTstat is (b x n) matrix of t-statistics for n cryptocurrency funds across b bootstrap simulations
% mxBSBetas      is (b x m) matrix of loadings for m passive benchmarks (factors) across b bootstrap simulations
% mxBSBetasTstat is (b x m) matrix of t-statistics for m passive benchmarks (factors) across b bootstrap simulations
% block_size is the size of the block

fe_boost                    = panel(id,time,vecY,mxX,'fe');

resY                        = fe_boost.res;

mxBSAlpha      = zeros(b,length(unique(id)));   % Alpha estimates
mxBSBetas      = zeros(b,size(mxX,2));          % Beta estimates

mxBSAlphaTstat = zeros(b,length(unique(id)));   % Alpha stat
mxBSBetasTstat = zeros(b,size(mxX,2));          % Beta tsta

for i = 1:b
    
    display(['Iteration number ', num2str(i)])
    
    idResample          = [];
    timeResample        = [];
    mxXResample         = [];
    mxYNoAlphaResample  = [];
    
    for ifund = 1:1:max(id)

        start_block     = [1:block_size:length(resY(id==ifund))];
        end_block       = start_block+2;
        end_block(end)  = length(resY(id==ifund));
        N_block         = length(start_block);
        
        mxX_ifund       = mxX(id==ifund,:);
        resY_ifund      = resY(id==ifund,:);

        [y_sample,index_block]      = datasample([1:1:N_block]',N_block);
        mxX_temp        = [];
        mxY_temp        = [];
        
        for iblock = 1:N_block
            mxX_temp        = [mxX_temp; mxX_ifund(start_block(index_block(iblock)):end_block(index_block(iblock)),:)];
            mxY_temp        = [mxY_temp; mxX_ifund(start_block(index_block(iblock)):end_block(index_block(iblock)),:) * fe_boost.coef + resY_ifund(start_block(index_block(iblock)):end_block(index_block(iblock)),:)];
        end
        
        idResample          = [idResample; ones(size(mxY_temp)) * ifund];
        timeResample        = [timeResample; ones(size(mxY_temp)) .* [1:length(mxY_temp)]'];
        mxYNoAlphaResample	= [mxYNoAlphaResample; mxY_temp];
        mxXResample         = [mxXResample; mxX_temp];
    end
    
    fe_boost            = panel(idResample,timeResample,mxYNoAlphaResample,mxXResample,'fe');
    [ieff, se, t, p]    = ieffects( fe_boost );

	mxBSAlpha(i,:)      = ieff;
    mxBSBetas(i,:)      = fe_boost.coef';
    mxBSAlphaTstat(i,:) = t;
    mxBSBetasTstat(i,:) = fe_boost.coef'./fe_boost.stderr';
    
end

end
