# HSEDOF-WSI MATLAB Reconstruction

MATLAB reconstruction code for high-speed extended depth-of-field whole-slide
imaging (HSEDOF-WSI). Two methods are provided:

- **RLD:** Richardson-Lucy deconvolution with total variation (TV) regularization.
- **WB-ARL:** TV-regularized Richardson-Lucy deconvolution with a
  Wiener-Butterworth accelerated back-projector.

The code reconstructs one RGB image per run and supports CPU execution,
GPU acceleration, and batched RGB processing on the GPU.

## Requirements

- MATLAB with Image Processing Toolbox.
- For GPU acceleration: Parallel Computing Toolbox and a compatible NVIDIA GPU.

If GPU initialization fails, the code automatically falls back to the CPU.

## Repository Structure

```text
Main.m                 # Reconstruction entry point and user configuration.
Data/                  # Example RGB images: RAW_IFS.tif and RAW_LBC.tif.
Functions/             # PSF calculation, deconvolution, and post-processing.
PSFR.mat               # Precomputed red-channel PSF (variable: PSFR).
PSFG.mat               # Precomputed green-channel PSF (variable: PSFG).
PSFB.mat               # Precomputed blue-channel PSF (variable: PSFB).
Result/                # Reconstructed images and run metadata.
LICENSE                # MIT License.
```

## Quick Start

Set MATLAB's Current Folder to the repository root. Edit the configuration
block in `Main.m`, then run `Main.m`:

```matlab
methodName = "WB-ARL";     % "RLD" or "WB-ARL".
rawFile = "RAW_IFS.tif";   % Example image in Data/; match filename capitalization.
requestGPU = true;         % false: use CPU.
batchRGBOnGPU = true;      % false: process channels sequentially on the GPU.
gpuPrecision = 'single';   % GPU array precision: 'single' or 'double'.
forceRecomputePSF = false; % Use the included PSFs.
cropBorder = 50;           % Pixels removed from each image border.
thresholdRate = 0.99;      % Bright-intensity clipping ratio.
```

```matlab
run("Main.m")
```

For custom data, place a three-channel RGB image in `Data/` and update
`rawFile`, or specify its absolute path. If GPU memory is insufficient, try
`batchRGBOnGPU = false` or `requestGPU = false`.

## Reconstruction Workflow

1. Load the raw RGB image and prepare the channels for CPU or GPU processing.
2. Load the precomputed PSFs, or calculate them from the optical model.
3. Apply RLD or WB-ARL independently to the RGB channels.
4. Normalize the reconstruction, transfer color from the raw image, clip bright
   intensities, crop the borders, and save the result.

Optical and sampling parameters are defined in `Main.m`. 
Set `forceRecomputePSF = true` to regenerate all three PSFs after changing the optical model. 
Missing PSF files also trigger recomputation, which uses large 3D arrays and overwrites
the PSF files. Cached PSFs are not automatically updated when parameters
change. For custom inputs, use appropriately sampled PSFs no larger than the
input image.

## Default Method Parameters

Parameters are defined in `Functions/defaultMethodParameters.m`.

| Method | Iterations | TV weight |
| --- | ---: | ---: |
| RLD | 100 | `1e-4` |
| WB-ARL | 10 | `1e-5` |

WB-ARL uses `alpha = 0.1`, `beta = 0.1`, and Butterworth order `n = 20`.
Both methods use a non-negativity lower bound of zero.

## Outputs

Results are saved in `Result/`:

- `Result_RLD.tif` or `Result_WBARL.tif`: post-processed RGB reconstruction.
- `RunInfo_RLD.mat` or `RunInfo_WBARL.mat`: method, reconstruction time,
  execution settings, crop indices, and method parameters.

The script also displays the cropped raw image and reconstruction side by side.
Reported time covers reconstruction, excluding input/PSF loading or PSF
recomputation, post-processing, and file saving. Repeating a method overwrites
its previous outputs.

## Citation

If you use this code in academic work, please cite the corresponding paper:

> High-speed extended depth-of-field whole-slide imaging (HSEDOF-WSI):
> bridging resolution, depth, and throughput for advanced digital pathology.

## License

This project is released under the [MIT License](LICENSE).

## Contact

- Runnan Zhang: runnanzhang@njust.edu.com
- Chao Zuo: zuochao@njust.edu.com
