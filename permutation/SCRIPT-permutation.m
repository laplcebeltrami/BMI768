%Permutation test
%(C) 2022 Jan 26 Moo K. Chung
%University of Wisconsin-Madison

t=[0:0.01:1];
for i=1:10
    x(i,:)=sqrt(t)+normrnd(0, 0.1,1,length(t));
end

for i=1:15
    y(i,:)=sqrt(1.2*t)+normrnd(0, 0.1,1,length(t));
end

figure; plot(t,x, 'r')
hold on; plot(t,y, '-k')


%Don't overwrite variables. Cause of most errors in programming. 
for i=1:10
    x(i,:) = smooth(x(i,:),20); %smooth.m uses the moving average method with span 10
end

for i=1:15
    y(i,:) = smooth(y(i,:),20);
end

figure; plot(t,x, 'r');
hold on; plot(t,y, '-k');


tic
per_s=100000;

m=size(x,1); %sample size in group I
n=size(y,1); %sample size in group II
z=[x; y];  %Combine the data


for i=1:per_s %each iteration gives a permutation
    zper=z(randperm(m+n),:); %random permutation of data z.
    xper=zper(1:m,:);yper=zper(m+1:m+n,:); %permuted data is split into group 1 and 2
    stat_s(i,:)=max(abs(mean(xper)-mean(yper)));
    
    %stat_s(i,:)=(mean(x)-mean(y)).*sqrt(m*n*(m+n-2)./((m+n)*((m-1)*var(x)+(n-1)*var(y)))); %t-stat
end

toc

observed_distance = max(abs(mean(x)-mean(y)))

figure; histogram(stat_s,100);
hold on; plot([observed_distance observed_distance],[0 10000],'--r','linewidth',2);

pvalue = online_pvalue(stat_s, observed_distance); %pvalue is computed in an online fashion. 
pvalue=pvalue(end)


% Self-asseemnet problem: (1) If you incrase 
% the amount of smoothing, you will get 
% smaller p-value in most cases, incrasing 
% discrimination power). Check this claim. 
% (2) Can you prove the claim mathematically? 
% --> Project










