#SingleInstance, force

global version := "v2.7"

global privateServerLink := ""
global webhookURL := ""
global discordID := ""
global longRecon := false

; -------- Configurable Variables --------
global uiNavKeybind := "\"
global invNavKeybind := "``"

; Edit this to change the seeds
global seedItems := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed"
    , "Orange Tulip Seed", "Tomato Seed", "Corn Seed"
    , "Daffodil Seed", "Watermelon Seed", "Pumpkin Seed"
    , "Apple Seed", "Bamboo Seed", "Coconut Seed", "Cactus Seed"
    , "Dragon Fruit Seed", "Mango Seed", "Grape Seed", "Mushroom Seed"
    , "Pepper Seed", "Cacao Seed", "Beanstalk Seed", "Ember Lily"
    , "Sugar Apple", "Burning Bud", "Giant Pinecone Seed", "Elder Strawberry","Romanesco"]

; Edit this to change the gear
global gearItems := ["Watering Can", "Trading Ticket", "Trowel"
    , "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler"
    , "Medium Toy","Medium Treat", "Godly Sprinkler"
    , "Magnifying Glass", "Master Sprinkler", "Cleaning Spray"
    , "Favorite Tool", "Harvest Tool", "Friendship Pot"
    , "Grandmaster Sprinkler", "Levelup Lollipop"]

; Edit this to change the eggs
global eggItems := ["Common Egg", "Common Sum Egg", "Rare Sum Egg"
    , "Mythical Egg", "Paradise Egg" ,"Bug Egg"]

; Edit this to change what you want to be pinged for
global pingList := ["Beanstalk Seed", "Ember Lily", "Sugar Apple", "Burning Bud","Giant Pinecone Seed","Elder Strawberry", "Master Sprinkler", "Grandmaster Sprinkler", "Levelup Lollipop", "Medium Treat", "Medium Toy", "Mythical Egg", "Paradise Egg", "Bug Egg"]

; - Technical stuff below, no touchy! -
global allList := []

allList.Push(seedItems*)
allList.Push(gearItems*)
allList.Push(eggItems*)

global currentlyAllowedSeeds := []
global currentlyAllowedGear := []
global currentlyAllowedEggs := []
global currentlyAllowedEvent := []

global scrollCount
scrollCount := {}
scrollCount["Zen Seed Pack"] := 2
scrollCount["Zen Egg"] := 2
scrollCount["Zen Crate"] := 2
scrollCount["Zen Gnome Crate"] := 2

global finished := true
global cycleCount := 0
global eggCounter := 0
global canDoEgg := true

global started := 0
global messageQueue := []
global sleepPerf := 200

global perfSetting := "Default"

WinActivate, ahk_exe RobloxPlayerBeta.exe

Gosub, ShowGui

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
    startInvAction()
    startUINav()
    keyEncoder("E")
    startInvAction()
    startUINav()
    keyEncoder("ULLULLULLULLULLULL")
    keyEncoder("RERRRDDRRRUUUE")
    repeatKey("Backspace", 30)
    typeString("recall")
    keyEncoder("EDUUEDRE")
    ; close it
    startInvAction()
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
    keyEncoder("UUUUUUUUUUUDRRW")
    repeatKey("Esc")
    sleep, 500
    startUINav()
    keyEncoder("ULLULLULLULLULLULLRRRRRRLELERRELLRELERRELLRELERRELLRELERRELLRELERRELLW")
    startUINav()
    repeatKey("Esc")
    sleep, 100
    repeatKey("Tab")
    sleep, 100
    keyEncoder("UUUUUUUUUUUDRRW")
    repeatKey("Esc")
    keyEncoder("WDREWW")
    tooltipLog("Alignment complete!")

SeedCycle:
    exitIfWindowDies()
    if (currentlyAllowedSeeds.Length() = 0) {
        Gosub, GearCycle
        Return
    }

    startUINav()
    ;open shop
    sleep, 1000
    keyEncoder("ULLULLULLULLULLULLWRRRRRLLEW")
    SendInput, e
    startUINav()
    startUINav()
    Sleep, 3000
    if(isShopOpen()) {
        ;we now have the carrot selected, start seed nav
        tooltipLog("Shopping for seeds...")
        goShopping(currentlyAllowedSeeds, seedItems)
        sendDiscordQueue("Seed Shop")
        startUINav()
    } else {
        tooltipLog("Error: Seed shop did not open")
        sendDiscordMessage("Seed shop did not open! Reconnecting...", 16711680)
        reconnect()
    }

GearCycle:
    exitIfWindowDies()
    if (currentlyAllowedGear.Length() = 0) {
        Gosub, EggCycle
        Return
    }

    tpToGear()

    tooltipLog("Opening gear shop...")
    SendInput, e
    Sleep, 3000

    Loop, 5 {
        Send, {WheelUp}
        Sleep, 10
    }
    Sleep, 500

    SafeClickRelative(0.9, 0.5)

    Sleep, 3000

    if(isShopOpen()) {
        startUINav()
        tooltipLog("Shopping for gear...")
        goShopping(currentlyAllowedGear, gearItems, 20)
        sendDiscordQueue("Gear Shop")
        startUINav()
        Sleep, 100
        Loop, 5 {
            Send, {WheelDown}
            Sleep, 10
        }
    } else {
        tooltipLog("Error: Gear shop did not open")
        sendDiscordMessage("Gear shop did not open! Reconnecting...", 16711680)
        reconnect()
    }

EggCycle:
    exitIfWindowDies()
    if(currentlyAllowedGear.Length() = 0 && currentlyAllowedEggs.Length() > 0) {
        tpToGear()
    }

    if(currentlyAllowedEggs.Length() > 0 && canDoEgg) {
        canDoEgg := false
        tooltipLog("Going to egg shop...")
        recalibrateCameraDistance()
        holdKey("w", 600)
        Sleep, %sleepPerf%
        SendInput, e
        Sleep, 3000

        Loop, 5 {
            Send, {WheelUp}
            Sleep, 10
        }
        Sleep, 500

        SafeClickRelative(0.75, 0.2)
        Sleep 3000

        if(isShopOpen()) {
            startUINav()
            tooltipLog("Shopping for eggs...")
            goShoppingEgg(currentlyAllowedEggs, eggItems)
            sendDiscordQueue("Egg Shop")
            Sleep, 500
            startUINav()
            Loop, 5 {
                Send, {WheelDown}
                Sleep, 10
            }
            Sleep, 500
        } else {
            tooltipLog("Error: Egg shop did not open")
            sendDiscordMessage("Egg shop did not open! Reconnecting...", 16711680)
            reconnect()
        }
    }

WaitForNextCycle:
    SafeMoveRelative(0.5, 0.5)
    finished := true
    cycleCount += 1
    SetTimer, ShowTimeTip, 1000
    sendDiscordMessage("Cycle " . cycleCount . " finished", 65280)
Return

tpToGear() {
    tooltipLog("Going to gear shop...")
    Send, {2}
    SafeClickRelative(0.5, 0.5)
    Sleep, 400
    Send, {2}
    Sleep, 400
}

reconnect() {
    WinClose, ahk_exe RobloxPlayerBeta.exe
    Sleep, 1000
    WinClose, ahk_exe RobloxPlayerBeta.exe
    Sleep, 3000
    if(longRecon) {
        Sleep, 180000 ; 3 minutes
        longRecon := false
    }
    ; open the private server link, no this is not a phishing link or whatever, shut up antivirus
    Run, %privateServerLink%
    Sleep, 45000
    SendInput, {tab}
    Sleep, 1000
    SafeClickRelative(0.5, 0.5)
    Sleep, 15000
    sendDiscordMessage("Reconnected to the game!", 65280)
    Gosub, Alignment
}

exitIfWindowDies() {
    if(!WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        Gosub, GuiClose
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

    if (SecondsUntil30 < 3) {
        canDoEgg := true
    }

    if (SecondsUntil5 < 3) {
        finished := false
        recalibrateCameraDistance()
        Gosub, Alignment
    }
Return

goShopping(arr, allArr, spamCount := 50) {
    repeatKey("Up", 40)
    keyEncoder("LLRDRD")
    for index, item in allArr {

        if(!arrContains(arr, item)) {
            repeatKey("Down")
            Continue
        }
        buyAllAvailable(spamCount, item)
    }
    if(messageQueue.Length() = 0) {
        messageQueue.Push("Bought nothing...")
    }
    repeatKey("Up", 40)
    keyEncoder("LLRDRWEWW")
}

goShoppingEgg(arr, allArr) {
    repeatKey("Up", 40)
    keyEncoder("LLLLURRRRRDD")
    for index, item in allArr {
        if(!arrContains(arr, item)) {
            repeatKey("Down")
            Continue
        }
        buyAllAvailable(5, item)
    }
    if(messageQueue.Length() = 0) {
        messageQueue.Push("Bought nothing...")
    }
    repeatKey("Up", 40)
    keyEncoder("ULLURRRRRDWRWRWRWRWLWRWE")
}

buyAllAvailable(spamCount := 50, item := "") {
    repeatKey("Enter")
    repeatKey("Down")
    if(isThereStock()) {
        if(item != "Trowel") {
            repeatKey("Left")
        }
        repeatKey("Enter", spamCount)
        messageQueue.Push("Bought " . item . "!")
    }
    repeatKey("Down")
}

isThereStock() {
    Sleep, 200
    return colorDetect(0x20b41c) || colorDetect(0x26EE26)
}

isShopOpen() {
    Sleep, 50

    ; 1. every other shop bg OR event and egg bg
    ; 2. check no large block of disconnect pixels exist
    return (colorDetect(0x50240c) || colorDetect(0x360805)) && !disconnectColorCheck()
}

colorDetect(c, v := 10) {
    startXPercent := 40
    startYPercent := 27
    endXPercent := 60
    endYPercent := 85

    CoordMode, Pixel, Screen

    x1 := Round((startXPercent / 100) * A_ScreenWidth)
    y1 := Round((startYPercent / 100) * A_ScreenHeight)
    x2 := Round((endXPercent / 100) * A_ScreenWidth)
    y2 := Round((endYPercent / 100) * A_ScreenHeight)

    PixelSearch, px, py, x1, y1, x2, y2, c, v, Fast RGB
    ; MouseMove, px, py ; uncomment to test colo(u)r detection
    if(ErrorLevel = 0) {
        return true
    }
    return false
}

disconnectColorCheck() {
    startXPercent := 40
    startYPercent := 27
    endXPercent := 60
    endYPercent := 85

    CoordMode, Pixel, Screen

    x1 := Round((startXPercent / 100) * A_ScreenWidth)
    y1 := Round((startYPercent / 100) * A_ScreenHeight)
    x2 := Round((endXPercent / 100) * A_ScreenWidth)
    y2 := Round((endYPercent / 100) * A_ScreenHeight)

    ImageSearch, px, py, x1, y1, x2, y2, images/gray.png
    if(ErrorLevel = 0) {
        longRecon := true
        return true
    }
    return false
}

SafeMoveRelative(xRatio, yRatio) {
    if !WinExist("ahk_exe RobloxPlayerBeta.exe") {
        Return
    }

    WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe
    moveX := winX + Round(xRatio * winW)
    moveY := winY + Round(yRatio * winH)
    MouseMove, %moveX%, %moveY%
}

SafeClickRelative(xRatio, yRatio) {
    if !WinExist("ahk_exe RobloxPlayerBeta.exe") {
        Return
    }

    WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe
    clickX := winX + Round(xRatio * winW)
    clickY := winY + Round(yRatio * winH)
    Click, %clickX%, %clickY%
}

startUINav() {
    SendInput, {%uiNavKeybind%}
    Sleep, 50
}

startInvAction() {
    SendInput, {%invNavKeybind%}
    Sleep, 50
}

tooltipLog(message, duration := 3000) {
    ToolTip, %message%
    SetTimer, HideTooltip, %duration%
}

HideTooltip:
    ToolTip
    SetTimer, HideTooltip, Off
Return

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
        Sleep, %sleepPerf%
    }
}

; holds keys obv
holdKey(key, time) {
    SendInput, {%key% Down}
    Sleep, %time%
    SendInput, {%key% Up}
}

indexOf(array := "", value := "") {
    for index, item in array {
        if (value = item) {
            return index
        }
    }

    return -1
}

arrContains(array := "", value := "") {
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
    if (refIndex = -1) ; reference doesn't exist, if you get here, we have issues
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
    Gui, +Caption +SysMenu +MinimizeBox
    Gui, Color, c000000
    Gui, Font, s10 cWhite, Segoe UI
    Gui, Show, w550 h410, Cobalt %version%
    
    cols := 3
    itemW := 150
    itemH := 28
    paddingX := 20
    paddingY := 80

    groupBoxX := 30
    groupBoxY := 30
    groupBoxW := 490
    groupBoxH := 320

    Gui, Add, Tab3, x10 y0 w530 h400, Seeds|Gear|Eggs|Ping List|Settings|Credits

    Gui, Tab, Seeds
    Gui, Font, s10
    Gui, Add, GroupBox, x%groupBoxX% y%groupBoxY% w%groupBoxW% h%groupBoxH%,

    Gui, Add, Checkbox, x205 y45 w150 h23 c1C96EF vCheckAllSeeds gToggleAllSeeds, Select All Seeds

    paddingY := groupBoxY + 50
    paddingX := groupBoxX + 25
    Loop % seedItems.Length() {
        row := Mod(A_Index - 1, Ceil(seedItems.Length() / cols))
        col := Floor((A_Index - 1) / Ceil(seedItems.Length() / cols))
        x := paddingX + (itemW * col)
        y := paddingY + (itemH * row)
        seed := seedItems[A_Index]
        isChecked := arrContains(currentlyAllowedSeeds, seed) ? 1 : 0
        Gui, Add, Checkbox, x%x% y%y% w143 h23 gUpdateSeedState vseedCheckboxes%A_Index% Checked%isChecked%, % seed
    }

    Gui, Tab, Gear
    Gui, Font, s10
    Gui, Add, GroupBox, x%groupBoxX% y%groupBoxY% w%groupBoxW% h%groupBoxH%,

    Gui, Add, Checkbox, x205 y45 w150 h23 c32FF32 vCheckAllGear gToggleAllGear, Select All Gear

    paddingY := groupBoxY + 50
    paddingX := groupBoxX + 25
    Loop % gearItems.Length() {
        row := Mod(A_Index - 1, Ceil(gearItems.Length() / cols))
        col := Floor((A_Index - 1) / Ceil(gearItems.Length() / cols))
        x := paddingX + (itemW * col)
        y := paddingY + (itemH * row)
        gear := gearItems[A_Index]
        isChecked := arrContains(currentlyAllowedGear, gear) ? 1 : 0
        Gui, Add, Checkbox, x%x% y%y% w151 h23 gUpdateGearState vgearCheckboxes%A_Index% Checked%isChecked%, % gear
    }

    Gui, Tab, Eggs
    Gui, Font, s10
    Gui, Add, GroupBox, x%groupBoxX% y%groupBoxY% w%groupBoxW% h%groupBoxH%,

    Gui, Add, Checkbox, x55 y45 w150 h23 vCheckAllEggs gToggleAllEggs cFFFF28, Select All Eggs

    paddingY := groupBoxY + 50
    paddingX := groupBoxX + 25
    cols := 1
    Loop % eggItems.Length() {
        row := Mod(A_Index - 1, Ceil(eggItems.Length() / cols))
        col := Floor((A_Index - 1) / Ceil(eggItems.Length() / cols))
        x := paddingX + (itemW * col)
        y := paddingY + (itemH * row)
        egg := eggItems[A_Index]
        isChecked := arrContains(currentlyAllowedEggs, egg) ? 1 : 0
        Gui, Add, Checkbox, x%x% y%y% w140 h23 gUpdateEggState veggCheckboxes%A_Index% Checked%isChecked%, % egg
    }

    ; ! experimental ping list, disable this before hotfix!
    Gui, Tab, Ping List
    Gui, Add, ListView, r15 w500 BackgroundBlack gAddToPingList Checked NoSort AltSubmit -Hdr vPingListLV, Ping List

    LV_Delete()
    GuiControl, -Redraw, PingListLV  ; suspend redraw for speed and reliability

    Loop % allList.Length() {
        LV_Add("", allList[A_Index]) ; no check state yet
    }

    ; now set checkboxes explicitly
    Loop % allList.Length() {
        if arrContains(pingList, allList[A_Index])
            LV_Modify(A_Index, "Check")
    }

    GuiControl, +Redraw, PingListLV  ; resume redraw
    LV_ModifyCol()

    Gui, Tab, Settings
    Gui, Font, s10
    Gui, Add, GroupBox, x%groupBoxX% y%groupBoxY% w%groupBoxW% h%groupBoxH%,

    Gui, Add, Text, x50 y55 w150 h30, Private Server Link
    Gui, Add, Text, x50 y85 w150 h30, Webhook URL
    Gui, Add, Text, x50 y115 w150 h30, Discord User ID
    Gui, Add, Text, x50 y145 w150 h30, Performance Setting
    Gui, Add, Text, x50 y175 w150 h30, UI Navigation Keybind
    Gui, Font, s6 cGray, Segoe UI
    Gui, Add, Link, x50 y135 w200 h15, <a href="https://discord.com/developers/docs/activities/building-an-activity#step-0-enable-developer-mode">(Enable Developer Mode in Discord to get your ID)</a>
    Gui, Font, s8 cBlack, Segoe UI

    Gui, Add, Edit, gUpdatePlayerValues r1 vprivateServerLink w185 x315 y55, % privateServerLink
    Gui, Add, Edit, gUpdatePlayerValues r1 vwebhookURL w185 x315 y85, % webhookURL
    Gui, Add, Edit, gUpdatePlayerValues r1 vdiscordID w185 x315 y115, % discordID
    choiceIndex := indexOf(["Supercomputer (Doesnt work, for fun)","Modern PC (stable FPS on high)", "Default", "Chromebook (cannot get stable FPS)","Atari 2600 (bless your soul)"], perfSetting)
    Gosub, UpdatePerfSetting

    navIndex := indexOf(["\", "#", "Tab"], uiNavKeybind)
    Gui, Add, DropDownList, w185 x315 y145 vperfSetting Choose%choiceIndex% gUpdatePerfSetting, Supercomputer (Doesnt work, for fun)|Modern PC (stable FPS on high)|Default|Chromebook (cannot get stable FPS)|Atari 2600 (bless your soul)
    Gui  Add, DropDownList, w185 x315 y175 vnavBind Choose%navIndex% gUpdateNavKeybind, \|#|Tab
    Gui, Add, Button, h30 w215 x50 y300 gGuiStartMacro, Start Macro (F5)
    Gui, Add, Button, h30 w215 x285 y300 gPauseMacro, Stop Macro (F7)
    Gui, Font, s10 cWhite, Segoe UI
    
    Gui, Tab, Credits
    Gui, Font, s10
    Gui, Add, GroupBox, x%groupBoxX% y%groupBoxY% w%groupBoxW% h%groupBoxH%
    Gui, Font, s10 cWhite w600, Segoe UI
    Gui, Add, Text, x50 y50 w330 h30, Cobalt %version% by Clovalt, Cobblestone
    Gui, Add, Picture, x50 y90 w100 h100, images/cobble.png
    Gui, Add, Text, x50 y190 w150 h100, Cobble (Cobblestone)
    Gui, Add, Picture, x250 y90 w100 h100, images/clovalt.png
    Gui, Add, Text, x250 y190 w150 h100, Clovalt
    Gui, Font, s8 cfb2c36, Segoe UI
    Gui, Add, Text, x50 y210 w150 h100, Macro Developer
    Gui, Font, s8 cBlue, Segoe UI
    Gui, Add, Text, x250 y210 w150 h100, Macro Developer and Project Lead
    Gui, Add, Link, x50 y250 w150 h30, <a href="https://madefrom.rocks">Website</a>
    Gui, Add, Link, x50 y280 w150 h30, <a href="https://github.com/HoodieRocks">Github</a>
    Gui, Add, Link, x250 y250 w150 h30, <a href="https://discord.gg/Fb4BBXxV9r">Macro Discord Server</a>
return

AddToPingList:
    if (A_GuiEvent == "I")
    {
        row := 0
        pingList := []
        Loop {
            row := LV_GetNext(row, "Checked")
            if not row
                Break
            pingList.Push(allList[row])
        }
        saveValues()
    }
return

UpdatePerfSetting:
    Gui, Submit, NoHide
    perfMode := StrSplit(perfSetting, " ")[1]
    if (perfMode = "Modern") {
        sleepPerf := 50
    } else if (perfMode = "Default") {
        sleepPerf := 75
    } else if (perfMode = "Chromebook") {
        sleepPerf := 125
    } else if (perfMode = "Atari") {
        sleepPerf := 200
    } else if (perfMode = "Supercomputer") {
        sleepPerf := 0
    } else {
        sleepPerf := 100
    }
    saveValues()
Return

UpdateNavKeybind:
    Gui, Submit, NoHide
    if (navBind = "\"){
        uiNavKeybind := "\"
    } else if (navBind = "#") {
        uiNavKeybind := "#"
    } else if (navBind = "Tab") {
        uiNavKeybind := "tab"
    }
    saveValues()
Return

UpdatePlayerValues:
    Gui, Submit, NoHide

    privateServerLink := Trim(privateServerLink)
    webhookURL := Trim(webhookURL)
    discordID := Trim(discordID)

    if(RegExMatch(discordID, "\D")) {
        tooltipLog("Your Discord ID must only contain numbers")
    }

    if(privateServerLink = "") {
        tooltipLog("If you want to rejoin on error, you must provide a private server link")
    }

    saveValues()
Return

loadValues() {
    IniRead, webhookURL, config.ini, PlayerConf, webhookURL
    IniRead, privateServerLink, config.ini, PlayerConf, privateServerLink
    IniRead, discordID, config.ini, PlayerConf, discordID
    IniRead, perfSetting, config.ini, PlayerConf, perfSetting
    IniRead, uiNavKeybind, config.ini, PlayerConf, uiNavKeybind

    IniRead, currentlyAllowedSeedsStr, config.ini, PersistentData, currentlyAllowedSeeds
    IniRead, currentlyAllowedGearStr, config.ini, PersistentData, currentlyAllowedGear
    IniRead, currentlyAllowedEggsStr, config.ini, PersistentData, currentlyAllowedEggs
    IniRead, currentlyAllowedEventStr, config.ini, PersistentData, currentlyAllowedEvent
    IniRead, pingListStr, config.ini, PersistentData, pingList

    if(pingListStr != "" and pingListStr != "ERROR") {
        pingList := StrSplit(pingListStr, ", ")
    }

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
    IniWrite, %perfSetting%, config.ini, PlayerConf, perfSetting
    IniWrite, %uiNavKeybind%, config.ini, PlayerConf, uiNavKeybind

    currentlyAllowedSeedsStr := arrayToString(currentlyAllowedSeeds)
    currentlyAllowedGearStr := arrayToString(currentlyAllowedGear)
    currentlyAllowedEggsStr := arrayToString(currentlyAllowedEggs)
    pingListStr := arrayToString(pingList)

    IniWrite, %currentlyAllowedSeedsStr%, config.ini, PersistentData, currentlyAllowedSeeds
    IniWrite, %currentlyAllowedGearStr%, config.ini, PersistentData, currentlyAllowedGear
    IniWrite, %currentlyAllowedEggsStr%, config.ini, PersistentData, currentlyAllowedEggs
    IniWrite, %pingListStr%, config.ini, PersistentData, pingList
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

GuiClose:
    sendDiscordMessage("Macro Exited!", 16711680, true)
ExitApp
return

Minimize:
    WinMinimize, A
return

Drag:
    PostMessage, 0xA1, 2,,, A
return

PauseMacro:
    sendDiscordMessage("Macro paused!", 16711680)
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
