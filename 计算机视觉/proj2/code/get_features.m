% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% Returns a set of feature descriptors for a given set of interest points. 

% 'image' can be grayscale or color, your choice.
% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
%   The local features should be centered at x and y.
% 'feature_width', in pixels, is the local feature width. You can assume
%   that feature_width will be a multiple of 4 (i.e. every cell of your
%   local SIFT-like feature will have an integer width and height).
% If you want to detect and describe features at multiple scales or
% particular orientations you can add input arguments.

% 'features' is the array of computed features. It should have the
%   following size: [length(x) x feature dimensionality] (e.g. 128 for
%   standard SIFT)

function [features] = get_features(image, x, y, feature_width)

% To start with, you might want to simply use normalized patches as your
% local feature. This is very simple to code and works OK. However, to get
% full credit you will need to implement the more effective SIFT descriptor
% (See Szeliski 4.1.2 or the original publications at
% http://www.cs.ubc.ca/~lowe/keypoints/)

% Your implementation does not need to exactly match the SIFT reference.
% Here are the key properties your (baseline) descriptor should have:
%  (1) a 4x4 grid of cells, each feature_width/4.
%  (2) each cell should have a histogram of the local distribution of
%    gradients in 8 orientations. Appending these histograms together will
%    give you 4x4 x 8 = 128 dimensions.
%  (3) Each feature should be normalized to unit length
%
% You do not need to perform the interpolation in which each gradient
% measurement contributes to multiple orientation bins in multiple cells
% As described in Szeliski, a single gradient measurement creates a
% weighted contribution to the 4 nearest cells and the 2 nearest
% orientation bins within each cell, for 8 total contributions. This type
% of interpolation probably will help, though.

% You do not have to explicitly compute the gradient orientation at each
% pixel (although you are free to do so). You can instead filter with
% oriented filters (e.g. a filter that responds to edges with a specific
% orientation). All of your SIFT-like feature can be constructed entirely
% from filtering fairly quickly in this way.

% You do not need to do the normalize -> threshold -> normalize again
% operation as detailed in Szeliski and the SIFT paper. It can help, though.

% Another simple trick which can help is to raise each element of the final
% feature vector to some power that is less than one.

% Placeholder that you can delete. Empty features.
%%
y_gradient = imfilter(image,[-1,0,1]');
x_gradient=imfilter(image,[-1,0,1]);
features = zeros(length(x),128);
for k = 1:length(x)                         %window of 16x16 of each feature 
    x_subwindow = x(k)-7:x(k)+8;   
    y_subwindow = y(k)-7:y(k)+8;
    x_subwindow_gradient = x_gradient(y_subwindow,x_subwindow);
    y_subwindow_gradient = y_gradient(y_subwindow,x_subwindow);
    angles = atan2(y_subwindow_gradient,x_subwindow_gradient); 
   %for i = 1:16
       %for j = 1:16
          % if angles(i,j)<0
              % angles(i,j) = angles(i,j) + 2*pi;
           %end
       %end
   %end
   angles(angles<0) = angles(angles<0) + 2*pi;
   %angles_bin = [0 pi/4 pi/2 3*pi/4 pi 5*pi/4 3*pi/2 7*pi/4 2*pi];
   angles_binranges = 0:pi/4:2*pi;
   B = zeros(1,128);
   for i = 1:feature_width/4:feature_width
       for j = 1:feature_width/4:feature_width
          %A = reshape(angles(i:i+3,j:j+3)',1,16);
          subwindow = angles(i:i+3,j:j+3);
          angles_bincounts = histc(subwindow(:),angles_binranges);
          begin = 1 + 32*(floor(i/4)) + 8*(floor(j/4));  %tab the orientation of each 4x4 window
          B(begin:begin+7) = angles_bincounts(1:8);    %get the eight orientation of each window
          %figure;
          %bar(angles_binranges,angles_bincounts,'histc');
       end
   end
   %disp(length(B/norm(B)));
   features(k,:) = B/norm(B);
end
%cut the end
power = 0.8;
features = features.^power;
end

% %% 步骤5：特征向量生成
% orient_bin_spacing = pi/4;
% %分成8个角度
% orient_angles = [-pi:orient_bin_spacing:(pi-orient_bin_spacing)];
%  
% grid_spacing = 4;
% %分别生成x,y方向的梯度矩阵
% [x_coords y_coords] = meshgrid( [-6:grid_spacing:6] );
% feat_grid = [x_coords(:) y_coords(:)]';%两行16列矩阵
% [x_coords y_coords] = meshgrid( [-(2*grid_spacing-0.5):(2*grid_spacing-0.5)] );
% feat_samples = [x_coords(:) y_coords(:)]';
% feat_window = 2*grid_spacing;
%  
% desc = [];
%  
% for k = 1:size(pos,1)
%    x = pos(k,1)/subsample(scale(k,1));
%    y = pos(k,2)/subsample(scale(k,1));  
%     
%    % 将坐标轴旋转为关键点的方向，以确保旋转不变性
%    M = [cos(orient(k)) -sin(orient(k)); sin(orient(k)) cos(orient(k))];%旋转矩阵
%    feat_rot_grid = M*feat_grid + repmat([x; y],1,size(feat_grid,2));
%    feat_rot_samples = M*feat_samples + repmat([x; y],1,size(feat_samples,2));
%     
%    % 初始化特征向量.
%    feat_desc = zeros(1,128);
%     
%    for s = 1:size(feat_rot_samples,2)
%       x_sample = feat_rot_samples(1,s);
%       y_sample = feat_rot_samples(2,s);
%        
%       % 在采样位置进行梯度插值
%       [X Y] = meshgrid( (x_sample-1):(x_sample+1), (y_sample-1):(y_sample+1) );
%       G = interp2( gauss_pyr{scale(k,1),scale(k,2)}, X, Y, '*linear' );  % 耗时太长
%       G(find(isnan(G))) = 0;
%       diff_x = 0.5*(G(2,3) - G(2,1));
%       diff_y = 0.5*(G(3,2) - G(1,2));
%       mag_sample = sqrt( diff_x^2 + diff_y^2 );
%       grad_sample = atan2( diff_y, diff_x );
%       if grad_sample == pi
%          grad_sample = -pi;
%       end     
%        
%       % 计算x、y方向上的权重
%       x_wght = max(1 - (abs(feat_rot_grid(1,:) - x_sample)/grid_spacing), 0);
%       y_wght = max(1 - (abs(feat_rot_grid(2,:) - y_sample)/grid_spacing), 0);
%       pos_wght = reshape(repmat(x_wght.*y_wght,8,1),1,128);
%        
%       diff = mod( grad_sample - orient(k) - orient_angles + pi, 2*pi ) - pi;
%       orient_wght = max(1 - abs(diff)/orient_bin_spacing,0);
%       orient_wght = repmat(orient_wght,1,16);        
%        
%       % 计算高斯权重
%       g = exp(-((x_sample-x)^2+(y_sample-y)^2)/(2*feat_window^2))/(2*pi*feat_window^2);
%        
%       feat_desc = feat_desc + pos_wght.*orient_wght*g*mag_sample;
%    end
%     
%    % 将特征向量的长度归一化，则可以进一步去除光照变化的影响.
%    feat_desc = feat_desc / norm(feat_desc);
%     
%    feat_desc( find(feat_desc > 0.2) ) = 0.2;
%    feat_desc = feat_desc / norm(feat_desc);
%     
%    % 存储特征向量.
%    desc = [desc; feat_desc];
%    tmp = mod(k,25);
%    if ( tmp == 0 )
%       fprintf( 2, '.' );
%    end
% end
% 
% features = zeros(size(x,1), 128);



% end








