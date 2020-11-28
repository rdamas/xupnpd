LUA     = lua-5.3.5
CFLAGS  = -fno-exceptions -fno-rtti -Os -I$(LUA) $(MY_CFLAGS) -DWITH_OPENSSL
OBJS    = main.o soap.o mem.o mcast.o luaxlib.o luaxcore.o luajson.o luajson_parser.o md5c.o
LIBS    = $(LUA)/liblua.a

all: $(LIBS) $(OBJS)
	PATH=$(PATH):$(LIBEXEC) STAGING_DIR=$(STAGING_DIR) $(CC) -B $(LIBEXEC) $(CFLAGS) -o $(TARGET_DIR)/xupnpd-$(PLATFORM) $(OBJS) $(LIBS) -ldl -lm -lcrypto -lssl
	$(STRIP) $(TARGET_DIR)/xupnpd-$(PLATFORM)

$(LUA)/liblua.a:
	$(MAKE) -C $(LUA) a CC=$(CC) PATH=$(PATH):$(LIBEXEC) STAGING_DIR=$(STAGING_DIR) MYCFLAGS="-DLUA_USE_LINUX -Os"

clean:
	$(RM) -f $(OBJS)
	$(MAKE) -C $(LUA) clean
	$(RM) -f $(TARGET_DIR)/xupnpd-$(PLATFORM)

.c.o:
	PATH=$(PATH):$(LIBEXEC) STAGING_DIR=$(STAGING_DIR) $(CC) -c -o $@ $<

.cpp.o:
	PATH=$(PATH):$(LIBEXEC) STAGING_DIR=$(STAGING_DIR) $(CPP) -c $(CFLAGS) -o $@ $<
