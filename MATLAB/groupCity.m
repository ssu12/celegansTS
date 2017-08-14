function path = groupCity(ord,loc)

inds = [[1,2];[1,3];[1,4];[1,5];[1,6];[2,3];[2,4];[2,5];[2,6];[3,4];...
    [3,5];[3,6];[4,5];[4,6];[5,6]];
pairs = inds;
path = {1,2,3,4,5,6}';
% Keep track of the number of merges
nmrg = length(path);
% Keep track of what has been merged
mrgs = false(length(path),1);

for k=1:length(ord)
    % Check if the two cities have been connected already
    if diff(inds(ord(k),:)) > 0
        nmrg = nmrg - 1;
        % Get the index to merge to
        mrgi = min(inds(ord(k),:));
        % Get the index to overwrite (cleanup!)
        mrgd = max(inds(ord(k),:));
        % Set the element to 'merged'
        mrgs(mrgi) = true; mrgs(mrgd) = true;
        % Get two arrays to be merged (left/right)
        [left,right] = path{inds(ord(k),:)};
        % Find the distances between the ends of the arrays (4 compares)
        whereJoin = [loc(ismember(pairs, sort([left(1) right(1)]), 'rows')), ...
            loc(ismember(pairs, sort([left(end) right(1)]), 'rows')), ...
            loc(ismember(pairs, sort([left(1) right(end)]), 'rows')), ...
            loc(ismember(pairs, sort([left(end) right(end)]), 'rows'))];
        % Find indice of the minimum distance 
        [~, minCase] = min(whereJoin);
        % Concatenate arrays correctly
        switch minCase
            case 1
                output = horzcat(fliplr(right), left);
            case 2
                output = horzcat(left, right);
            case 3
                output = horzcat(right, left);
            case 4
                output = horzcat(left, fliplr(right));
        end
        % Set the element in path to the merged array
        path{mrgi} = output;
        % Set the mgrd inds to mgri
        inds(inds == mrgd) = mrgi;
        % Overwrite mgrd in path
        path{mrgd} = mrgd;
    end
end

% Return full path
lngth = cellfun(@(x) length(x),path);
% Single value case
if nmrg == 1
    [~,i] = max(lngth);
    path = path{i};
% Case where there are 2 groups
elseif nmrg == 2
    [m1,i1] = max(lngth);
    % Case where there is 1 array and 1 single value
    if m1 == length(path) - 1
        i2 = find(mrgs == 0); m1 = path{i1}; m2 = path{i2};
        whereJoin = [loc(ismember(pairs, sort([m2 m1(1)]), 'rows')),...
            loc(ismember(pairs, sort([m2 m1(end)]), 'rows'))];
        [~,minCase] = min(whereJoin);
        switch minCase
            case 1
                path = [m2 m1];
            case 2 
                path = [m1 m2];
        end
    % Case where there are 2 arrays
    else 
        i2 = find(lngth == max(lngth(lngth<max(lngth))));
        m1 = path{i1}; m2 = path{i2};
        whereJoin = [loc(ismember(pairs, sort([m1(1) m2(1)]), 'rows')), ...
            loc(ismember(pairs, sort([m1(end) m2(1)]), 'rows')), ...
            loc(ismember(pairs, sort([m1(1) m2(end)]), 'rows')), ...
            loc(ismember(pairs, sort([m1(end) m2(end)]), 'rows'))];
        % Find indice of the minimum distance 
        [~, minCase] = min(whereJoin);
        % Concatenate arrays correctly
        switch minCase
            case 1
                path = horzcat(fliplr(m2), m1);
            case 2
                path = horzcat(m1, m2);
            case 3
                path = horzcat(m2, m1);
            case 4
                path = horzcat(m1, fliplr(m2));
        end
    end
else 
    path = nan;
end

