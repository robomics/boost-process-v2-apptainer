# Copyright (C) 2025 Roberto Rossini <roberros@uio.no>
#
# SPDX-License-Identifier: GPL-3.0
#
# This library is free software: you can redistribute it and/or
# modify it under the terms of the GNU Public License as published
# by the Free Software Foundation; either version 3 of the License,
# or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Public License along
# with this library.  If not, see
# <https://www.gnu.org/licenses/>.

FROM fedora:42 AS builder

RUN dnf install -y clang clang++ cmake make python

ARG CC=clang
ARG CXX=clang++
ARG CMAKE_POLICY_VERSION_MINIMUM=3.5

RUN python3 -m venv /tmp/venv \
&& /tmp/venv/bin/pip install 'conan==2.*'

ARG PATH="${PATH}:/tmp/venv/bin"

RUN conan profile detect

RUN conan install --requires b2/5.3.1 \
                  --options='b2*:toolset=clang' \
                  --build='*'

RUN mkdir -p /tmp/src

COPY conanfile.py /tmp/src
RUN conan install /tmp/src                       \
             --build=missing                     \
             -s build_type=Release               \
             -s compiler.libcxx=libstdc++11      \
             -s compiler.cppstd=23               \
             --output-folder=/tmp/conan-env

COPY CMakeLists.txt "/tmp/src/"
COPY src "/tmp/src/src/"

RUN cmake -DCMAKE_BUILD_TYPE=Release            \
          -DCMAKE_C_COMPILER=clang              \
          -DCMAKE_CXX_COMPILER=clang++          \
          -DCMAKE_PREFIX_PATH=/tmp/conan-env    \
          -S /tmp/src                           \
          -B /tmp/build

RUN cmake --build /tmp/build \
&& cmake --install /tmp/build --component Runtime

FROM fedora:42 AS base

COPY --from=builder /usr/local/bin/main /usr/local/bin/runme

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/runme"]
