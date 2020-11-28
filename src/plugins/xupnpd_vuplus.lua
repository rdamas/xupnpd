--[[
Plugin for converting channels lists from Enigma2 receivers with OpenWebif

This plugin is based on:

Plugin for converting channels lists from coolstream receivers
Author focus.cst@gmail.com
License GPL v2
Copyright (C) 2013 CoolStream International Ltd

Changes by Robert Damas <github.com/rdamas> (C) 2020
- make use of OpenWebif API to generate feed
- convert existing picons to JPEG logos
]]--

picon_path = "/usr/share/enigma2/picon/"
have_im6 = nil

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function is_file(name)
	if type(name)~="string" then return false end
	local f = io.open(name)
	if f then
		f:close()
		return true
	end
	return false
end

function convert_picon(picon)
	core.log("convert: "..picon)
	local logo = "xupnpd/"..picon:gsub(".png$",".jpg")
	if is_file(picon_path..logo) then
		local lm_picon = util.stat(picon_path..picon)
		local lm_logo = util.stat(picon_path..logo)
		if lm_logo and lm_picon and lm_logo > lm_picon then
			core.log("    nichts zu tun")
			return logo
		end
	end
	
	if have_im6 == nil then
		have_im6 = is_file("/usr/bin/convert.im6")
		os.execute("/bin/mkdir -p "..picon_path.."xupnpd")
		core.log("    Logo-Verzeichnis angelegt")
	end
	if have_im6 then
		local cmd = string.format("/usr/bin/convert.im6 '%s' -resize 150x150 -gravity center -background '#061324' -extent 170x236 '%s'", picon_path..picon:gsub("*","\\*"), picon_path..logo)
		os.execute(cmd)
		core.log("    Picon konvertieren: "..cmd)
		core.log("    Return: "..logo)
		return logo
	end
	core.log("    Falltrough und return: "..picon)
	return picon
end

function find_picon_sref(sref)
	local picon = sref:gsub(":","_"):sub(1,-2)..".png"
	return picon
end

function find_picon_byname(name)
	local picon = name..".png"
	return picon
end

function picon_url(name)
	return name:gsub(" ","%%20")
end

function find_picon(sref, name)
	local picon = find_picon_sref(sref)
	if is_file(picon_path..picon) then
		picon = convert_picon(picon)
		return picon
	end
	picon = find_picon_byname(name)
	if is_file(picon_path..picon) then
		picon = convert_picon(picon)
		return picon_url(picon)
	end
	return false
end

function vuplus_read_url(url)
	local string = ""
	string = http.download(url)

	if string == nil then
		string =""
	end
	return string
end

function vuplus_save_bouquets(feed, friendly_name, mode, sysip)
	local rc=false
	local feedspath = cfg.feeds_path

	local vuplus_url = 'http://'..feed..'/api/getallservices'
	if mode == "RADIO" then
		vuplus_url = vuplus_url .. "?type=radio"
	end

	local bouquets_data = vuplus_read_url(vuplus_url)
	local data = json.decode(bouquets_data)
	if not data then
	    return rc
	end
	local services = data.services

	local i, bobj = {}
	for i, bobj in pairs(services) do
		local bnum = string.format("%03d", i)
		local m3ufilename = cfg.tmp_path.."vuplus_"..friendly_name.."_"..mode.."_bouquet_"..bnum..".m3u"
		local m3ufile = io.open(m3ufilename,"w")
		m3ufile:write("#EXTM3U name=\""..trim(bobj.servicename).."\" plugin=vuplus type=ts\n")
		local j, sbobj = {}
		for j, sbobj in pairs(bobj.subservices) do
			local logo = find_picon(sbobj.servicereference,sbobj.servicename)
			local logourl = ""
			if logo then
				logourl=string.format(" logo=http://%s/picon/%s",feed,logo)
			end
			m3ufile:write("#EXTINF:0"..logourl..","..sbobj.servicename.."\n")
			m3ufile:write("http://"..feed..":8001/"..sbobj.servicereference.."\n")
		end
		m3ufile:close()
		os.execute(string.format('mv %s %s',m3ufilename,feedspath))
		rc=true
	end
	return rc
end

function vuplus_updatefeed(feed,friendly_name)
	local rc=false
	if not friendly_name then
		friendly_name = feed
	end

	local sysip = www_location
	sysip = sysip:match('(http://%d*.%d*.%d*.%d*):*.')
	if vuplus_save_bouquets(feed, friendly_name, "TV", sysip) then
		rc = true
	end
	if vuplus_save_bouquets(feed, friendly_name, "RADIO", sysip) then
		rc = true
	end

	return rc
end

function vuplus_sendurl(vuplus_url,range)
	local i,j,baseurl = string.find(vuplus_url,"(.+):.+")
	plugin_sendurl(vuplus_url,vuplus_url,range)
end

plugins.vuplus = {}
plugins.vuplus.name = "VU Plus"
plugins.vuplus.desc = "IP address (example: <i>192.168.0.1</i>)"
plugins.vuplus.updatefeed = vuplus_updatefeed
plugins.vuplus.sendurl = vuplus_sendurl
