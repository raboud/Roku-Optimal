Function RunScreenSaver(params as Object) as Object 'Required entrypoint for screensavers
    main()
End Function

Function main() as Void 'Optional entrypoint so screensaver can be run as a channel
    screen = createObject("roSGScreen")
    m.port = createObject("roMessagePort")
'    ipaddr = GetIPAddress()
    screen.setMessagePort(m.port)
    
    m.global = screen.getGlobalNode()
    m.global.AddField("MyField", "int", true) '(Global) Sets off message to change picture in XML
    m.global.MyField = 0
'    m.global.AddField("channels","stringarray",true) '(Global) array of channel paths to artwork 
'    m.global.channels = GetChannels(screen, ipaddr)
    m.global.AddField("vendors","stringarray",true) '(Global) array of channel paths to artwork 
    m.global.vendors = GetVendors()
    
    scene = screen.createScene("OptimalScreensaver") 'Create Scene called OptimalScreensaver
    screen.Show()
    
    while(true) 'While loop that fires every 8 seconds to change (Global) MyField value. It also checks to see if app is closed
        msg = wait(8000, m.port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        else
            m.global.MyField = m.global.MyField + 1
        end if
    end while
    
end Function

Function GetIPAddress() as String    'Retrieves IP Address of Roku Device
    di = CreateObject("roDeviceInfo")
    ipAddrs = di.GetIPAddrs()
    for each eth in ipAddrs
        if (ipAddrs[eth] <> invalid)
            ipAddr = ipAddrs[eth]
            exit for
        end if 
    end for
    return ipaddr
End Function

Function GetChannels(screen as object, ipaddr as String) as object 'Retrives artwork of home screen channels and returns an array with all artwork
    channels = []

    http = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    http.SetMessagePort(port)
    
    url = "http://" + ipaddr + ":8060/query/apps" 'This URL will query home screen channel artwork based off IP of the Roku
    http.SetUrl(url)
    
    if (http.AsyncGetToString())
        while (true) 'Parse through XMl to grab correct URI paths
            msg = port.GetMessage()
            if (msg <> invalid) and (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()
                if (code = 200)
                    xml = CreateObject("roXMLElement")
                    xml.Parse(msg.GetString())
                    exit while
                endif
                print stri(code)
                print msg.GetFailureReason()
            endif
        end while
        index = 0
        for each app in xml.app
            name = app.GetText()
            attributes = app.GetAttributes()
            id = attributes["id"]
            channeltype = attributes["type"]
            if channeltype = "appl" 'Only adds artwork of installed applications
                channels.push("http://" + ipaddr + ":8060/query/icon/" + id)
            end if
        end for
    endif
    return channels
End Function

Function GetVendors() as object 'Retrives artwork of home screen channels and returns an array with all artwork
    vendors = []
    vendors.push("pkg:/images/vendors/Bio-Botanical.png")
    vendors.push("pkg:/images/vendors/DFH_logo.png")
    vendors.push("pkg:/images/vendors/douglaslabs.jpg")
    vendors.push("pkg:/images/vendors/Elixinol-logo.jpg")
    vendors.push("pkg:/images/vendors/nic-light-3.png")
    vendors.push("pkg:/images/vendors/orthomolecualar.png")
    vendors.push("pkg:/images/vendors/rlclabs.png")
    vendors.push("pkg:/images/vendors/xymogen.png")
    return vendors
End Function
