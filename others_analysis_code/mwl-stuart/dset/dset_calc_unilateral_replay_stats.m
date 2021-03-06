function [stats, replay] = dset_calc_unilateral_replay_stats(d)

[lIdx,  rIdx, ~] = dset_calc_cl_idx(d);

smoothPdf = 1;

[stats{1}, replay{1} ] = dset_calc_replay_stats(d, lIdx, [],[],smoothPdf);
[stats{2}, replay{2} ] = dset_calc_replay_stats(d, rIdx, [],[],smoothPdf);

if sum(lIdx) > sum(rIdx)
    slope = stats{1}.slope;
    intercept = stats{1}.intercept;
else
    slope = stats{2}.slope;
    intercept = stats{2}.intercept;
end

[stats{3}, replay{3} ] = dset_calc_replay_stats(d, lIdx|rIdx, slope, intercept, smoothPdf);

labels = {'left', 'right', 'bilateral'};

end
