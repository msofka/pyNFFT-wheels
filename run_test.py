# From https://github.com/conda-forge/pynfft-feedstock/blob/7c29da63dbd4823b7911627488c1d36d25827feb/recipe/meta.yaml#L30-L34
import pynfft
from pynfft.nfft import NFFT

plan = NFFT(8, 8)
