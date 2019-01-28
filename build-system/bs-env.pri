# Informations about the git version
DUBO_GITVERSION = NOGIT
DUBO_GITCHANGENUMBER = NOGIT

exists($$PROJECT_ROOT/.git/HEAD) {
    GIT_LOG=$$system(git -C "$$PROJECT_ROOT" log -n1 --pretty=format:%h)
    !isEmpty(GIT_LOG) {
        DUBO_GITVERSION = $$GIT_LOG
        DUBO_GITCHANGENUMBER=$$system(git -C "$$PROJECT_ROOT" rev-list HEAD --count)
    }
}

# Environment overrides
renv=$$(DUBO_LINK_TYPE)
!isEmpty(renv){
    message(Link type overriden by environment)
    DUBO_LINK_TYPE = $$renv
}

renv=$$(DUBO_INTERNAL_VERSION)
!isEmpty(renv){
    message(Third-party version overriden by environment)
    DUBO_INTERNAL_VERSION = $$renv
}

renv=$$(DUBO_DESTDIR)
!isEmpty(renv){
    message(Destdir overriden by environment)
    DUBO_DESTDIR = $$renv
}

renv=$$(DUBO_EXTERNAL)
!isEmpty(renv){
    message(External deps specified by environment)
    DUBO_EXTERNAL = $$renv
}

isEmpty(DUBO_EXTERNAL){
    DUBO_INTERNAL = true
    !isEmpty(DUBO_INTERNAL_VERSION){
        DUBO_EXTERNAL= $$PROJECT_ROOT/third-party/$$DUBO_INTERNAL_PATH
    }
}

mac|win32{
    isEmpty(DUBO_EXTERNAL){
        error(You have to specify either a DUBO_INTERNAL_VERSION or DUBO_EXTERNAL where to find dependencies on windows and mac)
    }
}

# Build type
CONFIG(debug, debug|release){
    DUBO_BUILD_TYPE = debug
}else{
    DUBO_BUILD_TYPE = release
}

mac {
    DUBO_PLATFORM = mac
}

win32 {
    DUBO_PLATFORM = win
}

# XXX Totally stupid if cross-compiling obviously
unix:!mac{
    DUBO_PLATFORM =  nux-$$system(arch)
}
#!mac:!win32{
#    DUBO_PLATFORM = $$system(uname)-$$system(uname -n)-$$system(arch)
#}

DUBO_LINK_NAME = $${TARGET}
win32{
    contains(DUBO_LINK_TYPE, dynamic){
        DUBO_LINK_NAME = $${TARGET}$${VER_MAJ}
    }
}
# Export these to the root object
DEFINES += PROJECT_NAME=\"\\\"$${DUBO_PROJECT_NAME}\\\"\"
DEFINES += PROJECT_VENDOR=\"\\\"$${DUBO_VENDOR_NAME}\\\"\"
DEFINES += VERSION_FULL=\\\"$${DUBO_PROJECT_VERSION_MAJOR}.$${DUBO_PROJECT_VERSION_MINOR}.$${DUBO_PROJECT_VERSION_PATCH}\\\"
DEFINES += VERSION_GIT=\\\"$${DUBO_GITVERSION}\\\"
DEFINES += VERSION_CHANGE=\\\"$${DUBO_GITCHANGENUMBER}\\\"
DEFINES += PROJECT_BUILDTYPE=\\\"$${DUBO_BUILD_TYPE}\\\"
DEFINES += PROJECT_LINKTYPE=\\\"$${DUBO_LINK_TYPE}\\\"
