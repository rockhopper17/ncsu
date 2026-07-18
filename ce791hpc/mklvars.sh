#!/bin/sh
#===============================================================================
# Copyright 2003-2020 Intel Corporation.
#
# This software and the related documents are Intel copyrighted  materials,  and
# your use of  them is  governed by the  express license  under which  they were
# provided to you (License).  Unless the License provides otherwise, you may not
# use, modify, copy, publish, distribute,  disclose or transmit this software or
# the related documents without Intel's prior written permission.
#
# This software and the related documents  are provided as  is,  with no express
# or implied  warranties,  other  than those  that are  expressly stated  in the
# License.
#===============================================================================

mkl_help() {
    echo ""
    echo "Syntax:"
    echo "  $SCRIPT_NAME [MKL_interface] [${MOD_NAME}]"
    echo ""
    echo "   ${MOD_NAME} (optional) - set path to Intel(R) MKL F95 modules"
    echo ""
    echo "   MKL_interface (optional) - Intel(R) MKL programming interface for intel64"
    echo "                              Not applicable without ${MOD_NAME}"
    echo "       lp64         : 4 bytes integer (default)"
    echo "       ilp64        : 8 bytes integer"
    echo ""
    echo "If the arguments to the sourced script are ignored (consult docs for"
    echo "your shell) the alternative way to specify target is environment"
    echo "variables COMPILERVARS_ARCHITECTURE or MKLVARS_ARCHITECTURE to pass"
    echo "<arch> to the script, MKLVARS_INTERFACE to pass <MKL_interface> and"
    echo "MKLVARS_MOD to pass <MKL_MOD_NAME>"
    echo ""
}

set_mkl_env() {
    CPRO_PATH="/opt/intel/compilers_and_libraries_2020.3.279/mac"
    export MKLROOT="${CPRO_PATH}/mkl"

    local SCRIPT_NAME=$0
    local MOD_NAME=mod

    local MKL_LP64_ILP64=
    local MKL_MOD=
    local MKLVARS_VERBOSE=
    local MKL_BAD_SWITCH=
    local OLD_DYLD_LIBRARY_PATH=
    local OLD_LIBRARY_PATH=
    local OLD_NLSPATH=
    local OLD_CPATH=

    if  [ -z "$1" ] ; then
      if [ -n "$MKLVARS_INTERFACE" ] ; then
        MKL_LP64_ILP64="$MKLVARS_INTERFACE"
        if [ "${MKL_LP64_ILP64}" != "lp64" -a "${MKL_LP64_ILP64}" != "ilp64" ] ; then
          MKL_LP64_ILP64=
        fi
      fi
      if [ -n "$MKLVARS_MOD" ] ; then
        MKL_MOD="$MKLVARS_MOD"
      fi
      if [ -n "$MKLVARS_VERBOSE" ] ; then
        MKLVARS_VERBOSE="$MKLVARS_VERBOSE"
      fi
    else
        while [ -n "$1" ]; do
            if   [ "$1" = "intel64" ]     ; then :
            elif [ "$1" = "lp64" ]        ; then MKL_LP64_ILP64=lp64;
            elif [ "$1" = "ilp64" ]       ; then MKL_LP64_ILP64=ilp64;
            elif [ "$1" = "${MOD_NAME}" ] ; then MKL_MOD=${MOD_NAME};
            elif [ "$1" = "verbose" ]     ; then MKLVARS_VERBOSE=verbose;
            else
                MKL_BAD_SWITCH=$1
                break 10
            fi
            shift;
        done
    fi

    if [ -n "${MKL_BAD_SWITCH}" ] ; then

      echo
      echo "ERROR: Unknown option '${MKL_BAD_SWITCH}'"
      mkl_help

    else

        typeset mkl_ld_arch="${CPRO_PATH}/compiler/lib:${MKLROOT}/lib"

        if [ -z "${TBBROOT}" ]; then
            __tbb_path="${CPRO_PATH}/tbb/lib"
            if [ -d "${__tbb_path}" ]; then
                mkl_ld_arch="${__tbb_path}:${mkl_ld_arch}"
            fi
        fi

        if [ -n "${DYLD_LIBRARY_PATH}" ]; then OLD_DYLD_LIBRARY_PATH=":${DYLD_LIBRARY_PATH}"; fi
        export DYLD_LIBRARY_PATH="${mkl_ld_arch}${OLD_DYLD_LIBRARY_PATH}"

        if [ -n "${LIBRARY_PATH}" ]; then OLD_LIBRARY_PATH=":${LIBRARY_PATH}"; fi
        export LIBRARY_PATH="${mkl_ld_arch}${OLD_LIBRARY_PATH}"

        if [ -n "${NLSPATH}" ]; then OLD_NLSPATH=":${NLSPATH}"; fi
        export NLSPATH="${MKLROOT}/lib/locale/%l_%t/%N${OLD_NLSPATH}"

        if [ -n "$CPATH" ]; then OLD_CPATH=":${CPATH}"; fi
        export CPATH="${MKLROOT}/include${OLD_CPATH}"

        if [ "${MKL_MOD}" = "${MOD_NAME}" ] ; then
            if [ -z "$MKL_LP64_ILP64" ] ; then
                MKL_LP64_ILP64=lp64
            fi
            export CPATH="${CPATH}:${MKLROOT}/include/intel64_mac/${MKL_LP64_ILP64}"
        fi

        if [ -n "${PKG_CONFIG_PATH}" ]; then OLD_PKG_CONFIG_PATH=":${PKG_CONFIG_PATH}"; fi
        export PKG_CONFIG_PATH="${MKLROOT}/bin/pkgconfig${OLD_PKG_CONFIG_PATH}"

        if [ "${MKLVARS_VERBOSE}" = "verbose" ] ; then
            echo DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}
            echo LIBRARY_PATH=${LIBRARY_PATH}
            echo NLSPATH=${NLSPATH}
            echo CPATH=${CPATH}
            echo PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
        fi
    fi
}

set_mkl_env "$@"

