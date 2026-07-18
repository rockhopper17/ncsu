#!/bin/tcsh
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

set __mkl_tmp_cpro_path="/opt/intel/compilers_and_libraries_2020.3.279/mac"
setenv MKLROOT "${__mkl_tmp_cpro_path}/mkl"

set __mkl_tmp_script_name="mklvars.csh"
set __mkl_tmp_mod_name="mod"

set __mkl_tmp_lp64_ilp64=""
set __mkl_tmp_mod=""
set __mkl_tmp_mklvars_verbose=""

if ( $#argv == 0 ) then
    if ( $?MKLVARS_INTERFACE ) then
        set __mkl_tmp_lp64_ilp64="$MKLVARS_INTERFACE"
    endif
    if ( $?MKLVARS_MOD ) then
        set __mkl_tmp_mod="$MKLVARS_MOD"
    endif
    if ( $?MKLVARS_VERBOSE ) then
        set __mkl_tmp_mklvars_verbose="$MKLVARS_VERBOSE"
    endif
else
  while ( "$1" != "" )
    if      ( "$1" == "intel64"   ) then
        set __mkl_tmp_empty=""
    else if ( "$1" == "lp64"      ) then
        set __mkl_tmp_lp64_ilp64="lp64"
    else if ( "$1" == "ilp64"     ) then
        set __mkl_tmp_lp64_ilp64="ilp64"
    else if ( "$1" == ${__mkl_tmp_mod_name} ) then
        set __mkl_tmp_mod="${__mkl_tmp_mod_name}"
    else if ( "$1" == "verbose"   ) then
        set __mkl_tmp_mklvars_verbose="verbose"
    else
        echo
        echo "ERROR: Unknown option '$1'"
        goto Help
    endif
    shift
  end
endif

set __tbb_target_arch_path=""
if ( ! ${?TBBROOT} ) then
    set __tbb_path="${__mkl_tmp_cpro_path}/tbb/lib"
    if ( -d "${__tbb_path}" ) then
        set __tbb_target_arch_path=":${__tbb_path}"
    endif
endif

set __tmp_dyld_library_path="${__mkl_tmp_cpro_path}/compiler/lib:${MKLROOT}/lib${__tbb_target_arch_path}"
set __tmp_library_path="${__mkl_tmp_cpro_path}/compiler/lib:${MKLROOT}/lib${__tbb_target_arch_path}"
set __tmp_nlspath="${MKLROOT}/lib/locale/%l_%t/%N"

set __tmp_cpath="${MKLROOT}/include"
if ( "${__mkl_tmp_mod}" == "${__mkl_tmp_mod_name}" ) then
    if ( "$__mkl_tmp_lp64_ilp64" == "" ) then
        set __mkl_tmp_lp64_ilp64="lp64"
    endif

    set __tmp_cpath="${MKLROOT}/include/intel64_mac/${__mkl_tmp_lp64_ilp64}:${__tmp_cpath}"
endif

if ( ${?DYLD_LIBRARY_PATH} ) then
    setenv DYLD_LIBRARY_PATH "${__tmp_dyld_library_path}:${DYLD_LIBRARY_PATH}"
else
    setenv DYLD_LIBRARY_PATH "${__tmp_dyld_library_path}"
endif
if ( ${?LIBRARY_PATH} ) then
    setenv LIBRARY_PATH "${__tmp_library_path}:${LIBRARY_PATH}"
else
    setenv LIBRARY_PATH "${__tmp_library_path}"
endif
if ( ${?NLSPATH} ) then
    setenv NLSPATH "${__tmp_nlspath}:${NLSPATH}"
else
    setenv NLSPATH "${__tmp_nlspath}"
endif
if ( ${?CPATH} ) then
    setenv CPATH "${__tmp_cpath}:${CPATH}"
else
    setenv CPATH "${__tmp_cpath}"
endif
if ( ${?PKG_CONFIG_PATH} ) then
    setenv PKG_CONFIG_PATH "${MKLROOT}/bin/pkgconfig:${PKG_CONFIG_PATH}"
else
    setenv PKG_CONFIG_PATH "${MKLROOT}/bin/pkgconfig"
endif

if ( "${__mkl_tmp_mklvars_verbose}" == "verbose" ) then
    echo DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}
    echo LIBRARY_PATH=${LIBRARY_PATH}
    echo NLSPATH=${NLSPATH}
    echo CPATH=${CPATH}
    echo PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
endif

goto End

Help:
    echo ""
    echo "Syntax:"
    echo "  source $__mkl_tmp_script_name [MKL_interface] [${__mkl_tmp_mod_name}]"
    echo ""
    echo "   ${__mkl_tmp_mod_name} (optional) - set path to Intel(R) MKL F95 modules"
    echo ""
    echo "   MKL_interface (optional) - Intel(R) MKL programming interface for intel64"
    echo "                              Not applicable without ${__mkl_tmp_mod_name}"
    echo "       lp64         : 4 bytes integer (default)"
    echo "       ilp64        : 8 bytes integer"
    echo ""
    echo "If the arguments to the sourced script are ignored (consult docs for"
    echo "your shell) the alternative way to specify target is environment"
    echo "variables COMPILERVARS_ARCHITECTURE or MKLVARS_ARCHITECTURE to pass"
    echo "<arch> to the script, MKLVARS_INTERFACE to pass <MKL_interface> and"
    echo "MKLVARS_MOD to pass <__mkl_tmp_mod_name>"
    echo ""
    exit 1;

End: # Clean up of internal settings
    unset __mkl_tmp_cpro_path
    unset __mkl_tmp_script_name
    unset __mkl_tmp_mod
    unset __mkl_tmp_mod_name
    unset __mkl_tmp_lp64_ilp64
    unset __mkl_tmp_mklvars_verbose
    unset __tbb_path
    unset __tbb_target_arch_path
    unset __tmp_dyld_library_path
    unset __tmp_library_path
    unset __tmp_nlspath
    unset __tmp_cpath
