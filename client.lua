local freecam   = false
local cam       = nil
local speed     = 0.5
local slowSpeed = 0.1
local fov       = 70.0
local rotX, rotY = 0.0, 0.0

local screenshot_webhook = VeyraWebhook and VeyraWebhook.execute_url or ""

RegisterCommand("editor",   function() ToggleFreecam() end)
RegisterCommand("editorui", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ openUI = true })
end)

function ToggleFreecam()
    freecam = not freecam
    if freecam then
        local p = PlayerPedId()
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, GetEntityCoords(p))
        SetCamRot(cam, 0.0, 0.0, GetEntityHeading(p))
        SetCamFov(cam, fov)
        RenderScriptCams(true, false, 0, true, true)
        DisplayRadar(false)
        SendNUIMessage({ freecamHud = true })
    else
        ExitFreecam()
    end
end

function ExitFreecam()
    RenderScriptCams(false, false, 0, true, true)
    if cam then DestroyCam(cam, false) cam = nil end
    DisplayRadar(true)
    freecam = false
    SendNUIMessage({ freecamHud = false })
end

function RotationToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local n = math.abs(math.cos(x))
    return vector3(-math.sin(z) * n, math.cos(z) * n, math.sin(x))
end
local function TakeScreenshot()
    SendNUIMessage({ freecamHud = false })
    Citizen.Wait(0)
    Citizen.Wait(0)

    local function restoreHud()
        if freecam and cam then
            SendNUIMessage({ freecamHud = true })
        end
    end

    if not screenshot_webhook or screenshot_webhook == "" or string.find(screenshot_webhook, "YOUR_WEBHOOK", 1, true) then
        restoreHud()
        print("[EditorPro] Set screenshot_webhook in client.lua to upload freecam screenshots to Discord.")
        return
    end

    if GetResourceState("screenshot-basic") ~= "started" then
        restoreHud()
        print("[EditorPro] screenshot-basic is not started — cannot upload screenshot.")
        return
    end

    exports["screenshot-basic"]:requestScreenshotUpload(
        screenshot_webhook,
        "files[0]",
        function(data)
            restoreHud()
            local ok, resp = pcall(json.decode, data)
            if ok and resp and resp.attachments and resp.attachments[1] and resp.attachments[1].url then
                print("[EditorPro] Freecam screenshot: " .. resp.attachments[1].url)
            else
                print("[EditorPro] Screenshot upload response: " .. tostring(data))
            end
        end
    )
end

CreateThread(function()
    while true do
        Wait(0)
        if freecam and cam then
            DisableAllControlActions(0)
            if IsDisabledControlJustPressed(0, 15) then fov = math.max(5.0,   fov - 2.0); SetCamFov(cam, fov) end
            if IsDisabledControlJustPressed(0, 14) then fov = math.min(110.0, fov + 2.0); SetCamFov(cam, fov) end
            if IsDisabledControlJustPressed(0, 322) then ExitFreecam() end
            if IsDisabledControlJustPressed(0, 191) then
                Citizen.CreateThread(TakeScreenshot)
            end
            local mx = GetDisabledControlNormal(0, 1)
            local my = GetDisabledControlNormal(0, 2)
            rotX = math.max(-85.0, math.min(85.0, rotX + (my * -4.0)))
            rotY = rotY + (mx * -4.0)
            SetCamRot(cam, rotX, 0.0, rotY, 2)
            local s = IsDisabledControlPressed(0, 19) and slowSpeed
                   or (IsDisabledControlPressed(0, 21) and speed * 3.0 or speed)
            local f = RotationToDirection(GetCamRot(cam, 2))
            local r = vector3(f.y, -f.x, 0.0)
            local c = GetCamCoord(cam)
            if IsDisabledControlPressed(0, 32) then c = c + f * s end
            if IsDisabledControlPressed(0, 33) then c = c - f * s end
            if IsDisabledControlPressed(0, 34) then c = c - r * s end
            if IsDisabledControlPressed(0, 35) then c = c + r * s end
            if IsDisabledControlPressed(0, 44) then c = c + vector3(0, 0,  s) end
            if IsDisabledControlPressed(0, 38) then c = c - vector3(0, 0,  s) end

            SetCamCoord(cam, c)
        end
    end
end)

RegisterNUICallback("closeUI", function(d, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("hostingLinkLog", function(data, cb)
    if data and data.url and type(data.url) == "string" then
        print("[EditorPro] Hosted image: " .. data.url)
    elseif data and data.err then
        print("[EditorPro] Hosting upload failed: " .. tostring(data.err))
    end
    cb("ok")
end)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    SendNUIMessage({ freecamHud = false })
end)
