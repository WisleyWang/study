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
%转载请注明出处：http://blog.csdn.net/u010278305

% 
% 
% %计算X方向和Y方向的梯度及其平方
% %fx=[-1,0,1;-2,0,2;-1,0,1]
% %fy=[-1,-2,-1;0,0,0;1,2,1]
% X=imfilter(image,[-1 0 1]);
% X2=X.^2;
% Y=imfilter(image,[-1 0 1]');
% Y2=Y.^2;
% XY=X.*Y;
% 
% %生成高斯卷积核，对X2、Y2、XY进行平滑
% h=fspecial('gaussian',[5 1],1.5);
% w=h*h';
% A=imfilter(X2,w);
% B=imfilter(Y2,w);
% C=imfilter(XY,w);
% 
% %k一般取值0.04-0.06
% k=0.04;
% RMax=0;
% [height,width]=size(image);
% 
% R=zeros(height,width);
% for h=1:height
%     for w=1:width
%         %计算M矩阵
%         M=[A(h,w) C(h,w);C(h,w) B(h,w)];
%         %计算R用于判断是否是边缘
%         R(h,w)=det(M) - k*(trace(M))^2;
%         %获得R的最大值，之后用于确定判断角点的阈值
%         if(R(h,w)>RMax)
%             RMax=R(h,w);
%         end
%     end
% end
% 
% 
% %用Q*RMax作为阈值，判断一个点是不是角点
% Q=0.01;
% R_corner=(R>=(Q*RMax)).*R;
% 
% %非极大化抑制
% %寻找3x3邻域内的最大值，只有一个交点在8邻域内是该邻域的最大点时，才认为该点是角点
% fun = @(x) max(x(:)); 
% %对R中[3,3]区域寻找最大值
% R_localMax = nlfilter(R,[3 3],fun); 
% 
% %寻找既满足角点阈值，又在其8邻域内是最大值点的点作为角点
% %注意：需要剔除边缘点
% [y,x]=find(R_localMax(2:height-1,2:width-1)==R_corner(2:height-1,2:width-1));
% 
% x_indexleft = find(x <= feature_width/2 - 1);   %寻找x方向上左边边缘角点
% %去除边缘角点
% x(x_indexleft) = [];
% y(x_indexleft) = [];
% 
% y_indexup = find(y <= feature_width/2 - 1);    %寻找y方向上部边缘角点
% x(y_indexup) = [];
% y(y_indexup) = [];
% 
% x_indexright = find(x > width - 8);       %寻找x方向右边的边缘角点
% x(x_indexright) = [];
% y(x_indexright) = [];
% 
% y_indexdown = find(y > height - 8);       %寻找y方向下部的边缘角点
% x(y_indexdown) = [];
% y(y_indexdown) = [];
% %x(find(x<feature_width/2 - 1)) = [];
% %y(find(y<feature_width/2 - 1)) = [];
% 
% 
% 
%     
% 
% end
feature_width = 16;
fx = [-1,0,1;-2,0,2;-1,0,1];
fy = [-1,-2,-1;0,0,0;1,2,1];
Ix = imfilter(image,fx);
Iy = imfilter(image,fy);
Ix2 = Ix.* Ix;
%subplot(2,2,1);
%imshow(Ix2);
Ixy = Ix.* Iy;
% subplot(2,2,2);
% imshow(Ixy);
Iy2 = Iy.* Iy;
% subplot(2,2,3);
% imshow(Iy2);
h = fspecial('gaussian',25,2);
% subplot(2,2,4);
% imshow(h);
Ix2 = imfilter(Ix2,h);
Ixy = imfilter(Ixy,h);
Iy2 = imfilter(Iy2,h);
 
%寻找最大R值
Rmax = 0;
l = 0.05;
[img_height,img_width] = size(image);
M = zeros(img_height,img_width);
for i = 1:img_height
    for j = 1:img_width
        A = [Ix2(i,j),Ixy(i,j);Ixy(i,j),Iy2(i,j)];
        M(i,j) = det(A) -  l*(trace(A))^2;
        if M(i,j) > Rmax
            Rmax = M(i,j);
        end
    end
end
% 
% %用Q*RMax作为阈值，判断一个点是不是角点
% Q=0.01;
% R_corner=(M>=(Q*Rmax)).*M;
% % 
% % %非极大化抑制
% % %寻找3x3邻域内的最大值，只有一个交点在8邻域内是该邻域的最大点时，才认为该点是角点
% fun = @(x) max(x(:)); 
% % %对R中[3,3]区域寻找最大值
% R_localMax = nlfilter(M,[3 3],fun); 
% % 
% % %寻找既满足角点阈值，又在其8邻域内是最大值点的点作为角点
% % %注意：需要剔除边缘点
%  [y,x]=find(R_localMax(2:img_height-1,2:img_width-1)==R_corner(2:img_height-1,2:img_width-1));

%  
%局部非极大值抑制
k = 0.01;
cnt = 0;   %记录角点数目
result = zeros(img_height,img_width);
for i=2:img_height-1
    for j =2:img_width-1
        if M(i,j)>k*Rmax && M(i,j)>M(i-1,j-1) && M(i,j)>M(i-1,j)&&M(i,j)>M(i-1,j+1)&&M(i,j)>M(i,j-1)&&M(i,j)>M(i,j+1)&&M(i,j)>M(i+1,j-1)&&M(i,j)>M(i+1,j)&&M(i,j)>M(i+1,j+1)
            result(i,j) = 1;
            cnt = cnt + 1;
        end
    end
end
%  
[y,x] = find(result==1);
x_indexleft = find(x <= feature_width/2 - 1);   %寻找x方向上左边边缘角点
%去除边缘角点
x(x_indexleft) = [];
y(x_indexleft) = [];
y_indexup = find(y <= feature_width/2 - 1);    %寻找y方向上部边缘角点
x(y_indexup) = [];
y(y_indexup) = [];
x_indexright = find(x > img_width - 8);       %寻找x方向右边的边缘角点
x(x_indexright) = [];
y(x_indexright) = [];
y_indexdown = find(y > img_height - 8);       %寻找y方向下部的边缘角点
x(y_indexdown) = [];
y(y_indexdown) = [];
%x(find(x<feature_width/2 - 1)) = [];
%y(find(y<feature_width/2 - 1)) = [];
disp(length(x));    %显示角点数目
figure;
imshow(image);
hold on;
plot(x,y,'ro');
hold off;
end

