# Modified build_github:
function build_nfft {
    # Example: build_nfft fredrik-johansson/arb 2.11.1
    local path=$1
    local version=$2
    local configure_args=${@:3}
    local name=`basename "$path"`
    # This is tricky. If the version name starts with a "v",
    # then the archive name will not start with a "v"
    if [[ $version == v* ]]; then
        local name_version="${name}-${version:1}"
    else
        local name_version="${name}-${version}"
    fi
    if [ -e "${name}-stamp" ]; then
        return
    fi
    # fetch_unpack "https://github.com/${path}/archive/${version}.tar.gz"
    # From: https://github.com/conda-forge/nfft-feedstock/blob/afa706da1d537da38f232c12b74e7a13f06f639a/recipe/meta.yaml#L9
    fetch_unpack "https://www-user.tu-chemnitz.de/~potts/nfft/download/nfft-${version}.tar.gz"
    # From: https://github.com/conda-forge/nfft-feedstock/blob/afa706da1d537da38f232c12b74e7a13f06f639a/recipe/build.sh
    (cd $name_version \
        && ./bootstrap.sh \
        && ./configure --prefix=$BUILD_PREFIX $configure_args \
        && make -j4 \
        && make check \
        && make install)
    touch "${name}-stamp"
}

function pre_build {
    echo "Starting pre-build"

    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.

    build_fftw

    export STATIC_FFTW_DIR=$BUILD_PREFIX/lib
    export INCLUDE_FFTW_DIR=$BUILD_PREFIX/include

    set -v
    echo "Build nfft"
    # From: https://github.com/conda-forge/nfft-feedstock/blob/afa706da1d537da38f232c12b74e7a13f06f639a/recipe/build.sh#L6-L11
    build_nfft NFFT/nfft 3.2.4 \
            --enable-applications \
            --enable-all \
            --enable-openmp \
            --with-fftw3-libdir=$STATIC_FFTW_DIR \
            --with-fftw3-includedir=$INCLUDE_FFTW_DIR \
            --with-window=kaiserbessel

    export C_INCLUDE_PATH=$BUILD_PREFIX/include

    # TODO: add tests from: https://github.com/conda-forge/nfft-feedstock/blob/afa706da1d537da38f232c12b74e7a13f06f639a/recipe/meta.yaml#L28-L34

    ls -l $C_INCLUDE_PATH/
    ls -l $BUILD_PREFIX/lib
}

function run_tests {
    echo "Starting tests..."
    python ../run_test.py
}
