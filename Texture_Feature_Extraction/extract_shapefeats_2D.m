function feature_matrix = exact_shapefeats_2D(vol)
    
    feature_matrix = [];
    for j=1:size(vol.img,3)
        slice = uint8(vol.img(:,:,j));
        if max(max(slice))~=0
            BW = imbinarize(slice);
            BW = bwconncomp(BW);
            sf = regionprops(BW,'all');
            if size(sf,1)>1
               area_regions = cat(1,sf.Area);
               [~, ind] = sort(area_regions,'descend');
               sf = sf(ind(1));
            end
            area = sf.Area;
            majorAxis = sf.MajorAxisLength;
            minorAxis = sf.MinorAxisLength;
            eccentricity = sf.Eccentricity;
            elongation = minorAxis/majorAxis;
            orientation = sf.Orientation;
            perimeter = sf.Perimeter;
            convexPerimeter = regionprops(sf.ConvexImage,'perimeter');
            roundness = (4*pi*area)/(convexPerimeter.Perimeter*convexPerimeter.Perimeter);
            equivDiameter = sf.EquivDiameter;
            compactness = (4*pi*area)/(perimeter*perimeter);
            convexArea = sf.ConvexArea;
            solidity = sf.Solidity;
            convexity = convexPerimeter.Perimeter/perimeter;
            extent = sf.Extent;
            bbArea = sf.BoundingBox(1,3)*sf.BoundingBox(1,4);
            bbElongation = min(sf.BoundingBox(1,3),sf.BoundingBox(1,4))/max(sf.BoundingBox(1,3),sf.BoundingBox(1,4));
            filledArea = sf.FilledArea;
            
            feature_vector = [area majorAxis minorAxis eccentricity elongation orientation perimeter ...
                roundness equivDiameter compactness convexArea convexPerimeter.Perimeter solidity convexity ...
                extent bbArea bbElongation filledArea];
            feature_matrix = [feature_matrix ; feature_vector];
        else
            % In case there is no region, add a row of zeros
            feature_matrix = [feature_matrix ; zeros(1,18)]; 
        end
    end