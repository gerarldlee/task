////////////////////////////////////////////////////////////////////////////////
// taskwarrior - a command line task list manager.
//
// Copyright 2006-2012, Paul Beckingham, Federico Hernandez.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// http://www.opensource.org/licenses/mit-license.php
//
////////////////////////////////////////////////////////////////////////////////

#define L10N                                           // Localization complete.

#include <iostream>
#include <inttypes.h>
#include <Context.h>
#include <Socket.h>
#include <text.h>
#include <i18n.h>
#include <CmdSync.h>

extern Context context;

////////////////////////////////////////////////////////////////////////////////
CmdSync::CmdSync ()
{
  _keyword     = "synchronize";
  _usage       = "task          synchronize";
  _description = STRING_CMD_SYNC_USAGE;
  _read_only   = false;
  _displays_id = true;
}

////////////////////////////////////////////////////////////////////////////////
int CmdSync::execute (std::string& output)
{
  // If no server is set up, quit.
  std::string connection = context.config.get ("taskd.server");
  if (connection == "" ||
      connection.find (':') == std::string::npos)
    throw std::string (STRING_CMD_SYNC_NO_SERVER);

  // Obtain credentials.
  std::string credentials = context.config.get ("taskd.credentials");

  // TODO Read backlog.data.
  // TODO Send backlog.data in 'sync' request..

  // TODO Receive response.
  // TODO Apply tasks.
  // TODO Truncate backlog.data.
  // TODO Store new synch key.

  return 1;
}

////////////////////////////////////////////////////////////////////////////////
bool CmdSync::send (
  const std::string& to,
  const Msg& out,
  Msg& in)
{
  std::string::size_type colon = to.find (':');
  if (colon == std::string::npos)
    throw std::string ("ERROR: Malformed configuration setting '") + to + "'";

  std::string server = to.substr (0, colon);
  int port = strtoimax (to.substr (colon + 1).c_str (), NULL, 10);

  try
  {
    Socket s (AF_INET, SOCK_STREAM, IPPROTO_TCP);
    s.connect (server, port);
    s.write (out.serialize () + "\r\n");

    std::string response;
    s.read (response);
    s.close ();

    in.parse (response);

    // Indicate message sent.
    return true;
  }

  catch (std::string& error)
  {
    // TODO Report as diagnostics?
  }

  // Indicate message failed.
  return false;
}

////////////////////////////////////////////////////////////////////////////////