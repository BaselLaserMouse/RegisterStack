# RegisterStack
Affine registration of 3D image stacks with manually selected control 
points in [Matlab].

`RegisterStack` is an interactive tool that loads a pair of image stacks, 
helps with manual control point selection and displays affine transformation
results.

It requires [`TIFFStack`] to load TIFF files. Interleaved multichannel TIFFs
are supported. The number of channels must be specified before loading.

  [Matlab]: http://mathworks.com/
  [`TIFFStack`]: http://github.com/DylanMuir/TIFFStack/