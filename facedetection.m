function facedetection()
clear;
clc;
close all;
%% 读入照片

figure(1)
[fileName,filePath] = uigetfile('*','待检测图片');
str  = strcat(filePath,fileName);
input_img =  imread(str);
subplot(1,3,1); imshow(input_img);
title('待检测图片')
%% 将图片转化为灰度图像和在yCbCr空间中显示

image_gray1 = rgb2gray(input_img); 
edge1 =  edge(image_gray1,'canny');
I1 = medfilt2(edge1,[9 9]);
image_ycbcr = rgb2ycbcr(input_img);
subplot(1,3,2); imshow(image_gray1); title('灰度图');
subplot(1,3,3); imshow(image_ycbcr); title('RGB to YCbCr');
%% 获得图像高度和宽度
height = size(input_img,1);
width = size(input_img,2);
%% 分段判断是否肤色
% （1）对于亮度低于80像素点直接判决为非肤色像素点；
% （2）对于亮度在80-230之间的像素点采用肤色的椭圆聚类方法；
% （3）对于亮度大于230的像素点进行判决是，将肤色的聚类时的椭圆的长短轴同时扩大为原来的1.1倍。

for i = 1:height  
    for j = 1:width  
        Y  = image_ycbcr(i,j,1);  
        Cb = image_ycbcr(i,j,2);  
        Cr = image_ycbcr(i,j,3);  
            if(skin1(Y,Cb,Cr) == 1)  
                I1(i,j) = 255;  
            else  
                I1(i,j) = 0;  
            end  
    end  
end 
figure(2);subplot(1,2,1);imshow(I1);title('运行算法后的二值图');
imwrite(I1,'Anil.jpg')
%% 对二值图像进行形态学处理
erode_image = bwmorph(I1,'erode');
%open_image = bwmorph(erode_image,'open');
%close_image = bwmorph(open_image,'close');
%spur_image = bwmorph(open_image,'spur');
clean_image = bwmorph(erode_image,'clean');
subplot(1,2,2);imshow(clean_image);title('形态学处理后的图像');
%% 标记连通区域并保存
[D,num1] = bwlabel(clean_image,8);
stats = regionprops(D,'BoundingBox');
n =1;
result = zeros(n,4);
figure(3);imshow(input_img);
p=0;

for i= 1:num1
    box = stats(i).BoundingBox;   %取得连通区域矩形参数
    x = box(1);                   %矩形的x坐标
    y = box(2);                   %矩形的y坐标
    w = box(3);                   %矩形宽度
    h = box(4);                   %矩形高度
    ratio = h/w;                  %高度和宽度的比例
    ux=uint8(x);
    uy=uint8(y);
    
    if ux>1
        ux=ux-1;
    end
    if uy>1
        uy=uy-1;
    end
%  判断人脸应满足以下条件：
%  1.高度和宽度必须都大于20，且矩形面积大于400 (可手动设置阈值) 
%  2.高度和宽度比率应该在范围（0.6~1.8）内
    if w < 20|| h < 20 || w*h < 400
        continue
    elseif ratio> 0.3 
        % 记录人脸区域
        result(n,:)=[ux uy w h];
        n=n+1;
    end
end

hold on
if  size(result,1) == 1 && result(1,1) > 0
    rectangle('Position',[result(1,1),result(1,2),result(1,3),result(1,4)],'Curvature',[1,1],'LineStyle','--','EdgeColor','r','LineWidth',2);
  
else
    % 如果满足条件的矩形区域大于1则再根据其他信息进行筛选
    
    for m  = 1:size(result,1)  
        m1 = result(m,1);  
        m2 = result(m,2);  
        m3 = result(m,3);  
        m4 = result(m,4);  
        % 标记最终的人脸区域  
        if m1 + m3 < width && m2 + m4 < height   
            rectangle('Position',[m1,m2,m3,m4],'Curvature',[1,1],'LineStyle','--','EdgeColor','y','LineWidth',2);
        end  
    end     


   % pause(1);   
end
