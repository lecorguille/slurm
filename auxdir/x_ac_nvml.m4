##*****************************************************************************
#  AUTHOR:
#    Michael Hinton <hinton@schedmd.com>
#
#  SYNOPSIS:
#    X_AC_NVML
#
#  DESCRIPTION:
#    Determine if NVIDIA's NVML API library exists (comes with CUDA)
##*****************************************************************************

AC_DEFUN([X_AC_NVML],
[
  _x_ac_nvml_dirs="/usr/local/cuda /usr/cuda"
  _x_ac_nvml_libs="lib64 lib"

  AC_ARG_WITH(
    [nvml],
    AS_HELP_STRING(--with-nvml=PATH, Specify path to nvml installation),
    [AS_IF([test "x$with_nvml" != xno && test "x$with_nvml" != xyes],
           [_x_ac_nvml_dirs="$with_nvml"])])

  if [test "x$with_nvml" = xno]; then
     AC_MSG_WARN([support for nvml disabled])
  else
    for d in $_x_ac_nvml_dirs; do
      for bit in $_x_ac_nvml_libs; do
        _x_ac_nvml_ldflags_save="$LDFLAGS"
        _x_ac_nvml_cppflags_save="$CPPFLAGS"
        LDFLAGS="-L$d/$bit -lnvidia-ml"
        CPPFLAGS="-I$d/include $CPPFLAGS"
        AC_CHECK_HEADER([nvml.h], [ac_nvml_h=yes], [ac_nvml_h=no])
        AC_CHECK_LIB([nvidia-ml], [nvmlInit], [ac_nvml=yes], [ac_nvml=no])
        LDFLAGS="$_x_ac_nvml_ldflags_save"
        CPPFLAGS="$_x_ac_nvml_cppflags_save"
        if [ test "$ac_nvml" = "yes" && test "$ac_nvml_h" = "yes" ]; then
          nvml_includes="-I$d/include"
          nvml_libs="-L$d/$bit -lnvidia-ml"
          break
        fi
      done
      if [ test "$ac_nvml" = "yes" && test "$ac_nvml_h" = "yes" ]; then
        break
      fi
    done

    if [ test "$ac_nvml" = "yes" && test "$ac_nvml_h" = "yes" ]; then
      NVML_LIBS="$nvml_libs"
      NVML_CPPFLAGS="$nvml_includes"
      AC_DEFINE(HAVE_NVML, 1, [Define to 1 if NVML library found])
    else
      if test -z "$with_nvml"; then
        AC_MSG_WARN([unable to locate libnvidia-ml.so and/or nvml.h])
      else
        AC_MSG_ERROR([unable to locate libnvidia-ml.so and/or nvml.h])
      fi
    fi

    AC_SUBST(NVML_LIBS)
    AC_SUBST(NVML_CPPFLAGS)
  fi
  AM_CONDITIONAL(BUILD_NVML, test "$ac_nvml" = "yes" && test "$ac_nvml_h" = "yes")
])
