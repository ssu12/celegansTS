function rads = calcRadius(data)

Ntrials = length(data);

for i=1:Ntrials
    strt = data{i}(find(~isnan(data{i}(:,2:3)),1,'first'),:);
    data{i} = data{i} - strt;
    data{i}(1:strt(1),2:3) = repmat([0,0],strt(1),1);
    % Fix missing end values; copy over last good value
    temp = data{i}(isnan(data{i}(:,2)),2:3); [m,~] = size(temp);
    data{i}(isnan(data{i}(:,2)),2:3) = repmat(data{i}(find(~isnan(data{i}(:,2)),1,'last'),2:3),m,1);
    if length(data{i}) < 600
        data{i}  = [data{i};repmat(data{i}(end,:),600-length(data{i}),1)];
    end
end

rads = zeros(600,Ntrials);

for i=1:Ntrials
    rads(:,i) = sqrt(data{i}(:,2).^2 + data{i}(:,3).^2);
end