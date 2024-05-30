function featImgs = createFeatVols(featVecs,roi)

featImgs = nan(size(roi,1),size(roi,2),size(roi,3),length(featVecs));
for i = 1:length(featVecs)
    featImgs(:,:,:,i) = createFeatVol(featVecs{i},roi);
end
