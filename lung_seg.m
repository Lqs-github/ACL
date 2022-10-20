function I1=lung_seg(img)
[~,~,z]=size(img);

if z>1
    I=rgb2gray(img);
else
    I=img;
end

tI=IterationThreshold(I,1);%全局阈值
se=strel('disk',5);
tI=~tI;%取反
tI=imclose(tI,se);%闭运算
tI=~tI;%取反
tI=getConnectionArea(tI);%获取最大连通区域
hI=imfill(tI,'holes');%孔洞填充
[x_hI,y_hI] = size(hI);
lung_white = [];

for i=1:x_hI
    for j=1:y_hI
        if hI(i,j)>0
            lung_white = [lung_white,I(i,j)];
        end
    end
end

thresh=segmentation2(lung_white);
tI=im2bw(I,thresh(3));
tI=~tI;%取反
se=strel('disk',5);
tI=imclose(tI,se);%闭运算
tI=~tI;%取反
tI=getConnectionArea(tI);%获取最大连通区域
hI=imfill(tI,'holes');%孔洞填充
tI=hI-tI;%掩膜相减
I1=deleteConnectionArea(tI,3000);
end