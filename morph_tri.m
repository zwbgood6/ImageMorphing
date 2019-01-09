function [morphed_im] = morph_tri(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
%MORPH_TRI Image morphing via Triangulation
%	Input im1: source image
%	Input im2: target image
%	Input im1_pts: correspondences coordinates in the source image
%	Input im2_pts: correspondences coordinates in the target image
%	Input warp_frac: a vector contains warping parameters
%	Input dissolve_frac: a vector contains cross dissolve parameters
% 
%	Output morphed_im: a set of morphed images obtained from different warp and dissolve parameters
% Helpful functions: delaunay, tsearchn

% Wenbo Zhang | University of Pennsylvania

% Check whether the number of control points in both images the same
assert(size(im1_pts, 1) == size(im2_pts, 1),...
    'Control points in two images are not in the same amount! Please do it again.');

%% Initialize
M = length(warp_frac);
tri = delaunay(0.5 * im1_pts + 0.5 * im2_pts);
tri_num = size(tri,1); % Number of triangles
nr = size(im1,1);
nc = size(im1,2);
im1_warp = zeros(size(im1));
im2_warp = zeros(size(im2));
imwarp_pts = zeros(size(im1_pts));
morphed_im = cell(1,M);
[im1_x ,im1_y] = meshgrid(1:nc, 1:nr);

%% Trianglarization
% Loop for each triangle to calculate the transform matrix
for i = 1:M
imwarp_pts = (1 - warp_frac(i)) * im1_pts + warp_frac(i) * im2_pts;
tri = delaunay(imwarp_pts);
[tri_idx, P] = tsearchn(imwarp_pts, tri, [im1_x(:) im1_y(:)]);
% Loop for each pixel
    for p = 1:nr*nc
        abc = tri(tri_idx(p),:);
        a = abc(1);
        b = abc(2);
        c = abc(3);
        
        %image1
        im1_ax = im1_pts(a,1);
        im1_ay = im1_pts(a,2);
        im1_bx = im1_pts(b,1);
        im1_by = im1_pts(b,2);
        im1_cx = im1_pts(c,1);
        im1_cy = im1_pts(c,2);
        baryCoord = [im1_ax im1_bx im1_cx;
                     im1_ay im1_by im1_cy;
                      1  1  1];
        result = baryCoord*P(p,:)';
        result1_x = result(1)/result(3);
        result1_y = result(2)/result(3);
       
        %image2
        im2_ax = im2_pts(a,1);
        im2_ay = im2_pts(a,2);
        im2_bx = im2_pts(b,1);
        im2_by = im2_pts(b,2);
        im2_cx = im2_pts(c,1);
        im2_cy = im2_pts(c,2);
        baryCoord = [im2_ax im2_bx im2_cx;
                     im2_ay im2_by im2_cy;
                      1  1  1];
        result = baryCoord*P(p,:)';
        result2_x = result(1)/result(3);
        result2_y = result(2)/result(3);
% Test the size, if its more than the size of image  
        if result1_x > nc
            result1_x = nc; 
        end
        
        if result2_x > nc
            result2_x = nc; 
        end
        
        if result1_y > nr
            result1_y = nr; 
        end
        
        if result2_y > nr
            result2_y = nr; 
        end
        
        ind_y = mod(p,nr);
        if ind_y == 0
            ind_y = nr;
        end
        ind_x = (p-ind_y)/nr+1;
% Warp the image        
        im1_warp(ind_y,ind_x,:) = im1(ceil(result1_y),ceil(result1_x),:);  
        im2_warp(ind_y,ind_x,:) = im2(ceil(result2_y),ceil(result2_x),:);      
    end
% Dissolve the image
    morphed_im{i} = uint8( (1-dissolve_frac(i)) * im1_warp + dissolve_frac(i) * im2_warp );
end






