clear
clc

block_lung_min=1000;
f=ones(9)/81;
conn=8;
every_thresh=zeros([3400,4]);

A='ACL_Image\';%数据集地址
B='ACL_GroundTrue\';%GroundTrue地址
t=dir(A);
tt=struct2cell(t)';
[xx,~]=size(tt);
for img=3:xx
    name=tt(img,1);
    image=imread(strcat(A,name{1,1}));
    gt=imread(strcat(B,name{1,1}));%标签
    
    lung=lung_seg(image);
    precision=50;
    duibidu_image=contrast(image);
    
    if sum(sum(lung))>block_lung_min%无肺区域不分割
        lung=lung_seg(image);
        str=strel('disk',5);
        lung=imerode(lung,str);
        [x,y]=size(lung);
        a = sum(lung,1);
        tmp = a>0;
        loc = find(tmp==1);
        y_left = loc(1);
        y_right = loc(size(loc,2));
        a = sum(lung,2);
        tmp = a>0;
        loc = find(tmp==1);
        x_up = loc(1);
        x_down = loc(size(loc,1));
        lung_cut = lung(x_up:x_down,y_left:y_right);
        image_cut = image(x_up:x_down,y_left:y_right,:);
        [row,col] = size(lung_cut);
        half_col = floor(col/2.0);
        half_row = floor(row/2.0);
        
        if duibidu_image<300
            all_thresh=[];
            step_col = floor(col*0.5)-1;
            step_row =  floor(row*0.5)-1;
            window_row = floor(row*0.5);
            window_col = floor(col*0.5);
            
            for i=1:step_row:row - window_row
                for j=1:step_col:col - window_col
                    flag = sum(sum(lung_cut(i:i + window_row-1,j:j + window_col-1,:)));
                    %当前子块的肺部像素和
                    if flag>block_lung_min
                        tmp = image_cut(i:i + window_row-1,j:j + window_col-1,:);
                        %imshow(tmp);
                        all_thresh = [all_thresh;segmentation2(tmp)];
                    end
                end
            end
            
            %% 上色
            [x_image_cut,y_image_cut,~]=size(image_cut);
            flag_map=zeros([x_image_cut,y_image_cut]);
            
            for i=1:step_row:row - half_row
                for j=1:step_col:col - half_col
                    flag = sum(sum(lung_cut(i:i + half_row-1,j:j + half_col-1,:)));
                    if flag>block_lung_min
                        if size(all_thresh,1)>1
                            max_thresh = max(all_thresh);
                        end
                        if size(all_thresh,1)==1
                            max_thresh = all_thresh;
                        end
                        tmp = image_cut(i:i + half_row-1,j:j + half_col-1,:);
                        ill = segmentation3(tmp,max_thresh);
                        class=segmentation4(tmp,ill);
                        %         imshow(class);
                        [x_class,y_class,~]=size(class);
                        
                        for m=1:x_class
                            for n=1:y_class
                                if class(m,n,3)==100%病灶
                                    flag_map(i+m,j+n)=flag_map(i+m,j+n)+1;
                                end
                                if class(m,n,3)==200%正常
                                    flag_map(i+m,j+n)=flag_map(i+m,j+n)-1;
                                end
                            end
                        end
                        
                        [~,~,class_z]=size(class);
                        
                        if class_z==3
                            tmp = class(:,:,:);
                        end
                    end
                end
            end
            
            for i=1:step_row:row - half_row
                for j=1:step_col:col - half_col
                    flag = sum(sum(lung_cut(i:i + half_row-1,j:j + half_col-1,:)));
                    if flag>block_lung_min
                        if size(all_thresh,1)>1
                            max_thresh = max(all_thresh);
                        end
                        if size(all_thresh,1)==1
                            max_thresh = all_thresh;
                        end
                        tmp = image_cut(i:i + half_row-1,j:j + half_col-1,:);
                        ill = segmentation3(tmp,max_thresh);
                        class=segmentation4(tmp,ill);
                        [x_class,y_class,~]=size(class);
                        
                        for m=1:x_class
                            for n=1:y_class
                                if class(m,n,3)==100 || class(m,n,3)==200%病灶
                                    flag_map(i+m,j+n)=flag_map(i+m,j+n)+1;
                                end
                            end
                        end
                        
                        [~,~,class_z]=size(class);
                        if class_z==3
                            tmp = class(:,:,:);
                        end
                    end
                end
            end
            ill_aera=zeros([x_image_cut,y_image_cut]);
            normal_aera=zeros([x_image_cut,y_image_cut]);
            
            for i=1:x_image_cut
                for j=1:y_image_cut
                    if flag_map(i,j)>0
                        ill_aera(i,j)=1;
                    end
                    if flag_map(i,j)<=0
                        normal_aera(i,j)=1;
                    end
                end
            end
            
            ill_aera = bwareaopen(ill_aera,precision,conn);%去除小连通域
            if duibidu_image<=100
                swell=strel('square',1);
                normal_aera=imdilate(normal_aera,swell);%膨胀正常区域
                for i=1:x_image_cut
                    for j=1:y_image_cut
                        if normal_aera(i,j)==1
                            ill_aera(i,j)=0;%削减正常区域极其边缘
                        end
                    end
                end
                ill_aera = bwareaopen(ill_aera,precision*2,conn);%去除小连通域
                ill_aera=imfilter(ill_aera,f);%均值滤波正常区域
                ill_aera = bwareaopen(ill_aera,precision,conn);%去除小连通域
            else
                ill_aera = bwareaopen(ill_aera,precision*2,conn);%去除中等连通域
                ill_aera=imfilter(ill_aera,f);%均值滤波正常区域
                ill_aera = bwareaopen(ill_aera,precision,conn);%去除小连通域
            end
            
            for i=1:x_image_cut
                for j=1:y_image_cut
                    if ill_aera(i,j)==1
                        image_cut(i,j,1)=255;
                    end
                end
            end
            
            ill_image=image;
            ill_image(x_up:x_down,y_left:y_right,:)=image_cut(:,:,:);
            
            for i=1:x
                for j=1:y
                    if lung(i,j)==0
                        ill_image(i,j,:)=image(i,j,:);
                    end
                end
            end%还原其他部分
            
            right=zeros(x,y);
            
            for i=1:x
                for j=1:y
                    if ill_image(i,j,1)==255
                        right(i,j)=1;
                    end
                end
            end
            
        else %对比度>300
            gray_image=rgb2gray(image);
            lung_image=gray_image;
            ill_image=image;
            ill_aera=zeros([x,y]);
            
            for i=1:x
                for j=1:y
                    if lung(i,j)==0
                        lung_image(i,j)=0;
                    end
                end
            end
            
            thresh_special=segmentation2(lung_image);
            ill_aera=zeros(x,y);
            
            for i=1:x
                for j=1:y
                    if lung_image(i,j)>thresh_special(3)*255
                        ill_aera(i,j)=1;
                    end
                end
            end
            
            ill_aera = bwareaopen(ill_aera,precision,conn);%去除中等连通域
            ill_aera=imfilter(ill_aera,f);%均值滤波正常区域
            ill_aera = bwareaopen(ill_aera,precision,conn);%去除小连通域
            
            for i=1:x
                for j=1:y
                    if ill_aera(i,j)>0
                        ill_image(i,j,1)=255;
                    end
                end
            end
            
            right=ill_aera;
            SE=strel('disk',2);
            lung=imerode(lung,SE);
            
            for i=1:x
                for j=1:y
                    if lung(i,j)==0
                        ill_image(i,j,:)=image(i,j,:);
                    end
                end
            end%还原其他部分
        end
        subplot(131)
        imshow(image);
        title('Image')
        subplot(132)
        imshow(ill_image);
        title('ACL')
        subplot(133)
        imshow(gt);
        title('GroundTrue');
        hold on
        pause(0.01)
        fprintf('%s\n',strcat('当前第',num2str(img-2),'/',num2str(xx-2),'张已完成。'));
    else
        fprintf('%s\n',strcat('当前第',num2str(img-2),'/',num2str(xx-2),'张已完成。'));
    end  
end