LUA     = lua-5.3.5
EXTRA_CFLAGS  = -fno-exceptions -fno-rtti -Os -I$(LUA) $(MY_CFLAGS) -DWITH_OPENSSL
OBJS    = main.o soap.o mem.o mcast.o luaxlib.o luaxcore.o luajson.o luajson_parser.o md5c.o
LIBS    = $(LUA)/liblua.a

INSTALL = install
PREFIX  = /usr/local

all: $(LIBS) $(OBJS)
	$(CC) $(CFLAGS) -s -o $(TARGET_DIR)/xupnpd $(OBJS) $(LIBS) -ldl -lm -lcrypto -lssl

$(LUA)/liblua.a:
	$(MAKE) -C $(LUA) a CC="$(CC)" MYCFLAGS="-DLUA_USE_LINUX -Os"

clean:
	$(RM) -f $(OBJS)
	$(MAKE) -C $(LUA) clean
	$(RM) -f $(TARGET_DIR)/xupnpd

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin $(DESTDIR)$(PREFIX)/share/xupnpd
	cp -pr *.lua plugins profiles ui www $(DESTDIR)$(PREFIX)/share/xupnpd
	$(INSTALL) -m 0755 $(TARGET_DIR)/xupnpd $(DESTDIR)$(PREFIX)/bin/xupnpd

.c.o:
	$(CC) -c $(EXTRA_CFLAGS) -o $@ $<

.cpp.o:
	$(CXX) -c $(EXTRA_CFLAGS) -o $@ $<
