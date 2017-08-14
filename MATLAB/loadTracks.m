path = 'C:\Users\bdhua\Documents\Schoolwork\2017_S\ISC233\Laboratories\Lab11\Tracks\Tracks';
cd(path);

d = dir('*.txt');
fnames = {d.name}';
Ntrials = length(fnames);
[A,B,C,D,E,F] = deal(cell(1,1));

for i=1:Ntrials
    data = importdata(fnames{i});
    switch fnames{i}(1)
        case 'A'
            A = vertcat(A,{data.data});
        case 'B'
            B = vertcat(B,{data.data});
        case 'C'
            C = vertcat(C,{data.data});
        case 'D'
            D = vertcat(D,{data.data});
        case 'E'
            E = vertcat(E,{data.data});
        case 'F'
            F = vertcat(F,{data.data});
    end
end
A = A(2:end);
B = B(2:end);
C = C(2:end);
D = D(2:end);
E = E(2:end);
F = F(2:end);

Arad = calcRadius(A);
Brad = calcRadius(B);
Crad = calcRadius(C);
Drad = calcRadius(D);
Erad = calcRadius(E);
Frad = calcRadius(F);
rads = {Arad,Brad,Crad,Drad,Erad,Frad};

%% Cities

% import configuration
cities = importdata('cities.txt');
c_names = cell2mat(cities.rowheaders);
c_coord = cities.data / 100;
nCities = length(c_names);
%% Get city distances

c_dists = zeros(size(c_names,1),size(c_names,1));
for i=1:size(c_names,1)
    for j=(i+1):size(c_names,1)
        c_dists(i,j) = sqrt((c_coord(i,1) - c_coord(j,1))^2 + ...
            (c_coord(i,2) - c_coord(j,2))^2);
    end
end

c_dists = reshape(transpose(c_dists), 1, []);
c_dists = c_dists(c_dists~=0); % ith entry is distance between cities given by labels{i}

%% Combinatorics of trials per city

combs = combntns([1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3 4 4 4 4 4 4], 6);
combs = unique(combs, 'rows');
permuts = int16.empty;
for i=1:size(combs,1)
    compare = perms(combs(i,:));
    permuts = unique(vertcat(permuts, compare), 'rows');
end
clear temp; clear i

%% results for one set of results for one worm from each city

pairs = combntns(1:nCities,2); % possible pairings of two cities
nPairs = size(pairs,1);

combos = {};
for i=1:size(permuts,1) 
    combos{i} = double.empty;
    for j=1:nPairs % each combination of two pairs
        ind1 = pairs(j,1);
        ind2 = pairs(j,2);
        compare = rads{ind1}(:, permuts(i,ind1)) ...
            + rads{ind2}(:, permuts(i,ind2));
        combos{i} = horzcat(combos{i}, compare);
    end
end
clear ind1; clear ind2;

labels = {}; % nth entry is the 
for i=1:nPairs
    labels{i} = strcat(c_names(pairs(i,1)), c_names(pairs(i,2))); % use char references
    % labels{i} = [pairs(i,1), pairs(i,2)]; % use int references
end

%% Find order of convergence

converge = {};
twoConverge = {};
for i=1:size(combos,2)
    compare = combos{i} > c_dists;
    converge{i} = NaN(1, nPairs);
    for j=1:size(compare, 2)
        [row, col] = find(compare);
        try
            converge{i}(j) = min(row(col == j));
        catch
        end
    end
    nNotNans = sum(~isnan(converge{i}));
    [~, temp] = sort(converge{i}); % order in which two cities converge
    twoConverge{i} = temp(1, 1:nNotNans);
end
clear row; clear col; clear compare;

%% Find quasi-optimal path
paths = cellfun(@(x) groupCity(x,c_dists),twoConverge,'UniformOutput',false);
pthdists = cellfun(@(x) nansum(c_dists(ismember(pairs,sort([x',[x(2:end)';...
    x(1)]],2),'rows'))),paths);
% Remove nan values
pthdists = pthdists(pthdists > 0);

%% BRUTE FORCE SOLUTION %%
% this really could be optimised a lot

routes = perms([1:nCities]);
dist = zeros(length(routes),1);
for k=1:length(routes)
    dist(k) = sum(c_dists(ismember(pairs,...
    sort([routes(k,:);[routes(k,2:end),routes(k,1)]])','rows')));
end

[optPathDist, index] = min(dist);
wrsPathDist = max(dist);
avgPathDist = median(dist);
optPathInt = routes(index, :);
optPathStr = '';
for i=1:nCities
    optPathStr = strcat(optPathStr, c_names(optPathInt(i)));
end

%% Gridded result
gridr = [5,6,3,4,1,2];
gridd = sum(c_dists(ismember(pairs,...
    sort([gridr;[gridr(2:end),gridr(1)]]',2),'rows')));

%% Another look at radius/city:
avgrads = cellfun(@(x) mean(x,2),rads,'UniformOutput',false);
stdrads = cellfun(@(x) std(x,1,2),rads,'UniformOutput',false);
[stdfilx,stdfily] = cellfun(@(x,y) errEnvelop(0:.5:299.5,y,x),stdrads,...
    avgrads,'UniformOutput',false);
stdfilx = [stdfilx{:}]; stdfily = [stdfily{:}];
avgrads = [avgrads{:}];

% Figures
cols = linspecer(6);
figure(1); clf;
axis tight; grid on;
subplot(2,1,1); hold on;
p = plot(0:.5:299.5,avgrads);
f = fill(stdfilx,stdfily,'k');
for i=1:length(f)
    f(i).FaceAlpha = .2;
    f(i).LineStyle = 'none';
    f(i).FaceColor = cols(i,:);
    p(i).Color = cols(i,:);
end
subplot(2,1,2)
plot(0:.5:299,movmean(diff(avgrads)/.5,50));

%% Figure aesthetics!
figure(2); clf;
axis tight; hold on; grid minor; grid on;
h1 = histogram(unique(dist),10,'normalization','probability');
h2 = histogram(pthdists,10,'normalization','probability');
ylim([0 1]);
gr = line([gridd gridd],ylim);
gr.LineStyle = '--'; gr.Color = 'k';
legend([h1 h2 gr],{'All Possible Paths','Chemotactic Paths',...
    ['Orthogonal',char(10),'Gridding Path']},'FontSize',12);
xlabel('Path Distance (m)'); ylabel('Probability (a.u.)');




