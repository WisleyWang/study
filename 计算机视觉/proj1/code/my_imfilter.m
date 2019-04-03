function output = my_imfilter(image, filter)
% This function is intended to behave like the built in function imfilter()
% See 'help imfilter' or 'help conv2'. While terms like "filtering" and
% "convolution" might be used interchangeably, and they are indeed nearly
% the same thing, there is a difference:
% from 'help filter2'
%    2-D correlation is related to 2-D convolution by a 180 degree rotation
%    of the filter matrix.

% Your function should work for color images. Simply filter each color
% channel independently.

% Your function should work for filters of any width and height
% combination, as long as the width and height are odd (e.g. 1, 7, 9). This
% restriction makes it unambigious which pixel in the filter is the center
% pixel.

% Boundary handling can be tricky. The filter can't be centered on pixels
% at the image boundary without parts of the filter being out of bounds. If
% you look at 'help conv2' and 'help imfilter' you see that they have
% several options to deal with boundaries. You should simply recreate the
% default behavior of imfilter -- pad the input image with zeros, and
% return a filtered image which matches the input resolution. A better
% approach is to mirror the image content over the boundaries for padding.

% % Uncomment if you want to simply call imfilter so you can see the desired
% % behavior. When you write your actual solution, you can't use imfilter,
% % filter2, conv2, etc. Simply loop over all the pixels and do the actual
% % computation. It might be slow.
% output = imfilter(image, filter);


%%%%%%%%%%%%%%%[%
[img_h,img_w,img_c]=size(image);
[kernel_h,kernel_w]=size(filter);
if(mod(kernel_h,2)==0)
    disp('kernel size must odd£¡')
else
    new_image=zeros(img_h+(kernel_h-1),img_w+(kernel_w-1),img_c);
    new_image(((kernel_h-1)/2+1):(img_h+(kernel_h-1)/2),((kernel_w-1)/2+1):(img_w+(kernel_w-1)/2),:)=image;
end
c1= zeros(img_h,img_w);
c2= zeros(img_h,img_w);
c3= zeros(img_h,img_w);
for i=1:1:img_h
    for j=1:1:img_w
        pix1=0;
        pix2=0;
        pix3=0;
        for k=1:kernel_h
            for v=1:kernel_w
                pix1=pix1+filter(k,v)*new_image(i+k-1,j+v-1,1);
                pix2=pix2+filter(k,v)*new_image(i+k-1,j+v-1,2);
                pix3=pix3+filter(k,v)*new_image(i+k-1,j+v-1,3);
            end
        end
        c1(i,j)=pix1;
        c2(i,j)=pix2;
        c3(i,j)=pix3;       
    end
end


output=cat(3,c1,c2,c3);

%%%%%%%%%%%%%%%%





