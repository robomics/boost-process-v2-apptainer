<!--
Copyright (C) 2025 Roberto Rossini <roberros@uio.no>

SPDX-License-Identifier: GPL-3.0

This library is free software: you can redistribute it and/or
modify it under the terms of the GNU Public License as published
by the Free Software Foundation; either version 3 of the License,
or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Public License along
with this library.  If not, see
<https://www.gnu.org/licenses/>.
-->

# README

This repository hosts the code required to reproduce errors like `Bad file descriptor` when spawning processes using
Boost.Process v2 inside an Apptainer container under specific conditions.

The error looks something like:

## Build the container

```bash
sudo docker build . -t test
sudo apptainer build -F /tmp/test.sif docker-daemon://test:latest
sudo chown $USER /tmp/test.sif
```

## Triggering the bug

### Running with Docker

```console
user@dev:/tmp$ sudo docker run --rm test

SUCCESS: child process successfully spawned!
waiting for the child process to return...
child process returned with exit code 0
```

### Running with Apptainer

```console
user@dev:/tmp$ apptainer run /tmp/test.sif

SUCCESS: child process successfully spawned!
waiting for the child process to return...
child process returned with exit code 0
```

### Running with Apptainer on affected systems

```console
user@dev:/tmp$ apptainer run /tmp/test.sif

FAIL: failed to spawn child process: assign: Bad file descriptor [system:9 at /root/.conan2/p/b/boost5c3076847d3bd/p/include/boost/asio/detail/impl/reactive_descriptor_service.ipp:120:33 in function 'boost::system::error_code boost::asio::detail::reactive_descriptor_service::assign(reactive_descriptor_service::implementation_type &, const native_handle_type &, boost::system::error_code &)']
INFO:    Terminating squashfuse_ll after timeout
INFO:    Timeouts can be caused by a running background process
```
