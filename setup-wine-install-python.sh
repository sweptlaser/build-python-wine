#!/bin/bash
set -o errexit

echo "-------------- STARTING INSTALL PYTHON -------------------"
#  Python 3.7.3
if [ "${WINEARCH}" = "win32" ]; then
    PYTHON_INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Windows-x86.exe";
else
    PYTHON_INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Windows-x86_64.exe";
fi

echo "-------------- DOWNLOAD PYTHON ---------------"
PYTHON_INSTALLER=$(echo "${PYTHON_INSTALLER_URL}" | sed "s|^.*/|${CACHEDIR}/|");
if [ ! -f "${PYTHON_INSTALLER}" ]; then
    mkdir -p "${CACHEDIR}" 2>/dev/null || true;
    wget "${PYTHON_INSTALLER_URL}" -O "${PYTHON_INSTALLER}";
fi

echo "-------------- INSTALL MINICONDA ---------------"
"${WINE}" "${PYTHON_INSTALLER}" /S /RegisterPython=1 /AddToPath=1 /D=C:\\ProgramData\\Miniconda3

export WINE_PYTHON_PATH=$("${WINE}" python -c 'import os; import sys; print(os.path.dirname(sys.executable));' 2>/dev/null | tr --delete '\r\n');
export PYTHON_PATH=$(echo "${WINEPREFIX}/${WINE_PYTHON_PATH}" | sed -e 's|C:|drive_c|' -e 's|\\|/|g');

## Work around wine missing "chcp" (change codepage)
if [ ! -f "${WINEPREFIX}"/drive_c/windows/system32/chcp.com ]; then
    echo "#!/bin/bash" > "${WINEPREFIX}"/drive_c/windows/system32/chcp.com
    chmod +x "${WINEPREFIX}"/drive_c/windows/system32/chcp.com
    if [ "${WINEARCH}" != "win32" ]; then
        echo "#!/bin/bash" > "${WINEPREFIX}"/drive_c/windows/syswow64/chcp.com
        chmod +x "${WINEPREFIX}"/drive_c/windows/syswow64/chcp.com
    fi
fi

## Setup all the Python packages that we need for common builds
DEPENDENCIES="\
    python=3.7 \
    boost=1.68.0 \
    numpy=1.15.4 \
    cython=0.29.13 \
    pkgconfig=1.3.1 \
    python-dateutil=2.8.0 \
";
"${WINE}" conda install -y -c conda-forge ${DEPENDENCIES}

DEPENDENCIES="\
    scipy=1.3.1 \
";
"${WINE}" conda install -y ${DEPENDENCIES}

echo "-------------- DONE INSTALL PYTHON -------------------"