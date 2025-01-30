#!/bin/bash
set -e

echo "**************** M F R O N T  B U I L D  S T A R T S  H E R E ****************"

# https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots
if [[ "${target_platform}" == osx-* ]]; then
  export LDFLAGS="$LDFLAGS -lm -lpthread -ldl -lz -lomp"
else
  export LDFLAGS="$LDFLAGS -L$PREFIX/lib -lm -lpthread -lrt -ldl -lz -lgomp"
fi

export LIBPATH="$PREFIX/lib $LIBPATH"
cmake ${CMAKE_ARGS} -Wno-dev \
         -DCMAKE_BUILD_TYPE=Release \
         -Dlocal-castem-header=ON \
         -Denable-fortran=ON \
         -Denable-aster=ON \
         -Denable-cyrano=ON \
         -DPython_ADDITIONAL_VERSIONS=${CONDA_PY} \
         -DPYTHON_INCLUDE_DIRS=${PREFIX}/include \
         -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_VER} \
         -DPYTHON_LIBRARY="${PREFIX}/lib/libpython${PY_VER}${SHLIB_EXT}" \
         -DCOMPILER_CXXFLAGS="-I${PREFIX}/include -w" \
         -Denable-python=ON \
         -Denable-python-bindings=ON \
         -Denable-portable-build=ON \
         -DCMAKE_INSTALL_PREFIX=$PREFIX \
         -DUSE_EXTERNAL_COMPILER_FLAGS=ON \
         -S . -B build

cmake --build ./build --config Release -j ${CPU_COUNT}
cmake --install ./build --verbose

echo "**************** M F R O N T  B U I L D  E N D S  H E R E ****************"
