function [ Afeatures_remapped ] = remap_luminance( Afeatures, Bfeatures )
%remap_luminance Apply linear map to match mean and variance in A to B.
%   Detailed explanation goes here

%Remapping A:
%   Y(p) <- (sd_B/sd_A)(Y(p)-mean_A) + mean_B
mean_A = mean2(Afeatures);
mean_B = mean2(Bfeatures);
sd_A = std2(Afeatures);
sd_B = std2(Bfeatures);

sd_coefficient = (sd_B/sd_A);

Afeatures_remapped = sd_coefficient*(Afeatures - mean_A) + mean_B;

end

