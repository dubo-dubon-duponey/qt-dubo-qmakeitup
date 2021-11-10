# Boilerplate and defaults
DUBO_PROJECT_NAME = ProjectName
DUBO_BUNDLE_PREFIX = com.you-or-your-corp
DUBO_VENDOR_NAME = YourCorpName
DUBO_PROJECT_VERSION_MAJOR = 1
DUBO_PROJECT_VERSION_MINOR = 0
DUBO_PROJECT_VERSION_PATCH = 0
DUBO_MINIMUM_QT_MAJOR = 5
DUBO_MINIMUM_QT_MINOR = 6
DUBO_MIN_OSX = 10.14

DUBO_LINK_TYPE = dynamic
DUBO_INTERNAL_VERSION = blank
DUBO_INTERNAL_PATH =
DUBO_EXTERNAL =
DUBO_DESTDIR =
DUBO_LIBS =
DUBO_INC =

# Override with project specific settings and vars
exists($$PROJECT_ROOT/project.pri){
    include($$PROJECT_ROOT/project.pri)
}

mac:exists($$PROJECT_ROOT/mac.pri){
    include($$PROJECT_ROOT/mac.pri)
}

win32:exists($$PROJECT_ROOT/win.pri){
    include($$PROJECT_ROOT/win.pri)
}

!mac:!win32:exists($$PROJECT_ROOT/other.pri){
    include($$PROJECT_ROOT/other.pri)
}

# Set the target name
TARGET = $$DUBO_PROJECT_NAME

# Bundle prefix
QMAKE_TARGET_BUNDLE_PREFIX = $$DUBO_BUNDLE_PREFIX

XHOST = $$system(uname)

defineTest(copyToDestdir) {
    files = $$1
    dest = $$2

    for(FILE, files) {
        DDIR = $$dest

        !contains(XHOST, Darwin){
            # Replace slashes in paths with backslashes for Windows
            win32:FILE ~= s,/,\\,g
            win32:DDIR ~= s,/,\\,g
        }

        !contains(XHOST, Darwin):win32{
            system(mkdir $$quote($$DDIR))
        }else{
            system(mkdir -p $$quote($$DDIR))
        }

        QMAKE_POST_LINK += $$QMAKE_COPY $$quote($$FILE) $$quote($$DDIR) $$escape_expand(\\n\\t)
    }

    export(QMAKE_POST_LINK)
}

# Generic env setup
include($$PWD/build-system/bs-env.pri)
# QT os-specific setup
include($$PWD/build-system/bs-os.pri)
# QT generic setup
include($$PWD/build-system/bs-qt.pri)


# XXX unverified
!isEmpty(DUBO_EXTERNAL){
    # Fails on windows, fank you
    !win32{
        DUBO_EXTERNAL = $$absolute_path($$DUBO_EXTERNAL, $$PROJECT_ROOT)
    }
}

message(************************* Building template: $$TEMPLATE $$PROJECT_ROOT *************************)
message( -> Building: $${DUBO_PROJECT_NAME} $${VERSION} ($${DUBO_VENDOR_NAME}))
message( -> Git: $${DUBO_GITVERSION} changeset number $${DUBO_GITCHANGENUMBER})
message( -> Build type: $${DUBO_BUILD_TYPE})
message( -> Link: $${DUBO_LINK_TYPE} version)
message( -> Platform: $${DUBO_PLATFORM})
message( -> Temporary build dir: $${TMP_BASE_DIR})
message( -> Build destination dir $${DESTDIR})
message( -> Additional lib/include: $${DUBO_EXTERNAL})
message( -> LIBS: $${LIBS})
message( -> INCLUDEPATH: $${INCLUDEPATH})
