function [ newBp ] = remap_luminance_from_RGB( imgB, imgBp )
%remap_luminance_from_RGB Remap Bp to match B's luminance statistics.
%   Detailed explanation goes here

%Want to remap Bp to lum stats of B
lum_B = convertToLuminance(imgB);
lum_Bp = convertToLuminance(imgBp);

%Remapping Bp:
%   Y(p) <- (sd_B/sd_Bp)(Y(p)-mean_Bp) + mean_B
mean_Bp = mean2(lum_Bp);
mean_B = mean2(lum_B);
sd_Bp = std2(lum_Bp);
sd_B = std2(lum_B);

sd_coefficient = (sd_B/sd_Bp);

Bp_remapped = sd_coefficient*(lum_Bp - mean_Bp) + mean_B;

newBp = zeros(size(Bp_remapped,1),size(Bp_remapped,2),3);

for i=1:size(Bp_remapped,1)
    for j=1:size(Bp_remapped,2)
        Y = Bp_remapped(i,j);
        r = imgBp(i,j,1);
        g = imgBp(i,j,2);
        b = imgBp(i,j,3);
        
        newI = getI(r,g,b);
        newQ = getQ(r,g,b);
        
        RGB = convertYIQtoRGB(Y, newI, newQ);
        newBp(i,j,1) = RGB(1);
        newBp(i,j,2) = RGB(2);
        newBp(i,j,3) = RGB(3);
    end
end

end

