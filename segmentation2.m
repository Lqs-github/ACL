function thresh=segmentation2(img)
[~,~,z]=size(img);
if z>1
    I1=rgb2gray(img);
else
    I1=img;
end
thresh1=graythresh(I1);
[x,y]=size(I1);
I2=I1;
thresh_image_1=[];

for i=1:x
    for j=1:y
        if I2(i,j)<=thresh1*255
            thresh_image_1=[thresh_image_1,I2(i,j)];
        end
    end
end

thresh2=graythresh(thresh_image_1);
I3=I2;
thresh_image_2=[];

for i=1:x
    for j=1:y
        if I3(i,j)<thresh2*255
            I3(i,j)=0;
        end
        if I3(i,j)>=thresh2*255
            thresh_image_2=[thresh_image_2,I3(i,j)];
        end
    end
end

thresh3=graythresh(thresh_image_2);
thresh=[thresh1,thresh2,thresh3];
end