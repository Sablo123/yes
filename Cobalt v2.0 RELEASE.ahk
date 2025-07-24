; Cobalt v2-RELEASE

#SingleInstance, force

global privateServerLink := ""
global webhookURL := ""
global discordID := ""

; -------- Configurable Variables --------
global uiNavKeybind = "\"

; Edit this to change the seeds
global seedItems := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Orange Tulip Seed", "Tomato Seed", "Corn Seed"
    , "Daffodil Seed", "Watermelon Seed", "Pumpkin Seed"
    , "Apple Seed", "Bamboo Seed", "Coconut Seed", "Cactus Seed"
    , "Dragon Fruit Seed", "Mango Seed", "Grape Seed", "Mushroom Seed"
    , "Pepper Seed", "Cacao Seed", "Beanstalk Seed", "Ember Lily", "Sugar Apple", "Burning Bud","Giant Pinecone Seed"]

; Edit this to change the gear
global gearItems := ["Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler","Medium Toy","Medium Treat"
    , "Godly Sprinkler", "Magnifying Glass", "Tanning Mirror", "Master Sprinkler", "Cleaning Spray", "Favorite Tool", "Harvest Tool", "Friendship Pot", "Levelup Lollipop"]

; Edit this to change the eggs
global eggItems := ["Common Egg", "Common Sum Egg", "Rare Sum Egg", "Mythical Egg", "Paradise Egg"
    ,"Bug Egg"]

; Edit this to change what you want to be pinged for
global pingList := ["Beanstalk Seed", "Ember Lily", "Sugar Apple", "Burning Bud","Giant Pinecone Seed", "Master Sprinkler", "Levelup Lollipop", "Medium Treat", "Medium Toy", "Mythical Egg", "Paradise Egg", "Bug Egg"]

; - Technical stuff below, no touchy! -

global currentlyAllowedSeeds := []
global currentlyAllowedGear := []
global currentlyAllowedEggs := []

global finished := true
global cycleCount := 0
global eggCounter := 0
global canDoEgg := true

global started := 0
global messageQueue := []

WinActivate, ahk_exe RobloxPlayerBeta.exe

Gosub, ShowGui
Gosub, UpdateSeedState

StartMacro:
    if(started = 0) {
        Return
    }
    sendDiscordMessage("Macro started!", 65280)
    WinActivate, ahk_exe RobloxPlayerBeta.exe
    finished := false

Alignment:
    exitIfWindowDies()
    SetTimer, ShowTimeTip, Off
    tooltipLog("Placing Recall Wrench in slot 2...")
    ;open backpack and place wrench in slot 2
    startUINav()
    keyEncoder("REDDDE")
    repeatKey("Backspace", 20)
    typeString("recall")
    repeatKey("Enter")
    keyEncoder("DDUUEDRE")
    ;close it
    Send, ``
    tooltipLog("Aligning camera...")
    recalibrateCameraDistance()

    Sleep, 500
    SysGet, screenWidth, 78
    SysGet, screenHeight, 79

    CoordMode, Mouse, Screen

    Sleep, 100
    Click, Right, Down
    Sleep, 100
    SafeMoveRelative(0.5, 0.5)
    Sleep, 100

    MouseGetPos, xpos, ypos

    if (ypos >= screenHeight * 0.90) {
        moveDistance := -Round(screenHeight * 0.75)
    } else {
        moveDistance := Round(screenHeight * 0.75)
    }

    MouseMove, 0, %moveDistance%, R
    Sleep, 100

    Click, Right, Up
    Sleep, 100

    repeatKey("Esc")
    sleep, 100
    repeatKey("Tab")
    sleep, 100
    keyEncoder("UUUUUUUUUUUDRR")
    sleep 100
    repeatKey("Esc")
    sleep, 500
    startUINav()
    sleep, 50
    keyEncoder("RRRRELERRELLRELERRELLRELERRELLRELERRELLRELERRELL")
    sleep 50
    startUINav()
    sleep 50
    repeatKey("Esc")
    sleep, 100
    repeatKey("Tab")
    sleep, 100
    keyEncoder("UUUUUUUUUUUDRR")
    sleep 100
    repeatKey("Esc")
    sleep 100
    keyEncoder("WDWRWE")
    sleep 100
    startUINav()
    sleep 100
    keyEncoder("WRWRWRWRWE")
    Sleep 200
    startUINav()
    sleep 200
    tooltipLog("Alignment complete!")

SeedCycle:
    exitIfWindowDies()
    if (currentlyAllowedSeeds.Length() = 0) {
        Gosub, TPToGear
        Return
    }

    startUINav()
    ;open shop
    keyEncoder("RRREWWW")
    SendInput, e
    Sleep, 3000
    startUINav()
    startUINav()
    startUINav()
    startUINav()
    if(isShopOpen()) {
        ;we now have the carrot selected, start seed nav
        tooltipLog("Shopping for seeds...")
        goShopping(currentlyAllowedSeeds, seedItems)
        sendDiscordQueue("Seed Shop")
        startUINav()
    } else {
        tooltipLog("Error: Seed shop did not open")
        sendDiscordMessage("Seed shop did not open! Reconnecting...", 16711680)
        Gosub, Reconnect
    }

TPToGear:
    tooltipLog("Going to gear shop...")
    Send, {2}
    SafeMoveRelative(0.5, 0.5)
    MouseClick, Left
    Sleep, 400
    Send, {2}
    Sleep, 400

GearCycle:
    exitIfWindowDies()
    ; TODO when the gear shop is disabled but egg is still enabled, handle them differently
    If (gearItems.Length() = 0) {
        Gosub, EggCycle
        Return
    }

    tooltipLog("Opening gear shop...")
    SendInput, e
    Sleep, 3000

    Loop, 5 {
        Send, {WheelUp}
        Sleep, 10
    }
    Sleep, 500

    SafeMoveRelative(0.9, 0.4)
    MouseClick, Left

    Sleep, 3000

    if(isShopOpen()) {
        startUINav()
        startUINav()
        startUINav()
        tooltipLog("Shopping for gear...")
        goShopping(currentlyAllowedGear, gearItems, 20)
        sendDiscordQueue("Gear Shop")
        startUINav()
    } else {
        tooltipLog("Error: Gear shop did not open")
        sendDiscordMessage("Gear shop did not open! Reconnecting...", 16711680)
        Gosub, Reconnect
    }

EggCycle:
    exitIfWindowDies()
    if(currentlyAllowedEggs.Length() > 0 && canDoEgg) {
        canDoEgg := false
        tooltipLog("Going to egg shop...")
        recalibrateCameraDistance()
        SendInput, {W Down}
        Sleep, 600
        SendInput, {W Up}

        SendInput, e
        Sleep, 3000

        Loop, 5 {
            Send, {WheelUp}
            Sleep, 10
        }
        Sleep, 500

        SafeMoveRelative(0.9, 0.1)
        MouseClick, Left
        Sleep 3000

        if(isShopOpen()) {
            startUINav()
            tooltipLog("Shopping for eggs...")
            goShoppingEgg(currentlyAllowedEggs, eggItems)
            sendDiscordQueue("Egg Shop")
            Sleep, 500
            startUINav()
        } else {
            tooltipLog("Error: Egg shop did not open")
            sendDiscordMessage("Egg shop did not open! Reconnecting...", 16711680)
            Gosub, Reconnect
        }
    }
    SafeMoveRelative(0.5, 0.5)
    finished := true
    cycleCount += 1
    SetTimer, ShowTimeTip, 1000
    sendDiscordMessage("Cycle " . cycleCount . " finished", 65280)
Return

Reconnect:
    WinClose, ahk_exe RobloxPlayerBeta.exe
    Sleep, 1000
    WinClose, ahk_exe RobloxPlayerBeta.exe
    Sleep, 3000
    Run, %privateServerLink%
    Sleep, 45000
    exitIfWindowDies()
    SendInput, {Tab}
    Sleep, 1000
    SafeClickRelative(0.5, 0.5)
    Sleep, 15000
    Gosub, Alignment
    sendDiscordMessage("Reconnected to the game!", 65280)
Return

exitIfWindowDies() {
    if(!WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        Gosub, Close
    }
}

ShowTimeTip:
    SecondsUntil5 := 300 - (Mod(A_Min, 5) * 60 + A_Sec)
    SecondsUntil5 := Mod(SecondsUntil5, 301)
    RemainingMins5 := Floor(SecondsUntil5 / 60)
    RemainingSecs5 := Mod(SecondsUntil5, 60)
    FormattedTime5 := Format("{:02}:{:02}", RemainingMins5, RemainingSecs5)
    SecondsUntil30 := 1800 - (Mod(A_Min, 30) * 60 + A_Sec)
    SecondsUntil30 := Mod(SecondsUntil30, 1801)
    RemainingMins30 := Floor(SecondsUntil30 / 60)
    RemainingSecs30 := Mod(SecondsUntil30, 60)
    FormattedTime30 := Format("{:02}:{:02}", RemainingMins30, RemainingSecs30)

    ToolTip, Next cycle in %FormattedTime5%`nNext Egg Cycle in %FormattedTime30%

    if(SecondsUntil30 < 3) {
        canDoEgg := true
    }

    if(SecondsUntil5 < 3) {
        finished := false
        recalibrateCameraDistance()
        Gosub, Alignment
    }

Return

SafeMoveRelative(xRatio, yRatio) {

    if WinExist("ahk_exe RobloxPlayerBeta.exe") {
        WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe
        moveX := winX + Round(xRatio * winW)
        moveY := winY + Round(yRatio * winH)
        MouseMove, %moveX%, %moveY%
    }

}

SafeClickRelative(xRatio, yRatio) {

    if WinExist("ahk_exe RobloxPlayerBeta.exe") {
        WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe
        clickX := winX + Round(xRatio * winW)
        clickY := winY + Round(yRatio * winH)
        Click, %clickX%, %clickY%
    }

}

getMouseCoord(axis) {

    WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe
    CoordMode, Mouse, Screen
    MouseGetPos, mouseX, mouseY

    relX := (mouseX - winX) / winW
    relY := (mouseY - winY) / winH

    if (axis = "x")
        return relX
    else if (axis = "y")
        return relY

    return ""

}

goShopping(arr, allArr, spamCount := 50) {
    keyEncoder("DRDDWWEEWW")

    for index, item in allArr {
        if(!contains(arr, item)) {
            repeatKey("Down")
            Continue
        }
        buyAllAvailable(spamCount, item)
    }
    if(messageQueue.Length() = 0) {
        messageQueue.Push("Bought nothing...")
    }
    repeatKey("Up", 40)
    keyEncoder("DDUE")
}

goShoppingEgg(arr, allArr) {
    keyEncoder("DRDDWWEEWW")
    for index, item in allArr {
        if(!contains(arr, item)) {
            repeatKey("Down", 2)
            Continue
        }
        buyAllAvailableEgg(5, item)
    }
    if(messageQueue.Length() = 0) {
        messageQueue.Push("Bought nothing...")
    }
    repeatKey("Up", 40)
    keyEncoder("RRRDE")
}

buyAllAvailable(spamCount := 50, item := "") {
    repeatKey("Enter")
    repeatKey("Down")
    Sleep, 200
    if(isThereStock()) {
        repeatKey("Enter", spamCount)
        messageQueue.Push("Bought " . item . "!")
    }
    repeatKey("Down")
}

buyAllAvailableEgg(spamCount := 50, item := "") {
    repeatKey("Enter")
    repeatKey("Down", 2)
    Sleep, 200
    if(isThereStock()) {
        repeatKey("Enter", spamCount)
        messageQueue.Push("Bought " . item . "!")
    } else {
        ToolTip, No Stock
        Sleep, 300
        ToolTip
    }
    repeatKey("Down")
}

isThereStock() {
    return colorDetect(0x20b41c)
}

isShopOpen() {
    ; every other shop
    if(colorDetect(0x50240c)) {
        return true
    }

    ; egg shop and event shops only for some odd reason
    if(colorDetect(0x360805)) {
        return true
    }

    return false
}

colorDetect(c) {
    startXPercent := 42
    startYPercent := 25
    endXPercent := 70
    endYPercent := 75

    CoordMode, Pixel, Screen

    WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe

    x1 := Round((startXPercent / 100) * A_ScreenWidth)
    y1 := Round((startYPercent / 100) * A_ScreenHeight)
    x2 := Round((endXPercent / 100) * A_ScreenWidth)
    y2 := Round((endYPercent / 100) * A_ScreenHeight)

    PixelSearch, px, py, x1, y1, x2, y2, c, 10, Fast RGB
    if(ErrorLevel = 0) {
        return true
    }
    return false
}

startUINav() {
    SendInput, {%uiNavKeybind%}
}

tooltipLog(message, duration := 3000) {
    ToolTip, %message%
    SetTimer, HideTooltip, %duration%
}

HideTooltip:
    ToolTip
    SetTimer, HideTooltip, Off
Return

; R = right
; L = left
; U = up
; D = down
; E = enter
; W = 100ms wait
keyEncoder(str) {
    Loop, Parse, str
    {
        StringLower, key, A_LoopField

        if(key = "r") {
            repeatKey("Right")
        }
        if(key = "l") {
            repeatKey("Left")
        }
        if(key = "u") {
            repeatKey("Up")
        }
        if(key = "d") {
            repeatKey("Down")
        }
        if(key = "e") {
            repeatKey("Enter")
        }
        if(key = "w") {
            Sleep, 100
        }
    }
}

; repeats keys obv
repeatKey(key, count := 1) {
    Loop, %count% {
        SendInput, {%key%}
        Sleep, 50
    }
}

indexOf(array := "", value := "") {

    for index, item in array {
        if (value = item) {
            return index
        }
    }

    return -1
}

contains(array := "", value := "") {

    for index, item in array {
        if (value = item) {
            return true
        }
    }
    return false
}

typeString(string) {

    if (string = "") {
        Return
    }

    Loop, Parse, string
    {
        Send, {%A_LoopField%}
        Sleep, 50
    }
}

insertByReferenceOrder(targetList, value, referenceList) {
    refIndex := indexOf(referenceList, value)
    if (refIndex = -1) ; reference doesn't exist, if you get here we have issues
        return

    insertPos := 0
    for k, v in targetList {
        vRefIndex := indexOf(referenceList, v)
        if (vRefIndex != -1 && vRefIndex <= refIndex)
            insertPos := k
    }
    if (insertPos = 0)
        targetList.InsertAt(1, value)
    else
        targetList.InsertAt(insertPos + 1, value)
}

recalibrateCameraDistance() {
    Loop, 35 {
        Send, {WheelUp}
        Sleep, 10
    }
    Sleep, 500

    Loop, 7 {
        Send, {WheelDown}
        Sleep, 10
    }
}

sendDiscordQueue(title := "Bulk Message") {
    finalMessage := "**" . title . ":**\n"
    shouldPing := false
    for index, message in messageQueue {
        finalMessage .= "- -# " . message . "\n"
        for _, pingItem in pingList {
            if (InStr(message, pingItem)) {
                shouldPing := true
                break
            }
        }
    }
    sendDiscordMessage(finalMessage,, shouldPing)
    messageQueue := [] ; clear the queue
}

sendDiscordMessage(message, color := 0x0000FF, ping := false) {

    FormatTime, messageTime, , hh:mm tt

    pingMsg := ""

    if(ping) {
        pingMsg .= """content"": ""<@!" . discordID . ">"","
    }

    json := "{" . pingMsg . """embeds"": [{""type"": ""rich"",""description"": ""``" . messageTime . "`` | " . message . """,""color"": " . color . "}]}"
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")

    try {
        whr.Open("POST", webhookURL, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(json)
        whr.WaitForResponse()
        status := whr.Status

        if (status != 200 && status != 204) {
            return
        }
    } catch {
        return
    }

}

arrayToString(arr, delimiter := ", ") {
    local result := ""

    if (!IsObject(arr) || arr.Length() = 0) {
        return ""
    }

    Loop % arr.Length() {
        result .= arr[A_Index]
        if (A_Index < arr.Length()) {
            result .= delimiter
        }
    }

    return result
}

ShowGui:
    loadValues()
    Gui, +Caption +SysMenu +MinimizeBox +Resize
    Gui, Color, c000000
    Gui, Font, s10 cWhite, Segoe UI
    Gui, Add, Text, x0 y0 w490 h30 BackgroundTrans vTitleBar gDrag, Cobalt V2.0 RELEASE
    Gui, Add, Text, x490 y0 w30 h30 vCloseBtn gClose Center hwndhCloseBtn
    GuiControl,, CloseBtn, X
    GuiControl, +BackgroundFF4444, CloseBtn
    Gui, Add, Text, x460 y0 w30 h30 vMinBtn gMinimize Center hwndMinimize
    GuiControl,, MinBtn, _
    GuiControl, +BackgroundFFAA00, MinBtn
    Gui, Show, w520 h430, Cobalt V2.0 RELEASE
    Sleep, 100
    WinGet, hwnd, ID, Cobalt V2.0 RELEASE
    style := DllCall("GetWindowLong", "Ptr", hwnd, "Int", -16, "UInt")
    style := style & ~0xC00000 & ~0x800000 & ~0x100000 & ~0x40000
    DllCall("SetWindowLong", "Ptr", hwnd, "Int", -16, "UInt", style)
    DllCall("SetWindowPos", "Ptr", hwnd, "Ptr", 0, 0, 0, 0, 0, 0, 0x27)
    cols := 3
    itemW := 150
    itemH := 28
    paddingX := 20
    paddingY := 80

    groupBoxX := 30
    groupBoxY := 90
    groupBoxW := 490
    groupBoxH := 320

    Gui, Add, Tab3, x10 y35 w520 h400, Seeds|Gear|Eggs|Settings|Credits

    Gui, Tab, Seeds
    Gui, Font, s10
    Gui, Add, GroupBox, x%groupBoxX% y%groupBoxY% w%groupBoxW% h%groupBoxH%,

    Gui, Add, Checkbox, x205 y105 w150 h23 c1C96EF vCheckAllSeeds gToggleAllSeeds, Select All Seeds

    paddingY := groupBoxY + 50
    paddingX := groupBoxX +25
    Loop % seedItems.Length() {
        row := Mod(A_Index - 1, Ceil(seedItems.Length() / cols))
        col := Floor((A_Index - 1) / Ceil(seedItems.Length() / cols))
        x := paddingX + (itemW * col)
        y := paddingY + (itemH * row)
        seed := seedItems[A_Index]
        isChecked := contains(currentlyAllowedSeeds, seed) ? 1 : 0
        Gui, Add, Checkbox, x%x% y%y% w140 h23 gUpdateSeedState vseedCheckboxes%A_Index% Checked%isChecked%, % seed
    }

    Gui, Tab, Gear
    Gui, Font, s10
    Gui, Add, GroupBox, x%groupBoxX% y%groupBoxY% w%groupBoxW% h%groupBoxH%,

    Gui, Add, Checkbox, x205 y105 w150 h23 c32FF32 vCheckAllGear gToggleAllGear, Select All Gear

    paddingY := groupBoxY + 50
    paddingX := groupBoxX + 25
    Loop % gearItems.Length() {
        row := Mod(A_Index - 1, Ceil(gearItems.Length() / cols))
        col := Floor((A_Index - 1) / Ceil(gearItems.Length() / cols))
        x := paddingX + (itemW * col)
        y := paddingY + (itemH * row)
        gear := gearItems[A_Index]
        isChecked := contains(currentlyAllowedGear, gear) ? 1 : 0
        Gui, Add, Checkbox, x%x% y%y% w140 h23 gUpdateGearState vgearCheckboxes%A_Index% Checked%isChecked%, % gear
    }

    Gui, Tab, Eggs
    Gui, Font, s10
    Gui, Add, GroupBox, x%groupBoxX% y%groupBoxY% w%groupBoxW% h%groupBoxH%,

    Gui, Add, Checkbox, x55 y105 w150 h23 vCheckAllEggs gToggleAllEggs cFFFF28, Select All Eggs

    paddingY := groupBoxY + 50
    paddingX := groupBoxX + 25
    cols := 1
    Loop % eggItems.Length() {
        row := Mod(A_Index - 1, Ceil(eggItems.Length() / cols))
        col := Floor((A_Index - 1) / Ceil(eggItems.Length() / cols))
        x := paddingX + (itemW * col)
        y := paddingY + (itemH * row)
        egg := eggItems[A_Index]
        isChecked := contains(currentlyAllowedEggs, egg) ? 1 : 0
        Gui, Add, Checkbox, x%x% y%y% w140 h23 gUpdateEggState veggCheckboxes%A_Index% Checked%isChecked%, % egg
    }

    Gui, Tab, Settings
    Gui, Font, s10
    Gui, Add, GroupBox, x%groupBoxX% y%groupBoxY% w%groupBoxW% h%groupBoxH%,

    Gui, Add, Text, x50 y125 w150 h30, Private Server Link
    Gui, Add, Text, x50 y155 w150 h30, Webhook URL
    Gui, Add, Text, x50 y185 w150 h30, Discord User ID
    Gui, Font, s6 cGray, Segoe UI
    Gui, Add, Link, x50 y205 w200 h30, <a href="https://discord.com/developers/docs/activities/building-an-activity#step-0-enable-developer-mode">(Enable Developer Mode in Discord to get your ID)</a>
    Gui, Font, s8 cBlack, Segoe UI
    Gui, Add, Edit, r1 vprivateServerLink w185 x315 y125, % privateServerLink
    Gui, Add, Edit, r1 vwebhookURL w185 x315 y155, % webhookURL
    Gui, Add, Edit, r1 vdiscordID w185 x315 y185, % discordID
    Gui, Add, Button, h30 w135 x365 y300 gUpdatePlayerValues, Save Settings
    Gui, Add, Button, h30 w215 x50 y350 gGuiStartMacro, Start Macro (F5)
    Gui, Add, Button, h30 w215 x285 y350 gPauseMacro, Stop Macro (F7)
    Gui, Font, s10 cWhite, Segoe UI

    Gui, Tab, Credits
    Gui, Font, s10
    Gui, Add, GroupBox, x%groupBoxX% y%groupBoxY% w%groupBoxW% h%groupBoxH%
    Gui, Font, s10 cWhite w600, Segoe UI
    Gui, Add, Text, x50 y110 w300 h30, Cobalt V2.0 RELEASE by Clovalt, Cobblestone
    Gui, Add, Picture, x50 y150 w100 h100, images/cobble.png
    Gui, Add, Text, x50 y250 w150 h100, Cobble (Cobblestone)
    Gui, Add, Picture, x250 y150 w100 h100, images/clovalt.png
    Gui, Add, Text, x250 y250 w150 h100, Clovalt
    Gui, Font, s8 cfb2c36, Segoe UI
    Gui, Add, Text, x50 y270 w150 h100, Macro Developer
    Gui, Font, s8 cBlue, Segoe UI
    Gui, Add, Text, x250 y270 w150 h100, Macro Developer and Project Lead
    Gui, Font, s8 cBlue, Segoe UI
    Gui, Add, Link, x50 y310 w150 h30, <a href="https://madefrom.rocks">Website</a>
    Gui, Add, Link, x50 y330 w150 h30, <a href="https://github.com/HoodieRocks">Github</a>
    Gui, Add, Link, x250 y310 w150 h30, <a href="https://discord.gg/qsJ4mT3C4Z">Main Discord Server</a>
    Gui, Add, Link, x250 y330 w150 h30 <a href="https://discord.gg/Fb4BBXxV9r">Macro Discord Server</a>
return

UpdatePlayerValues:
    Gui, Submit, NoHide
    privateServerLink := Trim(privateServerLink)
    webhookURL := Trim(webhookURL)
    discordID := Trim(discordID)

    if (privateServerLink = "") {
        MsgBox, 48, Error, Private Server Link cannot be empty!
        return
    }

    if (webhookURL = "") {
        MsgBox, 48, Error, Webhook URL cannot be empty!
        return
    }

    if (discordID = "") {
        MsgBox, 48, Error, Discord User ID cannot be empty!
        return
    }

    saveValues()
    MsgBox, 64, Success, Settings saved successfully!
Return

loadValues() {
    IniRead, webhookURL, config.ini, PlayerConf, webhookURL
    IniRead, privateServerLink, config.ini, PlayerConf, privateServerLink
    IniRead, discordID, config.ini, PlayerConf, discordID

    IniRead, currentlyAllowedSeedsStr, config.ini, PersistentData, currentlyAllowedSeeds
    IniRead, currentlyAllowedGearStr, config.ini, PersistentData, currentlyAllowedGear
    IniRead, currentlyAllowedEggsStr, config.ini, PersistentData, currentlyAllowedEggs

    if (currentlyAllowedSeedsStr != "")
        currentlyAllowedSeeds := StrSplit(currentlyAllowedSeedsStr, ", ")
    else
        currentlyAllowedSeeds := []

    ; TODO: re-enable these when gear and egg GUI are implemented
    if (currentlyAllowedGearStr != "")
        currentlyAllowedGear := StrSplit(currentlyAllowedGearStr, ", ")
    else
        currentlyAllowedGear := []

    if (currentlyAllowedEggsStr != "")
        currentlyAllowedEggs := StrSplit(currentlyAllowedEggsStr, ", ")
    else
        currentlyAllowedEggs := []
}

saveValues() {
    IniWrite, %privateServerLink%, config.ini, PlayerConf, privateServerLink
    IniWrite, %webhookURL%, config.ini, PlayerConf, webhookURL
    IniWrite, %discordID%, config.ini, PlayerConf, discordID

    currentlyAllowedSeedsStr := arrayToString(currentlyAllowedSeeds)
    currentlyAllowedGearStr := arrayToString(currentlyAllowedGear)
    currentlyAllowedEggsStr := arrayToString(currentlyAllowedEggs)
    IniWrite, %currentlyAllowedSeedsStr%, config.ini, PersistentData, currentlyAllowedSeeds
    IniWrite, %currentlyAllowedGearStr%, config.ini, PersistentData, currentlyAllowedGear
    IniWrite, %currentlyAllowedEggsStr%, config.ini, PersistentData, currentlyAllowedEggs
}

ToggleAllSeeds:
    GuiControlGet, checkState,, CheckAllSeeds
    Loop % seedItems.Length() {
        control := "seedCheckboxes" A_Index
        GuiControl,, %control%, %checkState%
    }
    Gosub, UpdateSeedState
Return

UpdateSeedState:
    Gui Submit, NoHide

    currentlyAllowedSeeds := []
    Loop, % seedItems.Length() {
        if(seedCheckboxes%A_Index% = 1) {
            insertByReferenceOrder(currentlyAllowedSeeds, seedItems[A_Index], seedItems)
        }
    }
    saveValues()
return

ToggleAllGear:
    GuiControlGet, checkState,, CheckAllGear
    Loop % gearItems.Length() {
        control := "gearCheckboxes" A_Index
        GuiControl,, %control%, %checkState%
    }
    Gosub, UpdateGearState
return

UpdateGearState:
    Gui Submit, NoHide
    currentlyAllowedGear := []
    Loop, % gearItems.Length() {
        if(gearCheckboxes%A_Index% = 1)
            insertByReferenceOrder(currentlyAllowedGear, gearItems[A_Index], gearItems)
    }
    saveValues()
return

ToggleAllEggs:
    GuiControlGet, checkState,, CheckAllEggs
    Loop % eggItems.Length() {
        control := "eggCheckboxes" A_Index
        GuiControl,, %control%, %checkState%
    }
    Gosub, UpdateEggState
return

UpdateEggState:
    Gui Submit, NoHide
    currentlyAllowedEggs := []
    Loop, % eggItems.Length() {
        if(eggCheckboxes%A_Index% = 1)
            insertByReferenceOrder(currentlyAllowedEggs, eggItems[A_Index], eggItems)
    }
    saveValues()
return

Close:
ExitApp
return

Minimize:
    WinMinimize, A
return

Drag:
    PostMessage, 0xA1, 2,,, A
return

PauseMacro:
    Gui, Submit, NoHide
    Sleep, 50
    started := 0
Return

GuiStartMacro:
    started := 1
    Gosub, StartMacro
Return

F5::
    started := 1
    Gosub, StartMacro
Return

F7::

    Gosub, PauseMacro
    Reload
Return