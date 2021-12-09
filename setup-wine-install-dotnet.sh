#!/bin/bash

# Install .NET
echo "-------------- INSTALLING .NET ---------------"
#WINETRICKS=winetricks
#WINETRICKS="${DIR}"/winetricks/src/winetricks
"${WINETRICKS}" -q dotnet452
"${WINETRICKS}" win7
