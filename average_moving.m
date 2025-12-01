% 对光谱数据进行移动平均平滑
% average moving
% segment为平滑点数
function Xmov=average_moving(X,segment)

[m,n]=size(X);

middle=floor(segment/2);


for i=middle+1:n-middle
    sum=zeros(m,1);
   
    for k=i-middle:i+middle
    sum=sum+X(:,k);
    end
    Xmov(:,i)=sum/segment;
    Xmov = round(Xmov.*1000000)./1000000;
    
end
 
for j=1:middle     % 前几个点的处理
    sum=zeros(m,1);
    for k=1:j+middle
    sum=sum+X(:,k);
    end
    Xmov(:,j)=sum/(middle+j);
end
% 
for l=n:-1:n-middle+1    % 后几个点的处理
    sum=zeros(m,1);
    for h=n:-1:l-middle
    sum=sum+X(:,h);
    end 
    Xmov(:,l)=sum/(n-(l-middle)+1);
    
end
end