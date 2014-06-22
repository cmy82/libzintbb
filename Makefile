
#Defines
ZINT_VERSION_D:=-DZINT_VERSION=\"2.4.3.0\"
ZINT_VERSION = 2.4.3.0

#Includes
ILIBS = -lpng16 -lz -lm
IDIR_LIST = . $(QNX_TARGET)/usr/local/libpng16
IDIRS     = $(foreach d, $(IDIR_LIST), -I$d)
 
#Programs
AR = ntoarmv7-ar

#Directories
SRC_DIR = src
OBJ_DIR = objs
LIB_DIR = lib

#Flags
CCFLAGS+= -Wall -fstack-protector-strong -D_FORTIFY_SOURCE=2 
LDFLAGS+= -Wl,-z,relro -Wl,-z,now #-pie

#Common barcode objects
COMMON_SRCS= common.c render.c png.c library.c ps.c large.c reedsol.c gs1.c svg.c
COMMON_OBJS= $(COMMON_SRCS:.c=.o)
#Postal barcode objects
POSTAL_SRCS= postal.c auspost.c imail.c
POSTAL_OBJS= $(POSTAL_SRCS:.c=.o)
#1-D barcode objects
ONEDIM_SRCS= code.c code128.c 2of5.c upcean.c telepen.c medical.c plessey.c rss.c
ONEDIM_OBJS= $(ONEDIM_SRCS:.c=.o)
#2-D barcode objects
TWODIM_SRCS= code16k.c dmatrix.c pdf417.c qr.c maxicode.c composite.c aztec.c code49.c code1.c gridmtx.c
TWODIM_OBJS= $(TWODIM_SRCS:.c=.o)

libzintbb: clean \
           $(foreach d, $(COMMON_SRCS), $(SRC_DIR)/$d) $(foreach d, $(POSTAL_SRCS), $(SRC_DIR)/$d) \
           $(foreach d, $(ONEDIM_SRCS), $(SRC_DIR)/$d) $(foreach d, $(TWODIM_SRCS), $(SRC_DIR)/$d)
	mkdir -p $(LIB_DIR) $(OBJ_DIR)
	$(CC) $(CCFLAGS) $(ZINT_VERSION_D) $(IDIRS) -c -fPIC $(foreach d, $(COMMON_SRCS), $(SRC_DIR)/$d)
	$(CC) $(CCFLAGS) $(ZINT_VERSION_D) $(IDIRS) -c -fPIC $(foreach d, $(POSTAL_SRCS), $(SRC_DIR)/$d)
	$(CC) $(CCFLAGS) $(ZINT_VERSION_D) $(IDIRS) -c -fPIC $(foreach d, $(ONEDIM_SRCS), $(SRC_DIR)/$d)
	$(CC) $(CCFLAGS) $(ZINT_VERSION_D) $(IDIRS) -c -fPIC $(foreach d, $(TWODIM_SRCS), $(SRC_DIR)/$d)
	$(CC) -shared -Wl,-soname,libzintbb.so $(LDFLAGS) \
         -o libzintbb.so.$(ZINT_VERSION) $(COMMON_OBJS) $(POSTAL_OBJS) $(ONEDIM_OBJS) $(TWODIM_OBJS) $(ILIBS)
	mv libzintbb.so.$(ZINT_VERSION) $(LIB_DIR)
	cp $(LIB_DIR)/libzintbb.so.$(ZINT_VERSION) $(LIB_DIR)/libzintbb.so
	mv -v *.o $(OBJ_DIR)

clean:
	rm -fv $(COMMON_OBJS) $(POSTAL_OBJS) $(ONEDIM_OBJS) $(TWODIM_OBJS)
	rm -fv $(LIB_DIR)/*
	rm -fv $(OBJ_DIR)/*

all: libzintbb
	@:

