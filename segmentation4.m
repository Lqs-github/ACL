function seg_image=segmentation4(cut_image,cut_ill_aera)
[~,~,z]=size(cut_image);
if z>1
    I1=rgb2gray(cut_image);
else
    I1=cut_image;
end
[x,y]=size(I1);
seg_image=I1;
thresh_image_1=[];

for i=1:x
    for j=1:y
        if cut_ill_aera(i,j)>0
            thresh_image_1=[thresh_image_1,cut_image(i,j)];
        end
    end
end

thresh=graythresh(thresh_image_1);

for i=1:x
    for j=1:y
        if cut_ill_aera(i,j)>0 && cut_ill_aera(i,j)<thresh*255
            seg_image(i,j,3)=100;
        end
        if cut_ill_aera(i,j)>thresh*255
            seg_image(i,j,3)=200;
        end
    end
end

end