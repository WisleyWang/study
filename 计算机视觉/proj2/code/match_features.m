% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% 'features1' and 'features2' are the n x feature dimensionality features
%   from the two images.
% If you want to include geometric verification in this stage, you can add
% the x and y locations of the features as additional inputs.
%
% 'matches' is a k x 2 matrix, where k is the number of matches. The first
%   column is an index in features 1, the second column is an index
%   in features2. 
% 'Confidences' is a k x 1 matrix with a real valued confidence for every
%   match.
% 'matches' and 'confidences' can empty, e.g. 0x2 and 0x1.
function [matches, confidences] = match_features(features1, features2)

% This function does not need to be symmetric (e.g. it can produce
% different numbers of matches depending on the order of the arguments).

% To start with, simply implement the "ratio test", equation 4.18 in
% section 4.1.3 of Szeliski. For extra credit you can implement various
% forms of spatial verification of matches.

% Placeholder that you can delete. Random matches and confidences

ratio = 0.8;
% num_matches = 0;
num_features1 = size(features1,1);
% num_features2 = size(features2,1);
matches = zeros(num_features1,2);
confidences=zeros(num_features1,1);
for i = 1:num_features1
    distances = dist(features1(i,:),features2');
    [dists,index] = sort(distances);
    nndr = dists(1)/dists(2); 
    if nndr < ratio
      %num_matches = num_matches + 1;
      matches(i,:) = [i,index(1)];
      confidences(i) = 1 - nndr;
%     else 
%         confidences(i) = [];
%         matches(i,:) = [];
    end
end
%keep only those matched
matches_index = find(confidences>0);
matches = matches(matches_index,:);
confidences = confidences(matches_index);
 
% Sort the matches so that the most confident onces are at the top of the
% list. You should probably not delete this, so that the evaluation
% functions can be run on the top matches easily.
[confidences, ind] = sort(confidences, 'descend');
matches = matches(ind,:);