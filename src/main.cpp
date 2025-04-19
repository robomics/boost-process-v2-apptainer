// Copyright (C) 2025 Roberto Rossini <roberros@uio.no>
//
// SPDX-License-Identifier: GPL-3.0
//
// This library is free software: you can redistribute it and/or
// modify it under the terms of the GNU Public License as published
// by the Free Software Foundation; either version 3 of the License,
// or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
//
// You should have received a copy of the GNU Public License along
// with this library.  If not, see
// <https://www.gnu.org/licenses/>.

#include <boost/asio/io_context.hpp>
#include <boost/process/v2/environment.hpp>
#include <boost/process/v2/process.hpp>
#include <boost/process/v2/stdio.hpp>
#include <cstdio>
#include <print>

int main() {
  try {
    boost::asio::io_context ctx;
    boost::process::process proc(ctx, boost::process::environment::find_executable("sleep"), {"5"});
    if (proc.running() || proc.exit_code() == 0) {
      std::println(stderr, "SUCCESS: child process successfully spawned!");
      std::println(stderr, "waiting for the child process to return...");
      proc.wait();
      std::println(stderr, "child process returned with exit code {}", proc.exit_code());
      return proc.exit_code();
    }
    std::println(stderr, "FAIL: failed to spawn child process. Exit code: {}", proc.exit_code());

  } catch (const std::exception &e) {
    std::println(stderr, "FAIL: failed to spawn child process: {}", e.what());
  } catch (...) {
    std::println(stderr, "FAIL: failed to spawn child process: unknown error");
  }
  return 1;
}
