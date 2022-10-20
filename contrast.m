function cg = contrast(f) %f为输入图像，cg为输出的对比度数值
[~,~,z]=size(f);
if z>1
    f=rgb2gray(f);
end
[m,n] = size(f);%求原始图像的行数m和列数n
g = padarray(f,[1 1],'symmetric','both');%对原始图像进行扩展，比如50*50的图像，扩展后变成52*52的图像，
%扩展只是对原始图像的周边像素进行复制的方法进行
[r,c] = size(g);%求扩展后图像的行数r和列数c
g = double(g); %把扩展后图像转变成双精度浮点数
k = 0; %定义一数值k，初始值为0
for i=2:r-1
    for j=2:c-1
        k = k+(g(i,j-1)-g(i,j))^2+(g(i-1,j)-g(i,j))^2+(g(i,j+1)-g(i,j))^2+(g(i+1,j)-g(i,j))^2;
    end
end
cg = k/(4*(m-2)*(n-2)+3*(2*(m-2)+2*(n-2))+4*2);%求原始图像对比度
