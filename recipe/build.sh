#!/bin/bash
set -e

echo "**************** M F R O N T  B U I L D  S T A R T S  H E R E ****************"

# https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots
if [[ "${target_platform}" == osx-* ]]; then
  export LDFLAGS="-L$PREFIX/lib -lm -lpthread -ldl -lz -lomp"
  export LDFLAGS="$LDFLAGS -Wl,-flat_namespace,-undefined,suppress"
  export LIBPATH="$PREFIX/lib $LIBPATH"
else
  export LDFLAGS="-L$PREFIX/lib -lm -lpthread -lrt -ldl -lz -lgomp"
  export LIBPATH="$PREFIX/lib $LIBPATH"
fi

# Debug printing
echo "PYTHON: $PYTHON"
echo "PREFIX: $PREFIX"
echo "CMAKE_ARGS: $CMAKE_ARGS"
echo "CMAKE_PLATFORM_FLAGS: $CMAKE_PLATFORM_FLAGS"

cmake ${CMAKE_ARGS} -Wno-dev \
         -D CMAKE_PREFIX_PATH=$PREFIX \
         -D CMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
         ${CMAKE_PLATFORM_FLAGS[@]} \
         -D Python3_EXECUTABLE="${PYTHON}" \
         -D PYTHON_EXECUTABLE:FILEPATH=$PYTHON \
         -D PYTHON_INCLUDE_DIRS="${PREFIX}/include" \
         -D COMPILER_CXXFLAGS="-I${PREFIX}/include -w" \
         -D CMAKE_INSTALL_PREFIX=$PREFIX \
         -D local-castem-header=ON \
         -D enable-fortran=ON \
         -D enable-aster=ON \
         -D enable-cyrano=ON \
         -D enable-python=ON \
         -D enable-python-bindings=ON \
         -D enable-portable-build=ON \
         -S . -B build

cmake --build ./build --config Release -j 1 # docker gets killed with higher parallelism
cmake --install ./build --verbose

echo "**************** M F R O N T  B U I L D  E N D S  H E R E ****************"