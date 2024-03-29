# Refuse to compile with explicitly unsupported old version
equals(QT_MAJOR_VERSION, $$DUBO_MINIMUM_QT_MAJOR):lessThan(QT_MINOR_VERSION, $$DUBO_MINIMUM_QT_MINOR)|lessThan(QT_MAJOR_VERSION, $$DUBO_MINIMUM_QT_MAJOR){
    error("$$DUBO_PROJECT_NAME works only with Qt $$DUBO_MINIMUM_QT or greater (you have $$QT_VERSION, and this project requires $$DUBO_MINIMUM_QT_MAJOR.$$DUBO_MINIMUM_QT_MINOR)")
}

# QT basic config
DEFINES +=  QT_NO_CAST_FROM_ASCII \ # http://doc.qt.io/qt-5/qstring.html
            QT_NO_CAST_TO_ASCII \ # ibid
            QT_USE_QSTRINGBUILDER \ # ditto
            QT_STRICT_ITERATORS \ # https://wiki.qt.io/Iterators#QT_STRICT_ITERATORS
            QT_USE_FAST_CONCATENATION \ # XXX still used?
            QT_USE_FAST_OPERATOR_PLUS # XXX still used?

# To validate with breakpad
CONFIG += warn_on qt thread exceptions rtti stl c++17 strict_c++ strict_c

# The following define makes your compiler emit warnings if you use
# any feature of Qt which has been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x050F00    # disables all the APIs deprecated before Qt 5.15.0

# Version for app or library
VER_MAJ = $$DUBO_PROJECT_VERSION_MAJOR
VER_MIN = $$DUBO_PROJECT_VERSION_MINOR
VER_PAT = $$DUBO_PROJECT_VERSION_PATCH
VERSION = $${DUBO_PROJECT_VERSION_MAJOR}.$${DUBO_PROJECT_VERSION_MINOR}.$${DUBO_PROJECT_VERSION_PATCH}

# No debug
!CONFIG(debug, debug|release){
    CONFIG -= debug declarative_debug
    DEFINES += NDEBUG
}

# Setting path
VARIED_DIR = $$basename(QMAKE_CC)-qt$${QT_MAJOR_VERSION}.$${QT_MINOR_VERSION}-$${DUBO_LINK_TYPE}-$${DUBO_BUILD_TYPE}
TMP_BASE_DIR = $${PROJECT_ROOT}/../buildd/$${DUBO_PLATFORM}-tmp/$${VARIED_DIR}/$$TARGET
RCC_DIR     = $${TMP_BASE_DIR}/rcc
UI_DIR      = $${TMP_BASE_DIR}/ui
MOC_DIR     = $${TMP_BASE_DIR}/moc
OBJECTS_DIR = $${TMP_BASE_DIR}/obj
DESTDIR     = $${PROJECT_ROOT}/../buildd/$${DUBO_PLATFORM}/$${VARIED_DIR}

# If we don't have a specific destination directory
!isEmpty(DUBO_DESTDIR){
    DESTDIR = $${DUBO_DESTDIR}
}

contains(DUBO_LINK_TYPE, static){
    DEFINES += LIB$$upper($$TARGET)_USE_STATIC
}

# Only relevant for libs: enable dep tracking
contains(TEMPLATE, lib){
    CONFIG += absolute_library_soname

    # Define for the global files
    DEFINES += LIB$$upper($$TARGET)_LIBRARY

    # Linking against third-party libs if any
    !isEmpty(DUBO_EXTERNAL){
        INCLUDEPATH += $${DUBO_EXTERNAL}/include
        exists( $${DUBO_EXTERNAL}/lib) {
            LIBS += -L$${DUBO_EXTERNAL}/lib
        }
        mac{
            exists( $${DUBO_EXTERNAL}/Frameworks ) {
                QMAKE_LFLAGS += -F$${DUBO_EXTERNAL}/Frameworks
            }
        }
        !isEmpty(DUBO_INC){
            INCLUDEPATH += $${DUBO_EXTERNAL}/$${DUBO_INC}
        }
    }

    # Add custom flags to link against third-party, if any necessary
    LIBS += $$DUBO_LIBS

    CONFIG += create_prl
    DESTDIR = $${DESTDIR}/lib
    contains(DUBO_LINK_TYPE, static){
        CONFIG += static
        CONFIG += staticlib
    }
    contains(DUBO_LINK_TYPE, dynamic){
        CONFIG += shared
        CONFIG += dll
    }

    #redist.files = $$PROJECT_ROOT/../res/redist/*
    #redist.path = $$DESTDIR/../share/lib$${TARGET}
    #INSTALLS += redist
    copyToDestdir($$PROJECT_ROOT/res/redist/*, $$DESTDIR/../share/lib$${TARGET})
    copyToDestdir($$PROJECT_ROOT/src/lib$${TARGET}/*.h, $$DESTDIR/../include/lib$${TARGET})
}

# Allow app to read prl, conversely
contains(TEMPLATE, app){
    CONFIG += link_prl

    INCLUDEPATH +=  $$DESTDIR/include
    LIBS += -L$$DESTDIR/lib

    DESTDIR = $${DESTDIR}/bin
}

# XXXdmp check on windows
#unix{
contains(TEMPLATE, lib)|contains(TEMPLATE, app){
    target.path = $$DESTDIR
    INSTALLS += target
}
#}
