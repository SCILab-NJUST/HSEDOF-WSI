% CalculatePSF  Calculate Point Spread Function for annular illumination
%
% This function computes the 3D absorption PSF (APSF) for annular
% illumination in bright-field microscopy. The 3D absorption OTF (AOTF)
% of the annular aperture is synthesized first, then
% inverse-Fourier-transformed into the 3D APSF, which is finally projected onto
% a 2D plane through axial summation.
%
% Inputs:
%   NA              - Numerical Aperture of the objective lens
%   rhoxy           - Spatial frequency coordinates in XY plane [1/μm]
%   eta             - Spatial frequency coordinates in Z direction [1/μm]
%   lambda          - Wavelength of light [μm]
%   rho             - 3D spatial frequency coordinates [1/μm]
%   outer_diameter  - Outer diameter of annular aperture (normalized)
%   inner_diameter  - Inner diameter of annular aperture (normalized)
%
% Output:
%   PSF             - 2D projected Point Spread Function
%
% Algorithm:
%   1. Calculate maximum spatial frequency (rhop) based on NA and lambda
%   2. Compute outer ring AOTF
%   3. Compute inner ring AOTF
%   4. Calculate the annular AOTF as difference: outer - inner
%   5. Perform inverse Fourier transform of the AOTF to get the 3D APSF
%   6. Project 3D APSF onto 2D plane by summing along axial dimension


function PSF = CalculatePSF(NA, rhoxy, eta,lambda,rho, outer_diameter, inner_diameter)
    rhop = NA / lambda;
    outer_rhos = outer_diameter * rhop;
    outer_Fp = CalculateF(rhoxy,eta,lambda,rho,outer_rhos,rhop);
    outer_Fm = CalculateF(rhoxy,-eta,lambda,rho,outer_rhos,rhop);
    outer_AOTF = (outer_Fp + outer_Fm) .* lambda ./ (4 * pi);
    
    if inner_diameter == 0
        inner_AOTF = zeros(size(outer_AOTF), 'like', outer_AOTF);
    else
        inner_rhos = inner_diameter * rhop;
        inner_Fp = CalculateF(rhoxy,eta,lambda,rho,inner_rhos,rhop);
        inner_Fm = CalculateF(rhoxy,-eta,lambda,rho,inner_rhos,rhop);
        inner_AOTF = (inner_Fp + inner_Fm) .* lambda ./ (4 * pi);
    end
    
    AOTF = outer_AOTF - inner_AOTF;
    APSF = fftshift(ifftn(ifftshift(AOTF)));
    APSF = max(real(APSF), 0);

    [Ny, Nx, Nz] = size(APSF);
    PSFsum = zeros(Ny,Nx, 'like', APSF);
    for i = 1:Nz
        PSFsum = PSFsum + APSF(:, :, i);
    end

    PSF = PSFsum(floor(Ny/2)-101:floor(Ny/2)+101,floor(Nx/2)-101:floor(Nx/2)+101);
    if isa(PSF, 'gpuArray')
        PSFcpu = gather(PSF);
        OTF = psf2otf(PSFcpu, [Ny Nx]);
        PSF = cast(otf2psf(OTF, [Ny Nx]), 'like', PSF);
    else
        OTF = psf2otf(PSF,[Ny Nx]);
        PSF = otf2psf(OTF,[Ny Nx]);
    end
end