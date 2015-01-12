function [ ii, jj ] = getCorrespondingCoord( numRows, numCols, smaller_scale_numRows, smaller_scale_numCols, i, j )
%getCorrespondingCoord Given dimensions of two images, finds the given point
%corresponding to the other.
%   Detailed explanation goes here

percent_Row = i / numRows;
percent_Col = j / numCols;

ii = round(percent_Row*smaller_scale_numRows);
jj = round(percent_Col*smaller_scale_numCols);

ii = max(0,ii);
jj = max(0,jj);

ii=min(ii,smaller_scale_numRows);
jj=min(jj,smaller_scale_numCols);

end

