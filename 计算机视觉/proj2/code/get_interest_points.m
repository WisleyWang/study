% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% Returns a set of interest points for the input image

% 'image' can be grayscale or color, your choice.
% 'feature_width', in pixels, is the local feature width. It might be
%   useful in this function in order to (a) suppress boundary interest
%   points (where a feature wouldn't fit entirely in the image, anyway)
%   or(b) scale the image filters being used. Or you can ignore it.

% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
% 'confidence' is an nx1 vector indicating the strength of the interest
%   point. You might use this later or not.
% 'scale' and 'orientation' are nx1 vectors indicating the scale and
%   orientation of each interest point. These are OPTIONAL. By default you
%   do not need to make scale and orientation invariant local features.
function [x, y, confidence, scale, orientation] = get_interest_points(image, feature_width)

% Implement the Harris corner detector (See Szeliski 4.1.1) to start with.
% You can create additional interest point detector functions (e.g. MSER)
% for extra credit.

% If you're finding spurious interest point detections near the boundaries,
% it is safe to simply suppress the gradients / corners near the edges of
% the image.

% The lecture slides and textbook are a bit vague on how to do the
% non-maximum suppression once you've thresholded the cornerness score.
% You are free to experiment. Here are some helpful functions:
%  BWLABEL and the newer BWCONNCOMP will find connected components in 
% thresholded binary image. You could, for instance, take the maximum value
% within each component.
%  COLFILT can be used to run a max() operator on each sliding window. You
% could use this to ensure that every interest point is at a local maximum
% of cornerness.

% Placeholder that you can delete. 20 random points

%function:
%       Harris角点检测
%注意：
%       matlab自带的corner函数即可实现harris角点检测。但考虑到harris角点的经典性，本程序将其实现，纯粹出于学习目的，了解特征点检测的方法。
%       其中所有参数均与matlab默认保持一致
%referrence：
%      Chris Harris & Mike Stephens，A COMBINED CORNER AND EDGE DETECTOR
%date:2015-1-11
%author:chenyanan
%转载请注明出处：http://blog.csdn.net/u010278305

%清空变量，读取图像
clear;close all

%计算X方向和Y方向的梯度及其平方
X=imfilter(image,[-1 0 1]);
X2=X.^2;
Y=imfilter(image,[-1 0 1]');
Y2=Y.^2;
XY=X.*Y;

%生成高斯卷积核，对X2、Y2、XY进行平滑
h=fspecial('gaussian',[5 1],1.5);
w=h*h';
A=imfilter(X2,w);
B=imfilter(Y2,w);
C=imfilter(XY,w);

%k一般取值0.04-0.06
k=0.04;
RMax=0;
size=size(image);
height=size(1);
width=size(2);
R=zeros(height,width);
for h=1:height
    for w=1:width
        %计算M矩阵
        M=[A(h,w) C(h,w);C(h,w) B(h,w)];
        %计算R用于判断是否是边缘
        R(h,w)=det(M) - k*(trace(M))^2;
        %获得R的最大值，之后用于确定判断角点的阈值
        if(R(h,w)>RMax)
            RMax=R(h,w);
        end
    end
end

%用Q*RMax作为阈值，判断一个点是不是角点
Q=0.01;
R_corner=(R>=(Q*RMax)).*R;

%寻找3x3邻域内的最大值，只有一个交点在8邻域内是该邻域的最大点时，才认为该点是角点
fun = @(x) max(x(:)); 
%对R中[3,3]区域寻找最大值
R_localMax = nlfilter(R,[feature_width feature_width],fun); 

%寻找既满足角点阈值，又在其8邻域内是最大值点的点作为角点
%注意：需要剔除边缘点
[y,x]=find(R_localMax(2:height-1,2:width-1)==R_corner(2:height-1,2:width-1));





end

