% clear workspace
clc;
clear;

% read two images
im1 = imread('myImg.jpg');
im2 = imread('Donald_Trump_official_portrait.jpg');

% Resize images at the smallest extent if they are not in the same size
[nr1, nc1, ~] = size(im1);
[nr2, nc2, ~] = size(im2);
nr = min(nr1, nr2);
nc = min(nc1, nc2);
im1 = imresize(im1, [nr nc]);
im2 = imresize(im2, [nr nc]);

% select control points
[im1_pts, im2_pts] = click_correspondences(im1, im2);

% Set up video file
v = VideoWriter('face_morph.avi', 'Motion JPEG AVI');

% Open video
open(v);

% Initial the frame number
i = 0:1/60:1;
warp_frac = i;
dissolve_frac = i;

% Morph images
morphed_im = morph_tri(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac);

% Write the frame into video
for j = 1:61 
    writeVideo(v,im2double(morphed_im{j}));
end

% Close the video
close(v);