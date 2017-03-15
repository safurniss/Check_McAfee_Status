# Check_McAfee_Status
# PowerShell to check McAfee Status - Used with NSCLIENT++ & Nagios
# 
# This PowerShell script will check registry keys for McAfee based
# on the following parameters which need to be supplied:-
#
#		-AgentVersion
#		-VScanVersion 
#		-EngineVersion 
#		-WarnDays
#		-CritDays
#
# If the values of the supplied parameters do not match then a
# Warning or Critical level will be raised back to Nagios.
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# History:
#   Version 1.x
#     Originally created by Steve Furniss
#
# Revision History
# 14/03/2017	Steve Furniss		Created 1.0
#
#
# To execute from within NSClient++
#
# [NRPE Handlers]
# check_mcafee_status = cmd /c echo scripts\Check_McAfee_Status.ps1 -AgentVersion 5.0.4.283 -VScanVersion 8.8.0.1599 -EngineVersion 5800.7501 -WarnDays 2 -CritDays 5; exit($lastexitcode) | powershell.exe -command -
#
# On the check_nrpe command include the -t 60, since it can take longer than the standard 10 seconds to run.
