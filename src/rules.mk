LUA     = lua-5.3.5
EXTRA_CFLAGS  = -fno-exceptions -fno-rtti -Os -I$(LUA) $(MY_CFLAGS) -DWITH_OPENSSL
OBJS    = main.o soap.o mem.o mcast.o luaxlib.o luaxcore.o luajson.o luajson_parser.o md5c.o
LIBS    = $(LUA)/liblua.a

all: $(LIBS) $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET_DIR)/xupnpd $(OBJS) $(LIBS) -ldl -lm -lcrypto -lssl
	$(STRIP) $(TARGET_DIR)/xupnpd

$(LUA)/liblua.a:
	$(MAKE) -C $(LUA) a CC="$(CC)" MYCFLAGS="-DLUA_USE_LINUX -Os"

clean:
	$(RM) -f $(OBJS)
	$(MAKE) -C $(LUA) clean
	$(RM) -f $(TARGET_DIR)/xupnpd

.c.o:
	$(CC) -c $(EXTRA_CFLAGS) -o $@ $<

.cpp.o:
	$(CXX) -c $(EXTRA_CFLAGS) -o $@ $<
