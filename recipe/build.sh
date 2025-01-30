#!/bin/bash
set -e

echo "**************** M F R O N T  B U I L D  S T A R T S  H E R E ****************"

# https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots
if [[ "${target_platform}" == osx-* ]]; then
  export LDFLAGS="$LDFLAGS -lm -lpthread -ldl -lz -lomp"
  export LIBPATH="$PREFIX/lib $LIBPATH"
  export SUFFIX=.dylib
else
  export LDFLAGS="$LDFLAGS -L$PREFIX/lib -lm -lpthread -lrt -ldl -lz -lgomp"
  export LIBPATH="$PREFIX/lib $LIBPATH"
  export SUFFIX=.so
fi

cmake ${CMAKE_ARGS} -Wno-dev \
         -D CMAKE_PREFIX_PATH=$PREFIX \
         -D CMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
         -D Python3_EXECUTABLE="${PYTHON}" \
         -D PYTHON_LIBRARIES="${PREFIX}/lib/libpython${PY_VER}${SUFFIX}" \
         -D PYTHON_EXECUTABLE:FILEPATH=$PYTHON \
         -D PYTHON_INCLUDE_DIRS="${PREFIX}/include" \
         -D COMPILER_CXXFLAGS="-I${PREFIX}/include -w" \
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