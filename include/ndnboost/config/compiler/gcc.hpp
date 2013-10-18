//  (C) Copyright John Maddock 2001 - 2003. 
//  (C) Copyright Darin Adler 2001 - 2002. 
//  (C) Copyright Jens Maurer 2001 - 2002. 
//  (C) Copyright Beman Dawes 2001 - 2003. 
//  (C) Copyright Douglas Gregor 2002. 
//  (C) Copyright David Abrahams 2002 - 2003. 
//  (C) Copyright Synge Todo 2003. 
//  Use, modification and distribution are subject to the 
//  Boost Software License, Version 1.0. (See accompanying file 
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

//  See http://www.boost.org for most recent version.

//  GNU C++ compiler setup.

//
// Define NDNBOOST_GCC so we know this is "real" GCC and not some pretender:
//
#if !defined(__CUDACC__)
#define NDNBOOST_GCC (__GNUC__ * 10000 + __GNUC_MINOR__ * 100 + __GNUC_PATCHLEVEL__)
#endif

#if __GNUC__ < 3
#   if __GNUC_MINOR__ == 91
       // egcs 1.1 won't parse shared_ptr.hpp without this:
#      define NDNBOOST_NO_AUTO_PTR
#   endif
#   if __GNUC_MINOR__ < 95
      //
      // Prior to gcc 2.95 member templates only partly
      // work - define NDNBOOST_MSVC6_MEMBER_TEMPLATES
      // instead since inline member templates mostly work.
      //
#     define NDNBOOST_NO_MEMBER_TEMPLATES
#     if __GNUC_MINOR__ >= 9
#       define NDNBOOST_MSVC6_MEMBER_TEMPLATES
#     endif
#   endif

#   if __GNUC_MINOR__ < 96
#     define NDNBOOST_NO_SFINAE
#   endif

#   if __GNUC_MINOR__ <= 97
#     define NDNBOOST_NO_MEMBER_TEMPLATE_FRIENDS
#     define NDNBOOST_NO_OPERATORS_IN_NAMESPACE
#   endif

#   define NDNBOOST_NO_USING_DECLARATION_OVERLOADS_FROM_TYPENAME_BASE
#   define NDNBOOST_FUNCTION_SCOPE_USING_DECLARATION_BREAKS_ADL
#   define NDNBOOST_NO_IS_ABSTRACT
#   define NDNBOOST_NO_CXX11_EXTERN_TEMPLATE
// Variadic macros do not exist for gcc versions before 3.0
#   define NDNBOOST_NO_CXX11_VARIADIC_MACROS
#elif __GNUC__ == 3
#  if defined (__PATHSCALE__)
#     define NDNBOOST_NO_TWO_PHASE_NAME_LOOKUP
#     define NDNBOOST_NO_IS_ABSTRACT
#  endif
   //
   // gcc-3.x problems:
   //
   // Bug specific to gcc 3.1 and 3.2:
   //
#  if ((__GNUC_MINOR__ == 1) || (__GNUC_MINOR__ == 2))
#     define NDNBOOST_NO_EXPLICIT_FUNCTION_TEMPLATE_ARGUMENTS
#  endif
#  if __GNUC_MINOR__ < 4
#     define NDNBOOST_NO_IS_ABSTRACT
#  endif
#  define NDNBOOST_NO_CXX11_EXTERN_TEMPLATE
#endif
#if __GNUC__ < 4
//
// All problems to gcc-3.x and earlier here:
//
#define NDNBOOST_NO_TWO_PHASE_NAME_LOOKUP
#  ifdef __OPEN64__
#     define NDNBOOST_NO_IS_ABSTRACT
#  endif
#endif

#if __GNUC__ < 4 || ( __GNUC__ == 4 && __GNUC_MINOR__ < 4 )
// Previous versions of GCC did not completely implement value-initialization:
// GCC Bug 30111, "Value-initialization of POD base class doesn't initialize
// members", reported by Jonathan Wakely in 2006,
// http://gcc.gnu.org/bugzilla/show_bug.cgi?id=30111 (fixed for GCC 4.4)
// GCC Bug 33916, "Default constructor fails to initialize array members",
// reported by Michael Elizabeth Chastain in 2007,
// http://gcc.gnu.org/bugzilla/show_bug.cgi?id=33916 (fixed for GCC 4.2.4)
// See also: http://www.boost.org/libs/utility/value_init.htm#compiler_issues
#define NDNBOOST_NO_COMPLETE_VALUE_INITIALIZATION
#endif

#if !defined(__EXCEPTIONS) && !defined(NDNBOOST_NO_EXCEPTIONS)
# define NDNBOOST_NO_EXCEPTIONS
#endif


//
// Threading support: Turn this on unconditionally here (except for
// those platforms where we can know for sure). It will get turned off again
// later if no threading API is detected.
//
#if !defined(__MINGW32__) && !defined(linux) && !defined(__linux) && !defined(__linux__)
# define NDNBOOST_HAS_THREADS
#endif 

//
// gcc has "long long"
//
#define NDNBOOST_HAS_LONG_LONG

//
// gcc implements the named return value optimization since version 3.1
//
#if __GNUC__ > 3 || ( __GNUC__ == 3 && __GNUC_MINOR__ >= 1 )
#define NDNBOOST_HAS_NRVO
#endif

//
// Dynamic shared object (DSO) and dynamic-link library (DLL) support
//
#if __GNUC__ >= 4
#  if (defined(_WIN32) || defined(__WIN32__) || defined(WIN32)) && !defined(__CYGWIN__)
     // All Win32 development environments, including 64-bit Windows and MinGW, define 
     // _WIN32 or one of its variant spellings. Note that Cygwin is a POSIX environment,
     // so does not define _WIN32 or its variants.
#    define NDNBOOST_HAS_DECLSPEC
#    define NDNBOOST_SYMBOL_EXPORT __attribute__((dllexport))
#    define NDNBOOST_SYMBOL_IMPORT __attribute__((dllimport))
#  else
#    define NDNBOOST_SYMBOL_EXPORT __attribute__((visibility("default")))
#    define NDNBOOST_SYMBOL_IMPORT
#  endif
#  define NDNBOOST_SYMBOL_VISIBLE __attribute__((visibility("default")))
#else
// config/platform/win32.hpp will define NDNBOOST_SYMBOL_EXPORT, etc., unless already defined  
#  define NDNBOOST_SYMBOL_EXPORT
#endif

//
// RTTI and typeinfo detection is possible post gcc-4.3:
//
#if __GNUC__ * 100 + __GNUC_MINOR__ >= 403
#  ifndef __GXX_RTTI
#     ifndef NDNBOOST_NO_TYPEID
#        define NDNBOOST_NO_TYPEID
#     endif
#     ifndef NDNBOOST_NO_RTTI
#        define NDNBOOST_NO_RTTI
#     endif
#  endif
#endif

//
// Recent GCC versions have __int128 when in 64-bit mode.
//
// We disable this if the compiler is really nvcc as it
// doesn't actually support __int128 as of CUDA_VERSION=5000
// even though it defines __SIZEOF_INT128__.  
// See https://svn.boost.org/trac/boost/ticket/8048
// Only re-enable this for nvcc if you're absolutely sure
// of the circumstances under which it's supported:
//
#if defined(__SIZEOF_INT128__) && !defined(__CUDACC__)
#  define NDNBOOST_HAS_INT128
#endif

// C++0x features in 4.3.n and later
//
#if (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ > 2)) && defined(__GXX_EXPERIMENTAL_CXX0X__)
// C++0x features are only enabled when -std=c++0x or -std=gnu++0x are
// passed on the command line, which in turn defines
// __GXX_EXPERIMENTAL_CXX0X__.
#  define NDNBOOST_HAS_DECLTYPE
#  define NDNBOOST_HAS_RVALUE_REFS
#  define NDNBOOST_HAS_STATIC_ASSERT
#  define NDNBOOST_HAS_VARIADIC_TMPL
#else
#  define NDNBOOST_NO_CXX11_DECLTYPE
#  define NDNBOOST_NO_CXX11_FUNCTION_TEMPLATE_DEFAULT_ARGS
#  define NDNBOOST_NO_CXX11_RVALUE_REFERENCES
#  define NDNBOOST_NO_CXX11_STATIC_ASSERT

// Variadic templates compiler: 
//   http://www.generic-programming.org/~dgregor/cpp/variadic-templates.html
#  if defined(__VARIADIC_TEMPLATES) || (__GNUC__ > 4) || ((__GNUC__ == 4) && (__GNUC_MINOR__ >= 4) && defined(__GXX_EXPERIMENTAL_CXX0X__))
#    define NDNBOOST_HAS_VARIADIC_TMPL
#  else
#    define NDNBOOST_NO_CXX11_VARIADIC_TEMPLATES
#  endif
#endif

// C++0x features in 4.4.n and later
//
#if __GNUC__ < 4 || (__GNUC__ == 4 && __GNUC_MINOR__ < 4) || !defined(__GXX_EXPERIMENTAL_CXX0X__)
#  define NDNBOOST_NO_CXX11_AUTO_DECLARATIONS
#  define NDNBOOST_NO_CXX11_AUTO_MULTIDECLARATIONS
#  define NDNBOOST_NO_CXX11_CHAR16_T
#  define NDNBOOST_NO_CXX11_CHAR32_T
#  define NDNBOOST_NO_CXX11_HDR_INITIALIZER_LIST
#  define NDNBOOST_NO_CXX11_DEFAULTED_FUNCTIONS
#  define NDNBOOST_NO_CXX11_DELETED_FUNCTIONS
#endif

#if __GNUC__ < 4 || (__GNUC__ == 4 && __GNUC_MINOR__ < 5)
#  define NDNBOOST_NO_SFINAE_EXPR
#endif

// C++0x features in 4.5.0 and later
//
#if __GNUC__ < 4 || (__GNUC__ == 4 && __GNUC_MINOR__ < 5) || !defined(__GXX_EXPERIMENTAL_CXX0X__)
#  define NDNBOOST_NO_CXX11_EXPLICIT_CONVERSION_OPERATORS
#  define NDNBOOST_NO_CXX11_LAMBDAS
#  define NDNBOOST_NO_CXX11_LOCAL_CLASS_TEMPLATE_PARAMETERS
#  define NDNBOOST_NO_CXX11_RAW_LITERALS
#  define NDNBOOST_NO_CXX11_UNICODE_LITERALS
#endif

// C++0x features in 4.5.1 and later
//
#if (__GNUC__*10000 + __GNUC_MINOR__*100 + __GNUC_PATCHLEVEL__ < 40501) || !defined(__GXX_EXPERIMENTAL_CXX0X__)
// scoped enums have a serious bug in 4.4.0, so define NDNBOOST_NO_CXX11_SCOPED_ENUMS before 4.5.1
// See http://gcc.gnu.org/bugzilla/show_bug.cgi?id=38064
#  define NDNBOOST_NO_CXX11_SCOPED_ENUMS
#endif

// C++0x features in 4.6.n and later
//
#if __GNUC__ < 4 || (__GNUC__ == 4 && __GNUC_MINOR__ < 6) || !defined(__GXX_EXPERIMENTAL_CXX0X__)
#define NDNBOOST_NO_CXX11_CONSTEXPR
#define NDNBOOST_NO_CXX11_NOEXCEPT
#define NDNBOOST_NO_CXX11_NULLPTR
#define NDNBOOST_NO_CXX11_RANGE_BASED_FOR
#define NDNBOOST_NO_CXX11_UNIFIED_INITIALIZATION_SYNTAX
#endif

// C++0x features in 4.7.n and later
//
#if __GNUC__ < 4 || (__GNUC__ == 4 && __GNUC_MINOR__ < 7) || !defined(__GXX_EXPERIMENTAL_CXX0X__)
#  define NDNBOOST_NO_CXX11_TEMPLATE_ALIASES
#  define NDNBOOST_NO_CXX11_USER_DEFINED_LITERALS
#endif

// C++0x features in 4.8.1 and later
//
#if (__GNUC__*10000 + __GNUC_MINOR__*100 + __GNUC_PATCHLEVEL__ < 40801) || !defined(__GXX_EXPERIMENTAL_CXX0X__)
#  define NDNBOOST_NO_CXX11_DECLTYPE_N3276
#endif

#ifndef NDNBOOST_COMPILER
#  define NDNBOOST_COMPILER "GNU C++ version " __VERSION__
#endif

// ConceptGCC compiler:
//   http://www.generic-programming.org/software/ConceptGCC/
#ifdef __GXX_CONCEPTS__
#  define NDNBOOST_HAS_CONCEPTS
#  define NDNBOOST_COMPILER "ConceptGCC version " __VERSION__
#endif

// versions check:
// we don't know gcc prior to version 2.90:
#if (__GNUC__ == 2) && (__GNUC_MINOR__ < 90)
#  error "Compiler not configured - please reconfigure"
#endif
//
// last known and checked version is 4.6 (Pre-release):
#if (__GNUC__ > 4) || ((__GNUC__ == 4) && (__GNUC_MINOR__ > 6))
#  if defined(NDNBOOST_ASSERT_CONFIG)
#     error "Unknown compiler version - please run the configure tests and report the results"
#  else
// we don't emit warnings here anymore since there are no defect macros defined for
// gcc post 3.4, so any failures are gcc regressions...
//#     warning "Unknown compiler version - please run the configure tests and report the results"
#  endif
#endif

