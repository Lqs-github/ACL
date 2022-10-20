function OI=getConnectionArea(II)
%最大连通分量的提取
%II为输入二值图像，OI为输出图像
    L=bwlabel(II,4);
    OI=II;
    stats = regionprops(L);
    Ar = cat(1, stats.Area);
    ind=find(Ar==max(Ar));
    if sum(sum(L))~=0
        OI(L~=ind(1))=0;%将其他区域置为0
    end
end